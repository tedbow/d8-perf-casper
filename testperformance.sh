#!/usr/bin/env bash
if [ "$#" -ne 3 ]
then
  echo "Usage: 1st argument is alias without @ for both drush and drupal console"
  echo "Usage: 2nd arguments is number of entities. 3rd argument is number of revisions"
  exit 1
fi

XHPROF_DIR='/var/tmp/xhprof'
SITE_ALIAS=$1
DRUSH="drush @${SITE_ALIAS}"
DCONSOLE="drupal --target=${SITE_ALIAS}"
ENTITY_CNT=$2
REVISIONS_CNT=$3
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

casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=core --cache=cold
casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=core --cache=warm

#Clear cache for cold cache test
$DRUSH CR
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

casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=multiversion --cache=cold
casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=multiversion --cache=warm

#Clear cache for cold cache test
$DRUSH CR
casperjs loadtest.js --xhprof=1 --login=1 --dt=${dt} --modules=multiversion --cache=cold
casperjs loadtest.js --xhprof=1 --login=1 --dt=${dt} --modules=multiversion --cache=warm

$DRUSH uli
exit

