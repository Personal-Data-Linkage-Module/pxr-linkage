/** Copyright 2022 NEC Corporation
*/
// 出力データファイル管理作成
// createOutputUserDataFileMng.js
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0;
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
        let res = null;
        try {
            const getOutputConditionOptions = {
                url: config['bookManageService']['getOutputCondition'],
                method: 'GET',
                headers: headers
            }
            getOutputConditionOptions.url = getOutputConditionOptions.url.replace('{offset}', offset);
            res = await execRequest(getOutputConditionOptions, '承認済出力データ収集アクター取得');
            resBody = JSON.parse(res.body);
        } catch (e) {
            // 失敗した場合は処理終了
            throw e;
        }

        if (resBody && resBody.length > 0) {
            for (const target of resBody) {
                offset += target['condition'].length;
                let isReserveDeletion = Number(target['type']) === 4 || Number(target['type']) === 5;
                // アップロードファイル用の出力データ管理作成処理
                const postCreateMcdOutputCodeDataFileOptions = {
                    url: config['bookManageService']['postCreateMcdOutputCodeDataFile'],
                    method: 'POST',
                    headers: headers,
                    json: null
                };
                let isMngCreate = false;

                for (const condition of target['condition']) {
                    if (!condition['app'] && !condition['wf']) {
                        continue;
                    }

                    res = null;
                    const postGetMcdOutputCodeDataFileOptions = {
                        url: config['bookManageService']['postGetMcdOutputCodeDataFile'],
                        method: 'POST',
                        headers: headers,
                        json: {
                            mcdOutputCodeActorId: condition['id']
                        }
                    }
                    try {
                        res = await execRequest(postGetMcdOutputCodeDataFileOptions, '出力データ管理取得');
                    } catch (e) {
                        throw e;
                    }
                    if (res.body.length === 0) {
                        let json = {
                            mcdOutputCodeActorId: condition['id'],
                            code: target['code'],
                            outputApproved: 1,
                            actor: {
                                _value: condition['actor']['_value'],
                                _ver: condition['actor']['_ver']
                            },
                            outputFileType: 2,
                            inputFileIsReady: 0,
                            outputStatus: 0,
                            processing: 0
                        }
                        postCreateMcdOutputCodeDataFileOptions.json = json;
                        infoLog('postCreateMcdOutputCodeDataFileOptions: ' + JSON.stringify(postCreateMcdOutputCodeDataFileOptions.json));
                        if (Number(condition['returnable']) === 1) {
                            isMngCreate = true;
                            isReserveDeletion = false;
                            // 返却指定あり
                            const code = condition['app'] ? condition['app']['_value'] : condition['wf']['_value'];
                            const version = condition['app'] ? condition['app']['_ver'] : condition['wf']['_ver'];
                            const getCatalogForCodeOptions = {
                                url: config['catalogService']['getForCode'],
                                method: 'GET',
                                headers: headers
                            }
                            getCatalogForCodeOptions.url = getCatalogForCodeOptions.url.replace('{code}', Number(code)).replace('{version}', Number(version))
                            let catalogName;
                            try {
                                res = await execRequest(getCatalogForCodeOptions, '対象wf/appのカタログを取得');
                                catalogName = JSON.parse(res.body)['catalogItem']['name'];
                            } catch (e) {
                                // 失敗した場合は処理終了
                                throw e;
                            }
                            if (condition['request']) {
                                // 個別データ
                                json['uploadFileType'] = 2;
                                json['extDataRequested'] = 0;
                                json['fileName'] = `${ target['code'] }/${ code }-${ version }-${ catalogName }-個別データ.zip`;
                                json['isDeleteTarget'] = 0;
                                json['deleteStatus'] = 0;

                                try {
                                    await execRequest(postCreateMcdOutputCodeDataFileOptions, '出力データ管理作成');
                                } catch (e) {
                                    // 失敗した場合は処理終了
                                    throw e;
                                }
                            }

                            // 利用者データ
                            const deletable = 1;
                            json['uploadFileType'] = 1;
                            json['extDataRequested'] = 0;
                            json['fileName'] = `${ target['code'] }/${ code }-${ version }-${ catalogName }.zip`;
                            json['isDeleteTarget'] = condition['deletable'];
                            json['deleteStatus'] = condition['deletable'] === deletable ? 1 : 0;

                            try {
                                await execRequest(postCreateMcdOutputCodeDataFileOptions, '出力データ管理作成');
                            } catch (e) {
                                // 失敗した場合は処理終了
                                throw e;
                            }
                        } else if (Number(condition['deletable']) === 1) {
                            // データの返却なしの場合かつデータ削除指定が 削除可:1 の場合
                            json['isDeleteTarget'] = 1;
                            json['deleteStatus'] = 2;
                            try {
                                await execRequest(postCreateMcdOutputCodeDataFileOptions, '出力データ管理作成');
                            } catch (e) {
                                // 失敗した場合は処理終了
                                throw e;
                            }
                        } else {
                            infoLog('対象外のレコードのため、アップロードファイル用の出力データ管理作成処理をスキップします。');
                        }
                    } else {
                        if (Number(condition['returnable']) === 1) {
                            // 作成済の出力データ管理が返却指定ありの場合、削除予約フラグをfalseにしておく
                            isReserveDeletion = false;
                        }
                        infoLog('出力データファイル管理作成対象外のレコードのため、次のレコードに処理をスキップします。');
                    }
                }
                if (isMngCreate) {
                    res = null;
                    const postGetMcdOutputCodeDataFileOptions = {
                        url: config['bookManageService']['postGetMcdOutputCodeDataFile'],
                        method: 'POST',
                        headers: headers,
                        json: {
                            code: target['code'],
                            outputFileType: 1
                        }
                    }
                    try {
                        res = await execRequest(postGetMcdOutputCodeDataFileOptions, '出力データ管理取得');
                    } catch (e) {
                        throw e;
                    }
                    isMngCreate = res && res.body.length === 0;
                }

                if (isMngCreate) {
                    const typeDisplay = {
                        1: '開示請求', 2: 'Region利用終了', 3: 'Region利用終了', 4: 'Book閉鎖', 5: 'Book閉鎖'
                    };
                    const typeName = typeDisplay[Number(target['type'])];
                    json = {
                        mcdOutputCodeActorId: null,
                        code: target['code'],
                        outputApproved: 1,
                        actor: null,
                        outputFileType: 1,
                        uploadFileType: null,
                        extDataRequested: null,
                        fileName: `${ target['code'] }/${ typeName }-返却データ.zip`,
                        inputFileIsReady: 0,
                        isDeleteTarget: 0,
                        deleteStatus: 0,
                        outputStatus: 0,
                        processing: 0
                    }
                    postCreateMcdOutputCodeDataFileOptions.json = json;
                    try {
                        await execRequest(postCreateMcdOutputCodeDataFileOptions, 'ダウンロードファイル用の出力データ管理作成');
                    } catch (e) {
                        // 失敗した場合は処理終了
                        throw e;
                    }
                }

                // 出力タイプ が 4: Book閉鎖 または 5: Book強制閉鎖の場合、削除予約フラグをtrueにする
                if (isReserveDeletion) {
                    const postGetMcdOutputOption = {
                        url: config['bookManageService']['postGetMcdOutput'],
                        method: 'POST',
                        headers: headers,
                        json: {
                            code: target.code
                        }
                    };
                    let bookId;
                    try {
                        res = await execRequest(postGetMcdOutputOption, 'My-Condition-Data出力コード取得');
                        if (!res.body || res.body.length !== 1) {
                            infoLog('対象Bookは既に削除済です。code: ' + target.code);
                            break;
                        }
                        if (res.body[0].bookCloseAvailable) {
                            infoLog('対象Bookは既に削除予約済です。code: ' + target.code);
                            break;
                        }
                        bookId = res.body[0]['bookId'];
                    } catch (e) {
                        throw e;
                    }
                    const postReserveDeletionOption = {
                        url: config['bookManageService']['postReserveDeletion'],
                        method: 'POST',
                        headers: headers,
                        json: {}
                    };
                    postReserveDeletionOption.url = postReserveDeletionOption.url.replace('{id}', Number(bookId));
                    try {
                        await execRequest(postReserveDeletionOption, 'Book削除予約')
                    } catch (e) {
                        throw e;
                    }
                }
            }
        } else {
            break;
        }
    }
    infoLog('出力データファイル管理作成処理を終了します。');

    return;
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

infoLog('start  : output-user-data-file-mng-batch createOutputUserDataFileMng');
main().then(e => {
    infoLog('success: output-user-data-file-mng-batch createOutputUserDataFileMng');
    log4js.shutdown(() => {});
}).catch(e => {
    errorLog(e);
    errorLog('error  : output-user-data-file-mng-batch createOutputUserDataFileMng');
    log4js.shutdown(() => process.exit(1));
});