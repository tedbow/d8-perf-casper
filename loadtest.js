/**
 * Created by ted on 4/6/16.
 */

var casper = require('casper').create();
var helpy = require('./dohelpy');
var xhprof = casper.cli.get('xhprof');
if (casper.cli.get('login')) {
  casper.echo('Logging in');
  casper.start(helpy.buildUrl('user/login'), helpy.login('admin', 'pass'));
}
else {
  casper.start(helpy.buildUrl(''), function () {});
}

casper.thenOpen(helpy.buildUrl('load-test-nodes', {
  "xhprof_on" : xhprof
}), function () {
  this.echo(this.getTitle());

});
casper.thenOpen(helpy.buildUrl('load-test-users', {
  "xhprof_on" : xhprof
}), function () {
  this.echo(this.getTitle());

});
casper.thenOpen(helpy.buildUrl('load-test-terms', {
  "xhprof_on" : xhprof
}), function () {
  this.echo(this.getTitle());

});
/*
casper.thenOpen(helpy.buildUrl('', {
  "xhprof_on" : "1"
}), function (response) {
  nextLink = helpy.findXHProfLink.call(this);
  this.thenOpen(nextLink, function () {
    helpy.getFunctionsAndMemoryFromXHProf.call(this);
  });
});
*/
casper.run();

