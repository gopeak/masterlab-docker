#!/bin/bash
set -e


if [ -d "/var/lib/mysql/masterlab" ];then
    echo >&2 'MASTERLAB The database already exists'

    echo `service mysql status`
    service mysql start
    sleep 3
    echo `service mysql status`
    echo >&2 'MASTERLAB mysql container successful start'
else
    echo `service mysql status`

    echo >&2 "1.MASTERLAB start mysql"
    service mysql start
    sleep 3
    echo `service mysql status`

    echo >&2 '2.MASTERLAB start import masterlab.sql'
    mysql < /tmp/masterlab.sql
    echo >&2 '3.MASTERLAB successful import masterlab.sql'

    sleep 3
    echo `service mysql status`

    echo >&2 '4.MASTERLAB start modify password'
    mysql < /tmp/privileges.sql
    echo >&2 '5.MASTERLAB successful modify password'

    echo `service mysql status`
    echo >&2 'MASTERLAB mysql container successful start, and all data is ready, and all Settings are ready'

fi

# 防止容器退出
tail -f /dev/null

