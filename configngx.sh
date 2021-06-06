#!/bin/sh

GUARDIAN_CONF=/opt/guardian/guardian.json

HTTPS_SERVER_BLOCK="server {
        listen 443 ssl default_server;
        listen [::]:443 ssl default_server;
        ssl_certificate /opt/guardian/ssl/public.crt;
        ssl_certificate_key /opt/guardian/ssl/private.pem;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location /api {
                proxy_pass http://127.0.0.1:3000/api;
        }
        location /ui {
                proxy_pass http://127.0.0.1:3000/ui;
        }
}"

CERT_LOCATION="location /cert {
                proxy_pass http://127.0.0.1:3000/cert;
        }"

SETUP_LOCATION="location /setup {
                proxy_pass http://127.0.0.1:3000/cert;
        }"

extract_value () {
    echo "${1}" | jq -r .${2}
}

if [ -f "${GUARDIAN_CONF}" ]; then
    CONFIG="$(cat $GUARDIANCONF)"
    NGINX_CONF_FILE=/etc/nginx/conf.d/default.conf
    HTTPS_ENABLED=$(extract_value "${CONFIG}" httpsEnabled)
    CONFIGURED=$(extract_value "${CONFIG}" configured)
    cp $NGINX_CONF_FILE.tmpl $NGINX_CONF_FILE

    if [ "${HTTPS_ENABLED}" = "true" ]; then
	sed -i "s~HTTPS_SERVER_BLOCK~$HTTPS_SERVER_BLOCK~g" $NGINX_CONF_FILE
	sed -i "s~CERT_LOCATION~$CERT_LOCATION~g" $NGINX_CONF_FILE
    else
	sed -i "s~HTTPS_SERVER_BLOCK~~g" $NGINX_CONF_FILE
	sed -i "s~CERT_LOCATION~~g" $NGINX_CONF_FILE
    fi

    if [ "${CONFIGURED}" = "true" ]; then
	sed -i "s~SETUP_LOCATION~$SETUP_LOCATION~g" $NGINX_CONF_FILE
    else
	sed -i "s~SETUP_LOCATION~~g" $NGINX_CONF_FILE
    fi
else
    cp /etc/default/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
fi
