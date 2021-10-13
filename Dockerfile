FROM phusion/baseimage:0.11

ENV DEBIAN_FRONTEND=noninteractive \
    OPENIDC_VERSION=2.3.11 \
    LIBOAUTH2_VERSION=1.4.2 \
    OAUTH2_VERSION=3.2.1 \
    PHUSION_BASEIMAGE=0.11 \
    TCELL_VER=2.0.2

COPY . /tmp/build

RUN apt-get update && \
    apt-get upgrade -yq && \
    apt-get install -qy --no-install-recommends apache2 curl libjansson4 telnet tzdata && \
    /tmp/build/install-oauth2.sh && \
    apt-get --only-upgrade -y install openssl ca-certificates && \
    mkdir -p /etc/service/apache2/supervise && \
    mkdir /app && \
    rm -rf /etc/service/sshd && \
    rm -f /etc/my_init.d/00_regen_ssh_host_keys.sh && \
    mv /tmp/build/run.sh /etc/service/apache2/run && \
    mv /tmp/build/override.sh /etc/apache2/override.sh && \
    mv /tmp/build/oauth2.load /etc/apache2/mods-available && \
    mv /tmp/build/oauth2.conf /etc/apache2/mods-available && \
    mv /tmp/build/ports.conf /etc/apache2/ports.conf && \
    mv /tmp/build/site.conf /etc/apache2/sites-available/site.conf && \
    /tmp/build/setup-apache.sh && \
    mv /tmp/build/itsec.conf /etc/apache2/conf-available && \
    apt-get -yq autoremove && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*
