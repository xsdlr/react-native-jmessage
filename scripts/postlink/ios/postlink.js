var fs = require('fs');
var glob = require('glob');
var inquirer = require('inquirer');
var xcode = require('xcode');
var path = require('path');
var plist = require('plist');
var _ = require('lodash');
var Promise = require('promise');
var addFrameworkSearchPath = require('./addFrameworkSearchPath');
var addFramework = require('./addFramework');
var package = require('../../../../../package.json');

var ignoreNodeModules = { ignore: 'node_modules/**' };
var appDelegatePaths = glob.sync("**/AppDelegate.m", ignoreNodeModules);
var appDelegatePath = findFileByAppName(appDelegatePaths, package ? package.name : null) || appDelegatePaths[0];
var plistPath = glob.sync(path.join(path.dirname(appDelegatePath), "*Info.plist").replace(/\\/g, "/"), ignoreNodeModules)[0];
var appDelegateContents = fs.readFileSync(appDelegatePath, "utf8");
var plistContents = fs.readFileSync(plistPath, "utf8");

module.exports = function() {
  addCustomFramework(['JMessage.framework', 'JMessage.framework/jcore-ios-1.1.0.a']);
  addPlistConfig();
  addHeaderImport();
  modifyCode();
}

function addCustomFramework(fpaths) {
  var pluginPath = '../node_modules/react-native-jmessage/ios/RCTJMessage';
  var projectPath = glob.sync('**/project.pbxproj', ignoreNodeModules)[0];
  var project = xcode.project(projectPath);
  var frameworkPaths = fpaths.map(function(fpath) { return path.join(pluginPath, fpath); });
  project.parse(function(error) {
    if (error) {
      console.log('xcode project parse error', error);
      return;
    }
    var target = project.getFirstTarget().uuid;
    frameworkPaths.forEach(function(frameworkPath) {
      addFramework.call(project, frameworkPath, {customFramework: true, target: target, rnProject: true});
    });
    addFrameworkSearchPath(project, '"$(SRCROOT)/' + pluginPath + '/**"');
    fs.writeFileSync(projectPath, project.writeSync());
  });
}

function addPlistConfig() {
  if (!plistPath) {
    console.log("Couldn't find .plist file");
    return;
  }
  var parsedInfoPlist = plist.parse(plistContents);
  Promise.resolve().then(function() {
    //add JiguangAppKey
    return promptPlistValue(parsedInfoPlist, {
      key: 'JiguangAppKey',
      defaultValue: 'jiguang-app-key',
      existMessage: `"JiguangAppKey" already specified in the plist file.`,
      promptMessage: 'What is your JMessage app key for iOS (hit <ENTER> to ignore)',
    });
  }).then(function() {
    //add JiguangMasterSecret
    return promptPlistValue(parsedInfoPlist, {
      key: 'JiguangMasterSecret',
      defaultValue: 'jiguang-master-secret',
      existMessage: `"JiguangMasterSecret" already specified in the plist file.`,
      promptMessage: 'What is your JMessage master secret for iOS (hit <ENTER> to ignore)',
    });
  }).then(function() {
    //add JiguangAppChannel
    parsedInfoPlist.JiguangAppChannel = '';
    plistContents = plist.build(parsedInfoPlist);
    writePatches();
  });
}

function promptPlistValue(parsedInfoPlist, opt) {
  var key = opt.key;
  if (parsedInfoPlist[key]) {
    console.log(opt.existMessage);
    writePatches();
    return Promise.resolve();
  } else {
    return inquirer.prompt({
        type: 'input',
        name: key,
        message: opt.promptMessage
    }).then(function(answer) {
        parsedInfoPlist[key] = answer[key] || opt.defaultValue;
        plistContents = plist.build(parsedInfoPlist);
        writePatches();
    });
  }
}

function writePatches() {
    fs.writeFileSync(appDelegatePath, appDelegateContents);
    fs.writeFileSync(plistPath, plistContents);
}

function findFileByAppName(array, appName) {
    if (array.length === 0 || !appName) return null;
    for (var i = 0; i < array.length; i++) {
        var path = array[i];
        if (path && path.indexOf(appName) !== -1) {
            return path;
        }
    }
    return null;
}

function addHeaderImport() {
  var jmessageHeaderImportStatement = `#import "RCTJMessageModule.h"`;
  if (~appDelegateContents.indexOf(jmessageHeaderImportStatement)) {
    console.log(`"RCTJMessageModule.h" header already imported.`);
  } else {
    var appDelegateHeaderImportStatement = `#import "AppDelegate.h"`;
    appDelegateContents = appDelegateContents.replace(appDelegateHeaderImportStatement,
      `${appDelegateHeaderImportStatement}\n${jmessageHeaderImportStatement}`);
  }
}

function modifyCode() {
  var oldJsCodeStatement = appDelegateContents.match(/(NSURL \*jsCodeLocation;\s*)/)[1];
  var newJsCodeStatement =
    "[JMessage registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];\n" +
    "\t#ifdef DEBUG\n" +
    "\t[RCTJMessageModule setupJMessage:launchOptions apsForProduction:false category:nil];\n" +
    "\t#else\n"+
    "\t[RCTJMessageModule setupJMessage:launchOptions apsForProduction:true category:nil];\n" +
    "\t#endif\n\t";

  if (~appDelegateContents.indexOf(newJsCodeStatement)) {
      console.log('JMessage init code already insert.');
  } else {
      appDelegateContents = appDelegateContents.replace(oldJsCodeStatement,
          newJsCodeStatement + oldJsCodeStatement);
  }
}
