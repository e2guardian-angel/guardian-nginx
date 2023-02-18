FROM nginx:alpine
MAINTAINER Justin Schwartzbeck <justinmschw@gmail.com>

RUN mkdir -p /etc/nginx/conf.https.d

WORKDIR /etc/nginx

COPY ./nginx-https.conf ./nginx-https.conf
COPY ./default-https.conf ./conf.https.d/default-https.conf

WORKDIR /
COPY ./entrypoint.sh /

EXPOSE 80
EXPOSE 443

CMD ["/bin/sh", "/entrypoint.sh"]
