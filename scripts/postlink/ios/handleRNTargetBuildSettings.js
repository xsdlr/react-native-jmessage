
module.exports = function (project, cb) {
  const config = project.pbxXCBuildConfigurationSection();

  Object
    .keys(config)
    .filter(ref => ref.indexOf('_comment') === -1)
    .forEach(ref => {
      const buildSettings = config[ref].buildSettings;
      const shouldVisitBuildSettings = (
          Array.isArray(buildSettings.OTHER_LDFLAGS) ?
            buildSettings.OTHER_LDFLAGS :
            []
        )
        .indexOf('"-lc++"') >= 0;
      if (shouldVisitBuildSettings) {
        cb(buildSettings);
      }
    });
};
