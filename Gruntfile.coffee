module.exports = (grunt)->
  require('load-grunt-tasks')(grunt)
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    coffeelint:
      options:
        max_line_length:
          value: 100
          level: "warn"
      app: [
        'Gruntfile.coffee'
        'libs/**/*.coffee'
        'kladr.coffee'
      ]
    coffee:
      # для браузера
      compile:
        options:
          bare: false
          sourceMap: true
        files:
          'dist/kladr.js':[
            'kladr.coffee'
            'libs/**/*.coffee'
            '!libs/test*.coffee'
          ]
      # тесты для браузера
      # test:
      #   options:
      #     bare: true
      #     sourceMap: true
      #   files:
      #     'js/kladr.test.js':[
      #       'libs/test*.coffee'
      #     ]
    codo: options:
      # undocumented: true
      title: "Kladr"
      output: "doc"
      inputs: [
        "libs/"
      ]

    # mochaTest:
    #   spec:
    #     options:
    #       reporter: 'spec'
    #       require: 'coffee-script/register'
    #     src: ['test/**/*.coffee']
    #   md:
    #     options:
    #       reporter: 'Markdown'
    #       require: 'coffee-script/register'
    #       quiet: true
    #       captureFile: 'report.md'
    #     src: ['test/**/*.coffee']




    # uglify:
    #   main:
    #     files:
    #       'dist/kladr.min.js':[
    #         'dist/kladr.js'
    #       ]
    #   test:
    #     files:
    #       '../kladr_pages/js/kladr.min.js':[
    #         'dist/kladr.js'
    #       ]
    #   test1:
    #     files:
    #       '../kladr_pages/js/kladr.test.min.js':[
    #         'js/kladr.test.js'
    #       ]
    # concat:
    #   options:
    #     separator: '; ; ; ;;; ;;; ;;; ; ; ;'
    #   dist:
    #     src:[
    #       'js/kladr.min.js'
    #     ]
    #     dest:'js/test.min.js'
    connect:
      server:
        options:
          hostname:'localhost'
          port: 9001
          # base: 'www-root'
          livereload: true
    watch:
      config:
        options:
          livereload: true
        files: ['Gruntfile.coffee']
        tasks: ['coffeelint','coffee']
      tests:
        options:
          livereload: true
        files: ['test/*.coffee']
        tasks: ['coffeelint','mochaTest:spec' ]
      app:
        options:
          livereload: true
        files: ['kladr.coffee','libs/**/*.coffee']
        tasks: [
          'coffeelint'
          'coffee'
          'codo'
          # 'mochaTest:spec'
          # 'uglify'
          # 'concat'
        ]


  grunt.registerTask('default', [
    'coffeelint'
    'coffee'
    # 'uglify'
    # 'concat'
    'codo'
    # 'mochaTest:md'
    ])
  grunt.registerTask('serve', [
    'coffeelint'
    # 'mochaTest:spec'
    'coffee'
    'connect'
    'watch'
    ])
