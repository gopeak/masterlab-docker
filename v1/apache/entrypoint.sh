#!/bin/sh
set -eu

MASTERLAB_USER=www-data
MASTERLAB_MOUNT_POINT=/var/www/html

is_empty_dir(){
    return `ls -A $1|wc -w`
}

# start configure
if [ "$(id -u)" = 0 ]; then
    rsync_options="-rDog --chown www-data:root"
else
    rsync_options="-rD"
fi

if [ ! -d $MASTERLAB_MOUNT_POINT ] || is_empty_dir $MASTERLAB_MOUNT_POINT; then
    rsync $rsync_options /usr/src/masterlab/* $MASTERLAB_MOUNT_POINT
    cp -f $MASTERLAB_MOUNT_POINT/env.ini-example $MASTERLAB_MOUNT_POINT/env.ini
fi

echo >&2 "MasterLab has been successfully copied to $PWD"

chown -R $MASTERLAB_USER:$MASTERLAB_USER $MASTERLAB_MOUNT_POINT

mkdir -p /var/spool/cron/crontabs
cat > /var/spool/cron/crontabs/$MASTERLAB_USER <<EOF
0,30 22-23 * * * php -f $MASTERLAB_MOUNT_POINT/app/server/timer/project.php
55 23 * * * php -f $MASTERLAB_MOUNT_POINT/app/server/timer/projectDayReport.php
56 23 * * * php -f $MASTERLAB_MOUNT_POINT/app/server/timer/sprintDayReport.php
EOF

# start cron
cron

if [ -z $MASTERLAB_DOMAIN ]; then
    # 未设置MASTERLAB_DOMAIN
    MASTERLAB_DOMAIN_CUSTOM=""
else
    MASTERLAB_DOMAIN_CUSTOM="ServerName  ${MASTERLAB_DOMAIN}"
fi

# modify apache config
mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.bak
cat > /etc/apache2/sites-enabled/masterlab.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html/app/public
    # 这里修改成你自己的域名
    ${MASTERLAB_DOMAIN_CUSTOM}
    <Directory />
        Options Indexes FollowSymLinks
        AllowOverride All
        Allow from All
    </Directory>
    <Directory /var/www/html/app/public>
        Options  Indexes FollowSymLinks
        AllowOverride All
        Order allow,deny
        Allow from All
    </Directory>

    Alias /attachment /var/www/html/app/storage/attachment
    <Directory /var/www/html/app/storage/attachment>
        Options Indexes FollowSymLinks
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

echo >&2 "Complete! MasterLab-configure Initializing finished"

exec "$@"
