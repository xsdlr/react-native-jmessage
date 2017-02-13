var fs = require("fs");
var glob = require("glob");
var path = require("path");
var inquirer = require('inquirer');
var Promise = require('promise');

var buildGradlePath = path.join(__dirname,'../','../','../','./android/build.gradle');

module.exports = function addGradleConfig() {
  return Promise.resolve().then(function() {
    //add JiguangAppKey
    return promptGradleValue(buildGradlePath, {
      key: 'JiguangAppKey',
      findKey: '${JIGUANG_APPKEY}',
      defaultValue: 'jiguang-app-key',
      existMessage: '"JiguangAppKey" already specified in the gradle file.',
      promptMessage: 'What is your JMessage app key for android (hit <ENTER> to ignore)',
    });
  }).then(function() {
    //add JiguangMasterSecret
    return promptGradleValue(buildGradlePath, {
      key: 'JiguangMasterSecret',
      findKey: '${JIGUANG_MASTER_SECRET}',
      defaultValue: 'jiguang-master-secret',
      existMessage: '"JiguangMasterSecret" already specified in the gradle file.',
      promptMessage: 'What is your JMessage master secret for android (hit <ENTER> to ignore)',
    });
  });
}

function promptGradleValue(buildGradlePath, opt) {
  var key = opt.key;
  var buildGradleContents = fs.readFileSync(buildGradlePath, "utf8");
  if (!~buildGradleContents.indexOf(opt.findKey)) {
    console.log(opt.existMessage);
    return Promise.resolve();
  } else {
    return inquirer.prompt({
        type: 'input',
        name: key,
        message: opt.promptMessage
    }).then(function(answer) {
        writeGradleFile(buildGradleContents, opt.findKey, answer[key] || opt.defaultValue);
    });
  }
}

function writeGradleFile(buildGradleContents, findKey, newValue) {
    var content = buildGradleContents.replace(findKey, `"${newValue}"`);
    fs.writeFileSync(buildGradlePath, content);
}
