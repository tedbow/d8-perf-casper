/**
 * Created by ted on 4/5/16.
 */

"use strict";
var spawn = require("child_process").spawn
var execFile = require("child_process").execFile

var child = spawn("ls", ["-lF", "/rooot"])

child.stdout.on("data", function (data) {
  console.log("spawnSTDOUT:", JSON.stringify(data))
})
