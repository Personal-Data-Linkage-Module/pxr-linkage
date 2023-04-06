/** Copyright 2022 NEC Corporation
*/
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
    // 審査あり判定
    if (!globalCatalog['template']['use_region_service_operation']) {
        infoLog('Regionサービス運用の設定がされていないため、処理を終了します。');
        return;
    }

    let offset = 0;
    // Region利用者連携解除承認ステータス：承認不要
    let cooperationCancelApproved = 0;
    // 出力タイプ: 3 (Region利用自動終了)
    let outputType = 3;
    infoLog('Region利用自動終了の処理を開始します。');
    while (true) {
        let resBody;
        //  Book管理サービス.My-Condition-Data出力コード取得API
        const json = {
            type: outputType,
            cooperationCancelApproved: cooperationCancelApproved,
            cooperationCanceled: 0,
            processing: 0
        };
        const postGetMcdOutputOptions = {
            url: config['bookManageService']['postGetMcdOutput'],
            method: 'POST',
            headers: headers,
            json: json
        };
        postGetMcdOutputOptions.url = postGetMcdOutputOptions.url.replace('{offset}', offset);
        try {
            postGetMcdOutputOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
            const res = await execRequest(postGetMcdOutputOptions, 'My-Condition-Data出力コード取得');
            postGetMcdOutputOptions['headers']['Content-Length'] = undefined;
            resBody = res.body;
        } catch (e) {
            // 失敗した場合は処理終了
            throw e;
        }
        if (resBody && resBody.length > 0) {
            for (const target of resBody) {
                let userId = null;
                let res;
                let json;
                json = {
                    processing: 1
                };
                try {
                    // Book管理サービス.My-Condition-Data出力コード更新 API
                    // 処理中フラグを処理中：1 に更新する
                    const putUpdateMcdOutputOptions = {
                        url: config['bookManageService']['putUpdateMcdOutput'],
                        method: 'PUT',
                        headers: headers,
                        json: json
                    };
                    putUpdateMcdOutputOptions.url = putUpdateMcdOutputOptions.url.replace('{id}', Number(target['id']));
                    putUpdateMcdOutputOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                    await execRequest(putUpdateMcdOutputOptions, 'My-Condition-Data出力コード更新');
                    putUpdateMcdOutputOptions['headers']['Content-Length'] = undefined;
                } catch (e) {
                    infoLog('対象外のレコードのため次のレコードに処理をスキップします。');
                    offset++;
                    continue;
                }
                try {
                    // Book管理サービス.My-Condition-Book一覧取得 API
                    json = {
                        pxrId: [
                            target['pxrId']
                        ],
                        offset: 0,
                        limit: 10
                    };
                    const postMcbSearchOptions = {
                        url: config['bookManageService']['postMcbSearch'],
                        method: 'POST',
                        headers: headers,
                        json: json
                    };
                    postMcbSearchOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                    res = await execRequest(postMcbSearchOptions, 'My-Condition-Book一覧取得');
                    postMcbSearchOptions['headers']['Content-Length'] = undefined;
                    for (const book of res.body) {
                        if (book['cooperation'] && Array.isArray(book['cooperation'])) {
                            for (const cooperation of book['cooperation']) {
                                if (target['actor']['_value'] === Number(cooperation['actor']['_value']) &&
                                    cooperation['region'] && Number(target['region']['_value']) === Number(cooperation['region']['_value'])) {
                                    userId = cooperation['userId'];
                                }
                            }
                        }
                    }
                    if (!userId || Number(config['session']['actor']['_value']) !== Number(target['actor']['_value'])) {
                        // Book管理サービス.My-Condition-Data出力コード更新 API
                        // 処理中フラグ ＝ 処理待ち：0
                        json = {
                            processing: 0
                        };
                        const putUpdateMcdOutputOptions = {
                            url: config['bookManageService']['putUpdateMcdOutput'],
                            method: 'PUT',
                            headers: headers,
                            json: json
                        };
                        putUpdateMcdOutputOptions.url = putUpdateMcdOutputOptions.url.replace('{id}', Number(target['id']));
                        try {
                            putUpdateMcdOutputOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                            await execRequest(putUpdateMcdOutputOptions, 'My-Condition-Data出力コード更新');
                            putUpdateMcdOutputOptions['headers']['Content-Length'] = undefined;
                        } catch (e) {
                            throw e;
                        }
                        infoLog('対象外のレコードのため次のレコードに処理をスキップします。');
                        offset++;
                        continue;
                    }
                } catch (e) {
                    // Book管理サービス.My-Condition-Data出力コード更新 API
                    // 処理中フラグ ＝ 処理待ち：0
                    json = {
                        processing: 0
                    };
                    const putUpdateMcdOutputOptions = {
                        url: config['bookManageService']['putUpdateMcdOutput'],
                        method: 'PUT',
                        headers: headers,
                        json: json
                    };
                    putUpdateMcdOutputOptions.url = putUpdateMcdOutputOptions.url.replace('{id}', Number(target['id']));
                    try {
                        putUpdateMcdOutputOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                        await execRequest(putUpdateMcdOutputOptions, 'My-Condition-Data出力コード更新');
                        putUpdateMcdOutputOptions['headers']['Content-Length'] = undefined;
                    } catch (e) {
                        throw e;
                    }
                    // 当該レコードの処理をスキップして次のレコードを処理する
                    infoLog('対象外のレコードのため次のレコードに処理をスキップします。');
                    offset++;
                    continue;
                }

                // userId取得できた場合、targetの出力データ管理を取得してデータアップロード済かどうかチェックする
                try {
                    let isOutput = true;
                    let dataFileRes;
                    //  Book管理サービス.出力データ管理取得API
                    try {
                        const json = {
                            code: target['code']
                        }
                        const postGetMcdOutputCodeDataFileOptions = {
                            url: config['bookManageService']['postGetMcdDataFile'],
                            method: 'POST',
                            headers: headers,
                            json: json
                        }
                        const res = await execRequest(postGetMcdOutputCodeDataFileOptions, '出力データ管理取得');
                        dataFileRes = res.body;
                    } catch (e) {
                        // 取得に失敗した場合は対象userIdの処理を行わない
                        isOutput = false;
                    }
                    if (dataFileRes && dataFileRes.length > 0) {
                        for (const dataFile of dataFileRes) {
                            // いずれかのoutputStatusが1: 出力済でない場合は対象userIdの処理を行わない
                            // deleteStatusが3: 削除済かつoutputStatusが0: 未作成の場合は、返却指定なし・削除指定ありのパターンなので削除可
                            if (dataFile['outputStatus'] !== 1 && !(dataFile['outputStatus'] === 0 && dataFile['deleteStatus'] === 3)) {
                                isOutput = false;
                                break;
                            }
                        }
                    } else {
                        // 返却指定、削除指定ともにfalseの場合、region提携app、wfとの連携がない場合は出力データ管理が作成されていないため、削除可
                        isOutput = true;
                    }
                    if (!isOutput) {
                        // Book管理サービス.My-Condition-Data出力コード更新 API
                        // 処理中フラグ ＝ 処理待ち：0
                        json = {
                            processing: 0
                        };
                        const putUpdateMcdOutputOptions = {
                            url: config['bookManageService']['putUpdateMcdOutput'],
                            method: 'PUT',
                            headers: headers,
                            json: json
                        };
                        putUpdateMcdOutputOptions.url = putUpdateMcdOutputOptions.url.replace('{id}', Number(target['id']));
                        try {
                            putUpdateMcdOutputOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                            await execRequest(putUpdateMcdOutputOptions, 'My-Condition-Data出力コード更新');
                            putUpdateMcdOutputOptions['headers']['Content-Length'] = undefined;
                        } catch (e) {
                            throw e;
                        }
                        infoLog('未出力のデータが残っているため、次のレコードに処理をスキップします。');
                        offset++;
                        continue;
                    }

                    let regionActorCode;
                    // Regionカタログ取得
                    const getRegionCatalogOptions = {
                        url: config['catalogService']['getCatalog'],
                        method: 'GET',
                        headers: headers
                    };
                    getRegionCatalogOptions.url = getRegionCatalogOptions.url.replace('{code}', target['region']['_value']);
                    catalogRes = await execRequest(getRegionCatalogOptions, 'Regionカタログ取得');
                    const ns = JSON.parse(catalogRes.body)['catalogItem']['ns'];
                    regionActorCode = ns.slice(ns.lastIndexOf('_') + 1, ns.lastIndexOf('/'));
                    // 利用規約カタログ取得
                    const getTouCatalogOptions = {
                        url: config['catalogService']['getForNs'] + config['catalog']['regionTouNs'],
                        method: 'GET',
                        headers: headers
                    };
                    getTouCatalogOptions.url = getTouCatalogOptions.url.replace('{extName}', extName);
                    getTouCatalogOptions.url = getTouCatalogOptions.url.replace('{actor}', regionActorCode);
                    catalogRes = await execRequest(getCatalogOptions, 'Region利用規約カタログ取得');
                    // データ削除判定
                    let physicalDelete = false;
                    if (JSON.parse(catalogRes.body)[0]['template']['deleting-data-flag']) {
                        physicalDelete = true;
                    }

                    // 本人性確認サービス.確認済本人性確認コード生成 API を呼び出し、本人性確認コードを生成する
                    json = {
                        pxrId: target['pxrId'],
                        userId: userId,
                        actor: {
                            _value: target['actor']['_value'],
                            _ver: target['actor']['_ver']
                        },
                        region: {
                            _value: target['region']._value,
                            _ver: target['region']._ver
                        }
                    };
                    const postCodeVerifiedOptions = {
                        url: config['identityVerificateService']['postCodeVerified'],
                        method: 'POST',
                        headers: headers,
                        json: json
                    };
                    postCodeVerifiedOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                    res = await execRequest(postCodeVerifiedOptions, '確認済本人性確認コード生成');
                    postCodeVerifiedOptions['headers']['Content-Length'] = undefined;
                    const ident = res.body;

                    // Book運用サービス.利用者削除 API
                    const postUserDeleteOptions = {
                        url: config['bookOperateService']['postUserDelete'],
                        method: 'POST',
                        headers: headers,
                        json: {
                            identifyCode: ident['identifyCode']
                        }
                    };
                    postUserDeleteOptions.url = postUserDeleteOptions.url.replace('{physicalDelete}', physicalDelete);
                    await execRequest(postUserDeleteOptions, '利用者削除');

                    // Book管理サービス.My-Condition-Data出力コード更新 API
                    // Region利用者連携解除ステータス ＝ 1: 処理済
                    // 処理中フラグ ＝ 処理待ち：0
                    json = {
                        cooperationCanceled: 1,
                        processing: 0
                    };
                    const putUpdateMcdOutputOptions = {
                        url: config['bookManageService']['putUpdateMcdOutput'],
                        method: 'PUT',
                        headers: headers,
                        json: json
                    };
                    putUpdateMcdOutputOptions.url = putUpdateMcdOutputOptions.url.replace('{id}', Number(target['id']));
                    putUpdateMcdOutputOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                    await execRequest(putUpdateMcdOutputOptions, 'My-Condition-Data出力コード更新');
                    putUpdateMcdOutputOptions['headers']['Content-Length'] = undefined;
                } catch (e) {
                    // Book管理サービス.My-Condition-Data出力コード更新 API
                    // 処理中フラグ ＝ 処理待ち：0
                    headers['session'] = JSON.stringify(session);
                    json = {
                        processing: 0
                    };
                    const putUpdateMcdOutputOptions = {
                        url: config['bookManageService']['putUpdateMcdOutput'],
                        method: 'PUT',
                        headers: headers,
                        json: json
                    };
                    putUpdateMcdOutputOptions.url = putUpdateMcdOutputOptions.url.replace('{id}', Number(target['id']));
                    try {
                        putUpdateMcdOutputOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                        await execRequest(putUpdateMcdOutputOptions, 'My-Condition-Data出力コード更新');
                        putUpdateMcdOutputOptions['headers']['Content-Length'] = undefined;
                    } catch (e) {
                        throw e;
                    }
                    offset++;
                }
            }
        } else {
            if (resBody.length === 0) {
                if (cooperationCancelApproved === 0) {
                    offset = 0;
                    // Region利用者連携解除承認ステータス：承認
                    cooperationCancelApproved = 2;
                } else if (outputType === 3 && cooperationCancelApproved === 2) {
                    offset = 0;
                    // 出力タイプ: 2 (Region利用終了)
                    outputType = 2;
                    cooperationCancelApproved = 0;
                    infoLog('Region利用終了の処理を開始します。');
                } else {
                    // outputType === 3 && cooperationCancelApproved === 2 でres.bodyが0件の場合ループを抜けて処理終了する
                    break;
                }
            }
        }
    }
    infoLog(`Region利用自動終了処理を終了します。`);
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


infoLog('start  : region-end-of-use-batch regionEndOfUse');
main().then(e => {
    infoLog('success: region-end-of-use-batch regionEndOfUse');
    log4js.shutdown(() => {});
}).catch(e => {
    errorLog(e);
    errorLog('error  : region-end-of-use-batch regionEndOfUse');
    log4js.shutdown(() => process.exit(1));
});