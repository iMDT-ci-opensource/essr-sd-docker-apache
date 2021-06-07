FROM ubuntu:20.04

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
RUN apt-get update && apt-get install -yq \
    libapache2-mod-php7.4 \
    php7.4-cli \
    php7.4-common \
    php7.4-gd \
    php7.4-imap \
    php7.4-intl \
    php7.4-json \
    php7.4-mbstring \
    php7.4-mysql \
    php7.4-opcache \
    php7.4-readline \
    php7.4-xml \
    php7.4-zip \
    php7.4-curl \
    php7.4-xml \
    php7.4-zip \
    php-imagick \
    build-essential \
    php-xdebug

RUN apt-get install -yq sshfs

RUN a2enmod rewrite expires headers
RUN phpenmod imap

# RUN apt -y install libmcrypt-dev
# RUN pecl install mcrypt-1.0.2

RUN ln -sf /dev/stdout /var/log/apache2/access.log
RUN ln -sf /dev/stderr /var/log/apache2/error.log

EXPOSE 80
RUN adduser user1000 -u 1000
RUN groupadd fuse
RUN usermod -aG fuse user1000

ENV APACHE_RUN_USER=user1000
ENV APACHE_RUN_GROUP=user1000

# ======= Startup script =======
RUN echo ' \n\
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
mkdir /home/user1000/.ssh/ &> /dev/null || true \n \
cp -f /var/www/docker-apache-keys/* /home/user1000/.ssh/ \n \
chown -R user1000 /home/user1000/ \n \
chmod 600 /home/user1000/.ssh/* \n \
chown root.fuse /dev/fuse \n \
rm -f /var/run/apache2/apache2.pid || : \n \
cd /var/www/ \n \
cat /etc/apache2/envvars  | grep -v APACHE_RUN_ > /tmp/envvars \n \
cat /tmp/envvars > /etc/apache2/envvars \n \
touch storage/logs/laravel.log  \n \
chmod 666 storage/logs/laravel.log  \n \
echo "Starting apache :) :) \n \n" \n \
/usr/sbin/apache2ctl -D FOREGROUND \
' > /root/start-apache.sh
RUN chmod 700 /root/start-apache.sh

CMD ["/root/start-apache.sh"]
