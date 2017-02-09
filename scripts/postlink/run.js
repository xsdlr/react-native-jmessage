var initIOSConfig = require("./ios/postlink");
var initAndroidConfig = require("./android/postlink");

initAndroidConfig().then(function() {
  initIOSConfig();
});
