/** Copyright 2022 NEC Corporation
*/
// Book自動閉鎖
// bookEndOfUse.js
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

    // PF利用規約に未同意の個人を10件ずつ取得する
    let offset = 0;
    while (true) {
        let resBody;
        const getPlatformDeletionTargetOptions = {
            url: config['bookManageService']['getPlatformDeletionTarget'].replace('{offset}', offset),
            method: 'GET',
            headers: headers
        };
        try {
            const res = await execRequest(getPlatformDeletionTargetOptions, 'Platform利用規約未同意個人取得');
            resBody = JSON.parse(res.body);
        } catch (e) {
            // 失敗した場合は処理終了
            throw e;
        }
        if (resBody['targets'] && resBody['targets'].length > 0) {
            for (const target of resBody['targets']) {
                // 取得したレコードを元にBook管理サービス.強制停止 API を呼び出す
                const forceDeletionBody = {
                    pxrId: target['pxrId']
                }
                const forceDeletionOptions = {
                    url: config['bookManageService']['forceDeletion'],
                    method: 'PUT',
                    headers: headers,
                    json: forceDeletionBody
                };
                forceDeletionOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(forceDeletionBody));
                try {
                    const res = await execRequest(forceDeletionOptions, '強制停止');
                } catch (e) {
                    // 失敗した場合はoffset増やしてスキップ
                    infoLog('pxrId: '+ target['pxrId'] + 'の強制停止処理に失敗したため、スキップします。')
                    offset++;
                    continue;
                }
                // Book管理サービス.My-Condition-Data出力コード取得 API を呼び出す
                try {
                    let postGetOutputCodeResBody;
                    const postGetOutputCodeBody = {
                        pxrId: target['pxrId'],
                        type: 5
                    }
                    const postGetOutputCodeOptions = {
                        url: config['bookManageService']['postGetOutputCode'].replace('{offset}', 0),
                        method: 'POST',
                        headers: headers,
                        json: postGetOutputCodeBody
                    };
                    postGetOutputCodeOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postGetOutputCodeBody));
                    const res = await execRequest(postGetOutputCodeOptions, 'My-Condition-Data出力コード取得');
                    postGetOutputCodeOptions['headers']['Content-Length'] = undefined;
                    postGetOutputCodeResBody = res.body;

                    // My-Condition-Data出力コード のレコードが取得できない場合、以下の処理を行う
                    if (!postGetOutputCodeResBody || postGetOutputCodeResBody < 1) {
                        // Book管理サービス.データ出力準備 API を呼び出す
                        const postOutputPrepareBody = {
                            type: 5,
                            pxrId: target['pxrId'],
                            returnable: true
                        }
                        const postOutputPrepareOptions = {
                            url: config['bookManageService']['postOutputPrepare'],
                            method: 'POST',
                            headers: headers,
                            json: postOutputPrepareBody
                        };
                        postOutputPrepareOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postOutputPrepareBody));
                        await execRequest(postOutputPrepareOptions, 'データ出力準備');
                        postOutputPrepareOptions['headers']['Content-Length'] = undefined;
                    }
                    infoLog(target['pxrId'] + 'のBook自動閉鎖を行いました。');
                } catch {
                    // 強制停止API実行後にエラーが発生した場合は、Book管理サービス.強制解除 API を呼び出す
                    const forceEnableBody = {
                        pxrId: target['pxrId']
                    }
                    const forceEnableOptions = {
                        url: config['bookManageService']['forceEnable'],
                        method: 'PUT',
                        headers: headers,
                        json: forceEnableBody
                    };
                    forceEnableOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(forceEnableBody));
                    try {
                        const res = await execRequest(forceEnableOptions, '強制解除');
                    } catch (e) {
                        // 失敗した場合は処理終了
                        throw e;
                    }
                    // 今回のバッチ処理対象から外すためoffsetを増やす
                    infoLog('pxrId: '+ target['pxrId'] + 'のデータ出力準備処理に失敗したため、スキップします。')
                    offset++;
                }
            }
        } else {
            infoLog('Book自動閉鎖の対象がありません。');
            break;
        }
        if (!resBody['targets'] || resBody['targets'].length < 10) {
            infoLog('Book自動閉鎖の対象がありません。');
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

infoLog('start  : book-end-of-use-batch bookEndOfUse');
main().then(e => {
    infoLog('success: book-end-of-use-batch bookEndOfUse');
    log4js.shutdown(() => {});
}).catch(e => {
    errorLog(e);
    errorLog('error  : book-end-of-use-batch bookEndOfUse');
    log4js.shutdown(() => process.exit(1));
});
