FROM php:7.4-fpm

COPY ./sources.list.stretch /etc/apt/sources.list

#维护者信息
MAINTAINER sven 121642038@qq.com

# Extensions: ctype, dom, fileinfo, ftp, hash, iconv, json, pdo, pdo_sqlite, session,
# tokenizer, simplexml, xml, xmlreader, xmlwriter and phar are bundled and compiled into
# PHP by default. If missing, install them directly by `docker-php-ext-install extension_name`

# Notice:
# 1. Mcrypt was DEPRECATED in PHP 7.1.0, and REMOVED in PHP 7.2.0.
# 2. opcache requires PHP version >= 7.0.0.
# 3. soap requires libxml2-dev.
# 4. xml, xmlrpc, wddx require libxml2-dev and libxslt-dev.
# 5. Line `&& :\` is just for better reading and do nothing.

ENV \
  SWOOLE_DOWNLOAD_URL=https://download.masterlab.vip/swoole-swoole-v4.6.7.tar.gz \
  PHPREDIS_VERSION=5.2.2

COPY swoole-swoole-v4.6.7.tar.gz   /usr/src/php/ext/swoole.tar.gz
COPY phpredis-5.2.2.tar.gz  /usr/src/php/ext/phpredis.tar.gz

# 安装
RUN apt-get update && apt-get install -y --assume-yes apt-utils libfreetype6-dev libzip-dev libjpeg62-turbo-dev  libonig-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg  \
    && docker-php-ext-install -j$(nproc) gd  \
    && :\
    && apt-get install -y libicu-dev \
    && docker-php-ext-install intl \
    && :\
    && apt-get install -y libxml2-dev \
    && apt-get install -y libxslt-dev \
    && docker-php-ext-install soap \
    && docker-php-ext-install xsl \
    && docker-php-ext-install xmlrpc \
    && :\
    && apt-get install -y libbz2-dev \
    && docker-php-ext-install bz2 \
    && :\
    && docker-php-ext-install zip \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install exif \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install calendar \
    && docker-php-ext-install sockets \
    && docker-php-ext-install gettext \
    #&& docker-php-ext-install shmop \
    #&& docker-php-ext-install sysvmsg \
    && docker-php-ext-install sysvshm \
    && docker-php-ext-install opcache  \
    && apt-get install -y curl \
	&& apt-get install -y libldb-dev \
    && apt-get install -y libldap2-dev \
	&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap \
	# 手动安装扩展
    && docker-php-source extract \
    && cd /usr/src/php/ext/ \
    # 安装swoole扩展
    #&& curl -sSLo swoole.tar.gz $SWOOLE_DOWNLOAD_URL \
      && tar xzf swoole.tar.gz \
      && rm -f swoole.tar.gz \
    && docker-php-ext-install  -j "$(nproc)" swoole  \
	# 安装redis扩展  
	#&& curl -sSLo phpredis.tar.gz https://download.masterlab.vip/phpredis-$PHPREDIS_VERSION.tar.gz  \
    && tar xzf phpredis.tar.gz \ 
	&& mv phpredis-$PHPREDIS_VERSION redis \
    
    && cd redis  \ 
	&& phpize && ./configure \
    && make && make install \
	&& cd ../             \
	&& echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
	&& rm -f phpredis.tar.gz \ 
	&& docker-php-source delete

# Composer
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \

# ext
COPY ext.php /ext.php
RUN php -f /ext.php