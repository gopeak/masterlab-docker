----
### masterlab是什么?

基于事项驱动和敏捷开发的项目管理工具，参考了Jira和Gitlab优秀特性发展而来。适用于互联网团队进行高效协作和敏捷开发，交付极致卓越的产品。

- 基于事项驱动，功能全面 —— 跟踪bug，新功能，任务，优化改进等,提高团队协作效率。
- 开源，免费 —— 基于开源技术，回报社区。最新技术栈 使用 PHP7/Go/React/Vue/AntDesign 等前沿技术开发。
- 敏捷开发 —— 将先进理论融入全套流程，为你提供最优秀的敏捷开发实践，将团队协作提升至全新的标准。
- 简单易用，二次开发 —— 注重用户交互，扁平化风格，使用bootsrap和gitlab设计规范。
----
### 如何使用这个镜像

此镜像被设计用于微服务环境。有两种版本可供选择apache版本和fpm版本.

- apache版本包括一个apache web服务器，为了让你的部署更灵活，没有搭载mysql和redis。它的设计很容易使用，一条命令就能运行起来。masterlab:last就是此版本。

- fpm版本是基于php-fpm的镜像，运行了一个fastcgi进程，为您的Masterlab页面提供服务。要使用此镜像，必须与其他支持fastcgi端口的web服务器相结合 ，如Nginx、Caddy等。

----
##### 使用apache镜像

- 启动mysql容器
```bash
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 -v /your-mysql-path:/var/lib/mysql mysql:5.7 --sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION --innodb_use_native_aio=0
```

- 启动redis容器
```bash
docker run -d --name redis -v /your-redis-path:/data redis redis-server --appendonly yes
```

- 启动masterlab容器
```bash
docker run -d -it --name masterlab --link mysql --link redis -p 8888:80 -v /your-masterlab-path:/var/www/html masterlab
```

- 访问以下地址进行安装
```bash
http://ip:port/install
```

----
##### 使用fpm镜像(开发调试中，敬请期待)




## FAQ
1. 进入安装页面的redis地址填写什么？mysql连接地址填写什么？
填写镜像名

2. mysql的版本问题
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

3. 需要额外的PHP扩展
以pdo为例, 进入容器执行以下命令
```bash
/usr/local/bin/docker-php-ext-install pdo_mysql
```
然后重启容器
