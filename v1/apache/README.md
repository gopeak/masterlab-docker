


##### docker安装masterlab

masterlab是基于PHP开发的，所以masterlab的docker镜像只有PHP环境

docker镜像已经由docker hub自动构建
使用下面命令即可获取（注意替换 <tag> ）：
```
docker pull gopeak/masterlab:<tag>
```

运行容器
```
docker run -d -it --name masterlabt -p 9000:9000 -v /d/devdocker/masterlabtest:/var/www/html/masterlab masterlab
```

masterlab的运行环境是 NGINX+PHP+MYSQL+REDIS，所以需要另外部署NGINX、MYSQL和REDIS

假设masterlab的运行环境都是基于docker来构建的

采用官方镜像MYSQL和REDIS来构建


使用官方mysql镜像（5.6）
```
docker run --name mysql -e MYSQL_ROOT_PASSWORD=password -d -p 3306:3306 -v /c/Users/<ACCOUNT>/mysql_data:/var/lib/mysql mysql:5.6 --innodb_use_native_aio=0
```
注意上面的运行命令添加了 --innodb_use_native_aio=0 ，因为mysql的aio对windows文件系统不支持


如果要使用 5.7 版本的mysql，需要再添加 --sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION 参数，因为不支持全零的date字段值（ https://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sqlmode_no_zero_date ）

```
docker run --name mysql57 -e MYSQL_ROOT_PASSWORD=password -d -p 3306:3306 -v /c/Users/<ACCOUNT>/mysql_data:/var/lib/mysql mysql:5.7 --sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION --innodb_use_native_aio=0
```

如果使用 8.0 版本的mysql，则直接设定 --sql_mode=''，即禁止掉缺省的严格模式，（参考 https://dev.mysql.com/doc/refman/8.0/en/sql-mode.html ）
```
docker run --name mysql -e MYSQL_ROOT_PASSWORD=password -d -p 3306:3306 -v /c/Users/<ACCOUNT>/mysql_data:/var/lib/mysql mysql:8 --sql_mode='' --innodb_use_native_aio=0
```
或者你也可以挂载使用一个自定义的 my.cnf 来添加上述参数。