# openidc-baseimage

[![Docker Hub](https://img.shields.io/docker/pulls/broadinstitute/openidc-baseimage.svg)](https://hub.docker.com/r/broadinstitute/openidc-baseimage/)
[![Docker Hub](https://img.shields.io/docker/build/broadinstitute/openidc-baseimage.svg)](https://hub.docker.com/r/broadinstitute/openidc-baseimage/)
[![Docker Repository on Quay](https://quay.io/repository/broadinstitute/openidc-baseimage/status "Docker Repository on Quay")](https://quay.io/repository/broadinstitute/openidc-baseimage)

## An Apache baseimage containing OpenIDC

This repo contains the configuration for a Docker image, based on [Phusion Baseimage][1] which has [Apache][2] installed including Ping Identity's [mod_auth_openidc][3] OpenIDC module.

## Google preparation for OpenIDC

Certain steps need to be finished in Google before one can start this container successfully.  Firstly, one must create a Google Project at [https://console.developers.google.com/](https://console.developers.google.com/).  After the project has been created, you must click on the `APIs & auth` menu item, then click `Credentials`.  For the OpenIDC module to work, you will need to click on the `Create new Client ID` button and create a new `Web application`.  You will then need the *Client ID* and *Client Secret* values for further configuration of the container.  You will also eventually need to add add the `Redirect URIs` and `JavaScript origins` to this new Client ID that will correspond to the location of this container.  The `Redirect URI` on the container defaults to **ht&#8203;tps://${SERVER_NAME}/oauth2callback**, so if you keep the default, you should be able to just substitute in the hostname of the server to get the redirect URI working.

## Quick Start

Make sure you have the `Client ID` and `Client Secret` from the above steps.  You can then run docker substituting in environment variables to fit your environment.

The environment variables recognized by the container are as follows:

* AUTH_REQUIRE: An OIDC claim to restrict access on *PROXY_PATH*.  Default: __Require all granted__
* AUTH_REQUIRE2: An OIDC claim to restrict access on *PROXY_PATH2*.  Default: __Require valid-user__
* AUTH_TYPE: The AuthType to use for *PROXY_PATH*.  Default: __AuthType None__
* AUTH_TYPE2: The AuthType to use for *PROXY_PATH2*.  Default: __AuthType oauth20__
* CALLBACK_PATH: Just the path to the callback URI, used by Apache to setup a `Location` tag.  Defaults to the path following the hostname in `CALLBACK_URI`
* CALLBACK_URI: The fully qualified callback URI.  Default: __ht&#8203;tps://SERVER_NAME/oauth2callback__
* CLIENTID: __Required parameter for openidc-connect__.  The Client ID received from the Google Cloud Console in previous steps. The container will fail to launch if this value is not set.
* CLIENTSECRET: __Required parameter for openidc-connect__.  The Client ID received from the Google Cloud Console in previous steps. The container will fail to launch if this value is not set.
* ENABLE_TCELL: Enable the [tCell][5] module for Apache.  Default: __no__
  * **Note**: For [tCell][5] to function, it needs a configuration file as described [https://docs.tcell.io/docs/server-agent-options](here).  That configuration file needs to be volume mounted into the container at `/etc/apache2/tcell_agent.config`.
* ENABLE_WEBSOCKET: Set to __yes__ to enable websocket/wstunnel module. Default: Not set (so not enabled)
* HTTPD_PORT: The non-SSL port on which to run Apache.  Default: __80__
* LOG_LEVEL: The logging level for Apache.  Default: __warn__
* OIDC_COOKIE: The name of the OIDC cookie to set for the session.  Default: __prometheus_session__
* OIDC_PROVIDER_METADATA_URL: The URL to the OpenIDC provider's well known OpenID configuration.  Default: __ht&#8203;tps://accounts.google.com/.well-known/openid-configuration__
* OIDC_SCOPES: The scopes to request from Google upon successful authentication.  Default: __openid email profile__
* PROXY_PATH: The Apache `Location` to configure without authentication.  Default: __/__
* PROXY_PATH2: The Apache `Location` to configure with OAuth2.0 authentication, which will require a valid Google token to access.  Default: __/api__
* PROXY_TIMEOUT: The Apache `ProxyTimeout` to configure timeout for proxies globally.  Default: __300__
* REMOTE_USER_CLAIM: The OIDC configuration variable OIDCRemoteUserClaim setting.  Default: __email__
* SERVER_ADMIN: The email address to use in Apache for the `ServerAdmin` value.  Default: __webmaster@example.org__
* SERVER_NAME: The hostname to use in Apache for the `ServerName` value.  Default: __localhost__
* SSL_HTTPD_PORT:  The SSL port on which to run Apache.  Default: __443__
* SSL_PROTOCOL:  The SSL protocols to use when running Apache.  Default: __-SSLv3 -TLSv1 -TLSv1.1 +TLSv1.2__
* SSL_CIPHER_SUITE:  The SSL cipher suite to use when running Apache.  Default: __ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!ADH!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA:!DH__

### Basic example

Once all these environment variables are setup correctly, you can run a fully-functional version fo the container that will be setup to communicate with Google for authentication.  The following example fills in some necessary environment variables while inheriting the defaults of others:

```sh
docker run -it --rm --name apacheoidc --hostname test.example.org \
    -e CALLBACK_URI=https://test.example.org/oauth2callback \
    -e CLIENTID=replacewithclientid \
    -e CLIENTSECRET=replacewithclientsecret \
    -e PROXY_PATH=/ \
    -e PROXY_PATH2=/api \
    -e SERVER_NAME=test.example.org \
    -p 80:80 \
    -p 443:443 \
    broadinstitute/openidc-baseimage:latest
```

**Note: This container also redirects all traffic from the non-SSL port to the SSL port to make sure all communication happens over an encrypted channel.**

### docker-compose Example with tCell

The GitHub repository [https://github.com/broadinstitute/openidc-baseimage](https://github.com/broadinstitute/openidc-baseimage) for this container also contains a [Docker Compose][4] YAML file that you can use as a template to build an OpenIDC container without the super long `docker run` line.  Here is an example `docker-compose.yml` file with [tCell][5] enabled:

```yaml
apache:
  image: broadinstitute/openidc-baseimage:latest
  ports:
    - "80:80"
    - "443:443"
  environment:
    CALLBACK_PATH: /
    CALLBACK_URI: https://test.example.org
    CLIENTID: replacewithclientid
    CLIENTSECRET: replacewithclientsecret
    ENABLE_TCELL: 'yes'
    OIDC_CLAIM: Require claim hd:example.org
    OIDC_COOKIE: example_session
    OIDC_SCOPES: openid email profile test
    PROXY_PATH: /
    PROXY_PATH2: /api
    SERVER_ADMIN: webmaster@example.org
    SERVER_NAME: test.example.org
  volumes:
    - /path/to/tcell/config.cfg:/etc/apache2/tcell_agent.config:ro
  hostname: test.example.org
```

### Override script

Since this container is inherited by several other sub-images, it has become necessary to allow sub-images to tweak Apache before starting up.  As such, we have created the ability to add in an `/etc/apache2/override.sh` script.  This script will be run after all the default actions in `/etc/service/apache2/run`, but before Apache itself is run.  Therefore, if sites need to be enabled/disabled, variables need to be checked or set, etc. that is different than what comes standard with this image, adding an `override.sh` script can do all that.  To see the specifics about where `override.sh` comes in the run order, check out the `run.sh` script in this repo.

### More security

To lock down Apache even more, we have some typical content restriction headers (X-Frame-Options, Content-Security-Policy, etc.) in an available configuration named __itsec__.  The following are the headers that are set in this configuration:

```Apache
Header always append X-Frame-Options SAMEORIGIN
Header always set X-XSS-Protection "1; mode=block"
Header always set X-Content-Type-Options: nosniff
Header set Content-Security-Policy "script-src 'self'; object-src 'self'"
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
```

#### Activating in a new image

Therefore, if you build a new image from this image, you can activate the headers by adding the following to your `Dockerfile`:

```Dockerfile
RUN a2enconf itsec
```

#### Activating in the current image

You can use the `override.sh` script to activate it with the current image:

`/path/to/override.sh`:

```sh
#!/bin/bash

a2enconf itsec
```

Then, map the override script into the container so the configuration gets activated just before Apache starts:

```yaml
apache:
  image: broadinstitute/openidc-baseimage:latest
  environment:
    CALLBACK_PATH: /
    CALLBACK_URI: https://test.example.org
    CLIENTID: replacewithclientid
    CLIENTSECRET: replacewithclientsecret
    OIDC_CLAIM: Require claim hd:example.org
    OIDC_COOKIE: example_session
  volumes:
    - /path/to/override.sh:/etc/apache2/override.sh:ro
  hostname: test.example.org
```

## Mounted Volumes

This container defaults to exposing a web application located at `/app` on the container filesystem.  Therefore, you can either inherit this image from a new image and either `COPY` or `ADD` your site into `/app` on the container, or you could mount your site in using something like __-v /path/to/site:/app__.

## Base Image

Built using the [Phusion Baseimage][1] container image.

## Branching, Building, Releasing, Tagging, Maintenance Process

### Docker Container

This Git repo is set up on DockerHub to automatically build docker images upon certain types of changes to the repo.  Currently these changes are:

* Any update to the "master" branch will initiate a build at DockerHub tagging the newly built docker image with the docker tag: "dev".  As such the "dev" docker tag will be floating - always tracking HEAD of master.
* Any git tag starting with a number and followed by any number of "dots", numbers or charaacters will initiate a build at DockerHub against the git hash assoicated with that tag.  The resulting docker container will also have a docker tag to match the git tag.

### Branching

All changes must happen on a feature branch usually based off of the git "master" branch and the name of the branch can be anything you like with one exception.  When one needs to update a released version (ie a version that has a X.Y.Z git tag) a X.Y.Z_hotfix branch must first be created (if it does not already exist) based on the git tag matching the version (X.Y.Z).  Then you must create your feature branch off of this "_hotfix" branch.  Needless to say branch names X.Y.Z_hotfix are reserved and should be treated similar to "master" git branch.  Once your feature branch has been tested, you must create a PR into the appropriate base branch.
**NOTE: feature work done against a "_hotfix" branch that is considered useful to other releases should be also applied to all "_hotfix" branches as well as to "master"**
How one performs a release will be covered in more detail in the Releasing section below

### Releasing

#### Relasing a new version of OpenIDC Proxy

New versions of openIDC proxy must be done off of the master branch.  Generally this will involve:

* creating a "feature branch" based on the HEAD of master branch
* Make the necessary changes for the new version
* build and test updates manually
* Once tested and ready, create PR into "master"
* Merge PR into master
* Create a version tag against newly merged master.  This tag will trigger the auto-build at DockerHub and actually create a "released" docker container.
* After DockerHub completes the autobuild, pull new image, re-tag with a "_latest" tag (ie X.Y.Z_latest).  This will be a floating tag that should always point to the latest docker container for that released version.

**NOTE**: in future the "latest" tag will be driven by a Jenkins job

#### Updates to a previous released OpenIDC version

Due to how the software is built, changes after a release are generally around updates to the phusion/baseimage version, patches to the underlying OS and/or additions of packages to the container.  The process consists of:

* Determine if there already exist a "_hotfix" branch associated with the version of OpenIDC proxy you need to update.
* If "_hotfix" branch exists, check out HEAD of "_hotfix" branch.  If branch does not exist, create a new version "_hotfix" (ie X.Y.Z_hotfix) based off of the X.Y.Z tag (git checkout -b X.Y.Z_hotfix X.Y.Z). Push newly created "_hotfix" branch to origin
* Create a feature branch for your changes off of the HEAD of the associated "_hotfix" branch.
* Make the necessary/desired updates on your feature branch
* build and test manually
* Once tested and ready, create a PR into the version "_hotfix" branch.
* Merge PR
* List all existing tags.  Look for tags of the form "X.Y.Z_#" and "X.Y.Z" that match the version you are updating.
** If there is no "_#" tags then the tag name will be "X.Y.Z_1"
** Find the highest "_#" number and add one - this will be your new tag name
* Create a tag for new "_#" tag - this will cause DockerHub to autobuild
* As with a new release, after the Dockerhub container is built, pull new image, re-tag with a "_latest" tag (ie X.Y.Z_latest).  This will be a floating tag that should always point to the latest docker container for that released version.

[1]: https://github.com/phusion/baseimage-docker "Phusion Baseimage"
[2]: http://httpd.apache.org/ "Apache"
[3]: https://github.com/pingidentity/mod_auth_openidc "mod_auth_openidc"
[4]: https://docs.docker.com/compose/ "Docker Compose"
[5]: https://earlyaccess.rapid7.com/tcell/ "tCell"
[6]: https://hub.docker.com/r/broadinstitute/openidc-baseimage/ "Broad OpenIDC Baseimage"
