module.exports = function (context) {
  var shell = require('shelljs');
  shell.cd(context.opts.plugin.dir);
  shell.exec('npm install');
};
