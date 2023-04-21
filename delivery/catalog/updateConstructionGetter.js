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

// EKS環境
var protocol = 'https';
var host = 'root.test.org';
var port = '443/catalog';

// ローカル環境
// var protocol = process.argv.length > 2 ? process.argv[2] : 'http';
// var host = process.argv.length > 3 ? process.argv[3] : 'localhost';
// var port = process.argv.length > 4 ? process.argv[4] : '3001';

let now = new Date();
let fileName = ('0000' + now.getFullYear()).slice(-4) + ('00' + (now.getMonth() + 1)).slice(-2) + ('00' + now.getDate()).slice(-2) + '_' +
    ('00' + now.getHours()).slice(-2) + ('00' + now.getMinutes()).slice(-2) + ('00' + now.getSeconds()).slice(-2) + '_update';
let outFile = './logs/update/' + fileName + '.sql';
fs.writeFileSync(outFile, '');
var out = fs.createWriteStream(outFile);
var logger = console.Console(out);

var codeRanges = [
    {
        start: 1,
        end: 200
    },
    {
        start: 10001,
        end: 10100
    },
    {
        start: 20001,
        end: 20100
    },
    {
        start: 30001,
        end: 30100
    },
    {
        start: 1000001,
        end: 1000500
    }
];

async function main() {
    // codeRange
    for (let codeRange of codeRanges) {
        let index = codeRange.start;
        let LastIndex = codeRange.end;

        for (index; index <= LastIndex; index++) {
            let options = {
                url: protocol + '://' + host + ':' + port + '/catalog/' + index,
                method: 'GET',
                headers: headers
            };
            await execRequest(options, index);
        }
    }
}

function execRequest(options, index) {
    return new Promise(function (resolve, reject) {
        request(options, function (error, res, body) {
            if (!error && res.statusCode == 200) {
                logger.log('UPDATE pxr_catalog.catalog_item set construction = \'' + body + '\' where code = ' + index + ';');
                resolve({ statusCode: res.statusCode, body: body, error: null });
            } else if (!error && res.statusCode == 204) {
                resolve({ statusCode: res.statusCode, body: body, error: null });
            } else {
                console.error('想定外のエラーです: ' + options['url']);
                reject({ statusCode: res.statusCode, body: null, error: body });
            }
        });
    });
}

try {
    main();
} catch (e) {
    console.error(e);
}
