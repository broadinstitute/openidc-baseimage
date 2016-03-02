#!/bin/sh

set -e

export LANG=C
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export TZ=America/New_York

OVERRIDE_SCRIPT="/etc/apache2/override.sh"

# update ClientID
if [ -z "$CLIENTID" ] ; then
    export CLIENTID='none'
fi

# update ClientSecret
if [ -z "$CLIENTSECRET" ] ; then
    export CLIENTSECRET='none'
fi

# update REMOTE_USER_CLAIM
if [ -z "$REMOTE_USER_CLAIM" ] ; then
    export REMOTE_USER_CLAIM=email
fi

# update SERVER_ADMIN
if [ -z "$SERVER_ADMIN" ] ; then
    export SERVER_ADMIN=devops@broadinstitute.org
fi

# update SERVER_NAME
if [ -z "$SERVER_NAME" ] ; then
    export SERVER_NAME=localhost
fi

# update AUTH_REQUIRE
if [ -z "$AUTH_REQUIRE" ] ; then
    # backward compatibility for OIDC_CLAIM
    if [ -n "$OIDC_CLAIM" ] ; then
        export AUTH_REQUIRE="${OIDC_CLAIM}"
    else
        export AUTH_REQUIRE='Require all granted'
    fi
elif [ "$AUTH_REQUIRE" = '(none)' ]; then
    export AUTH_REQUIRE=
fi

# update AUTH_REQUIRE2
if [ -z "$AUTH_REQUIRE2" ] ; then
    # backward compatibility for OIDC_CLAIM2
    if [ -n "$OIDC_CLAIM2" ] ; then
        export AUTH_REQUIRE2="${OIDC_CLAIM2}"
    else
        export AUTH_REQUIRE2='Require valid-user'
    fi
elif [ "$AUTH_REQUIRE2" = '(none)' ]; then
    export AUTH_REQUIRE2=
fi

# update AUTH_TYPE
if [ -z "$AUTH_TYPE" ] ; then
    export AUTH_TYPE='AuthType None'
fi

# update AUTH_TYPE2
if [ -z "$AUTH_TYPE2" ] ; then
    export AUTH_TYPE2='AuthType oauth20'
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
    export PROXY_PATH2=/api
fi

# update PROXY_TIMEOUT
if [ -z "$PROXY_TIMEOUT" ] ; then
    export PROXY_TIMEOUT='300'
fi

# update PROXY_URL
if [ -z "$PROXY_URL" ] ; then
    export PROXY_URL=http://app:8080/
fi

# update PROXY_URL2
if [ -z "$PROXY_URL2" ] ; then
    export PROXY_URL2=http://app:8080/api
fi

# update OIDC_PROVIDER_METADATA_URL
if [ -z "$OIDC_PROVIDER_METADATA_URL" ] ; then
    export OIDC_PROVIDER_METADATA_URL='https://accounts.google.com/.well-known/openid-configuration'
fi

# update OIDC_SCOPES
if [ -z "$OIDC_SCOPES" ] ; then
    export OIDC_SCOPES='openid email profile'
fi

# set httpd ssl port
if [ -z "$SSL_HTTPD_PORT" ] ; then
    export SSL_HTTPD_PORT=443
fi

# set SSL protocol
if [ -z "$SSL_PROTOCOL" ] ; then
    export SSL_PROTOCOL='-SSLv3 -TLSv1 -TLSv1.1 +TLSv1.2'
fi

# set the SSL Cipher Suite
if [ -z "$SSL_CIPHER_SUITE" ] ; then
    export SSL_CIPHER_SUITE='ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-ES256-SHA:!3DES:!ADH:!DES:!DH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!EXPORT:!KRB5-DES-CBC3-SHA:!MD5:!PSK:!RC4:!aECDH:!aNULL:!eNULL'
fi

# If there is an override script, pull it in
if [ -f "${OVERRIDE_SCRIPT}" ]; then
    . $OVERRIDE_SCRIPT
fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

exec /usr/sbin/apachectl -DNO_DETACH -DFOREGROUND 2>&1
