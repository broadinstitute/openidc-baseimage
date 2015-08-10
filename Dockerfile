FROM phusion/baseimage:0.9.17

MAINTAINER Andrew Teixeira <teixeira@broadinstitute.org>

ENV DEBIAN_FRONTEND=noninteractive

ADD build-oidc.sh setup-apache.sh /root/

RUN apt-get update && \
    apt-get install -qy apache2 curl libcurl4 libjansson4 && \
    /root/build-oidc.sh && \
    mkdir -p /etc/service/apache2/supervise && \
    apt-get -yq autoremove && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

ADD run.sh /etc/service/apache2/run
ADD auth_openidc.load /etc/apache2/mods-available/auth_openidc.load
ADD auth_openidc.conf /etc/apache2/conf-available/auth_openidc.conf
ADD ports.conf /etc/apache2/ports.conf
ADD site.conf /etc/apache2/sites-available/site.conf
ADD ca-bundle.crt /etc/ssl/certs/ca-bundle.crt

RUN /root/setup-apache.sh
