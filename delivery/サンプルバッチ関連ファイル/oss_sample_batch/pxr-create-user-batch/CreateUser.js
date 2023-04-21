/** Copyright 2022 NEC Corporation
*/
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0;
const fs = require('fs');
const path = require('path');
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

async function main() {
    // セッション情報取得
    const session = config['session'];
    session['sessionId'] = '097240851664f1830554bacab28165793328128db1474af4da708a9ee9a1f732';
    session['operatorId'] = 999999999999;
    session['type'] = 3;
    headers['session'] = JSON.stringify(session);
    infoLog('session情報: ' + JSON.stringify(session));

    // 利用者作成(バッチ)
    const postUserBatchBody = {};
    const postUserBatchOptions = {
        url: config['bookOperateService']['postUserBatch'],
        method: 'POST',
        headers: headers,
        json: postUserBatchBody
    };
    postUserBatchOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postUserBatchBody));
    try {
        await execRequest(postUserBatchOptions, '利用者作成(バッチ)');
        postUserBatchOptions['headers']['Content-Length'] = undefined;
    } catch (e) {
        // 失敗した場合は処理終了
        throw e;
    }
}

function execRequest(options, targetMessage) {
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

function getTime() {
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

infoLog('start  : create-user-batch CreateUser');
main().then(e => {
    infoLog('success: create-user-batch CreateUser');
    log4js.shutdown(() => {});
}).catch(e => {
    errorLog(e);
    errorLog('error  : create-user-batch CreateUser');
    log4js.shutdown(() => process.exit(1));
});
