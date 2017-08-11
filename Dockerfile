FROM phusion/baseimage:0.9.17

MAINTAINER Andrew Teixeira <teixeira@broadinstitute.org>

ENV DEBIAN_FRONTEND=noninteractive \
    OPENIDC_VERSION=1.8.6 \
    PHUSION_BASEIMAGE=0.9.17

ADD . /tmp/build

RUN apt-get update && \
    apt-get install -qy apache2 curl libjansson4 telnet && \
    /tmp/build/install-openidc.sh && \
    apt-get --only-upgrade -y install openssl && \
    mkdir -p /etc/service/apache2/supervise && \
    mkdir /app && \
    rm -rf /etc/service/sshd && \
    rm -f /etc/my_init.d/00_regen_ssh_host_keys.sh && \
    mv /tmp/build/run.sh /etc/service/apache2/run && \
    mv /tmp/build/override.sh /etc/apache2/override.sh && \
    mv /tmp/build/auth_openidc.load /etc/apache2/mods-available && \
    mv /tmp/build/auth_openidc.conf /etc/apache2/mods-available && \
    mv /tmp/build/ports.conf /etc/apache2/ports.conf && \
    mv /tmp/build/site.conf /etc/apache2/sites-available/site.conf && \
    mv /tmp/build/ca-bundle.crt /etc/ssl/certs/ca-bundle.crt && \
    /tmp/build/setup-apache.sh && \
    apt-get -yq autoremove && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*
