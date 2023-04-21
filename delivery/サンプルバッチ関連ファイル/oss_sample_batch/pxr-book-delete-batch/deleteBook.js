/** Copyright 2022 NEC Corporation
*/
// カタログ登録
// catalogRegister.js
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

    const getCatalogOptions = {
        url: config['catalogService']['getForNs'] + config['catalog']['platformTermsOfUseNs'],
        method: 'GET',
        headers: headers
    };
    let isPhysicalDelete = false;
    try {
        const res = await execRequest(getCatalogOptions, 'PF利用規約カタログ取得');
        const pfCatalog = JSON.parse(res.body)[0];
        isPhysicalDelete = Boolean(pfCatalog['template']['deleting-data-flag']);
    } catch (e) {
        // 失敗した場合は処理終了
        throw e;
    }

    // Block判定処理
    const getBlockCatalogOptions = {
        url: config['catalogService']['getForCode'],
        method: 'GET',
        headers: headers
    };
    let blockNs;
    try {
        getBlockCatalogOptions.url = getBlockCatalogOptions.url + Number(config['session']['block']['_value']);
        res = await execRequest(getBlockCatalogOptions, 'Blockカタログ取得');
        blockNs = JSON.parse(res.body)['catalogItem']['ns'];
    } catch (e) {
        // 失敗した場合は処理終了
        throw e;
    }

    let offset = 0;
    while (true) {
        let resBody;
        // Book管理サービス.削除可能Book取得API より自動削除を行う対象の個人を10件ずつ取得
        let rootHeaders = null;
        if (config['rootSession']) {
            rootHeaders = {
                'accept': 'application/json',
                'Content-Type': 'application/json'
            };
            const rootSession = config['rootSession'];
            rootSession['sessionId'] = '097240851664f1830554bacab28165793328128db1474af4da708a9ee9a1f732';
            rootSession['operatorId'] = 999999999999;
            rootSession['type'] = 3;
            rootHeaders['session'] = JSON.stringify(rootSession);
            infoLog('session情報: ' + JSON.stringify(rootSession));
        }
        const getDeleteTargetOprions = {
            url: config['bookManageService']['getDeleteTarget'].replace('{offset}', offset),
            method: 'GET',
            headers: rootHeaders || headers
        };
        try {
            const res = await execRequest(getDeleteTargetOprions, '削除可能Book取得');
            resBody = JSON.parse(res.body);
        } catch (e) {
            throw e;
        }

        if (resBody.length > 0) {
            for (const target of resBody) {
                const pxrId = target.pxrId;
                const json = {
                    pxrId: [
                        pxrId
                    ],
                    offset: 0,
                    limit: 10
                };
                let books;
                const postSearchBookOptions = {
                    url: config['bookManageService']['postSearchBook'],
                    method: 'POST',
                    headers: headers,
                    json: json
                };
                try {
                    const res = await execRequest(postSearchBookOptions, 'My-Condition-Book一覧取得');
                    books = JSON.parse(JSON.stringify(res.body));
                } catch (e) {
                    throw e;
                }
                if (blockNs.indexOf('/pxr-root') >= 0) {
                    // Root-Blockの場合
                    // 利用者連携が全て消えているか確認
                    let deletion = true;
                    for (book of books) {
                        if (book['cooperation'] && book['cooperation'].length > 0) {
                            for (cooperation of book['cooperation']) {
                                if (cooperation.userId && cooperation.status !== 0) {
                                    // Data-Traderとの利用者連携か確認
                                    const getActorCatalogOptions = {
                                        url: config['catalogService']['getForCode'],
                                        method: 'GET',
                                        headers: headers
                                    };
                                    let actorNs;
                                    try {
                                        getActorCatalogOptions.url = getActorCatalogOptions.url + Number(cooperation['actor']['_value']);
                                        res = await execRequest(getActorCatalogOptions, '利用者連携アクターカタログ取得');
                                        actorNs = JSON.parse(res.body)['catalogItem']['ns'];
                                    } catch (e) {
                                        // 失敗した場合は処理終了
                                        throw e;
                                    }
                                    if (actorNs.indexOf('/data-trader') >= 0) {
                                        try {
                                            const userId = cooperation['userId'];
                                            const ident = {
                                                pxrId: pxrId,
                                                userId: userId,
                                                actor: {
                                                    _value: cooperation['actor']['_value'],
                                                    _ver: cooperation['actor']['_ver']
                                                }
                                            };
                                            const postCodeVerifiedOptions = {
                                                url: config['identityVerificateService']['postCodeVerified'],
                                                method: 'POST',
                                                headers: headers,
                                                json: ident
                                            };
                                            let identifyCode;
                                            try {
                                                const res = await execRequest(postCodeVerifiedOptions, '確認済本人性確認コード生成');
                                                identifyCode = JSON.parse(JSON.stringify(res.body))['identifyCode'];
                                            } catch (e) {
                                                // 失敗した場合は処理終了
                                                throw e;
                                            }
    
                                            // Book管理サービス.利用者ID連携解除 API
                                            const releaseSession = config['releaseSession'];
                                            releaseSession['actor']['_value'] = Number(cooperation['actor']['_value']);
                                            releaseSession['actor']['_ver'] = Number(cooperation['actor']['_ver']);
                                            headers['session'] = JSON.stringify(releaseSession);
                                            infoLog('利用者ID連携解除 session情報: ' + JSON.stringify(releaseSession));
    
                                            const postCooperateReleaseOptions = {
                                                url: config['bookManageService']['postCooperateRelease'],
                                                method: 'POST',
                                                headers: headers,
                                                json: {
                                                    identifyCode: identifyCode
                                                }
                                            };
                                            await execRequest(postCooperateReleaseOptions, '利用者ID連携解除');
                                            headers['session'] = JSON.stringify(session);
                                        } catch (e) {
                                            // 利用者ID連携解除に失敗した場合はBook削除を行わない
                                            deletion = false;
                                            errorLog('利用者ID連携解除に失敗したため、次のレコードに処理をスキップします。');
                                        }
                                    } else {
                                        // Data-Trader以外との連携がある場合はBook削除を行わない
                                        deletion = false;
                                    }
                                }
                            }
                        }
                    }
                    if (deletion) {
                        const deleteForceOptions = {
                            url: '',
                            method: 'DELETE',
                            headers: headers
                        };
                        try {
                            deleteForceOptions.url = config['bookManageService']['deleteForce'].replace('{pxrId}', pxrId).replace('{physicalDelete}', isPhysicalDelete);
                            await execRequest(deleteForceOptions, '強制削除');
                        } catch (e) {
                            // 削除スキップの場合offsetを増やす
                            offset ++;
                            errorLog('強制削除に失敗したため、該当Bookの処理をスキップします。' + 'pxrId: ' + pxrId);
                            continue;
                        }
                    } else {
                        // 削除スキップの場合offsetを増やす
                        offset ++;
                        infoLog('利用者連携が残っているため、Book削除処理をスキップします。');
                        continue;
                    }
                } else {
                    // Root-Block以外の場合
                    for (const book of books) {
                        if (book['cooperation'] && book['cooperation'].length > 0) {
                            for (const cooperation of book['cooperation']) {
                                if (!cooperation['userId']) {
                                    infoLog('対象利用者がいないため、削除処理をスキップします');
                                    continue;
                                }
                                if (cooperation['status'] === 0) {
                                    // ステータスが連携申請中の場合、処理をスキップ
                                    infoLog('対象が連携申請中のため、削除処理をスキップします');
                                    continue;
                                } else {
                                    if (Number(config['session']['actor']['_value']) !== Number(cooperation['actor']['_value'])) {
                                        // 自ブロックのBookではない場合、処理をスキップ
                                        infoLog('対象のBookのBlockが異なるため、削除処理をスキップします。');
                                        continue;
                                    }
                                }
                                try {
                                    const userId = cooperation['userId'];
                                    const ident = {
                                        pxrId: pxrId,
                                        userId: userId,
                                        actor: {
                                            _value: cooperation['actor']['_value'],
                                            _ver: cooperation['actor']['_ver']
                                        }
                                    };
                                    if (cooperation['region']) {
                                        ident['region'] = {
                                            _value: cooperation['region']['_value'],
                                            _ver: cooperation['region']['_ver']
                                        };
                                    }
                                    if (cooperation['app']) {
                                        ident['app'] = {
                                            _value: cooperation['app']['_value'],
                                            _ver: cooperation['app']['_ver']
                                        };
                                    }
                                    if (cooperation['wf']) {
                                        ident['wf'] = {
                                            _value: cooperation['wf']['_value'],
                                            _ver: cooperation['wf']['_ver']
                                        };
                                    }
                                    const postCodeVerifiedOptions = {
                                        url: config['identityVerificateService']['postCodeVerified'],
                                        method: 'POST',
                                        headers: headers,
                                        json: ident
                                    };
                                    let identifyCode;
                                    try {
                                        const res = await execRequest(postCodeVerifiedOptions, '確認済本人性確認コード生成');
                                        identifyCode = JSON.parse(JSON.stringify(res.body))['identifyCode'];
                                    } catch (e) {
                                        throw e;
                                    }
                                    const postUserDeleteOptions = {
                                        url: config['bookOperateService']['postUserDelete'],
                                        method: 'POST',
                                        headers: headers,
                                        json: {
                                            identifyCode: identifyCode
                                        }
                                    };
                                    postUserDeleteOptions.url = postUserDeleteOptions.url.replace('{physicalDelete}', isPhysicalDelete);
                                    await execRequest(postUserDeleteOptions, '利用者削除');
                                } catch (e) {
                                    errorLog('利用者削除に失敗したため、次のレコードに処理をスキップします。');
                                }
                            }
                        }
                        // root以外の利用者を削除してもMy-Condition-Bookは取得できるためoffsetを増やす
                        offset ++;
                    }
                }
            }
        } else {
            infoLog('対象のBookをすべて削除しました。');
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

infoLog('start  : book-delete-batch deleteBook');
main().then(e => {
    infoLog('success: book-delete-batch deleteBook');
    log4js.shutdown(() => {});
}).catch(e => {
    errorLog(e);
    errorLog('error  : book-delete-batch deleteBook');
    log4js.shutdown(() => process.exit(1));
});