#!/bin/bash

# This script installs openidc apache module using the debian packages
# in the git repo instead of building from source

set -xe

OPENIDC_BASEURL='https://github.com/zmartzone/mod_auth_openidc'

OPENIDC_VERSION=${OPENIDC_VERSION:-''}
PHUSION_BASEIMAGE=${PHUSION_BASEIMAGE:-''}

function get_pack() {
   pack="$1"
   oidc_version="$2"

   case "$oidc_version" in
      1.8.*|2.0.*|2.1.*|2.2.*|2.3.0|2.3.1|2.3.2)
         if [ "$pack" = 'xenial' ]; then
            # no xenial package but wily works
            pack='wily'
         elif [ "$pack" = 'bionic' ]; then
            # bionic is not supported at these versions
            pack=''
         fi
         ;;
      2.3.10.2|2.3.11.*)
         if [ "$pack" = 'trusty' ]; then
            # no trusty package.  OS is too old
            pack=''
         fi
   esac

   echo -n "$pack"
}

function get_cjose_ver() {
   oidc_version="$1"
   ver=

   case "$oidc_version" in
      2.0.*|2.1.*|2.2.*)
         ver='0.4.1'
         ;;
      2.3.1|2.3.2|2.3.3|2.3.4|2.3.5|2.3.6|2.3.7|2.3.8|2.3.9|2.3.10.*)
         ver='0.5.1'
         ;;
      2.3.11)
         ver='0.6.1.4'
         ;;
   esac

   echo -n "$ver"
}

function get_cjose_dist_ver() {
   oidc_version="$1"
   ver=

   case "$oidc_version" in
      2.0.*)
         ver='2.0.0'
         ;;
      2.1.0|2.1.1|2.1.2)
         ver='2.1.0'
         ;;
      2.1.3|2.1.4|2.1.5|2.1.6)
         ver='2.1.3'
         ;;
      2.2.0)
         ver='2.2.0'
         ;;
      2.3.11)
         ver='2.3.11'
         ;;
      2.3.*)
         ver='2.3.0'
         ;;
   esac

   echo -n "$ver"
}

function get_ubuntu_name() {
   oidc_version="$1"
   name=

   # deb package naming change after 2.2.x
   case "$oidc_version" in
      1.8.*|2.0.*|2.1.*|2.2.*)
         name='ubuntu1'
         ;;
   esac

   echo -n "$name"
}

function get_cjose_name() {
   oidc_version="$1"
   name=

   case "$oidc_version" in
      2.2.*|2.3.*)
         name='0'
         ;;
   esac

   echo -n "$name"
}

function get_cjose_name() {
   oidc_version="$1"
   name=

   case "$oidc_version" in
      2.2.*|2.3.*)
         name='0'
         ;;
   esac

   echo -n "$name"
}

function get_rel_char() {
   oidc_version="$1"
   char='.'

   case "$oidc_version" in
      2.3.8|2.3.9|2.3.10.*|2.3.11)
         char='+'
         ;;
   esac

   echo -n "$char"
}

# init var
pack=''

if [ -z "$OPENIDC_VERSION" ] || [ -z "$PHUSION_BASEIMAGE" ]; then
   echo 'MUST SET OPENIDC_VERSION AND PHUSION_BASEIMAGE env vars'
   exit 1
fi

# set initial ubuntu release code based on phusion base image version
case "$PHUSION_BASEIMAGE" in
   0.9.17|0.9.18)
      pack='trusty'
      ;;
   0.9.19|0.9.20|0.9.21|0.9.22|0.10.*)
      pack='xenial'
      ;;
   0.11)
      pack='bionic'
      ;;
esac

# override pack based on OPENIDC version
pack=$( get_pack "$pack" "$OPENIDC_VERSION" )

# var to hold added name for download URL some versions require it
#  some do not. Versions > 2.1.6 do not have additional tag in URL so the
#  default is to not supply it
ubuntu=''

# var to hold added tag for libcjose name.  Versions > 2.1.6 added a zero
# to URL name - so default has zero added
cjosename='0'

# default is CJOSE not used so null out var
CJOSE_VERSION=''

# a new cjose distro is not released every time so need to reference
#  a previous openidc release tree for cjose package
CJOSE_OPENIDC_DIST_VERSION=''

CJOSE_VERSION=$( get_cjose_ver "$OPENIDC_VERSION" )
CJOSE_OPENIDC_DIST_VERSION=$( get_cjose_dist_ver "$OPENIDC_VERSION" )
ubuntu=$( get_ubuntu_name "$OPENIDC_VERSION" )
cjosename=$( get_cjose_name "$OPENIDC_VERSION" )

# If the pack can't be figured out, just build from scratch
if [ -z "$pack" ]; then
   sh /tmp/build/build-oidc.sh
   exit 0
fi

# initialize URLs to null
CJOSE_URL=''
pack_list=''

# set URLs
rel_char=$( get_rel_char "$OPENIDC_VERSION" )
OPENIDC_URL="${OPENIDC_BASEURL}/releases/download/v${OPENIDC_VERSION}/libapache2-mod-auth-openidc_${OPENIDC_VERSION}-1${ubuntu}.${pack}${rel_char}1_amd64.deb"

rel_char=$( get_rel_char "$CJOSE_OPENIDC_DIST_VERSION" )
test ! -z "$CJOSE_VERSION" && CJOSE_URL="${OPENIDC_BASEURL}/releases/download/v${CJOSE_OPENIDC_DIST_VERSION}/libcjose${cjosename}_${CJOSE_VERSION}-1${ubuntu}.${pack}${rel_char}1_amd64.deb"

# Download packages
if [ ! -z "$OPENIDC_URL" ]; then
   echo "downloading OPENIDC version (${OPENIDC_VERSION}) ${pack} debian package"
   curl -L -o /tmp/libapache2-mod-auth-openidc.deb "$OPENIDC_URL"
   pack_list="${pack_list} /tmp/libapache2-mod-auth-openidc.deb"
fi

if [ ! -z "${CJOSE_URL}" ]; then
   echo "downloading CJOSE version (${CJOSE_VERSION}) ${pack} debian package"
   curl -L -o /tmp/libcjose.deb "$CJOSE_URL"
   pack_list="${pack_list} /tmp/libcjose.deb"
fi

# test -z "$pack_list" && echo 'Missing openidc packages - ERROR' && exit 1

echo 'Installing packages for openidc'
if [ -z "$pack_list" ]; then
   sh /tmp/build/build-oidc.sh
else
   # since dpkg install will return non-zero due to not able to
   # satisfy dependencies just yet need to add the echo to force zero exit status
   dpkg -i $pack_list || echo

   # Now to satisfy dependencies need to run apt install command
   apt-get -f -y --no-install-recommends install
fi
