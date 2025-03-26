// 利用者データ削除
// deleteUser.js
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

    // 利用者データ削除対象を10件ずつ取得する
    const approved = 1;
    let offset = 0;
    while (true) {
        let resBody;
        let postGetMcdOutputCodeDataFileBody = {
            outputTypes: [2, 3, 4, 5],
            outputFileType: 2,
            // outputStatus: 1,
            deleteStatus: 2,
            processing: 0
        };
        let postGetMcdOutputCodeDataFileOptions = {
            url: config['bookManageService']['postGetMcdOutputCodeDataFile'],
            method: 'POST',
            headers: headers,
            json: postGetMcdOutputCodeDataFileBody
        };
        postGetMcdOutputCodeDataFileOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postGetMcdOutputCodeDataFileBody));
        try {
            postGetMcdOutputCodeDataFileOptions.url = postGetMcdOutputCodeDataFileOptions.url.replace('{offset}', offset);
            postGetMcdOutputCodeDataFileOptions.url = postGetMcdOutputCodeDataFileOptions.url.replace('{approved}', approved);
            const res = await execRequest(postGetMcdOutputCodeDataFileOptions, '利用者データ削除対象取得');
            postGetMcdOutputCodeDataFileOptions['headers']['Content-Length'] = undefined;
            resBody = res.body;
        } catch (e) {
            // 失敗した場合は処理終了
            throw e;
        }
        
        if (resBody.length > 0) {
            // offset += resBody.length;
            // 処理完了フラグ
            let isDeleted;
            for (const target of resBody) {
                isDeleted = false;
                // Book管理サービス.出力データ管理更新 API を呼び出し、 処理中フラグを 処理中：1 に更新する  
                // 排他制御にて更新に失敗した場合、当該レコードの処理をスキップして次のレコードを処理する
                let postMcdOutputCodeDataFileUpdateBody = {
                    processing: 1
                };
                let postMcdOutputCodeDataFileUpdateOptions = {
                    url: config['bookManageService']['postUpdateMcdOutputCodeDataFile'],
                    method: 'PUT',
                    headers: headers,
                    json: postMcdOutputCodeDataFileUpdateBody
                };
                postMcdOutputCodeDataFileUpdateOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postMcdOutputCodeDataFileUpdateBody));
                try {
                    postMcdOutputCodeDataFileUpdateOptions.url = postMcdOutputCodeDataFileUpdateOptions.url.replace('{id}', target['id']);
                    await execRequest(postMcdOutputCodeDataFileUpdateOptions, '処理中フラグ更新');
                    postMcdOutputCodeDataFileUpdateOptions['headers']['Content-Length'] = undefined;
                } catch (e) {
                    // 失敗した場合は次のレコードを処理する
                    infoLog('出力データ管理の排他が取得できないため、処理をスキップします。');
                    offset++;
                    continue;
                }
                try {
                    // Book管理サービス.My-Condition-Book一覧取得 API を呼び出し、利用者ID連携情報を取得する
                    let userId;
                    let app;
                    let wf;
                    const postMcbSearchBody = {
                        pxrId: [
                            target['pxrId']
                        ],
                        includeDeleteCoop: true
                    };
                    const postMcbSearchOptions = {
                        url: config['bookManageService']['postMcbSearch'],
                        method: 'POST',
                        headers: headers,
                        json: postMcbSearchBody
                    };
                    postMcbSearchOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postMcbSearchBody));
                    res = await execRequest(postMcbSearchOptions, 'My-Condition-Book一覧取得');
                    postMcbSearchOptions['headers']['Content-Length'] = undefined;
                    for (const book of res.body) {
                        if (book['cooperation'] && Array.isArray(book['cooperation'])) {
                            for (const cooperation of book['cooperation']) {
                                if (config['session']['actor']['_value'] === Number(cooperation['actor']['_value']) &&
                                    target['actor']['_value'] === Number(cooperation['actor']['_value']) &&
                                    ((cooperation['app'] && target['app'] && Number(target['app']['_value']) === Number(cooperation['app']['_value'])) ||
                                        (cooperation['wf'] && target['wf'] && Number(target['wf']['_value']) === Number(cooperation['wf']['_value'])))) {
                                    userId = cooperation['userId'];
                                    app = target['app'] ? Number(target['app']['_value']) : undefined;
                                    wf = target['wf'] ? Number(target['wf']['_value']) : undefined;
                                }
                            }
                        }
                    }
                    // Book運用サービス.利用者データ削除 API を呼び出す
                    if (userId) {
                        let catalogRes;
                        let deletingFlg = false;
                        let touCatalog;
                        if (Number(target['outputType']) === 2 || Number(target['outputType']) === 3) {
                            // 取得した 出力データ管理取得 レコードの 出力タイプ が Region利用終了: 2 または  Region利用自動終了: 3 の場合、Regionの利用規約を取得する
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
                            touCatalog = JSON.parse(catalogRes.body)[0];
                        } else if (Number(target['outputType']) === 4 || Number(target['outputType']) === 5) {
                            // 取得した 出力データ管理取得 レコードの 出力タイプ が Book閉鎖: 4 または Book強制閉鎖: 5 の場合、Platformの利用規約を取得する
                            // 利用規約カタログ取得
                            const getTouCatalogOptions = {
                                url: config['catalogService']['getForNs'] + config['catalog']['platformTouNs'],
                                method: 'GET',
                                headers: headers
                            };
                            getTouCatalogOptions.url = getTouCatalogOptions.url.replace('{extName}', extName);
                            catalogRes = await execRequest(getTouCatalogOptions, 'Platform利用規約カタログ取得');
                            touCatalog = JSON.parse(catalogRes.body)[0];
                        }
                        // データ削除判定
                        if (touCatalog['template']['deleting-data-flag']) {
                            deletingFlg = true;
                        }
                        let deleteUserDataOptions = {
                            url: config['bookOperateService']['deleteUserData'],
                            method: 'DELETE',
                            headers: headers
                        };
                        deleteUserDataOptions.url = deleteUserDataOptions.url.replace('{userId}', userId);
                        deleteUserDataOptions.url = deleteUserDataOptions.url.replace('{physicalDelete}', deletingFlg);
                        if (app) {
                            deleteUserDataOptions.url = deleteUserDataOptions.url + encodeURIComponent('&app=' + app);
                        } else {
                            deleteUserDataOptions.url = deleteUserDataOptions.url + encodeURIComponent('&wf=' + wf);
                        }
                        await execRequest(deleteUserDataOptions, '利用者データ削除');

                        // 削除ステータスを 3: 削除済 に更新する
                        postMcdOutputCodeDataFileUpdateBody = {
                            processing: 0,
                            deleteStatus: 3
                        };
                        postMcdOutputCodeDataFileUpdateOptions = {
                            url: config['bookManageService']['postUpdateMcdOutputCodeDataFile'],
                            method: 'PUT',
                            headers: headers,
                            json: postMcdOutputCodeDataFileUpdateBody
                        };
                        postMcdOutputCodeDataFileUpdateOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postMcdOutputCodeDataFileUpdateBody));
                        postMcdOutputCodeDataFileUpdateOptions.url = postMcdOutputCodeDataFileUpdateOptions.url.replace('{id}', target['id']);
                        await execRequest(postMcdOutputCodeDataFileUpdateOptions, '出力ファイル管理ステータス更新');
                        postMcdOutputCodeDataFileUpdateOptions['headers']['Content-Length'] = undefined;
                        // 処理完了フラグをONにする
                        isDeleted = true;
                    } else {
                        // 処理待ちに更新
                        postMcdOutputCodeDataFileUpdateBody = {
                            processing: 0
                        };
                        postMcdOutputCodeDataFileUpdateOptions = {
                            url: config['bookManageService']['postUpdateMcdOutputCodeDataFile'],
                            method: 'PUT',
                            headers: headers,
                            json: postMcdOutputCodeDataFileUpdateBody
                        };
                        postMcdOutputCodeDataFileUpdateOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postMcdOutputCodeDataFileUpdateBody));
                        postMcdOutputCodeDataFileUpdateOptions.url = postMcdOutputCodeDataFileUpdateOptions.url.replace('{id}', target['id']);
                        await execRequest(postMcdOutputCodeDataFileUpdateOptions, '出力ファイル管理ステータス更新');
                        postMcdOutputCodeDataFileUpdateOptions['headers']['Content-Length'] = undefined;
                    }
                } catch (e) {
                    errorLog(e);
                    // エラーが発生した場合、処理待ちに更新
                    postMcdOutputCodeDataFileUpdateBody = {
                        processing: 0
                    };
                    postMcdOutputCodeDataFileUpdateOptions = {
                        url: config['bookManageService']['postUpdateMcdOutputCodeDataFile'],
                        method: 'PUT',
                        headers: headers,
                        json: postMcdOutputCodeDataFileUpdateBody
                    };
                    postMcdOutputCodeDataFileUpdateOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(postMcdOutputCodeDataFileUpdateBody));
                    try {
                        postMcdOutputCodeDataFileUpdateOptions.url = postMcdOutputCodeDataFileUpdateOptions.url.replace('{id}', target['id']);
                        await execRequest(postMcdOutputCodeDataFileUpdateOptions, '出力ファイル管理ステータス更新');
                        postMcdOutputCodeDataFileUpdateOptions['headers']['Content-Length'] = undefined;
                    } catch (e) {
                        // 失敗した場合は処理終了
                        throw e;
                    }
                }

                if (!isDeleted) {
                    // 処理失敗時のみoffset追加
                    offset++;
                }
            }
        } else {
            infoLog('利用者データ削除の対象がありません。');
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

infoLog('start  : delete-user-batch deleteUser');
main().then(e => {
    infoLog('success: delete-user-batch deleteUser');
    log4js.shutdown(() => {});
}).catch(e => {
    errorLog(e);
    errorLog('error  : delete-user-batch deleteUser');
    log4js.shutdown(() => process.exit(1));
});
