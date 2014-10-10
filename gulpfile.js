var gulp      = require('gulp');
var coffee    = require('gulp-coffee');
var util      = require('gulp-util');
var watch     = require("gulp-watch");
var connect   = require('gulp-connect');
var plumber   = require('gulp-plumber');

gulp.task('app', function() {
  return gulp.src('game/game.coffee')
    .pipe(plumber())
    .pipe(coffee()).on('error', util.log)
    .pipe(gulp.dest('game/'));
});

gulp.task("default", ["app"], function() {
  gulp.watch("game/game.coffee", { maxListeners: 999 }, ["app"])
})

gulp.task('connect', function() {
  connect.server({
    root: 'game',
    port: 8000
  });
});