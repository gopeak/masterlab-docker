#!/bin/bash
set -e

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

tail -f /dev/null