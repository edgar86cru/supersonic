module.exports =
  dir:
    dist: 'dist'
    sass: 'scss'
    fonts: 'fonts'
    src: 'src'
    tasks: 'tasks'
    test: 'test'
    testApp: "testApp/www"
    components: "components/*"
    docs: 'docs'
    docsCSS: 'docs/css'
    docsFonts: 'docs/fonts'
    docsGruntOutputDirs: [
      '<%= dir.docs %>/_data/'
      '<%= dir.docs %>/supersonic/api-reference/stable/'
    ]
  files:
    src: '<%= dir.src %>/**/*.coffee'
    test: '<%= dir.test %>/**/*Spec.coffee'
    stylesheets: '<%= dir.sass %>/**/*.*'
    components: 'components/**/*.*'
  file:
    componentImport: '<%= dir.dist %>/components/import.html'
