var _ = require('lodash');
var handleRNTargetBuildSettings = require('./handleRNTargetBuildSettings');
const defaultSearchPaths = ['"$(inherited)"'];

module.exports = function(project, path) {
  handleRNTargetBuildSettings(project, function(buildSettings) {
    var searchPaths = Array.isArray(buildSettings.FRAMEWORK_SEARCH_PATHS) ? buildSettings.FRAMEWORK_SEARCH_PATHS : defaultSearchPaths;
    buildSettings.FRAMEWORK_SEARCH_PATHS = _.concat(searchPaths, path)
  });
}
