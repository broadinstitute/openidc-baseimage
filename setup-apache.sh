#!/bin/sh

set -e

echo "Setting up Apache environment"

# Disable default site
a2dissite 000-default
# Enable custom site
a2ensite site
# Enable required modules
a2enmod auth_openidc headers rewrite proxy proxy_http socache_shmcb ssl

# Generate a snakeoil certificate in case it's needed
openssl req -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=Massachusetts/L=Cambridge/O=Random Bits/OU=Widgets/CN=localhost/emailAddress=webmaster@example.org" \
    -keyout /etc/ssl/private/server.key \
    -out /etc/ssl/certs/server.crt

# Use the snakeoil cert as the ca-bundle.crt as well
cp /etc/ssl/certs/server.crt /etc/ssl/certs/ca-bundle.crt
