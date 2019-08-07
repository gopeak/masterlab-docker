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

if [ ! -d /var/spool/cron/crontabs ]; then
    mkdir -p /var/spool/cron/crontabs
fi
cat > /var/spool/cron/crontabs/$MASTERLAB_USER <<EOF
0,30 22-23 * * * php -f $MASTERLAB_MOUNT_POINT/app/server/timer/project.php
55 23 * * * php -f $MASTERLAB_MOUNT_POINT/app/server/timer/projectDayReport.php
56 23 * * * php -f $MASTERLAB_MOUNT_POINT/app/server/timer/sprintDayReport.php
EOF

# start cron
cron

echo >&2 "Complete! MasterLab-configure Initializing finished"

exec "$@"
