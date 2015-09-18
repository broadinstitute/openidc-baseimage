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

# update ALLOW_HEADERS
if [ -z "$ALLOW_HEADERS" ] ; then
    export ALLOW_HEADERS='Header set Access-Control-Allow-Headers "authorization, content-type, accept, origin'
fi

# set ALLOW_HEADERS
if [ -z "$ALLOW_HEADERS2" ] ; then
    export ALLOW_HEADERS2=
fi

# update AUTH_REQUIRE
if [ -z "$AUTH_REQUIRE" ] ; then
    # backward compatibility for OIDC_CLAIM
    if [ -n "$OIDC_CLAIM" ] ; then
        export AUTH_REQUIRE=$OIDC_CLAIM
    else
        export AUTH_REQUIRE='Require valid-user'
    fi
elif [ "$AUTH_REQUIRE" = '(none)' ]; then
    export AUTH_REQUIRE=
fi

# update AUTH_REQUIRE2
if [ -z "$AUTH_REQUIRE2" ] ; then
    # backward compatibility for OIDC_CLAIM2
    if [ -n "$OIDC_CLAIM2" ] ; then
        export AUTH_REQUIRE2=$OIDC_CLAIM2
    else
        export AUTH_REQUIRE2='Require valid-user'
    fi
elif [ "$AUTH_REQUIRE2" = '(none)' ]; then
    export AUTH_REQUIRE2=
fi

# update AUTH_TYPE
if [ -z "$AUTH_TYPE" ] ; then
    export AUTH_TYPE='AuthType oauth20'
fi

# update AUTH_TYPE2
if [ -z "$AUTH_TYPE2" ] ; then
    export AUTH_TYPE2='AuthType None'
fi

# update CALLBACK_URI
if [ -z "$CALLBACK_URI" ] ; then
    export CALLBACK_URI="https://${SERVER_NAME}/oauth2callback"
fi

# update CALLBACK_PATH
if [ -z "$CALLBACK_PATH" ] ; then
    export CALLBACK_PATH=/`echo $CALLBACK_URI | rev | cut -d/ -f1 | rev`
fi

# set httpd port
if [ -z "$HTTPD_PORT" ] ; then
    export HTTPD_PORT=80
fi

# update LOG_LEVEL
if [ -z "$LOG_LEVEL" ] ; then
    export LOG_LEVEL=warn
fi

# update OIDC_COOKIE
if [ -z "$OIDC_COOKIE" ] ; then
    export OIDC_COOKIE='prometheus_session'
fi

# update PROXY_PATH
if [ -z "$PROXY_PATH" ] ; then
    export PROXY_PATH=/
fi

# update PROXY_PATH2
if [ -z "$PROXY_PATH2" ] ; then
    export PROXY_PATH2=/swagger
fi

# update OIDC_SCOPES
if [ -z "$OIDC_SCOPES" ] ; then
    export OIDC_SCOPES='openid email profile'
fi

# set httpd ssl port
if [ -z "$SSL_HTTPD_PORT" ] ; then
    export SSL_HTTPD_PORT=443
fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

exec /usr/sbin/apachectl -DNO_DETACH -DFOREGROUND 2>&1
