gulp = require 'gulp'
aglio = require 'gulp-aglio'
plumber = require 'gulp-plumber'
notify = require 'gulp-notify'
watch = require 'gulp-watch'
webserver = require 'gulp-webserver'
mockserver = require 'api-mock'
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
  string: ['file', 'port'],
  alias:
    f: 'file',
    p: 'port'
  default:
    port: 3001

# $ gulp api:mock --file <apiblueprint>
gulp.task 'api:mock', ->
  options = minimist process.argv.slice(2), mockKnownOptions
  new mockserver
    blueprintPath: "doc/#{options.file}",
    options:
      color: options.color,
      port: options.port
  .run()
  console.log "Mockserver started at http://localhost:#{options.port}"

gulp.task 'default', ['doc:watch', 'doc:server']
