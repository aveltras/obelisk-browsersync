const gulp = require('gulp');
const path = require('path');
const browserSync = require('browser-sync').create();
const { exec, spawn } = require('child_process');
const concat = require('gulp-concat');
const postcss = require('gulp-postcss');
const postcssPresetEnv = require('postcss-preset-env');
const postcssImport = require('postcss-import');
const postcssNested = require('postcss-nested');
const cssnano = require('cssnano');

const regexAsset = 'static/([a-z0-9]+)-([a-z0-9]+)\.([a-z]+)';

function browserSyncInit(done) {
  browserSync.init({
    port: 3000,
    notify: false,
    open: false,
    serveStatic: [path.join(__dirname, 'build')],
    rewriteRules: [
      {
        match: new RegExp(regexAsset),
        fn: function(req, res, match) {
          return match.replace(/static\/[a-z0-9]+-([a-z0-9]+)\.([a-z]+)/g, '/$1.$2');
        }
      }
    ],
    proxy: {
      target: "localhost:8000",
      ws: true
    }
  });  
  done();
}

function browserSyncReload(done) {
  browserSync.reload();
  done();
}

function dumpJsaddle(done) {
  exec('curl http://localhost:8000/jsaddle/jsaddle.js -o ./build/jsaddle/jsaddle.js --create-dirs');
  exec('sed -i \'s/localhost:8000/localhost:3000/g\' ./build/jsaddle/jsaddle.js');
  done();
}

function watchFiles() {
  gulp.watch("./assets/**/*.css", { ignoreInitial: false }, css);
  gulp.watch("./build/**/*", browserSyncReload);
  gulp.watch("./ghcid-output.txt", dumpJsaddle);
}

function css() {
  return gulp.src('./assets/main.css')
    .pipe(postcss([
      postcssImport(),
      postcssNested(),
      cssnano(),
      postcssPresetEnv(),
    ]))
    .pipe(concat('all.css'))
    .pipe(gulp.dest('./build'));
}

function direnv(done) {
  exec('touch release.nix');
  done();
}

function ghcid(done) {
  spawn('ob', ['run'])
    .stdout.on('data', (data) => {
    console.log(`\x1b[31m ${data}`);
  });
  
  done();
}

const build = gulp.series(css);
const watch = gulp.parallel(ghcid, browserSyncInit, watchFiles);

exports.watch = watch;
exports.ghcid = ghcid;
exports.default = build;
