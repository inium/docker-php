FROM php:7.4.4
LABEL maintainer="inlee <einable@gmail.com>"

# 미러 사이트를 kaist로 변경
RUN sed -i 's/deb.debian.org/ftp.kaist.ac.kr/g' /etc/apt/sources.list

# Package 설치
RUN apt-get update && apt-get install -y \
        build-essential \
        git \
        curl \
        wget \
        openssl \
        unzip \
        supervisor \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
        libicu-dev \
        libzip-dev \
        libonig-dev \
    && docker-php-ext-install zip iconv opcache \
    && docker-php-ext-install bcmath ctype json mbstring pdo pdo_mysql tokenizer xml \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd

# Composer install
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Set volume
VOLUME ["/var/www/html", "/usr/local/etc/php/conf.d/php.ini"]

# Set working directory
WORKDIR /var/www/html

# Port expose
EXPOSE 80 8000

CMD ["/bin/bash"]
