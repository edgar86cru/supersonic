###

Default Gruntfile for AppGyver Steroids
http://www.appgyver.com
Licensed under the MIT license.

###

module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-steroids"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-shell"

  grunt.loadTasks(__dirname + "/node_modules/grunt-steroids/tasks/module-env")

  grunt.initConfig
    clean:
      "supersonic-dist":
        "#{__dirname}/bower_components/supersonic/"
    copy:
      "supersonic-dist":
        expand: true
        cwd: "../dist/"
        src: "**/*.*"
        dest: "#{__dirname}/bower_components/supersonic/"
    shell:
      "supersonic-build":
        command: "grunt build-dist"
        options:
          execOptions:
            cwd: '..'

  grunt.registerTask "default", [
    "shell:supersonic-build"
    "clean:supersonic-dist"
    "copy:supersonic-dist"
    "steroids-make-fresh"
    "steroids-copy-module-dependencies"
  ]
