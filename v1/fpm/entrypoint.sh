#!/bin/sh
set -eu

MASTERLAB_USER=www-data
MASTERLAB_MOUNT_POINT=/var/www/html
MASTERLAB_SOURCE_TARGET_ROOT=/var/www/html/masterlab

run_as() {
    if [ "$(id -u)" = 0 ]; then
        su -p www-data -s /bin/sh -c "$1"
    else
        sh -c "$1"
    fi
}

cp -rf /usr/src/masterlab $MASTERLAB_MOUNT_POINT

# start configure
cp -f $MASTERLAB_SOURCE_TARGET_ROOT/env.ini-example $MASTERLAB_SOURCE_TARGET_ROOT/env.ini
echo >&2 "MasterLab has been successfully copied to $PWD"

chown -R $MASTERLAB_USER:$MASTERLAB_USER $MASTERLAB_MOUNT_POINT

mkdir -p /var/spool/cron/crontabs
cat > /var/spool/cron/crontabs/$MASTERLAB_USER <<EOF
0,30 22-23 * * * php -f $MASTERLAB_SOURCE_TARGET_ROOT/app/server/timer/project.php
55 23 * * * php -f $MASTERLAB_SOURCE_TARGET_ROOT/app/server/timer/projectDayReport.php
56 23 * * * php -f $MASTERLAB_SOURCE_TARGET_ROOT/app/server/timer/sprintDayReport.php
EOF

# start cron
cron

echo >&2 "Complete! MasterLab-configure has been successfully installed"

exec "$@"
