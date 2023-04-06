/** Copyright 2022 NEC Corporation
*/
// Region利用終了
// closeRegion.js
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
        //  Book管理サービス.Region終了対象取得 API
        try {
            const getRegionCloseOptions = {
                url: config['bookManageService']['getRegionClose'],
                method: 'GET',
                headers: headers
            }
            getRegionCloseOptions.url = getRegionCloseOptions.url.replace('{offset}', offset.toString());
            const res = await execRequest(getRegionCloseOptions, 'Region終了時対象取得');
            resBody = JSON.parse(res.body);
        } catch (e) {
            // 失敗した場合は処理終了
            throw e;
        }
        if (resBody && resBody['targets'] && resBody['targets'].length > 0) {
            // offset += resBody['targets'].length;
            // 処理完了フラグ
            let isRegionClosed;
            for (const target of resBody['targets']) {
                isRegionClosed = false;
                // Book管理サービス.My-Condition-Data出力コード取得 API
                let mcdOutputCodes = [];
                let mcdOutputCodeOffest = 0;
                let cooperationCancelApproved = 0;
                while (true) {
                    let mcdOutputCodeRes;
                    try {
                        const json = {
                            type: 2,
                            actor: {
                                _value: Number(target['actor']['_value']),
                                _ver: Number(target['actor']['_ver'])
                            },
                            region: {
                                _value: Number(target['region']['_value']),
                                _ver: Number(target['region']['_ver'])
                            },
                            cooperationCancelApproved: cooperationCancelApproved,
                            cooperationCanceled: 0,
                            processing: 0
                        };
                        const postOutputOptions = {
                            url: config['bookManageService']['postOutput'],
                            method: 'POST',
                            headers: headers,
                            json: json
                        };
                        postOutputOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                        postOutputOptions.url = postOutputOptions.url.replace('{offset}', mcdOutputCodeOffest.toString());
                        const res = await execRequest(postOutputOptions, 'My-Condition-Data出力コード取得');
                        postOutputOptions['headers']['Content-Length'] = undefined;
                        mcdOutputCodeRes = res.body;
                    } catch (e) {
                        throw e;
                    }
                    if (mcdOutputCodeRes && mcdOutputCodeRes.length > 0) {
                        // レコードが取得できた場合
                        mcdOutputCodeOffest += mcdOutputCodeRes.length;
                        mcdOutputCodes = mcdOutputCodes.concat(mcdOutputCodeRes);
                    } else {
                        // レコードが取得できなかった場合
                        if (cooperationCancelApproved === 0) {
                            cooperationCancelApproved = 2;
                            mcdOutputCodeOffest = 0;
                        } else {
                            break;
                        }
                    }
                }
                // レコードが取得できた場合
                if (mcdOutputCodes && mcdOutputCodes.length > 0) {
                    for (const mcdOutputCode of mcdOutputCodes) {
                        let userId;
                        // Book管理サービス.My-Condition-Data出力コード更新 API
                        try {
                            let json = {
                                processing: 1
                            };
                            const putOutputIdOptions = {
                                url: config['bookManageService']['putOutputId'],
                                method: 'PUT',
                                headers: headers,
                                json: json
                            };
                            putOutputIdOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                            putOutputIdOptions.url = putOutputIdOptions.url.replace('{id}', mcdOutputCode['id']);
                            await execRequest(putOutputIdOptions, 'My-Condition-Data出力コード更新');
                            putOutputIdOptions['headers']['Content-Length'] = undefined;
                        } catch (e) {
                            infoLog('対象外のレコードのため次のレコードに処理をスキップします。');
                            continue;
                        }
                        try {
                            // Book管理サービス.My-Condition-Book一覧取得 API
                            let json = {
                                pxrId: [
                                    mcdOutputCode['pxrId']
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
                            let res = await execRequest(postMcbSearchOptions, 'My-Condition-Book一覧取得');
                            postMcbSearchOptions['headers']['Content-Length'] = undefined;

                            for (const book of res.body) {
                                if (book['cooperation'] && Array.isArray(book['cooperation'])) {
                                    for (const cooperation of book['cooperation']) {
                                        if (mcdOutputCode['actor']['_value'] === Number(cooperation['actor']['_value']) &&
                                            cooperation['region'] && Number(mcdOutputCode['region']['_value']) === Number(cooperation['region']['_value'])) {
                                            userId = cooperation['userId'];
                                        }
                                    }
                                }
                            }
                            if (userId) {
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
                                
                                // 本人性確認サービス.確認済本人性確認コード生成 API
                                json = {
                                    pxrId: mcdOutputCode['pxrId'],
                                    userId: userId,
                                    actor: {
                                        _value: Number(mcdOutputCode['actor']['_value']),
                                        _ver: Number(mcdOutputCode['actor']['_ver'])
                                    },
                                    region: {
                                        _value: Number(mcdOutputCode['region']['_value']),
                                        _ver: Number(mcdOutputCode['region']['_ver'])
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
                                const identityVerificateCode = res.body;
                                infoLog(JSON.stringify(identityVerificateCode));

                                // Book運用サービス.利用者削除 API
                                const releaseSession = config['releaseSession'];
                                releaseSession['actor']['_value'] = Number(target['actor']['_value']);
                                releaseSession['actor']['_ver'] = Number(target['actor']['_ver']);
                                headers['session'] = JSON.stringify(releaseSession);
                                infoLog('利用者削除 session情報: ' + JSON.stringify(releaseSession));

                                const postUserDeleteOptions = {
                                    url: config['bookOperateService']['postUserDelete'],
                                    method: 'POST',
                                    headers: headers,
                                    json: {
                                        identifyCode: identityVerificateCode['identifyCode']
                                    }
                                };
                                postUserDeleteOptions.url = postUserDeleteOptions.url.replace('{physicalDelete}', physicalDelete);
                                await execRequest(postUserDeleteOptions, '利用者削除');
                                headers['session'] = JSON.stringify(session);
                            }

                            // 処理に成功した場合
                            // Book管理サービス.My-Condition-Data出力コード更新 API
                            json = {
                                cooperationCanceled: 1,
                                processing: 0
                            };
                            const putOutputIdOptions = {
                                url: config['bookManageService']['putOutputId'],
                                method: 'PUT',
                                headers: headers,
                                json: json
                            };
                            putOutputIdOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                            putOutputIdOptions.url = putOutputIdOptions.url.replace('{id}', mcdOutputCode['id']);
                            await execRequest(putOutputIdOptions, 'My-Condition-Data出力コード更新');
                            putOutputIdOptions['headers']['Content-Length'] = undefined;

                            // Regionカタログのステータス変更および終了済Region削除処理
                            await CloseRegion(target, session);
                        } catch (e) {
                            errorLog(e);
                            try {
                                // エラーが発生した場合
                                // Book管理サービス.My-Condition-Data出力コード更新 API
                                headers['session'] = JSON.stringify(session);
                                const json = {
                                    processing: 0
                                };
                                const putOutputIdOptions = {
                                    url: config['bookManageService']['putOutputId'],
                                    method: 'PUT',
                                    headers: headers,
                                    json: json
                                };
                                putOutputIdOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
                                putOutputIdOptions.url = putOutputIdOptions.url.replace('{id}', mcdOutputCode['id']);
                                await execRequest(putOutputIdOptions, 'My-Condition-Data出力コード更新');
                                putOutputIdOptions['headers']['Content-Length'] = undefined;
                            } catch (e) {
                                errorLog(e);
                                throw e;
                            }
                        }
                    }
                } else {
                    // レコード取得できない場合、該当Regionの利用者が存在するか確認する
                    let regionCloseTargetOffset = 0;
                    while (true) {
                        let resBody;
                        //  Book管理サービス.Region終了時利用者ID連携解除対象個人取得 API
                        try {
                            const getRegionCloseTargetOptions = {
                                url: config['bookManageService']['getRegionCloseTarget'],
                                method: 'GET',
                                headers: headers
                            }
                            getRegionCloseTargetOptions.url = getRegionCloseTargetOptions.url.replace('{offset}', regionCloseTargetOffset);
                            const res = await execRequest(getRegionCloseTargetOptions, 'Region終了時利用者ID連携解除対象個人取得');
                            resBody = JSON.parse(res.body);
                        } catch (e) {
                            // 失敗した場合Region終了処理は行わない
                            errorLog(e);
                            break;
                        }
                        if (resBody && resBody['targets'] && resBody['targets'].length > 0) {
                            regionCloseTargetOffset += resBody['targets'].length;
                            const RegionUser = resBody['targets'].find(user => Number(user['actor']['_value']) === Number(target['actor']['_value']) &&
                                Number(user['actor']['_ver']) === Number(target['actor']['_ver']) &&
                                Number(user['region']['_value']) === Number(target['region']['_value']) &&
                                Number(user['region']['_ver']) === Number(target['region']['_ver'])
                            );
                            if (RegionUser) {
                                // 処理中のRegionに利用者が存在する場合、My-Condition-Data出力コード取得処理に問題があるためRegion終了処理は行わない
                                infoLog('対象個人: ' + RegionUser.pxrId);
                                infoLog('My-Condition-Data出力コードが存在しない利用者が存在するためRegion終了処理をスキップします。');
                                break;
                            }
                        } else {
                            // 処理中のRegionに利用者が1人も存在しない場合、Region終了処理を行う
                            try {
                                isRegionClosed = await CloseRegion(target, session);
                            } catch (e) {
                                errorLog(e);
                            }
                            break;
                        }
                    }
                }
                if (!isRegionClosed) {
                    // 処理失敗時のみoffset追加
                    offset++;
                }
            }
        } else {
            // Book管理サービス.Region終了対象取得 APIの取得結果が0件になればバッチ処理終了
            break;
        }
    }
    infoLog('Region利用終了処理を終了します。');
}
    /**
     * Regionカタログのステータス更新および終了済Region削除処理
     * @param {*} target 終了対象のRegion
     * @returns 成功可否のboolean値
     */
    async function CloseRegion(target, session) {
        // Regionカタログ取得
        const getCatalogByCodeOptions = {
            url: config['catalogService']['getByCode'],
            method: 'GET',
            headers: headers
        };
        getCatalogByCodeOptions.url = getCatalogByCodeOptions.url.replace('{code}', target['region']['_value'].toString());
        const catalogRes = await execRequest(getCatalogByCodeOptions, 'Regionカタログ取得');
        const regionCatalog = JSON.parse(catalogRes.body);

        // Regionカタログのstatusがcloseでない場合Regionカタログのstatusをcloseに変更する
        if (regionCatalog['template']['status'] !== 'close') {
            // カタログ更新
            const closeRegionSession= config['closeRegionSession'];
            closeRegionSession['actor']['_value'] = Number(target['actor']['_value']);
            closeRegionSession['actor']['_ver'] = Number(target['actor']['_ver']);
            headers['session'] = JSON.stringify(closeRegionSession);
            infoLog('カタログ更新 session情報: ' + JSON.stringify(closeRegionSession));

            regionCatalog['template']['status'] = 'close';
            const regionCatalogForUpdate = parse4update(regionCatalog);
            const putCatalogExtCodeOptions = {
                url: config['catalogService']['putCatalogExtCode'],
                method: 'PUT',
                headers: headers,
                json: regionCatalogForUpdate
            };
            putCatalogExtCodeOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(regionCatalogForUpdate));
            putCatalogExtCodeOptions.url = putCatalogExtCodeOptions.url.replace('{code}', target['region']['_value'].toString());
            await execRequest(putCatalogExtCodeOptions, 'カタログ更新');
            putCatalogExtCodeOptions['headers']['Content-Length'] = undefined;
            headers['session'] = JSON.stringify(session);
        }
        // 終了済Regionを削除済に更新する
        const json = {
            actor: {
                _value: Number(target['actor']['_value']),
                _ver: Number(target['actor']['_ver'])
            },
            region: {
                _value: Number(target['region']['_value']),
                _ver: Number(target['region']['_ver'])
            },
        };
        const putRegionCloseOptions = {
            url: config['bookManageService']['putRegionClose'],
            method: 'PUT',
            headers: headers,
            json: json
        };
        putRegionCloseOptions['headers']['Content-Length'] = Buffer.byteLength(JSON.stringify(json));
        await execRequest(putRegionCloseOptions, '終了済Region更新');
        putRegionCloseOptions['headers']['Content-Length'] = undefined;
        // 処理結果を返却
        return true;
    }

function parse4update (data) {
    const result = {};
    // catalogItemの修正
    data.catalogItem._code._ver = null;
    data.catalogItem.inherit._ver = null;
    result.catalogItem = data.catalogItem;

    const parser = (input) => {
        const result = [];
        for (const index in input) {
            const pusher = {
            };
            const val = input[index];

            if (typeof val === 'object' && Array.isArray(val)) {
                for (const arrayIndex in val) {
                    const arrayValue = {
                        key: index
                    };
                    arrayValue.value = parser(val[arrayIndex]);
                    result.push(arrayValue);
                }
                continue;
            } else if (typeof val === 'object') {
                pusher.key = index;
                pusher.value = parser(val);
            } else {
                pusher.key = index;
                pusher.value = input[index];
            }
            result.push(pusher);
        }
        return result;
    };

    // templateの修正
    result.template = {};
    const templateProperties = [];
    for (const index in data.template) {
        if (index === '_code') {
            continue;
        }
        const prop = data.template[index];
        const value = {
            key: index
        };

        if (prop && typeof prop === 'object' && Array.isArray(prop)) {
            for (const arrayIndex in prop) {
                const arrayValue = {
                    key: index
                };
                arrayValue.value = parser(prop[arrayIndex]);
                templateProperties.push(arrayValue);
            }
            continue;
        } else if (prop && typeof prop === 'object') {
            value.value = parser(prop);
        } else {
            // プリミティブな値であれば、それらはそのまま値として設定する
            value.value = prop;
        }

        templateProperties.push(value);
    }
    result.template.value = templateProperties;

    // 固定で設定するプロパティ値
    result.template.prop = null;
    result.inner = null;
    result.attribute = null;

    return result;
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

infoLog('start  : pxr-close-region-batch closeRegion');
main().then(e => {
    infoLog('success: pxr-close-region-batch closeRegion');
    log4js.shutdown(() => {});
}).catch(e => {
    errorLog(e);
    errorLog('error  : pxr-close-region-batch closeRegion');
    log4js.shutdown(() => process.exit(1));
});