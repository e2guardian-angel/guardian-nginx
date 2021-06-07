#!/bin/sh

GUARDIAN_CONF=/opt/guardian/conf/guardian.json
NGINX_CONF_DIR=/etc/nginx
# Assume https disabled by default
NGINX_CONF=${NGINX_CONF_DIR}/nginx-http.conf

extract_value () {
    echo "${1}" | jq -r .${2}
}

if [ -f "${GUARDIAN_CONF}" ]; then
    CONFIG="$(cat $GUARDIAN_CONF)"
    HTTPS_ENABLED=$(extract_value "${CONFIG}" httpsEnabled)
    if [ "${HTTPS_ENABLED}" = "true" ]; then
	export NGINX_CONF=${NGINX_CONF_DIR}/nginx-https.conf
    else
	export NGINX_CONF=${NGINX_CONF_DIR}/nginx-http.conf
    fi
fi
echo $NGINX_CONF

/usr/sbin/nginx -c ${NGINX_CONF}

