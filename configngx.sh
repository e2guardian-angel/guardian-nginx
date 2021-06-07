#!/bin/sh

GUARDIAN_CONF=/opt/guardian/conf/guardian.json
CERTFILE=/opt/guardian/ssl/tls.crt
KEYFILE=/opt/guardian/ssl/tls.key

IFS='%'
HTTPS_SERVER_BLOCK="server {"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        listen 443 ssl default_server;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        listen [::]:443 ssl default_server;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        ssl_certificate ${CERTFILE};"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        ssl_certificate_key ${KEYFILE};"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        ssl_ciphers HIGH:!aNULL:!MD5;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        location / {"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                proxy_pass http://127.0.0.1:3000/ui/dashboard;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                proxy_intercept_errors on;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                error_page 401 = @error401;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        }"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        location /api {"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                proxy_pass http://127.0.0.1:3000/api;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                proxy_intercept_errors on;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                error_page 401 = @error401;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        }"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        location /login {"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                proxy_pass http://127.0.0.1:3000/ui/login;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                proxy_intercept_errors on;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                error_page 401 = @error401;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        }"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        location /passreset {"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                proxy_pass http://127.0.0.1:3000/ui/passreset;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                proxy_intercept_errors on;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                error_page 401 = @error401;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        }"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        location @error401 {"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n                return 302 /login-module/login;"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n        }"
HTTPS_SERVER_BLOCK="${HTTPS_SERVER_BLOCK}\n}"

CERT_LOCATION="location /cert {"
CERT_LOCATION="${CERT_LOCATION}\n                proxy_pass http://127.0.0.1:3000/ui/cert;"
CERT_LOCATION="${CERT_LOCATION}\n        }"

SETUP_LOCATION="location /setup {"
SETUP_LOCATION="${SETUP_LOCATION}\n                proxy_pass http://127.0.0.1:3000/ui/setup;"
SETUP_LOCATION="${SETUP_LOCATION}\n        }"

extract_value () {
    echo "${1}" | jq -r .${2}
}

if [ -f "${GUARDIAN_CONF}" ]; then
    CONFIG="$(cat $GUARDIAN_CONF)"
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

    if [ "${CONFIGURED}" = "false" ]; then
	sed -i "s~SETUP_LOCATION~$SETUP_LOCATION~g" $NGINX_CONF_FILE
    else
	sed -i "s~SETUP_LOCATION~~g" $NGINX_CONF_FILE
    fi
else
    cp /etc/default/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
fi
