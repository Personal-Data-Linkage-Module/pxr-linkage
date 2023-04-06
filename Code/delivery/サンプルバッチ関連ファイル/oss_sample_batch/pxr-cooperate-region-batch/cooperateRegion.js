/** Copyright 2022 NEC Corporation
*/
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0;
const fs = require('fs');
const request = require('request');
const { info } = require('console');
const uuid = require('uuid');
const headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json'
};

const config = ReadConfig();

const log4js = require('log4js');
const log4jsConfig = JSON.parse(fs.readFileSync('./config/log4js.config.json', 'utf-8'));
log4js.configure(log4jsConfig);
const applicationLogger = log4js.getLogger('application');

async function main () {
    // セッション情報取得
    const session = config['session'];
    session['sessionId'] = '097240851664f1830554bacab28165793328128db1474af4da708a9ee9a1f732';
    session['operatorId'] = 999999999999;
    session['type'] = 3;
    headers['session'] = JSON.stringify(session);
    infoLog('session情報: ' + JSON.stringify(session));
    /**
     * グローバル設定を取得して、Regionサービス運用の設定がONになっているかを確認する  
     * Regionサービス運用の設定がOFFの場合、以降の処理を行わない
     */

    // カタログ取得
    const getCatalogNameOptions = {
        url: config['pxrBlockProxyService']['postRoot'] + config['catalogService']['getCatalogName'],
        method: 'GET',
        headers: headers
    }
    const getCatalogOptions = {
        url: config['pxrBlockProxyService']['postRoot'] + config['catalogService']['getForNs'] + config['catalog']['globalSettingNs'],
        method: 'GET',
        headers: headers
    };
    let globalCatalog;
    let extName;
    try {
        let res = await execRequest(getCatalogNameOptions, 'カタログ名称取得');
        extName = JSON.parse(res.body)['ext_name'];
        getCatalogOptions.url = getCatalogOptions.url.replace('{extName}', extName);
        res = await execRequest(getCatalogOptions, 'グローバル設定カタログ取得');
        globalCatalog = JSON.parse(res.body)[0];
    } catch (e) {
        // 失敗した場合は処理終了
        throw e;
    }
    // 審査あり判定
    if (!globalCatalog['template']['use_region_service_operation']) {
        infoLog('Regionサービス運用の設定がされていないため、処理を終了します。');
        return;
    }

    // 通知を取得する
    let notifications;
    const getRegionTargetOptions = {
        url: config['notificationService']['getNotification'],
        method: 'GET',
        headers: headers
    };
    try {
        const res = await execRequest(getRegionTargetOptions, '通知取得');
        notifications = JSON.parse(res.body);
    } catch (e) {
        // 失敗した場合は処理終了
        throw e;
    }

    // 通知が1件以上あった場合、以下の処理を行う
    if (notifications.length > 0) {
        for (let notification of notifications) {
            // 通知のattributeから本人性確認コードを取得する
            let identifyCode = notification['attribute']['identifyCode'];
            if (! identifyCode) {
                infoLog('通知ID: ' + notification['id'] + ' は本人性確認コードがない通知のため、スキップします。');
                continue;
            }
            if (notification['category']['_value'] && Number(notification['category']['_value']) === 181) {
                infoLog('通知ID: ' + notification['id'] + ' は連携解除用通知のため、スキップします。');
                continue;
            }

            // 未確認の本人性確認コード(個人から発行されたコード) の場合、利用者ID設定と本人性確認を行う
            if (!notification['attribute']['verifiedFlg']) {
                // uuidを生成して利用者IDとして、利用者ID設定APIを呼び出す
                const postUserSettingsBody = {
                    identifyCode: notification['attribute']['identifyCode'],
                    userId: uuid()
                };
                const postUserSettingsOptions = {
                    url: config['pxrBlockProxyService']['postRoot'] + config['identityVerificateService']['postUserSettings'],
                    method: 'POST',
                    headers: headers,
                    json: postUserSettingsBody
                };
                postUserSettingsOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postUserSettingsBody));
                try {
                    await execRequest(postUserSettingsOptions, '利用者ID設定');
                    postUserSettingsOptions['headers']['Content-Length'] = undefined;
                } catch (e) {
                    // エラーが有効期限切れの場合は既読処理を行ってスキップ
                    if (e.error === 'expired') {
                        const putNotificationBody = {
                            id: notification['id']
                        };
                        const putNotificationOptions = {
                            url: config['notificationService']['putNotification'],
                            method: 'PUT',
                            headers: headers,
                            json: putNotificationBody
                        };
                        putNotificationOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(putNotificationBody));
                        try {
                            await execRequest(putNotificationOptions, '既読処理');
                            putNotificationOptions['headers']['Content-Length'] = undefined;
                        } catch (e) {
                            // 失敗した場合は処理終了
                            throw e;
                        }
                        infoLog('通知ID: ' + notification['id'] + 'の本人性確認コードは期限切れのため、スキップします。')
                        continue;
                    } else {
                        // それ以外の場合は未読のままスキップ
                        infoLog('利用者ID設定に失敗したため、スキップします。')
                        continue;
                    }
                }
                // 本人性確認を行う
                const putVerifyOthersBody = {
                    status: 1
                };
                const putVerifyOthersOptions = {
                    url: config['pxrBlockProxyService']['postRoot'] + config['identityVerificateService']['putVerifyOthers'] + notification['attribute']['identifyCode'],
                    method: 'PUT',
                    headers: headers,
                    json: putVerifyOthersBody
                };
                putVerifyOthersOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(putVerifyOthersBody));
                try {
                    await execRequest(putVerifyOthersOptions, '本人性確認');
                    putVerifyOthersOptions['headers']['Content-Length'] = undefined;
                } catch (e) {
                    // 失敗した場合は処理終了
                    throw e;
                }
            }
            // 利用者連携APIを呼び出す
            const postUserBody = {
                identifyCode: notification['attribute']['identifyCode'],
                attributes: {},
                userInformation: null
              };
            const postUserOptions = {
                url: config['bookOperateService']['postUser'],
                method: 'POST',
                headers: headers,
                json: postUserBody
            };
            postUserOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postUserBody));
            try {
                await execRequest(postUserOptions, '利用者作成');
                postUserOptions['headers']['Content-Length'] = undefined;
            } catch (e) {
                // 失敗した場合は未読のままスキップ
                infoLog('通知ID: ' + notification['id'] + 'は利用者作成に失敗したため、スキップします。')
                continue;
            }
            // 連携に使用した通知を既読にする
            const putNotificationBody = {
                id: notification['id']
            };
            const putNotificationOptions = {
                url: config['notificationService']['putNotification'],
                method: 'PUT',
                headers: headers,
                json: putNotificationBody
            };
            putNotificationOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(putNotificationBody));
            try {
                await execRequest(putNotificationOptions, '既読処理');
                putNotificationOptions['headers']['Content-Length'] = undefined;
            } catch (e) {
                // 失敗した場合は処理終了
                throw e;
            }
        }
    }
}

function execRequest (options, targetMessage) {
    infoLog(targetMessage + 'を開始します。')
    infoLog(options['method']);
    infoLog(options['url']);
    if (options['json']) {
        infoLog(JSON.stringify(options['json']));
    }
    return new Promise(function (resolve, reject) {
        request(options, function (error, res, body) {
            if (!error && res.statusCode == 200) {
                infoLog(targetMessage + 'に成功しました。');
                if (typeof body === 'object') {
                    infoLog(JSON.stringify(body));
                } else {
                    infoLog(body);
                }
                infoLog(targetMessage + 'を終了します。');
                resolve({ statusCode: res.statusCode, body: body, error: null });
            } else {
                errorLog(targetMessage + 'に失敗しました。');
                errorLog(error);
                if (res) {
                    errorLog(res.statusCode);
                }
                if (body) {
                    if (body.message) {
                        errorLog('message: ' + body.message);
                        if (body.message === '指定された本人性確認コードは、有効期限切れです') {
                            error = 'expired';
                        }
                    } else {
                    errorLog(body);
                    }
                }
                errorLog(targetMessage + 'を終了します。');
                reject({ statusCode: (res ? res.statusCode : null), body: null, error: error });
            }
        });
    });
}

function infoLog (message) {
    if (typeof message === 'object') {
        message = JSON.stringify(message);
    }
    console.log(getTime() + message);
    applicationLogger.info(message);
}

function errorLog (message) {
    if (typeof message === 'object') {
        message = JSON.stringify(message);
    }
    console.error(getTime() + message);
    applicationLogger.error(message);
}

function getTime () {
    const now = new Date();
    const time = '[' + now.getFullYear() + '-' + ('00' + (now.getMonth() + 1)).slice(-2) + '-' + ('00' + now.getDate()).slice(-2) + ' ' +
        ('00' + now.getHours()).slice(-2) + ':' + ('00' + now.getMinutes()).slice(-2) + ':' + ('00' + now.getSeconds()).slice(-2) + '.' +
        ('000' + now.getMilliseconds()).slice(-3) + '] ';
    return time;
}

/**
 * 設定ファイル読込(JSON)
 */
function ReadConfig () {
    let config = null;
    config = JSON.parse(fs.readFileSync('./config/config.json', 'utf-8'));
    if (fs.existsSync('./config/block-common-conf.json')) {
        config = mergeDeeply(config, JSON.parse(fs.readFileSync('./config/block-common-conf.json', 'utf-8')));
    }
    if (fs.existsSync('./config/common-conf.json')) {
        config = mergeDeeply(config, JSON.parse(fs.readFileSync('./config/common-conf.json', 'utf-8')));
    }
    if (config['ext_name'] || (config['block'] && config['block']['_value'])) {
        let configString = JSON.stringify(config);
        if (config['ext_name']) {
            configString = configString.replace(/{ext_name}/g, config['ext_name']);
        }
        if (config['block'] && config['block']['_value']) {
            configString = configString.replace(/{block_code}/g, config['block']['_value']);
        }
        config = JSON.parse(configString);
    }
    return config;
}

/**
 * jsonマージ処理
 * @param target
 * @param source
 * @returns
 */
function mergeDeeply (target, source) {
    const isObject = obj => obj && typeof obj === 'object' && !Array.isArray(obj);
    const result = Object.assign({}, target);
    for (const [sourceKey, sourceValue] of Object.entries(source)) {
        const targetValue = target[sourceKey];
        if (isObject(sourceValue) && isObject(targetValue)) {
            result[sourceKey] = mergeDeeply(targetValue, sourceValue);
        } else {
            Object.assign(result, { [sourceKey]: sourceValue });
        }
    }
    return result;
}

infoLog('start  : cooperate-region-batch cooperateRegion');
main().then(e => {
    infoLog('success: cooperate-region-batch cooperateRegion');
    log4js.shutdown(() => {});
}).catch(e => {
    errorLog(e);
    errorLog('error  : cooperate-region-batch cooperateRegion');
    log4js.shutdown(() => process.exit(1));
});