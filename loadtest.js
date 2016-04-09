/**
 * Created by ted on 4/6/16.
 */

var casper = require('casper').create();
/*var casper = require('casper').create({
  verbose: true,
  logLevel: "debug"
});*/
var helpy = require('./dohelpy');
var xhprof = casper.cli.get('xhprof');
var login = casper.cli.get('login');
var modules = casper.cli.get('modules');
var cacheMode = casper.cli.get('cache');
var dt_str = casper.cli.get('dt');

if (!modules) {
  modules = '';
}
if (login) {
  casper.echo('Logging in');
  casper.start(helpy.buildUrl('user/login'), helpy.login('admin', 'pass'));
}
else {
  login = 0;
  casper.start(helpy.buildUrl(''), function () {});
}

helpy.loadAndLog(casper,'load-test-nodes', xhprof, login, modules, cacheMode);
helpy.loadAndLog(casper,'load-test-users', xhprof, login, modules, cacheMode);
helpy.loadAndLog(casper,'load-test-terms', xhprof, login, modules, cacheMode);
casper.run();

