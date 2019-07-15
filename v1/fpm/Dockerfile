FROM php:7.2-fpm-stretch

ENV TZ=Asia/Shanghai
ENV MASTERLAB_VERSION v1.2

COPY sources.list /etc/apt/sources.list

ADD ./redis-4.2.0.tgz ./memcached-3.0.4.tgz /tmp/

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        rsync \
        bzip2 \
        busybox-static \
        cron

# install the PHP extensions we need
RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
    ; \
    \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr; \
    docker-php-ext-configure ldap --with-libdir="lib/$debMultiarch"; \
    docker-php-ext-install \
        exif \
        gd \
        intl \
        ldap \
        opcache \
        pcntl \
        mysqli \
        pdo_mysql \
        pdo_pgsql \
        zip \
    ; \
    \

#    pecl install memcached-3.0.4; \
#    pecl install redis-4.2.0; \

# source compilation and installation extension because pecl installation easy to failure
    cd /tmp/redis-4.2.0; \
    phpize; \
    ./configure; \
    make; \
    make install; \
    cd /tmp/memcached-3.0.4; \
    phpize; \
    ./configure; \
    make; \
    make install; \
    \
    docker-php-ext-enable \
        memcached \
        redis \
    ; \
    \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# set recommended PHP.ini settings
RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.enable_cli=1'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.revalidate_freq=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini; \
    \
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini; \
    \
    echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini; \
    \
    { \
        echo 'short_open_tag=On'; \
        echo 'upload_max_filesize=128M'; \
        echo 'post_max_size=128M'; \
        echo 'max_execution_time=30'; \
    } > /usr/local/etc/php/conf.d/masterlab.ini; \
    \
    mkdir /var/www/data; \
    chown -R www-data:root /var/www; \
    chmod -R g=u /var/www


# install composer
RUN set -ex; \
    curl -sS https://getcomposer.org/installer | php; \
    mv composer.phar /usr/local/bin/composer; \
    #composer config -g repo.packagist composer https://packagist.phpcomposer.com
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# download masterlab source
RUN set -ex; \
    fetchDeps=" \
        gnupg \
        dirmngr \
    "; \
    apt-get install -y --no-install-recommends $fetchDeps; \
    \
    mkdir -p /usr/src/masterlab; \
    \
    curl -fsSL -o masterlab.tar.gz \
        "https://github.com/gopeak/masterlab/archive/${MASTERLAB_VERSION}.tar.gz"; \
    \
    tar zxvf masterlab.tar.gz -C /usr/src/masterlab/ --strip-components 1; \
    \
    rm -r masterlab.tar.gz; \
    chmod +x /usr/src/masterlab/bin/*; \
    \
    cd /usr/src/masterlab/; \
    composer install; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps; \
    rm -rf /var/lib/apt/lists/*

# www-data user can su
RUN sed -i "/www-data/s/\/usr\/sbin\/nologin/\/bin\/bash/g" /etc/passwd

# delete symbolic link for windows share folder
RUN rm -rf /usr/src/masterlab/vendor/bin/*

VOLUME /var/www/html
#VOLUME ["/var/www/html/","/usr/src/masterlab"]

COPY entrypoint.sh /usr/local/bin/

RUN set -ex; \
    chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
