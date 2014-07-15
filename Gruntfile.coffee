module.exports = (grunt) ->
  
  target = grunt.option('target') or 'dev'
  DEBUG = target is 'dev'

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    cssmin:
      combine:
        files:
          'www/css/main.css': ['www/css/main.css']

    copy:
      build:
        cwd: 'assets'
        src: [ 'images/*' ]
        dest: 'www'
        expand: true

    connect:
      server:
        options:
          port: 3000
          useAvailablePort: true
          hostname: '*'
          base: 'www'
          # keepalive: true

    'gh-pages':
      options:
        base: 'www'
      src: ['**']

    stylus:
      compile:
        options:
          compress: !DEBUG
        files:
          'www/css/main.css': 'styles/main.styl'

    browserify:
      dist:
        files:
          'www/js/app.js': ['src/app.coffee']
        options:
          transform: ['coffeeify']
          extensions: '.coffee'

    jade:
      compile:
        options:
          data:
            DEBUG: DEBUG
        files:
          'www/index.html': ['views/index.jade']

    uglify:
      options:
        mangle: false
        nonull: true
        banner: '/*! <%= pkg.name %> <%= grunt.template.today(\'yyyy-mm-dd HH:mm:ss\') %> */\n'
      lib:
        files:
          'www/js/lib.js': [
            'bower_components/lodash/dist/lodash.js'
            'bower_components/jquery/dist/jquery.js'
            'bower_components/angular/angular.js'
            'bower_components/d3/d3.js'
          ]
      prod:
        src: ['www/js/lib.js', 'www/js/app.js']
        dest: 'www/js/app.min.js'

    autoprefixer:
      options: {}     
      no_dest:
        src: 'www/css/main.css'

    watch:
      stylus:
        files: ['styles/**/*.styl']
        tasks: ['stylus']
      browserify:
        files: ['src/**/*.coffee']
        tasks: ['browserify']
      jade:
        files: ['views/**/*.jade']
        tasks: ['jade']
      livereload:
        options:
          livereload: true
        files: [
          'www/css/main.css'
          'www/index.html'
          'www/js/app.js'
        ]

  grunt.loadNpmTasks 'grunt-autoprefixer'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-gh-pages'

  grunt.registerTask 'default', ['browserify', 'stylus', 'jade', 'uglify', 'autoprefixer', 'copy']
  grunt.registerTask 'server', ['connect', 'watch']
