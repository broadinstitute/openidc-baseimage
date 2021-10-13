# openidc-baseimage

[![Docker Hub](https://img.shields.io/docker/pulls/broadinstitute/openidc-baseimage.svg)](https://hub.docker.com/r/broadinstitute/openidc-baseimage/)
[![Docker Hub](https://img.shields.io/docker/build/broadinstitute/openidc-baseimage.svg)](https://hub.docker.com/r/broadinstitute/openidc-baseimage/)
[![Docker Repository on Quay](https://quay.io/repository/broadinstitute/openidc-baseimage/status "Docker Repository on Quay")](https://quay.io/repository/broadinstitute/openidc-baseimage)

## An Apache baseimage containing OpenIDC

This repo contains the configuration for a Docker image, based on [Phusion Baseimage][1] which has [Apache][2] installed including Ping Identity's [mod_auth_openidc][3] OpenIDC module.

## Google preparation for OpenIDC

Certain steps need to be finished in Google before one can start this container successfully.  Firstly, one must create a Google Project at [https://console.developers.google.com/](https://console.developers.google.com/).  After the project has been created, you must click on the `APIs & auth` menu item, then click `Credentials`.  For the OpenIDC module to work, you will need to click on the `Create new Client ID` button and create a new `Web application`.  You will then need the *Client ID* and *Client Secret* values for further configuration of the container.  You will also eventually need to add add the `Redirect URIs` and `JavaScript origins` to this new Client ID that will correspond to the location of this container.  The `Redirect URI` on the container defaults to __ht&#8203;tps://${SERVER_NAME}/oauth2callback__, so if you keep the default, you should be able to just substitute in the hostname of the server to get the redirect URI working.

## Quick Start

Make sure you have the `Client ID` and `Client Secret` from the above steps.  You can then run docker substituting in environment variables to fit your environment.

The environment variables recognized by the container are as follows:

* AUTH_REQUIRE: An OIDC claim to restrict access on *PROXY_PATH*.  Default: __Require all granted__
* AUTH_REQUIRE2: An OIDC claim to restrict access on *PROXY_PATH2*.  Default: __Require valid-user__
* AUTH_TYPE: The AuthType to use for *PROXY_PATH*.  Default: __AuthType None__
* AUTH_TYPE2: The AuthType to use for *PROXY_PATH2*.  Default: __AuthType oauth2__
* CALLBACK_PATH: Just the path to the callback URI, used by Apache to setup a `Location` tag.  Defaults to the path following the hostname in `CALLBACK_URI`
* CALLBACK_URI: The fully qualified callback URI.  Default: __ht&#8203;tps://SERVER_NAME/oauth2callback__
* CLIENTID: __Required parameter for openidc-connect__.  The Client ID received from the Google Cloud Console in previous steps. The container will fail to launch if this value is not set.
* CLIENTSECRET: __Required parameter for openidc-connect__.  The Client ID received from the Google Cloud Console in previous steps. The container will fail to launch if this value is not set.
* ENABLE_TCELL: Enable the [tCell][5] module for Apache.  Default: __no__
  * __Note__: For [tCell][5] to function, it needs a configuration file as described [https://docs.tcell.io/docs/server-agent-options](here).  That configuration file needs to be volume mounted into the container at `/etc/apache2/tcell_agent.config`.
* ENABLE_WEBSOCKET: Set to __yes__ to enable websocket/wstunnel module. Default: Not set (so not enabled)
* ENVFILE: Set the path to an environment variable override file in the container.  Default: __/etc/apache2/env-override__.
  * __Note__: If the file at this path in the container does not exist, the container will just ignore this setting.
* HTTPD_PORT: The non-SSL port on which to run Apache.  Default: __80__
* LOG_LEVEL: The logging level for Apache.  Default: __warn__
* OIDC_COOKIE: The name of the OIDC cookie to set for the session.  Default: __prometheus_session__
* OIDC_PROVIDER_METADATA_URL: The URL to the OpenIDC provider's well known OpenID configuration.  Default: __ht&#8203;tps://accounts.google.com/.well-known/openid-configuration__
* OIDC_SCOPES: The scopes to request from Google upon successful authentication.  Default: __openid email profile__
* PROXY_PATH: The Apache `Location` to configure without authentication.  Default: __/__
* PROXY_PATH2: The Apache `Location` to configure with OAuth2.0 authentication, which will require a valid Google token to access.  Default: __/api__
* PROXY_TIMEOUT: The Apache `ProxyTimeout` to configure timeout for proxies globally.  Default: __300__
* PROXY_URL: The URL to which we should proxy for *PROXY_PATH*.  Default: __ht&#8203;tp://app:8080/__
* PROXY_URL2: The URL to which we should proxy for *PROXY_PATH2*.  Default: __ht&#8203;tp://app:8080/api__
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

__Note: This container also redirects all traffic from the non-SSL port to the SSL port to make sure all communication happens over an encrypted channel.__

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

[1]: https://github.com/phusion/baseimage-docker "Phusion Baseimage"
[2]: http://httpd.apache.org/ "Apache"
[3]: https://github.com/pingidentity/mod_auth_openidc "mod_auth_openidc"
[4]: https://docs.docker.com/compose/ "Docker Compose"
[5]: https://earlyaccess.rapid7.com/tcell/ "tCell"
