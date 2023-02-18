#!/bin/sh

GUARDIAN_CONF=/opt/guardian/conf/guardian.json
NGINX_CONF_DIR=/etc/nginx
NGINX_CONF=${NGINX_CONF_DIR}/nginx-https.conf

/usr/sbin/nginx -c ${NGINX_CONF}

