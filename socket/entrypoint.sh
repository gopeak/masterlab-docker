#!/bin/sh
set -eu

# APP_PORT
# MYSQL_HOST
# MYSQL_PORT
# MYSQL_DB_NAME
# MYSQL_USER
# MYSQL_PASSWORD



cat > /go/src/app/config.toml <<EOF
####################
# Masterlab Socket 配置文件 #
####################

name        =   "Masterlab Socket Server"
enable      =   true
status      =   "dev"
version     =   "1.0"
single_mode =   true

[connector]
    socket_port     = $APP_PORT
    websocket_port  = 9003
    max_conections  = 5024
    max_packet_rate = 100
    max_conntions_ip= 100
    max_packet_rate_unit = 10
    auth_cmds = ["Auth","Authorize"]

[mysql]
    database    =   "$MYSQL_DB_NAME"
    host        =   "$MYSQL_HOST"
    port        =   "$MYSQL_PORT"
    user        =   "$MYSQL_USER"
    password    =   "$MYSQL_PASSWORD"
    charset     =   "utf8mb4_unicode_ci"
    timeout     =   "10"
    max_open_conns = 2000
    max_idle_conns = 1000

[object]
    data_type   = "redis"
    redis_host  = "127.0.0.1"
    redis_port  = "6379"
    redis_password = ""

[worker]
    to_servers = []

[hub]
    hub_host = "127.0.0.1"
    hub_port = "7302"

[area]
    init_area = ["area-global", "area-global2", "area-global3"]

[log]
    log_level   =   "error"
    log_file    =   ""
EOF

cat > /go/src/app/cron.json <<EOF
{
  "desc": "Project compute",
  "schedule": []
}
EOF

echo >&2 "Complete! MasterLab-socket Initializing finished"

exec "$@"
