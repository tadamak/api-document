gulp = require 'gulp'
aglio = require 'gulp-aglio'
plumber = require 'gulp-plumber'
notify = require 'gulp-notify'
watch = require 'gulp-watch'
webserver = require 'gulp-webserver'
mockserver = require 'drakov'
minimist = require 'minimist'

paths =
  src: 'doc/*.{md,apib}',
  watch: 'doc/**/*.{md,apib,json}',
  dest: 'public'

aglioOptions =
  template: 'default',
  includePath: 'doc'

gulp.task 'doc:build', ->
  gulp.src(paths.src)
    .pipe plumber
      errorHandler: notify.onError("Error: <%= error.message %>")
    .pipe aglio(aglioOptions)
    .pipe gulp.dest(paths.dest)

gulp.task 'doc:watch', ->
  watch paths.watch, (file) ->
    console.log "#{file.event}: #{file.relative}"
    gulp.start 'doc:build'

gulp.task 'doc:server', ['doc:build'], ->
  gulp.src(paths.dest)
    .pipe webserver
      livereload: true,
      directoryListing:
        enable: true,
        path: 'public'
      open: true

mockKnownOptions =
  string: ['file', 'port', 'delay', 'key', 'cert'],
  boolean: ['stealthmode', 'disableCORS',],
  alias:
    sourceFiles: 'file',
    serverPort: 'port',
    sslKeyFile: 'key',
    sslCrtFile: 'cert'
  default:
    file: paths.src,
    port: 3001,
    delay: 200,
    stealthmode: false,
    disableCORS: false,

# $ gulp api:mock --file <apiblueprint glob>
gulp.task 'api:mock', ->
  options = minimist process.argv.slice(2), mockKnownOptions
  mockserver.run options

gulp.task 'default', ['doc:watch', 'doc:server']
