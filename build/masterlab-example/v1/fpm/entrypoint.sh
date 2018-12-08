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

cp -rf /usr/src/* $MASTERLAB_MOUNT_POINT

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


cat > $MASTERLAB_SOURCE_TARGET_ROOT/app/config/deploy/app.cfg.php <<EOF
<?php
error_reporting(E_ERROR);
define('ROOT_URL', '$MASTERLAB_DOMAIN');
define('ATTACHMENT_URL', ROOT_URL . 'attachment/');
define('ENABLE_CACHE', true);
define('CACHE_HANDLER', 'Redis');
define('CACHE_EXPIRE', 360000);
define('ENABLE_XHPROF', false);
define('XHPROF_RATE', 1);
define('WRITE_REQUEST_LOG', false);
define('XPHP_DEBUG', false);
define('ENABLE_TRACE', false);
define('ENABLE_REFLECT_METHOD', true);
EOF

cat > $MASTERLAB_SOURCE_TARGET_ROOT/app/config/deploy/cache.cfg.php <<EOF
<?php
\$_config = array (
    'redis' => array (
        'data' => array (
                    0 => '$MASTERLAB_REDIS_SERVER_DATA_HOST',
                    1 => '$MASTERLAB_REDIS_SERVER_DATA_PORT',
                    2 => 'masterlab',
                ),
        'session' => array (
            0 => array (
                    0 => '$MASTERLAB_REDIS_SERVER_SESSION_HOST',
                    1 => '$MASTERLAB_REDIS_SERVER_SESSION_PORT',
                    2 => 'masterlab-session',
            ),
        ),
    ),
    'enable' => true,
    'cache_gc_rate' => 1000,
    'default_expire' => 1000,
);
return \$_config;
EOF

cat > $MASTERLAB_SOURCE_TARGET_ROOT/app/config/deploy/database.cfg.php <<EOF
<?php
\$_config = array (
    'database' => array (
        'default' => array (
                        'driver' => 'mysql',
                        'host' => '$MASTERLAB_DB_HOST',
                        'port' => '$MASTERLAB_DB_PORT',
                        'user' => '$MASTERLAB_DB_USER',
                        'password' => '$MASTERLAB_DB_PASSWORD',
                        'db_name' => '$MASTERLAB_DB_DATANAME',
                        'charset' => 'utf8',
                        'timeout' => 10,
                        'show_field_info' => false,
                    ),
        'framework_db' => array (
                            'driver' => 'mysql',
                            'host' => '$MASTERLAB_DB_HOST',
                            'port' => '$MASTERLAB_DB_PORT',
                            'user' => '$MASTERLAB_DB_USER',
                            'password' => '$MASTERLAB_DB_PASSWORD',
                            'db_name' => '$MASTERLAB_DB_DATANAME',
                            'charset' => 'utf8',
                            'timeout' => 10,
                            'show_field_info' => false,
                        ),
        'log_db' => array (
                        'driver' => 'mysql',
                        'host' => '$MASTERLAB_DB_HOST',
                        'port' => '$MASTERLAB_DB_PORT',
                        'user' => '$MASTERLAB_DB_USER',
                        'password' => '$MASTERLAB_DB_PASSWORD',
                        'db_name' => '$MASTERLAB_DB_DATANAME',
                        'charset' => 'utf8',
                        'timeout' => 10,
                        'show_field_info' => false,
                    ),
    ),
    'config_map_class' => array (
                            'default' => array (),
                            'framework_db' => array (
                                                0 => 'FrameworkUserModel',
                                                1 => 'FrameworkCacheKeyModel',
                                            ),
                            'log_db' => array (
                                            0 => 'UnitTestUnitModel',
                                        ),
    ),
);
return \$_config;
EOF

echo >&2 "Complete! MasterLab-configure has been successfully installed"

exec "$@"
