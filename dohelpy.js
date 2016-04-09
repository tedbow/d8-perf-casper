var fs = require('fs');

var helpy = {
  disabledRedirects : [],
  stopIds : [],

  loadAndLog: function (casper,path, xhprof, login, modules, cacheMode) {
    casper.thenOpen(helpy.buildUrl(path, {
      "xhprof_on" : xhprof
    }), function () {
      this.echo(this.getTitle());

    });
    if (xhprof) {

      casper.thenOpen('http://xhprof-kit.wps-testing.dev', function (response) {
        nextLink = helpy.findXHProfLink.call(this);
        var runNumber = helpy.getRunNumber(nextLink);
        //
       // var runNumber = 2;
        var results = {};
        casper.thenOpen(nextLink, function () {
          results = helpy.getFunctionsAndMemoryFromXHProf.call(this);

          helpy.writeToFile(runNumber, path,login, modules, cacheMode, results);
          helpy.copyFile(runNumber);

        });

      });
    }

  },
  copyFile : function (runNumber) {
    var source = "/var/tmp/xhprof/" + runNumber + ".drupal-perf.xhprof";
    var dest = "xhprof-files/" + runNumber + ".drupal-perf.xhprof";
    fs.copy(source, dest);
  },
  getRunNumber : function (nextLink) {
    var qs = nextLink.split("?")[1];
    var parts = qs.split("&");
    for (var i = 0; i < parts.length; i++) {
      var part = parts[i];
      var keyValue = part.split("=");
      if (keyValue[0] == 'run') {
        return keyValue[1];
      }
    }
    return 'unknown';
  },
  findXHProfLink : function () {

    //var link;
    casper.thenOpen('http://xhprof-kit.wps-testing.dev', function () {
      link = casper.evaluate(function() {
        return document.querySelectorAll("ul li a");
      });
     // var link = document.querySelectorAll('a')[0].href;


    });
    link = casper.evaluate(function() {
      return document.querySelectorAll("a");
    });
    //this.echo(link[0].href);
    return link[0].href;
  },

  getFunctionsAndMemoryFromXHProf : function () {
    var functionCalls = this.evaluate(function () {
      var functionCalls = document.querySelectorAll('table td')[7];
      return functionCalls.innerHTML.replace(/\D/g,'');
    });

    var memoryUsed = this.evaluate(function () {
      var memory = document.querySelectorAll('table td')[5];
      return memory.innerHTML.replace(/\D/g,'');
    });
    var timeWall = this.evaluate(function () {
      var time = document.querySelectorAll('table td')[1];
      return time.innerHTML.replace(/\D/g,'');
    });

    //this.echo("Function calls: " + functionCalls);
    //this.echo("Memory Used: " + memoryUsed);
    //this.echo("Time wall: " + timeWall);

    var nextLink = this.getCurrentUrl();
    nextLink += "&symbol=PDOStatement::execute";
    this.thenOpen(nextLink, function () {
      // NESTING LEVEL IS GETTING OUT OF HAND.
      helpy.getPDOExecuteFromXHProf.call(this);
    });

    return {
      "memoryUsed" : memoryUsed,
      "functionCalls" : functionCalls,
      "timewall" : timeWall
    }
  },

  getPDOExecuteFromXHProf : function () {
    var PDOCalls = this.evaluate(function () {
      var PDOCalls = document.querySelectorAll('table td')[2];
      return PDOCalls.innerHTML;
    });

    //this.echo("PDO calls: " + PDOCalls);
  },

  adjustFormUrls : function () {
    this.evaluate(function () {
      var forms = document.querySelectorAll('form');
      for (var i = 0, len = forms.length; i < len; i++) {
        forms[i].action = '/index-perf.php?url=' + escape(forms[i].action);
      }
    });
  },

  disableRedirectForUrl: function (url, casper) {
    if (!this.disabledRedirects.length) {
      this.setupRedirectListeners(casper);
    }

    this.disabledRedirects.push(url);
  },

  setupRedirectListeners : function (casper) {
    var helpy = this;

    casper.on('resource.requested', function (data, net) {
      if (helpy.stopIds.indexOf(data.url) > -1) {
        console.log("Aborting " + data.url);
        net.abort();
      }
    });

    casper.on("resource.received", function(response) {
      if (response.redirectURL.indexOf('index-perf.php') > -1) {
        return;
      }
      // Only redirects?
      if (response.status !== 303 && response.status !== 302 && response.status !== 301) {
        return;
      }

      for (var x = 0, len = helpy.disabledRedirects.length; x < len; x++) {
        if (response.redirectURL.indexOf(helpy.disabledRedirects[x]) === -1) {
          continue;
        }

        console.log("adding id to stopIds: " + response.redirectURL);
        helpy.stopIds.push(response.redirectURL);
      }
    });
  },

  login : function (name, pass) {
    return function () {
      this.fill('form[id="user-login-form"]', {
        'name' : name,
        'pass' : pass // TODO: Config and shit?
      }, true);
    }
  },

  getSiteUrl : function () {
    return casper.cli.has('uri') ? casper.cli.get('uri') : 'http://wps-testing.dev';
  },

  buildUrl : function (path, options) {
    var urlBase = this.getSiteUrl();

    var query = [];

    if (!path) {
      path = '/';
    }
    //return urlBase + path;
    query.push('url=' + path);

    if (!options) {
      options = {};
    }

    if (options.disable_opcache) {
      query.push('disable_opcache=1');
    }
    if (!options.xhprof_on) {
      query.push('disable_xhprof=1');
    }
    /*else {
      query.push('disable_xhprof=0');
    }*/
    //return urlBase + path + "?" + query.join("&");
    return urlBase + '/index-perf.php' + "?" + query.join("&");
  },
  /**
   *
   * @param runNumber
   * @param path
   * @param login
   * @param modules
   * @param cacheMode
   * @param results
   *  keys = "memoryUsed","functionCalls","timewall"
   */
  writeToFile: function (runNumber, path,login, modules, cacheMode, results){
    if (login) {
      login = "loggedin";
    }
    else {
      login = "anonymous";
    }
    var lineItems = [runNumber, path,login, modules, cacheMode];
    lineItems.push(results.timewall);
    lineItems.push(results.memoryUsed);
    lineItems.push(results.functionCalls);
    var line = lineItems.join(",") + "\n";
    try {
      fs.write('results-files/results-' + dt_str + '.csv', line , 'a');
    } catch(e) {
      console.log(e);
    }

  }
};

module.exports = helpy;
