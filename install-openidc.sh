#!/bin/bash

# This script installs openidc apache module using the debian packages
# in the git repo instead of building from source

set -xe

OPENIDC_VERSION=${OPENIDC_VERSION:-""}
PHUSION_BASEIMAGE=${PHUSION_BASEIMAGE:-""}
# init var
pack=""

if [ -z "${OPENIDC_VERSION}" ] || [ -z "${PHUSION_BASEIMAGE}" ]
then
   echo "MUST SET OPENIDC_VERSION AND PHUSION_BASEIMAGE env vars"
   exit 1
fi

# set initial ubuntu release code based on phusion base image version
case ${PHUSION_BASEIMAGE} in
   0.9.17|0.9.18) pack="trusty"
      ;;
   0.9.22|0.9.21|0.9.20|0.9.19) pack="xenial"
      ;;
esac

# default is CJOSE not used so null out var
CJOSE_VERSION=""
# a new cjose distro is not released every time so need to reference 
#  a previous openidc release tree for cjose package
CJOSE_OPENIDC_DIST_VERSION=""
# set CJOSE version and override pack based on OPENIDC version
case ${OPENIDC_VERSION} in 
   1.8.6|1.8.7|1.8.8) 
        if [ "${pack}" = "xenial" ]
        then
           # no xenial package but wiley works"
           pack="wiley"
        fi
     ;;
   2.0.0) 
        if [ "${pack}" = "xenial" ]
        then
           # no xenial package but wiley works"
           pack="wiley"
        fi
        CJOSE_VERSION="0.4.1"
        CJOSE_OPENIDC_DIST_VERSION="2.0.0"
     ;;
   2.1.0|2.1.1|2.1.2) 
        if [ "${pack}" = "xenial" ]
        then
           # no xenial package but wiley works"
           pack="wiley"
        fi
        CJOSE_VERSION="0.4.1"
        CJOSE_OPENIDC_DIST_VERSION="2.1.0"
     ;;
   2.1.3) 
        if [ "${pack}" = "xenial" ]
        then
           # no xenial package but wiley works"
           pack="wiley"
        fi
        CJOSE_VERSION="0.4.1"
        CJOSE_OPENIDC_DIST_VERSION="2.1.3"
     ;;
esac
   
if [ -z "${pack}" ]
then
    echo "ERROR could not determine distro pack value."
    exit 1
fi

# initialize URLs to null
CJOSE_URL=""
pack_list=""

# set URLs
OPENIDC_URL="https://github.com/pingidentity/mod_auth_openidc/releases/download/v${OPENIDC_VERSION}/libapache2-mod-auth-openidc_${OPENIDC_VERSION}-1ubuntu1.${pack}.1_amd64.deb"

test ! -z "${CJOSE_VERSION}" && CJOSE_URL="https://github.com/pingidentity/mod_auth_openidc/releases/download/v${CJOSE_OPENIDC_DIST_VERSION}/libcjose_${CJOSE_VERSION}-1ubuntu1.${pack}.1_amd64.deb"

# Download packages
if [ ! -z "${OPENIDC_URL}" ]
then
   echo "downloading OPENIDC version (${OPENIDC_VERSION}) ${pack} debian package"
   curl -L -o /tmp/libapache2-mod-auth-openidc.deb ${OPENIDC_URL}
   pack_list="${pack_list} /tmp/libapache2-mod-auth-openidc.deb"
fi

if [ ! -z "${CJOSE_URL}" ]
then
   echo "downloading CJOSE version (${CJOSE_VERSION}) ${pack} debian package"
   curl -L -o /tmp/libcjose.deb ${CJOSE_URL}
   pack_list="${pack_list} /tmp/libcjose.deb"
fi

test -z "${pack_list}" && echo "Missing openidc packages - ERROR" && exit 1

echo "Installing packages for openidc"

# since dpkg install will return non-zero due to not able to
# satisfy dependencies just yet need to add the echo to force zero exit status 
dpkg -i ${pack_list} || echo

# Now to satisfy dependencies need to run apt install command
apt-get -f -y install
