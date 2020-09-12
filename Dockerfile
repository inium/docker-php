FROM php:7.4.10-fpm
LABEL maintainer="inlee <einable@gmail.com>"

# 미러 사이트를 kaist로 변경. 필요시 아래 주석 해제 후 사용.
# RUN sed -i 's/deb.debian.org/ftp.kaist.ac.kr/g' /etc/apt/sources.list

# php-fpm 9000번 기본 포트를 80번으로 변경
# 9000번은 xdebug용으로 사용하기 때문에 혼란이 올 수 있어서 Port 번호 교체
RUN sed -i 's/9000/80/' /usr/local/etc/php-fpm.d/zz-docker.conf

# Install packages & docker configurations.
RUN apt-get update && apt-get install -y \
        build-essential \
        git \
        curl \
        wget \
        openssl \
        unzip \
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

# Install xdebug
RUN pecl install xdebug

# Composer install
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Set default environment
## 운영모드. development / production 중 1 이며 default는 development.
ENV DOCKER_ENV development
## Laravel 프로젝트용인지 여부. Default는 false.
ENV DOCKER_LARAVEL false

# Add a entrypoint script
ADD ./docker-run.sh /run.sh
RUN chmod +x /run.sh

# Remove CR(Carriage Return, /r) in case of the file made or modified from Windows.
RUN sed -i -e 's/\r$//' /run.sh

# Set volume
VOLUME ["/var/www/html", "/usr/local/etc/php/conf.d/php.ini"]

# Set working directory
WORKDIR /var/www/html

# Port expose
EXPOSE 80

CMD [ "/run.sh"]
