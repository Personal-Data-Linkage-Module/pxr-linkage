// カタログ登録
// catalogRegister.js
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0;
var fs = require('fs');
var path = require('path');
var request = require('request');
var headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
    'session': JSON.stringify({
        sessionId: 'dummy_session_for_catalog_registration',
        operatorId: 9999999,
        type: 3,
        loginId: 'catalog_registrant',
        name: 'catalog_registrant',
        block: {
            _value: 9999999,
            _ver: 1
        },
        actor: {
            _value: 9999999,
            _ver: 1
        }
    })
};

// 環境設定（既定はローカル環境）
// ドメインが指定されれば自動的にhttpsを選択
var protocol = process.argv.length > 2 ? 'https' : 'http'; 
var host = process.argv.length > 2 ? process.argv[2] : 'localhost';
var port = process.argv.length > 2 ? '443' : '3001';
var serviceRootPath = process.argv.length > 2 ? '/catalog/catalog' : '/catalog';

if (! fs.existsSync('logs')) {
    fs.mkdirSync('logs', { recursive: true }, (err) => {
        if (err) throw err;
    });;
}
if (! fs.existsSync('logs/info')) {
    fs.mkdirSync('logs/info', { recursive: true }, (err) => {
        if (err) throw err;
    });
}
if (! fs.existsSync('logs/error')) {
    fs.mkdirSync('logs/error', { recursive: true }, (err) => {
        if (err) throw err;
    });
}
let now = new Date();
let fileName = ('0000' + now.getFullYear()).slice(-4) + ('00' + (now.getMonth() + 1)).slice(-2) + ('00' + now.getDate()).slice(-2) + '_' +
    ('00' + now.getHours()).slice(-2) + ('00' + now.getMinutes()).slice(-2) + ('00' + now.getSeconds()).slice(-2);
let outFile = './logs/info/' + fileName + '.log';
let errFile = './logs/error/' + fileName + '.log';
fs.writeFileSync(outFile, '');
fs.writeFileSync(errFile, '');
var out = fs.createWriteStream(outFile);
var err = fs.createWriteStream(errFile);
var logger = console.Console(out, err);

async function main() {
    // 同ディレクトリにあるアクティベートjsonを読み取る
    let activateJsonFile;
    try {
        activateJsonFile = fs.readdirSync('.').filter(function (file) {
            return fs.statSync(file).isFile() && /.*\.json$/.test(file) && ! /package\-lock\.json/.test(file) && ! /package\.json/.test(file);
        });

        // 1件以外であればエラー
        if (activateJsonFile.length != 1) {
            throw new Error('アクティベート用jsonファイルが存在しない、または複数存在します。');
        }
    
        // 読み取ったjsonを登録
        let activateJson = require(path.resolve('./' + activateJsonFile[0]));
        let options = {
            url: protocol + '://' + host + ':' + port + serviceRootPath + '/name',
            method: 'POST',
            headers: headers,
            json: activateJson
        };
    
        try {
            await execRequest(options, 'アクティベート');
        } catch (e) {
            throw new Error('既にアクティベート済みです。');
        }
    } catch (e) {
        // ファイルが存在しない場合、アクティベート済として先に進む
    }

    // まずmodel, built_in, extの順でディレクトリを探索し、ns, カタログ登録用jsonを取得する
    let catalogItems = await search('model', 'model');
    catalogItems = catalogItems.concat(await search('built_in', 'built_in'));
    catalogItems = catalogItems.concat(await search('ext', 'ext'));
    let forRegists = [];

    for (let catalogItem of catalogItems) {
        try {
            let catalogItemJson = require(catalogItem);
            if (catalogItemJson['catalogItem']) {
                let forList = {
                    ns: catalogItemJson['catalogItem']['ns'],
                    code: catalogItemJson['catalogItem']['_code'] ? catalogItemJson['catalogItem']['_code']['_value'] : null,
                    json: catalogItemJson
                };
                forRegists.push(forList);
            }
        } catch (e) {
            errorLog('ファイルが取得できませんでした。', e, JSON.stringify(catalogItem));
        }
    }

    // 取得したカタログをCode順にソート
    forRegists.sort(function (a, b) {
        aCode = a['code'];
        bCode = b['code'];

        if (aCode !== aCode && bCode !== bCode) return 0;
        if (aCode !== aCode) return 1;
        if (bCode !== bCode) return -1;

        if (aCode == null && bCode == null) return 0;
        if (aCode == null) return 1;
        if (bCode == null) return -1;

        if (aCode === '' && bCode === '') return 0;
        if (aCode === '') return 1;
        if (bCode === '') return -1;

        if (aCode > bCode) return 1;
        if (aCode < bCode) return -1;
        return 0;
    });

    // 処理時間測定開始
    const performance = require('perf_hooks').performance;
    const start = performance.now();
    for (let forRegist of forRegists) {
        let type = 'model';
        type = forRegist['ns'].indexOf('/model/') < 0 ? type : 'model';
        type = forRegist['ns'].indexOf('/built_in/') < 0 ? type : 'built_in';
        type = forRegist['ns'].indexOf('/ext/') < 0 ? type : 'ext';
        let catalogOptions = {
            url: protocol + '://' + host + ':' + port + serviceRootPath + '/' + type,
            method: 'POST',
            headers: headers,
            json: forRegist['json']
        };
        try {
            await execRequest(catalogOptions, 'カタログ項目の登録');
        } catch (e) {
            // logは execRequest で出力しているので処理なし
        }
    }
    // 処理時間測定終了
    const end = performance.now();
    const time = (end - start).toFixed(3);
    console.log('実行時間 = ' + time + 'msec');
}

async function search(catalogType, dir) {
    let catalogItems = [];

    // 指定されたディレクトリへ移動
    try {
        process.chdir('./' + dir);
    } catch (e) {
        // 指定のディレクトリが確認できなければ探索終了
        return catalogItems;
    }

    //ファイルリストを取得
    let files;
    try {
        files = fs.readdirSync('.').filter(function (file) {
            return fs.statSync(file).isFile();
        });
    } catch (e) {
        throw new Error('search - ファイルリストが取得できません。');
    }

    // ネームスペースの登録
    // ns.jsonが存在すれば登録
    let nsJsonFile = files.filter(function (file) {
        return file === 'ns.json';
    });
    if (nsJsonFile.length === 1) {
        let isNsRegistered = false;

        let nsJson = require(path.resolve('./' + nsJsonFile[0]));
        let options = {
            url: protocol + '://' + host + ':' + port + serviceRootPath + '/ns/' + catalogType,
            method: 'POST',
            headers: headers,
            json: nsJson
        };
        try {
            await execRequest(options, 'ネームスペースの登録');
            isNsRegistered = true;
        } catch (e) {
            // logは execRequest で出力しているので処理なし
            // ns登録に失敗しても処理継続
        }

        if (isNsRegistered) {
            // カタログ定義jsonの取得
            let catalogJsonFiles = files.filter(function (file) {
                return /.*\_item\.json/.test(file);
            });
            // ネーム取得
            for (let catalogJsonFile of catalogJsonFiles) {
                catalogItems.push(path.resolve('./' + catalogJsonFile));
            }
        }
    }

    // 下位ディレクトリが存在するならば探索
    let lowerDirs;
    try {
        lowerDirs = fs.readdirSync('.').filter(function (dir) {
            return fs.statSync(dir).isDirectory();
        });
    } catch (e) {
        throw new Error('search - ディレクトリリストが取得できません。');
    }

    // 順に呼出して同じ処理を実行する
    for (let lowerDir of lowerDirs) {
        catalogItems = catalogItems.concat(await search(catalogType, lowerDir));
    }

    process.chdir('./..');
    return catalogItems;
}

function execRequest(options, targetMessage) {
    return new Promise(function (resolve, reject) {
        request(options, function (error, res, body) {
            if (!error && res.statusCode == 200) {
                // レスポンス情報をファイルに出力
                accessInfoLog(options['method'], options['url']);
                infoLog(targetMessage + 'に成功しました。', JSON.stringify(body));
                resolve({ statusCode: res.statusCode, body: body, error: null });
            } else {
                accessErrorLog(options['method'], options['url']);
                errorLog(targetMessage + 'に失敗しました。', body, JSON.stringify(options['json']));
                reject({ statusCode: (res ? res.statusCode : null), body: null, error: error });
            }
        });
    });
}

function infoLog(message, content) {
    logger.log(message);
    logger.log(content);
    logger.log('');
}

function errorLog(message, detail, content) {
    logger.error(message);
    logger.error(detail);
    logger.error(content);
    logger.error('');
    console.error(message);
    console.error(detail);
    console.error(content);
    console.error('');
} 

function accessInfoLog(method, url) {
    logger.log(method + " : " + url);
} 

function accessErrorLog(method, url) {
    logger.error(method + " : " + url);
    console.error(method + " : " + url);
} 

try {
    main();
} catch (e) {
    logger.error(e);
    console.error(e);
}
