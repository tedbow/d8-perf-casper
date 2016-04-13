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
var dt_str = casper.cli.get('dt');
var csv_extra = casper.cli.get('csv_extra');

if (login) {
  casper.echo('Logging in');
  casper.start(helpy.buildUrl('user/login'), helpy.login('admin', 'pass'));
}
else {
  login = 0;
  casper.start(helpy.buildUrl(''), function () {});
}

helpy.loadAndLog(casper,'load-test-nodes', xhprof, login, csv_extra);
helpy.loadAndLog(casper,'load-test-users', xhprof, login, csv_extra);
helpy.loadAndLog(casper,'load-test-terms', xhprof, login, csv_extra);
casper.run();

