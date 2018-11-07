FROM php:7.2-fpm

ENV TZ=Asia/Shanghai

COPY sources.list /etc/apt/sources.list

RUN DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y build-essential libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libxml2 libfreetype6 libjpeg62-turbo libmcrypt4 curl --no-install-recommends \
    && docker-php-ext-install iconv mbstring \
        xml json mysqli pdo pdo_mysql zip \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/*

# 手动编译安装redis扩展
ADD ./phpredis-php7.tar.gz /tmp
WORKDIR /tmp/phpredis-php7
RUN /usr/local/bin/phpize \
&& ./configure --with-php-config=/usr/local/bin/php-config \
&& make \
&& make install \
&& echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini