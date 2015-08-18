#!/bin/sh

set -e

export LANG=C
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export TZ=America/New_York

# update ClientID
if [ -z "$CLIENTID" ] ; then
    exit 1
fi

# update ClientSecret
if [ -z "$CLIENTSECRET" ] ; then
    exit 2
fi

# update SERVER_ADMIN
if [ -z "$SERVER_ADMIN" ] ; then
    export SERVER_ADMIN=devops@broadinstitute.org
fi

# update SERVER_NAME
if [ -z "$SERVER_NAME" ] ; then
    export SERVER_NAME=localhost
fi

# update CALLBACK_URI
if [ -z "$CALLBACK_URI" ] ; then
    export CALLBACK_URI="https://${SERVER_NAME}/oauth2callback"
fi

# update CALLBACK_PATH
if [ -z "$CALLBACK_PATH" ] ; then
    export CALLBACK_PATH=/`echo $CALLBACK_URI | rev | cut -d/ -f1 | rev`
fi

# update OIDC_CLAIM
if [ -z "$OIDC_CLAIM" ] ; then
    export OIDC_CLAIM='Require claim hd:broadinstitute.org'
elif [ "$OIDC_CLAIM" == '(none)' ]; then
    export OIDC_CLAIM=
fi

# update OIDC_COOKIE
if [ -z "$OIDC_COOKIE" ] ; then
    export OIDC_COOKIE='prometheus_session'
fi

# update LOG_LEVEL
if [ -z "$LOG_LEVEL" ] ; then
    export LOG_LEVEL=warn
fi

# update OIDC_SCOPES
if [ -z "$OIDC_SCOPES" ] ; then
    export OIDC_SCOPES='openid email profile'
fi

# set httpd port
if [ -z "$HTTPD_PORT" ] ; then
    export HTTPD_PORT=80
fi

# set httpd ssl port
if [ -z "$SSL_HTTPD_PORT" ] ; then
    export SSL_HTTPD_PORT=443
fi

# update PROXY_PATH
if [ -z "$PROXY_PATH" ] ; then
    export PROXY_PATH=/
fi

# update PROXY_PATH2
if [ -z "$PROXY_PATH2" ] ; then
    export PROXY_PATH2=/api
fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

exec /usr/sbin/apachectl -DNO_DETACH -DFOREGROUND 2>&1
