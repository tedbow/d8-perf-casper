#!/usr/bin/env bash
# tl:dr;
# This scripts tests the performance of Drupal 8 Core VS Drupal 8 with Multiversion module compared installed
#
#
if [ "$#" -ne 3 ]
then
  echo "Usage: 1st argument is alias without @ for both drush and drupal console"
  echo "Usage: 2nd arguments is number of entities."
  echo "Usage: 3rd argument is number of revisions"
  exit 1
fi

# Setup Variables
SITE_ALIAS=$1
DRUSH="drush @${SITE_ALIAS}"
DCONSOLE="drupal --target=${SITE_ALIAS}"
ENTITY_CNT=$2
REVISIONS_CNT=$3
dt=`date '+%Y_%m_%d-%H_%M_%S'`

# Test 1. Drupal Core
$DRUSH si -y --account-pass=pass
$DCONSOLE module:install performance_tester -y
$DCONSOLE module:install devel devel_generate -y
# Generate Entities
$DRUSH genu $ENTITY_CNT
$DRUSH gent tags $ENTITY_CNT
$DRUSH genc $ENTITY_CNT --types=page
# Uninstall unneeded modules after generation
$DCONSOLE module:uninstall devel  -y
$DCONSOLE module:uninstall devel_generate  -y
# Create revisions for Nodes. Other entity types not supported without Multiversion
$DCONSOLE performance_tester:revisions node --count $REVISIONS_CNT
# Uninstall unneeded modules after generation
$DCONSOLE module:uninstall performance_tester  -y

# Make requests 2x logged out. 1 cold cache. 1 warm cache
casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=core --cache=cold
casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=core --cache=warm

#Clear cache for cold cache test
$DRUSH cr
# Make requests 2x logged in. 1 cold cache. 1 warm cache
casperjs loadtest.js --xhprof=1 --login=1 --dt=${dt} --modules=core --cache=cold
casperjs loadtest.js --xhprof=1 --login=1 --dt=${dt}  --modules=core --cache=warm
##$DCONSOLE xhprof_csv:summary with_mv.csv

# Test 2. Drupal Core + Multiversion
$DRUSH si -y --account-pass=pass
$DCONSOLE module:install performance_tester -y
$DCONSOLE module:install multiversion -y
# Generate Entities
$DCONSOLE module:install devel devel_generate -y
$DRUSH genu $ENTITY_CNT
$DRUSH gent tags $ENTITY_CNT
$DRUSH genc $ENTITY_CNT --types=page
# Uninstall unneeded modules after generation
$DCONSOLE module:uninstall devel  -y
$DCONSOLE module:uninstall devel_generate  -y
# Create Revisions
$DCONSOLE performance_tester:revisions node --count $REVISIONS_CNT
$DCONSOLE performance_tester:revisions taxonomy_term --count $REVISIONS_CNT
$DCONSOLE performance_tester:revisions user --count $REVISIONS_CNT
# Uninstall unneeded modules after revisions
$DCONSOLE module:uninstall performance_tester  -y

# Make requests 2x logged out. 1 cold cache. 1 warm cache
casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=multiversion --cache=cold
casperjs loadtest.js --xhprof=1 --dt=${dt} --modules=multiversion --cache=warm

#Clear cache for cold cache test
$DRUSH cr
# Make requests 2x logged in. 1 cold cache. 1 warm cache
casperjs loadtest.js --xhprof=1 --login=1 --dt=${dt} --modules=multiversion --cache=cold
casperjs loadtest.js --xhprof=1 --login=1 --dt=${dt} --modules=multiversion --cache=warm

$DRUSH uli
exit

