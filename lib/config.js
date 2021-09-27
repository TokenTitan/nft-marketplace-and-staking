const fs = require('fs')
const path = require('path');

const setEnv = async (key, val) => {
  let parsedFile = JSON.parse(fs.readFileSync(path.resolve("config.json"), 'utf8'));
  parsedFile[key] = val
  fs.writeFileSync(path.resolve("config.json"), JSON.stringify(parsedFile, null, 2))
}

module.exports = { setEnv };