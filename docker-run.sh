#!/bin/bash

# Install composer packages.
composer install

# If the DOCKER_ENV env is production mode, run on production mode.
if [ "${DOCKER_ENV}" == "production" ]; then
    echo "***** Your app is production mode & . *****"

    php-fpm

# Otherwise, run on development mode.
else
    echo "***** Your app is development mode & . *****"

    # Set Xdebug
    docker-php-ext-enable xdebug

    echo "xdebug.default_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    echo "xdebug.idekey=VSCODE" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    echo "xdebug.remote_log=/usr/local/etc/php/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

    echo "***** Xdebug is enabled *****"

    # if the DOCKER_LARAVEL env is true, do Laravel execution.
    # run on /var/www/html/public directory files.
    if [ "${DOCKER_LARAVEL}" == true ]; then
        echo "***** Laravel execution *****"

        php -S 0.0.0.0:80 -t public

    # Otherwise, run on /var/www/html directory files.
    else 
        echo "***** General execution *****"

        php -S 0.0.0.0:80
    fi
fi
