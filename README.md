## Why?
Multiversion Performance Testing

@todo Update this README

For now a couple paths are hardcoded
Numbers and aliases must be updated via 



## Requirements

* [CasperJS](http://casperjs.readthedocs.org/en/latest/installation.html) [On OSX, install from Git or NPM, not Homebrew](https://www.drupal.org/node/2497185#comment-10206465).
* [xhprof-kit](https://github.com/LionsAd/xhprof-kit)
* Drupal 8 environment of your choosing.

## Configuration

Download and install [xhprof-kit](https://github.com/LionsAd/xhprof-kit). Follow the setup instructions to ensure the symlinks are in the proper places for your drupal installation. This will create an `index-perf.php` file which dohelpy.buildUrl is expecting to be there on requests it profiles.

## Calling Stuff @todo Update Section
Assuming you have the same alias for both drush(w/o @) and drupal console alias to whatever you're trying to run this against:

```bash
./testperformance.sh {alias} {entities} {revisions} 
```
## Docker Integration @todo Update Section

The `Dockerfile` provides a basic set of instructions to build a docker container which contains node, casperjs, and drush.

### Building the container @todo Update Section

The scripts assume you'll be using a drush alias in order to perform the actions against the D8 site, but it needs those to be inside the container.

Place any required drush alias files in the drush folder before building the container. Look at the [drush folder's readme](drush/readme.md) for instructions on extra parameters you might need to add.

Run `docker build -t "cthos/d8-perf-casper" .` to then build the container.

### Running the container @todo Update Section

`docker run -i -t cthos/d8-perf-casper A @drupalvm.drupalvm.dev`

#### If you're using drupalvm @todo Update Section

You might need to mount the insecure_private_key as well as add the virtual host to the hosts file (assuming it's not accessible from the web).

`docker run --add-host="drupalvm.dev:192.168.88.88" -v /Users/cthos/.vagrant.d:/root/.vagrant.d -i -t cthos/d8-perf-casper A @drupalvm.drupalvm.dev`
