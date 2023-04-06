var crypto = require('crypto');

function hashing (password, salt, stretch) {
  var index = 0;
  var result = password + salt;
  for (index = 0; index < stretch; index++) {
      result = crypto.createHash('sha256').update(result, 'utf8').digest('hex');
  }
  return result;
}

if (process.argv.length < 5) {
  console.log("usage: " + process.argv[0] + " " + process.argv[1] + " raw_password salt stretch_count");
  process.exit(1);
}

console.log(hashing(...process.argv.slice(2)));