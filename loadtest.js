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
var requests = casper.cli.get('requests');
if (requests == null) {
  requests = 1;
}

if (login) {
  casper.echo('Logging in');
  helpy.login(casper, 'admin', 'pass');
 /* casper.start(helpy.buildUrl('user/login'));
  casper.then(function () {
    helpy.login(casper, 'admin', 'pass');
  }) */
}
else {
  login = 0;
  casper.start(helpy.buildUrl(''));
}
var testPathes = ['load-test-nodes', 'load-test-users', 'load-test-terms'];
for (i = 0; i < testPathes.length; i++) {
  for (r = 0; r < requests; r++) {
    helpy.loadAndLog(casper, testPathes[i], xhprof, login, csv_extra);
  }

}
casper.run();

