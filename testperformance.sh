#!/usr/bin/env bash
XHPROF_DIR='/var/tmp/xhprof'
SITE_ALIAS='d8wps.dev'
DRUSH="drush @${SITE_ALIAS}"
DCONSOLE="drupal --target=${SITE_ALIAS}"
ENTITY_CNT=1000
REVISIONS_CNT=20
dt=`date '+%Y_%m_%d-%H_%M_%S'`

$DRUSH si -y --account-pass=pass
$DCONSOLE module:install performance_tester -y
#$DRUSH en xhprof_csv -y
$DCONSOLE module:install devel devel_generate -y
#$DCONSOLE xhprof_csv:summary with_mv.csv
$DRUSH genu $ENTITY_CNT
$DRUSH gent tags $ENTITY_CNT
$DRUSH genc $ENTITY_CNT --types=page
$DCONSOLE performance_tester:revisions node --count $REVISIONS_CNT

# Make first request and don't record results
casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=core --cache=cold
casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=core --cache=warm

casperjs loadtest.js --xhprof=1 --login=1 --dt=${dt} --modules=core --cache=cold
casperjs loadtest.js --xhprof=1 --login=1 --dt=${dt}  --modules=core --cache=warm
##$DCONSOLE xhprof_csv:summary with_mv.csv

#$DRUSH cr

$DRUSH si -y --account-pass=pass
$DCONSOLE module:install performance_tester -y
$DCONSOLE module:install multiversion -y
#$DRUSH en xhprof_csv -y
$DCONSOLE module:install devel devel_generate -y
#$DCONSOLE xhprof_csv:summary with_mv.csv
$DRUSH genu $ENTITY_CNT
$DRUSH gent tags $ENTITY_CNT
$DRUSH genc $ENTITY_CNT --types=page

$DCONSOLE performance_tester:revisions node --count $REVISIONS_CNT
$DCONSOLE performance_tester:revisions taxonomy_term --count $REVISIONS_CNT
$DCONSOLE performance_tester:revisions user --count $REVISIONS_CNT

# Make first request and don't record results
casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=multiversion --cache=cold
casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=multiversion --cache=warm

casperjs loadtest.js --xhprof=1 --login=1 --dt=${dt} --modules=multiversion --cache=cold
casperjs loadtest.js --xhprof=1 --login=1 --dt=${dt} --modules=multiversion --cache=warm

$DRUSH uli
exit

