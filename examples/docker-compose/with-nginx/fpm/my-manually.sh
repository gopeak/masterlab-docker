
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=123456 -p 3306:3306 -v /D_DRIVE/devdocker/masterlabtest/mysql:/var/lib/mysql mysql:5.7 --sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION --innodb_use_native_aio=0


docker run -d --name redis -v /D_DRIVE/devdocker/masterlabtest/redis:/data redis redis-server --appendonly yes

docker run -d --name masterlab --link mysql --link redis -v /D_DRIVE/devdocker/masterlabtest/www:/var/www/html gopeak/masterlab:fpm

docker run -d --name nginx --link masterlab -p 8888:80 --volumes-from masterlab mynginx