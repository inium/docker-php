FROM php:7.1-apache
MAINTAINER inlee <einable@gmail.com>

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/apache2/apache2.conf

RUN a2enmod rewrite
