var pbxFile = require('xcode/lib/pbxFile');

module.exports = function(fpath, opt) {
    var customFramework = opt && opt.customFramework == true;
    var link = !opt || (opt.link == undefined || opt.link);    //defaults to true if not specified
    var embed = opt && opt.embed;                              //defaults to false if not specified
    var rnProject = opt && opt.rnProject;                      //defaults to false if not specified

    if (opt) {
      delete opt.embed;
    }

    var file = new pbxFile(fpath, opt);

    file.uuid = this.generateUuid();
    file.fileRef = this.generateUuid();
    file.target = opt ? opt.target : undefined;

    if (this.hasFile(file.path)) return false;

    this.addToPbxBuildFileSection(file);        // PBXBuildFile
    this.addToPbxFileReferenceSection(file);    // PBXFileReference
    this.addToFrameworksPbxGroup(file);         // PBXGroup

    if (link) {
      this.addToPbxFrameworksBuildPhase(file);    // PBXFrameworksBuildPhase
    }

    if (customFramework) {

        !rnProject && this.addToFrameworkSearchPaths(file);

        if (embed) {
          opt.embed = embed;
          var embeddedFile = new pbxFile(fpath, opt);

          embeddedFile.uuid = this.generateUuid();
          embeddedFile.fileRef = file.fileRef;

          //keeping a separate PBXBuildFile entry for Embed Frameworks
          this.addToPbxBuildFileSection(embeddedFile);        // PBXBuildFile

          this.addToPbxEmbedFrameworksBuildPhase(embeddedFile); // PBXCopyFilesBuildPhase

          return embeddedFile;
        }
    }

    return file;
}
