#!/bin/sh
set -eu

run_as() {
    if [ "$(id -u)" = 0 ]; then
        su -p www-data -s /bin/sh -c "$1"
    else
        sh -c "$1"
    fi
}

cp -rf /usr/src/* /var/www/html


# 修改配置
cp -f /var/www/html/masterlab/env.ini-example /var/www/html/masterlab/env.ini


echo >&2 "Complete! MasterLab has been successfully copied to $PWD"

exec "$@"
