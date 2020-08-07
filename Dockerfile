FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN apt-get install -yq \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    locales \
    git

# Set locales
RUN locale-gen en_US.UTF-8 pt_BR.UTF-8 de_DE.UTF-8 fr_CH.UTF-8 it_CH.UTF-8 de_CH.UTF-8
ENV LANG en_US.UTF-8

# ======= Tools =======
RUN apt-get update && apt-get install -yq \
    graphicsmagick \
    imagemagick \
    ghostscript \
    mysql-client \
    iputils-ping \
    apt-utils \
    xpdf \
    imagemagick \
    telnet \
    netcat

# ======= Apache =======
RUN apt-get install -yq apache2

# ======= PHP =======
RUN add-apt-repository ppa:ondrej/php

RUN apt-get update && apt-get install -yq \
    # Install php 7
    libapache2-mod-php7.1 \
    php7.1-cli \
    php7.1-common \
    php7.1-gd \
    php7.1-imap \
    php7.1-intl \
    php7.1-json \
    php7.1-mbstring \
    php7.1-mcrypt \
    php7.1-mysql \
    php7.1-opcache \
    php7.1-readline \
    php7.1-xml \
    php7.1-zip \
    php7.1-curl \
    php7.1-xml \
    php7.1-zip \
    php-imagick \
    build-essential \
    php-xdebug

RUN a2enmod rewrite expires headers
RUN phpenmod imap

RUN ln -sf /dev/stdout /var/log/apache2/access.log
RUN ln -sf /dev/stderr /var/log/apache2/error.log

EXPOSE 80

# ======= Startup script =======
run echo ' \n\
<VirtualHost *:80>\n\
	ServerAdmin webmaster@localhost\n\
	DocumentRoot /var/www/public/\n\
	ErrorLog ${APACHE_LOG_DIR}/error.log\n\
	CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>\n\
\n\
<Directory /var/www/>\n\
    AllowOverride all\n\
</Directory>\n\
' > /etc/apache2/sites-available/000-default.conf

RUN echo '#!/bin/bash -e \n \
rm -f /var/run/apache2/apache2.pid || : \n \
cd /var/www/ \n \
touch storage/logs/laravel.log  \n \
echo "Starting apache :) \n \n" \n \
/usr/sbin/apache2ctl -D FOREGROUND \
' > /root/start-apache.sh
RUN chmod 700 /root/start-apache.sh

CMD ["/root/start-apache.sh"]
