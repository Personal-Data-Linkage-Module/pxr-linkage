/** Copyright 2022 NEC Corporation
*/
// カタログ登録
// catalogRegister.js
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0;
const fs = require('fs');
const request = require('request');
const { info } = require('console');
const headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json'
};

const config = ReadConfig();

const log4js = require('log4js');
const log4jsConfig = JSON.parse(fs.readFileSync('./config/log4js.config.json', 'utf-8'));
log4js.configure(log4jsConfig);
const applicationLogger = log4js.getLogger('application');

// if (!fs.existsSync('logs')) {
//     fs.mkdir('logs', { recursive: true }, (err) => {
//         if (err) throw err;
//     });;
// }
// let logFile = './logs/application.log';
// fs.writeFileSync(logFile, '');
// var out = fs.createWriteStream(logFile);
// var err = fs.createWriteStream(logFile);
// var logger = console.Console(out, err);

async function main () {
    // セッション情報取得
    const session = config['session'];
    session['sessionId'] = '097240851664f1830554bacab28165793328128db1474af4da708a9ee9a1f732';
    session['operatorId'] = 999999999999;
    session['type'] = 3;
    headers['session'] = JSON.stringify(session);
    infoLog('session情報: ' + JSON.stringify(session));

    // カタログ取得
    const getCatalogNameOptions = {
        url: config['catalogService']['getCatalogName'],
        method: 'GET',
        headers: headers
    }
    const getCatalogOptions = {
        url: config['catalogService']['getForNs'] + config['catalog']['globalSettingNs'],
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

    // Region利用規約更新通知個人管理に通知対象の個人を登録する
    const getRegionTargetFindOptions = {
        url: config['bookManageService']['getRegionTargetFind'],
        method: 'GET',
        headers: headers
    };
    try {
        await execRequest(getRegionTargetFindOptions, 'Region利用規約更新通知個人管理通知対象者発見');
    } catch (e) {
        // 失敗した場合は処理終了
        throw e;
    }
    // PXR-ROOT-BLOCK カタログを取得
    const getPxrRootBlockCatalogOptions = {
        url: config['catalogService']['getForNs'] + config['catalog']['pxrRootBlockNs'],
        method: 'GET',
        headers: headers
    };
    let blockCode;
    try {
        getPxrRootBlockCatalogOptions.url = getPxrRootBlockCatalogOptions.url.replace('{extName}', extName);
        res = await execRequest(getPxrRootBlockCatalogOptions, 'PXR-ROOT-BLOCKカタログ取得');
        blockCode = JSON.parse(res.body)[0]['catalogItem']['_code']['_value'];
    } catch (e) {
        // 失敗した場合は処理終了
        throw e;
    }

    // Region利用規約更新通知対象の個人を10件ずつ取得する
    let offset = 0;
    while (true) {
        let resBody;
        const getRegionTargetOptions = {
            url: config['bookManageService']['getRegionTarget'].replace('{offset}', offset),
            method: 'GET',
            headers: headers
        };
        try {
            const res = await execRequest(getRegionTargetOptions, 'Region利用規約更新知対象者取得');
            resBody = JSON.parse(res.body);
        } catch (e) {
            // 失敗した場合は処理終了
            throw e;
        }
        // 再同意通知メッセージを登録する
        if (resBody.length > 0) {
            // offset += resBody.length;
            for (const target of resBody) {
                infoLog(target['pxrId'] + 'へRegion改定再同意通知を送付します。');
                // 通知
                const registerNotificationBody = {
                    type: 0,
                    title: "再同意依頼",
                    content: "Region改定の再同意依頼が届いています。確認の上、Region改定に再同意をお願いいたします。",
                    category: {
                        _value: 187,
                        _ver: 1
                    },
                    destination: {
                        blockCode: blockCode,
                        operatorType: 0,
                        isSendAll: false,
                        operatorId: null,
                        userId: null,
                        pxrId: [target['pxrId']]
                    },
                    attribute: {
                        code: target['termOfUse']
                    }
                };
                const postNotificationOptions = {
                    url: config['notificationService']['register'],
                    method: 'POST',
                    headers: headers,
                    json: registerNotificationBody
                };
                postNotificationOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(registerNotificationBody));
                try {
                    await execRequest(postNotificationOptions, '通知登録');
                    postNotificationOptions['headers']['Content-Length'] = undefined;
                } catch (e) {
                    // 失敗した場合はスキップ
                    infoLog([target['pxrId']] + 'への通知登録に失敗したため、処理をスキップします。');
                    // ['headers']['Content-Length'] = undefined の処理をしないと次周のPlatform利用規約更新通知対象者取得が失敗する
                    postNotificationOptions['headers']['Content-Length'] = undefined;
                    offset++;
                    continue;
                }

                // Region利用規約更新通知個人管理の最終送付日時を更新する
                const getRegionNotificationCompleteBody = {
                    pxrId: target['pxrId']
                };
                const getRegionNotificationCompleteOptions = {
                    url: config['bookManageService']['getRegionNotificationComplete'],
                    method: 'POST',
                    headers: headers,
                    json: getRegionNotificationCompleteBody
                };
                getRegionNotificationCompleteOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(getRegionNotificationCompleteBody));
                try {
                    await execRequest(getRegionNotificationCompleteOptions, '最終送信日時登録');
                    getRegionNotificationCompleteOptions['headers']['Content-Length'] = undefined;
                } catch (e) {
                    // 失敗した場合はスキップ
                    infoLog([target['pxrId']] + 'への最終送信日時登録に失敗したため、処理をスキップします。');
                    getRegionNotificationCompleteOptions['headers']['Content-Length'] = undefined;
                    offset++;
                    continue;
                }
                infoLog(target['pxrId'] + 'へデータ操作定義通知を送付しました。');
            }
        } else {
            infoLog('Region改定再同意通知の送付対象がいないため、通知を送付しませんでした。');
            break;
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
                infoLog(body);
                infoLog(targetMessage + 'を終了します。');
                resolve({ statusCode: res.statusCode, body: body, error: null });
            } else {
                errorLog(targetMessage + 'に失敗しました。');
                errorLog(error);
                if (res) {
                    errorLog(res.statusCode);
                }
                if (body) {
                    errorLog(body);
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


infoLog('start  : region-term-of-use-notification-batch sendNotification');
main().then(e => {
    infoLog('success: region-term-of-use-notification-batch sendNotification');
    log4js.shutdown(() => {});
}).catch(e => {
    errorLog(e);
    errorLog('error  : region-term-of-use-notification-batch sendNotification');
    log4js.shutdown(() => process.exit(1));
});
