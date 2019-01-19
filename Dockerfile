#Nginx
FROM nginx:1.13.1-alpine

MAINTAINER Troy <tcytroy@163.com>

#https://yeasy.gitbooks.io/docker_practice/content/image/build.html
RUN mkdir -p /etc/nginx/cert \
	&& mkdir -p /etc/nginx/conf.d

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/conf.d/ /etc/nginx/conf.d/
COPY ./nginx/cert/ /etc/nginx/cert/

# mount nginx log
VOLUME /var/log/nginx

WORKDIR /usr/share/nginx/html

#Php
FROM bravist/php-fpm-alpine-aliyun-app:1.16

RUN mkdir -p /usr/share/nginx/html/public
COPY ./php/index.php /usr/share/nginx/html/public

# Expose volumes
VOLUME ["/usr/share/nginx/html", "/usr/local/var/log/php7", "/var/run/"]
EXPOSE 9000
WORKDIR /usr/share/nginx/html

#SUPERVISOR
FROM bravist/php-cli-alpine-aliyun-app:1.12

RUN apk update \
	&& apk upgrade \
	&& apk add supervisor \
	&& rm -rf /var/cache/apk/*

# Define mountable directories.
VOLUME ["/etc/supervisor/conf.d", "/var/log/supervisor/"]


# Define working directory.
WORKDIR /usr/share/nginx/html
COPY ./supervisor/conf.d/ /etc/supervisor/conf.d/
COPY ./entrypoint.sh /usr/share/nginx/html/
RUN chmod +x /usr/share/nginx/html/entrypoint.sh

COPY ./crontabs/default /var/spool/cron/crontabs/
RUN cat /var/spool/cron/crontabs/default >> /var/spool/cron/crontabs/root
RUN mkdir -p /var/log/cron \
	&& touch /var/log/cron/cron.log

VOLUME /var/log/cron


#CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
ENTRYPOINT ["./entrypoint.sh"]
