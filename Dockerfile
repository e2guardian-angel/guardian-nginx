FROM nginx:alpine
MAINTAINER Justin Schwartzbeck <justinmschw@gmail.com>

RUN apk update \
  && apk add jq \
  && rm -rf /var/cache/apk/* \
  && mkdir -p /etc/nginx/conf.http.d \
  && mkdir -p /etc/nginx/conf.https.d

WORKDIR /etc/nginx

COPY ./default-http.conf ./conf.http.d/default-http.conf
COPY ./default-https.conf ./conf.https.d/default-https.conf
COPY ./nginx-http.conf ./nginx-http.conf
COPY ./nginx-https.conf ./nginx-https.conf

WORKDIR /
COPY ./entrypoint.sh /

EXPOSE 80
EXPOSE 443

CMD ["/bin/sh", "/entrypoint.sh"]
