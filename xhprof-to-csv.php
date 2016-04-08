#!/usr/bin/env php
<?php

$whitelist = [
  "main()",
  "MemcachePool::get",
  "PDOStatement::execute",
  "PDO::commit",
  "DatabaseStatementBase::execute",
  "InsertQuery_mysql::execute",
  "SelectQuery::execute",
  "db_query",
  "UpdateQuery::execute",
  "DeleteQuery::execute",
  "DatabaseConnection_mysql::queryRange",
  "DatabaseConnection::pushTransaction",
  "DatabaseConnection_mysql::popCommittableTransactions",
  "MergeQuery::execute",
];

function xhprof_raw_format_to_call_records($run_id, $raw_xhprof, $whitelist, $params = []) {
  $calls = [];


  foreach ($raw_xhprof['data'] as $key => $values) {

    if ($key === 'main()') {
       $caller = "";
       $callee = "main()";
    }
    else {
      list($caller, $callee) = explode('==>', $key);
    }

    if (!in_array($callee, $whitelist)) continue;

    $calls[] = array_merge(
      ["run_id" => $run_id, "callee" => $callee, "caller" => $caller],
      $values,
      $params
    );
  }
  return $calls;
}

function xhprof_call_records_to_csv($calls, $headers = TRUE) {
  if ($headers) {
    $header = array_keys($calls[0]);
    $lines = [implode(",", $header)];
  }
  else {
    $lines = [];
  }

  foreach ($calls as $call) {
    $lines[] = implode(",", $call);
  }
  return implode(PHP_EOL, $lines).PHP_EOL;
}

function xhprof_get_params_from_options($options) {

  if (!isset($options["param"])) return [];

  $params = $options["param"];
  if (!is_array($params)) {
    $params = [$params];
  }

  $params_hash = [];
  foreach ($params as $param) {
    list($k, $v) = explode(":", $param);
    $params_hash[$k] = $v;
  }
  return $params_hash;
}

function xhprof_get_args($argv) {
  array_shift($argv);
  return array_values(
    array_filter($argv, function($arg) {
      return strpos($arg, "-") !== 0;
    })
  );
}

$longopts = ["param::"];
$options = getopt("", $longopts);

$params = xhprof_get_params_from_options($options);

$args = xhprof_get_args($argv);
$file = $args[0];
if (is_dir($file)) {
  $dir = $file;
  $files = glob("{$dir}/*.xhprof") + glob("{$dir}/*.xhprof.gz");
}
else {
  $files = [$file];
}

$headers_printed = false;
foreach ($files as $file) {
  if (!file_exists($file)) throw new RuntimeException("$file doesn't exist!");
  preg_match("/^(?<run>[^.]+)\.(?<namespace>.*)(?:\.(?<ext>xhprof)?(\.gz)?)$/", basename($file), $matches);
  $run_id = $matches['run'];

  $file = strpos($file, 'gz') === (strlen($file) - 2) ? "compress.zlib://$file" : $file;

  $raw_xhprof = @unserialize(file_get_contents($file));

  if ($raw_xhprof === FALSE) {
    continue;
  }

  $calls = xhprof_raw_format_to_call_records($run_id, $raw_xhprof, $whitelist, $params);

  if ($headers_printed) {
    print xhprof_call_records_to_csv($calls, false);
  }
  else {
    print xhprof_call_records_to_csv($calls);
    $headers_printed = true;
  }
}
