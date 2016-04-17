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
REQUEST_CNT=$4
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


start=`date +%s%N`
$DCONSOLE performance_tester:revisions node --count $REVISIONS_CNT
end=`date +%s%N`

core_runtime=$((end-start))

echo "core ${core_runtime}"

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

start=`date +%s%N`
$DCONSOLE performance_tester:revisions node --count $REVISIONS_CNT
end=`date +%s%N`

mu_runtime=$((end-start))

echo "mu ${mu_runtime}"

diff_time=$((core_runtime-mu_runtime/1000))
echo "core ${core_runtime}"
echo "mu ${mu_runtime}"
echo "diff ${diff_time}"
#$DRUSH uli
exit

