/**
 * Created by ted on 4/13/16.
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
casper.echo('Logging in');
helpy.login(casper, 'admin', 'pass');
casper.run();
//casper.start(helpy.buildUrl('user/login'), function () {helpy.login.call(this,'admin', 'pass')});
