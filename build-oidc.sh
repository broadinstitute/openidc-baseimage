#!/bin/sh

set -e

echo "Building mod_auth_openidc from source"

echo "Installing dependencies"
apt-get install -qy apache2-dev automake gcc git libapr1-dev \
    libaprutil1-dev libcurl4-openssl-dev libjansson-dev libpcre3-dev libssl-dev \
    make pkg-config

git clone https://github.com/pingidentity/mod_auth_openidc /tmp/mod_auth_openidc

cd /tmp/mod_auth_openidc
./autogen.sh
./configure --with-apxs2=/usr/bin/apxs
make
make install

echo "Cleaning out dependencies"
apt-get remove -qy apache2-dev automake gcc libapr1-dev libaprutil1-dev \
    libcurl4-openssl-dev libjansson-dev libpcre3-dev libssl-dev make
