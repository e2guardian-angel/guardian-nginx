FROM nginx:alpine
MAINTAINER Justin Schwartzbeck <justinmschw@gmail.com>

RUN apk update \
  && apk add jq \
  && rm -rf /var/cache/apk/* \
  && mkdir -p /etc/default/nginx/conf.d \
  && cp /etc/nginx/conf.d/default.conf /etc/default/nginx/conf.d/

WORKDIR /etc/nginx
ENV NGINX_CONF_DIR=/etc/nginx/conf.d

COPY ./default.conf.tmpl ./conf.d/default.conf.tmpl

WORKDIR /
COPY ./entrypoint.sh /
COPY ./configngx.sh /

EXPOSE 80
EXPOSE 443


