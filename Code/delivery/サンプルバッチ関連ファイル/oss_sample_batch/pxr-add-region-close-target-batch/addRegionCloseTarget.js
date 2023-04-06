/** Copyright 2022 NEC Corporation
*/
// Region終了対象追加
// addRegionCloseTarget.js
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0;
const AWS = require('aws-sdk');
const fs = require('fs');
const request = require('request');
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
    /**
     * グローバル設定を取得して、Regionサービス運用の設定がONになっているかを確認する
     * Regionサービス運用の設定がOFFの場合、以降の処理を行わない
     */
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
    // Regionサービス運用の設定判定
    if (!globalCatalog['template']['use_region_service_operation']) {
        infoLog('Regionサービス運用の設定がされていないため、処理を終了します。');
        return;
    }

    let offset = 0;
    while (true) {
        let resBody;
        //  Book管理サービス.Region終了時利用者ID連携解除対象個人取得 API
        try {
            const getRegionCloseTargetOptions = {
                url: config['bookManageService']['getRegionCloseTarget'],
                method: 'GET',
                headers: headers
            }
            getRegionCloseTargetOptions.url = getRegionCloseTargetOptions.url.replace('{offset}', offset);
            const res = await execRequest(getRegionCloseTargetOptions, 'Region終了時利用者ID連携解除対象個人取得');
            resBody = JSON.parse(res.body);
        } catch (e) {
            // 失敗した場合は処理終了
            throw e;
        }
        if (resBody && resBody['targets'] && resBody['targets'].length > 0) {
            offset += resBody['targets'].length;
            for (const target of resBody['targets']) {
                // Book管理サービス.My-Condition-Data出力コード取得 API
                let mcdOutputCodeBody;
                try {
                    const json = {
                        bookId: Number(target['bookId']),
                        type: 2,
                        region: {
                            _value: Number(target['region']['_value']),
                            _ver: Number(target['region']['_ver'])
                        }
                    };
                    const postOutputOptions = {
                        url: config['bookManageService']['postOutput'],
                        method: 'POST',
                        headers: headers,
                        json: json
                    };
                    postOutputOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                    const res = await execRequest(postOutputOptions, 'My-Condition-Data出力コード取得');
                    postOutputOptions['headers']['Content-Length'] = undefined;
                    mcdOutputCodeBody = res.body;
                } catch (e) {
                    throw e;
                }
                // レコードが取得できなかった場合
                if (!mcdOutputCodeBody || mcdOutputCodeBody.length < 1) {
                    // Book管理サービス.データ出力準備 API
                    try {
                        const json = {
                            type: 2,
                            pxrId: target['pxrId'],
                            actor: {
                                _value: Number(target['actor']['_value']),
                                _ver: Number(target['actor']['_ver'])
                            },
                            region: {
                                _value: Number(target['region']['_value']),
                                _ver: Number(target['region']['_ver'])
                            },
                            cooperationRelease: true,
                            returnable: true
                        };
                        const postOutputConditionPrepareOptions = {
                            url: config['bookManageService']['postOutputConditionPrepare'],
                            method: 'POST',
                            headers: headers,
                            json: json
                        };
                        postOutputConditionPrepareOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                        await execRequest(postOutputConditionPrepareOptions, 'データ出力準備');
                        postOutputConditionPrepareOptions['headers']['Content-Length'] = undefined;
                    } catch (e) {
                        throw e;
                    }
                }
            }
        } else {
            break;
        }
    }
    infoLog('Region終了対象追加処理を終了します。');
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

infoLog('start  : pxr-add-region-close-target-batch addRegionCloseTarget');
main().then(e => {
    infoLog('success: pxr-add-region-close-target-batch addRegionCloseTarget');
    log4js.shutdown(() => {});
}).catch(e => {
    errorLog(e);
    errorLog('error  : pxr-add-region-close-target-batch addRegionCloseTarget');
    log4js.shutdown(() => process.exit(1));
});
