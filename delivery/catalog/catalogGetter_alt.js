// カタログ登録
// catalogRegister.js
var fs = require('fs');
var path = require('path');
var request = require('request');
var headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
    'session': JSON.stringify({
        sessionId: 'sessionId',
        operatorId: 1,
        type: 3,
        loginId: 'loginid',
        name: 'test-user',
        mobilePhone: '0311112222',
        auth: {
            add: true,
            update: true,
            delete: true
        },
        lastLoginAt: '2020-01-01T00:00:00.000+0900',
        attributes: {},
        roles: [
            {
                _value: 1,
                _ver: 1
            }
        ],
        block: {
            _value: 1000110,
            _ver: 1
        },
        actor: {
            _value: 1000001,
            _ver: 1
        }
    })
};

// ローカル環境
var protocol = process.argv.length > 2 ? process.argv[2] : 'http';
var host = process.argv.length > 3 ? process.argv[3] : 'localhost';
var port = process.argv.length > 4 ? process.argv[4] : '3001';
var firstPath = process.argv.length > 5 ? process.argv[5] : '/catalog';

if (! fs.existsSync('logs')) {
    fs.mkdirSync('logs', { recursive: true }, (err) => {
        if (err) throw err;
    });
}
if (! fs.existsSync('logs/catalog')) {
    fs.mkdirSync('logs/catalog', { recursive: true }, (err) => {
        if (err) throw err;
    });
}
if (! fs.existsSync('logs/error')) {
    fs.mkdirSync('logs/error', { recursive: true }, (err) => {
        if (err) throw err;
    });
}
let now = new Date();
let time = ('0000' + now.getFullYear()).slice(-4) + ('00' + (now.getMonth() + 1)).slice(-2) + ('00' + now.getDate()).slice(-2) + '_' +
    ('00' + now.getHours()).slice(-2) + ('00' + now.getMinutes()).slice(-2) + ('00' + now.getSeconds()).slice(-2);
let errFile = './logs/error/' + time + '.log';
fs.writeFileSync(errFile, '');
var err = fs.createWriteStream(errFile);
var logger = console.Console(err);

// カタログ出力用ディレクトリ生成
fs.mkdirSync('logs/catalog/' + time);

async function main() {
    // まずmodelを掘る。以下はメソッド化してbuilt_in, extでも同じものを使用する
    // let catalogItems = await search('model', 'model');
    // catalogItems = catalogItems.concat(await search('built_in', 'built_in'));
    // catalogItems = catalogItems.concat(await search('ext', 'ext'));
    // let targetCodes = [];

    // for (let catalogItem of catalogItems) {
    //     try {
    //         let catalogItemJson = require(catalogItem);
    //         if (catalogItemJson['catalogItem'] && catalogItemJson['catalogItem']['_code']) {
    //             targetCodes.push(catalogItemJson['catalogItem']['_code']['_value']);
    //         }
    //     } catch (e) {
    //         errorLog('ファイルが取得できませんでした。', e, JSON.stringify(catalogItem));
    //     }
    // }

    // targetCodes.sort(function (a, b) {
    //     if (a !== a && b !== b) return 0;
    //     if (a !== a) return 1;
    //     if (b !== b) return -1;

    //     if (a == null && b == null) return 0;
    //     if (a == null) return 1;
    //     if (b == null) return -1;

    //     if (a === '' && b === '') return 0;
    //     if (a === '') return 1;
    //     if (b === '') return -1;

    //     if (a > b) return 1;
    //     if (a < b) return -1;
    //     return 0;
    // });
    /*
        select max(code) from pxr_catalog.catalog_item where code <= 10000;
        select max(code) from pxr_catalog.catalog_item where code <= 20000;
        select max(code) from pxr_catalog.catalog_item where code <= 30000;
        select max(code) from pxr_catalog.catalog_item where code <= 1000000;
        select max(code) from pxr_catalog.catalog_item;
    */
    let targetCodes = [];
    // for (let i = 1; i <= 138; i++) {
    //     targetCodes.push(i);
    // }
    // for (let i = 10001; i <= 10060; i++) {
    //     targetCodes.push(i);
    // }
    // for (let i = 20001; i <= 20052; i++) {
    //     targetCodes.push(i);
    // }
    // for (let i = 30001; i <= 30035; i++) {
    //     targetCodes.push(i);
    // }
    // for (let i = 1000001; i <= 1000424; i++) {
    //     targetCodes.push(i);
    // }
    // for (let i = 1000008; i <= 1000009; i++) {
    //     targetCodes.push(i);
    // }
    // for (let i = 1000074; i <= 1000077; i++) {
    //     targetCodes.push(i);
    // }
    for (let i = 1001097; i <= 1001098; i++) {
        targetCodes.push(i);
    }

    // 処理時間測定開始
    const performance = require('perf_hooks').performance;
    const start = performance.now();
    for (let targetCode of targetCodes) {
        let catalogOptions = {
            url: protocol + '://' + host + ':' + port + firstPath + '/' + targetCode,
            method: 'GET',
            headers: headers
        };

        try {
            await execRequest(catalogOptions, targetCode);
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
    process.chdir('./' + dir);

    //ファイルリストを取得
    let files;
    try {
        files = fs.readdirSync('.').filter(function (file) {
            return fs.statSync(file).isFile();
        });
    } catch (e) {
        throw Error('search - ファイルリストが取得できません。');
    }

    // ns.jsonが存在すれば登録
    let nsJsonFile = files.filter(function (file) {
        return file === 'ns.json';
    });
    if (nsJsonFile.length === 1) {
        // カタログ定義jsonの取得
        let catalogJsonFiles = files.filter(function (file) {
            return /.*\_item\.json/.test(file);
        });
        // ネーム取得
        for (let catalogJsonFile of catalogJsonFiles) {
            catalogItems.push(path.resolve('./' + catalogJsonFile));
        }
    }

    // 下位ディレクトリが存在するならば探索
    let lowerDirs;
    try {
        lowerDirs = fs.readdirSync('.').filter(function (dir) {
            return fs.statSync(dir).isDirectory();
        });
    } catch (e) {
        throw Error('search - ディレクトリリストが取得できません。');
    }

    // 順に呼出して同じ処理を実行する
    for (let lowerDir of lowerDirs) {
        catalogItems = catalogItems.concat(await search(catalogType, lowerDir));
    }

    process.chdir('./..');
    return catalogItems;
}

function execRequest(options, targetCode) {
    return new Promise(function (resolve, reject) {
        request(options, function (error, res, body) {
            if (!error && res.statusCode == 200) {
                bodyJson = JSON.parse(body);
                // fs.writeFileSync('./logs/catalog/' + time + '/' + ( '0000000' + targetCode ).slice( -7 ) + '.json', JSON.stringify(bodyJson, null, '    '));
                ns = (bodyJson['catalogItem']['ns']).replace(/\//gi, '_');
                name = (bodyJson['catalogItem']['name']).replace(/\//gi, '_').replace(/\*/gi, '_');
                code = bodyJson['catalogItem']['_code']['_value'];
                fs.writeFileSync('./logs/catalog/' + time + '/' + ns + '_' + code + '_' + name + '.json', JSON.stringify(bodyJson, null, '    '));
                resolve({ statusCode: res.statusCode, body: body, error: null });
            } else {
                accessErrorLog(options['method'], options['url']);
                errorLog('_code: ' + targetCode + ' のカタログ取得に失敗しました。', body, JSON.stringify(options['json']));
                reject({ statusCode: res.statusCode, body: null, error: body });
            }
        });
    });
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
