#!/usr/bin/env sh

set -e -u

# Settings

BOOKSTACK_VERSION='0.19.0'
NGINX_PORT=${NGINX_PORT:-80}
NGINX_SERVER_NAME=${NGINX_SERVER_NAME:-bookstack}

# Installtion

echo '[INFO] Install base components' && \
    apk add --no-cache \
        runit \
        nginx \
        php7 \
        php7-fpm \
        php7-openssl \
        php7-pdo_mysql \
        php7-mbstring \
        php7-tokenizer \
        php7-gd \
        php7-mysqlnd \
        php7-tidy \
        php7-json \
        php7-phar \
        php7-zlib \
        php7-simplexml \
        php7-dom \
        php7-fileinfo \
        php7-xmlwriter \
        php7-xml \
        php7-session \
        php7-ctype

echo '[INFO] Install build dependencies' && \
    apk add --no-cache --virtual .build-deps \
        wget 

echo '[INFO] Update scripts and configs' && \
    mv /tmp/assets/sbin/entrypoint.sh /sbin && \
    mv /tmp/assets/runtime/configs/nginx/default.conf /etc/nginx/conf.d/default.conf && \
    mv /tmp/assets/runtime/configs/php-fpm7/bookstack.conf /etc/php7/php-fpm.d/www.conf && \
    mv /tmp/assets/runtime/configs/bookstack/env.conf /var/www/.env

echo '[INFO] Configure env for nginx server' && \
    chown nginx:nginx /var/www && \
    rm -rf /var/www/*

# Install BookStack

echo '[INFO] Install PHP composer' && \
    mkdir -p /tmp/composer && \
    cd /tmp/composer && \
    wget https://getcomposer.org/installer -q -O - | php

echo '[INFO] Install BookStack' && \
    mkdir -p /tmp/bookstack && \
    cd /tmp/bookstack && \
    wget https://github.com/BookStackApp/BookStack/archive/v${BOOKSTACK_VERSION}.tar.gz -q -O bookstack.tar.gz && \
    tar -xf bookstack.tar.gz && \
    mv BookStack-${BOOKSTACK_VERSION}/* /var/www && \
    cd /var/www && \
    /tmp/composer/composer.phar install 

echo '[INFO] Set directory permissions' && \
    chown -R nginx:nginx \
        /var/www/storage/ \
        /var/www/public/uploads/ \
        /var/www/bootstrap/cache/

# Service start-up scripts for runit

echo '[INFO] Activate service: nginx' && \
    mkdir -p /etc/service/nginx/ /run/nginx/ && \
    printf "#!/bin/sh\nset -e\nexec /usr/sbin/nginx -g \"daemon off;\"" > /etc/service/nginx/run && \
    chmod +x /etc/service/nginx/run

echo '[INFO] Activate service: php-fpm' && \
    mkdir -p /etc/service/php-fpm7/ && \
    printf "#!/bin/sh\nset -e\nexec /usr/sbin/php-fpm7 --nodaemonize" > /etc/service/php-fpm7/run && \
    chmod +x /etc/service/php-fpm7/run

# Cleaning procedure

echo '[INFO] Remove build dependencies' && \
    apk del .build-deps

echo '[INFO] Cleaning up' && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/assets && \
    rm -rf /tmp/composer && \
    rm -rf /tmp/bookstack


