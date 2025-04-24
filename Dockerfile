FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# configure timezone data
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tzdata apt-utils && \
    ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && \
    dpkg-reconfigure tzdata

# install system packages
RUN apt-get update && apt-get install -y software-properties-common apt-transport-https build-essential
# RUN add-apt-repository ppa:ondrej/php
RUN apt-get install -y vim \
    zip \
    unzip \
    p7zip-full \
    curl \
    s3cmd \
    php8.3-fpm \
    php8.3-mysqli \
    php8.3-curl \
    php8.3-cli \
    php8.3-mbstring \
    php8.3-gd \
    php8.3-zip \
    php8.3-xml \
    poppler-utils \
    python3-pip \
    imagemagick \
    ffmpeg \
    net-tools \
    nginx \
    git \
    pdftk \
    poppler-utils \
    wget

# install composer
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN usermod -d /tmp/www-data www-data

# set php configuration values
WORKDIR /var/www
ENV PHP_INI_DIR='/etc/php/8.3/fpm'
RUN sed -i 's/post_max_size = 8M/post_max_size = 1024M/' "${PHP_INI_DIR}/php.ini" && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/' "${PHP_INI_DIR}/php.ini" && \
    sed -i 's/memory_limit = 128M/memory_limit = 2048M/' "${PHP_INI_DIR}/php.ini" && \
    sed -i "\|include /etc/nginx/sites-enabled/\*;|d" "/etc/nginx/nginx.conf"

## tribe
RUN wget https://github.com/tribe-framework/tribe/archive/refs/tags/v3.1.6.tar.gz -O tribe.tar.gz
RUN tar -xzf tribe.tar.gz -C /var/www --strip-components=1 && rm tribe.tar.gz

RUN composer u

## phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz -O pma.tar.gz
RUN mkdir /var/www/phpmyadmin && \
    tar -xzf pma.tar.gz -C /var/www/phpmyadmin --strip-components=1 && \
    rm pma.tar.gz

## junction
COPY "applications/junction/dist" "junction"

RUN chown -R www-data: uploads/ logs/

RUN service php8.3-fpm restart;

EXPOSE 80
EXPOSE 81

CMD /etc/init.d/php8.3-fpm start && service nginx start && tail --follow /dev/null
