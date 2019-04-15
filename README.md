----
### masterlab是什么?

基于事项驱动和敏捷开发的项目管理工具，参考了Jira和Gitlab优秀特性发展而来。适用于互联网团队进行高效协作和敏捷开发，交付极致卓越的产品。

- 基于事项驱动，功能全面 —— 跟踪bug，新功能，任务，优化改进等,提高团队协作效率。
- 开源，免费 —— 基于开源技术，回报社区。最新技术栈 使用 PHP7/Go/React/Vue/AntDesign 等前沿技术开发。
- 敏捷开发 —— 将先进理论融入全套流程，为你提供最优秀的敏捷开发实践，将团队协作提升至全新的标准。
- 简单易用，二次开发 —— 注重用户交互，扁平化风格，使用bootsrap和gitlab设计规范。
----
### 如何使用这个镜像

此镜像被设计用于微服务环境。由hub.docker.com自动构建, 有两种版本可供选择apache版本和fpm版本以及异步事件服务器socket版本。

- apache版本包括一个apache web服务器，为了让你的部署更灵活，没有搭载mysql和redis。它的设计是易于使用，一条命令就能运行起来。gopeak/masterlab:last就是此版本。

- fpm版本是基于php-fpm的镜像，运行了一个fastcgi进程，为您的Masterlab页面提供服务。要使用此镜像，必须与其他支持fastcgi端口的web服务器相结合 ，如Nginx、Caddy等。

- socket版本是masterlab架构中的异步服务组件，涉及到邮件推送等异步服务，需要与masterlab同时部署。

----
#### 使用apache镜像

- 启动mysql容器
```bash
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 -v /your-mysql-path:/var/lib/mysql mysql:5.7 --sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION --innodb_use_native_aio=0
```

- 启动redis容器
```bash
docker run -d --name redis -v /your-redis-path:/data redis redis-server --appendonly yes
```

- 启动masterlab:socket容器
```bash
docker run -d --name mlsocket --link mysql -e MYSQL_HOST=mysql -e MYSQL_PORT=3306 -e MYSQL_DB_NAME=masterlab -e MYSQL_USER=root -e MYSQL_PASSWORD=password gopeak/masterlab:socket
```
    masterlab:socket的环境变量默认值
    ```
APP_PORT        9002
MYSQL_HOST      mysql
MYSQL_PORT      3306
MYSQL_DB_NAME   masterlab
MYSQL_USER      root
MYSQL_PASSWORD  123456
    ```


- 启动masterlab:apache容器
```bash
docker run -d -it --name masterlab --link mysql --link redis --link mlsocket -p 8888:80 -v /your-masterlab-path:/var/www/html gopeak/masterlab
```
    masterlab:apache的环境变量
    ```
MASTERLAB_DOMAIN
    ```

- 访问以下地址进行安装
```bash
http://ip:8888/install
```

----
#### 使用fpm镜像

要使用fpm镜像，您需要一个额外的web服务器，它可以代理http请求到容器的fpm端口。对于fpm连接，此容器公开端口9000。在大多数情况下，您可能希望使用另一个容器或主机作为代理。如果您使用您的主机，您可以直接在端口9000上找到您的masterlab容器的地址。如果您使用另一个容器，请确保将它们添加到相同的docker网络(通过docker run --network <NAME>…或者docker-compose文件)。

###### 基础使用
```bash
docker run -d --name masterlab gopeak/masterlab:fpm
```
由于fastCGI进程无法提供静态文件(css、image、js)，Web服务器需要访问这些文件。这可以通过volumes-from选项来实现。您可以在《使用docker-compose进行部署》部分找到更多信息。

###### 启动全部运行环境(nginx+masterlab+mysql+redis)
- 启动mysql容器
```bash
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 -v /your-mysql-path:/var/lib/mysql mysql:5.7 --sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION --innodb_use_native_aio=0
```

- 启动redis容器
```bash
docker run -d --name redis -v /your-redis-path:/data redis redis-server --appendonly yes
```

- 启动masterlab:fpm容器
```bash
docker run -d --name masterlab --link mysql --link redis -v /your-masterlab-path:/var/www/html gopeak/masterlab:fpm
```

- 启动nginx容器
[关于nginx配置的示例](https://github.com/gopeak/masterlab-docker/blob/master/examples/docker-compose/with-nginx/fpm/nginx/nginx.conf), 请自行构建mynginx的镜像(docker build -t mynginx .)，在生产环境下需要按需扩展nginx.conf的内容。
```bash
docker run -d --name nginx --link masterlab -p 8888:80 --volumes-from masterlab mynginx
```

- 访问以下地址进行安装流程
```bash
http://ip:8888/install
```

----
#### 使用docker-compose进行部署
获得功能齐全的设置的最简单方法是使用docker-compose文件。 但有太多不同的可能性来设置您的运行环境方案，所以这里只是给出一些示例。

##### 基于masterlab:apache
```bash
version: '2'

services:
  mysql:
    image: mysql:5.7
    container_name: mysql
    ports:
      - 3306:3306
    command: --sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION --innodb_use_native_aio=0
    restart: always
    volumes:
      - /your-mysql-path:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=123456

  redis:
    image: redis
    container_name: redis
    command: redis-server --appendonly yes
    volumes:
      - /your-redis-path:/data

  masterlab:
    image: gopeak/masterlab
    container_name: masterlab
    ports:
      - 8888:80
    links:
      - mysql
      - redis
    volumes:
      - /your-masterlab-path:/var/www/html
    restart: always
```
运行 docker-compose up -d, 访问 http://ip:8888/install 进行安装流程.

##### 基于masterlab:fpm
```bash
version: '2'

services:
  mysql:
    image: mysql:5.7
    container_name: mysql
    ports:
      - 3306:3306
    command: --sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION --innodb_use_native_aio=0
    restart: always
    volumes:
      - /your-mysql-path:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=123456

  redis:
    image: redis
    container_name: redis
    command: redis-server --appendonly yes
    volumes:
      - /your-redis-path:/data

  masterlab:
    image: gopeak/masterlab:fpm
    container_name: masterlab
    links:
      - mysql
      - redis
    volumes:
      - /your-masterlab-path:/var/www/html
    restart: always

  web:
    image: mynginx
    container_name: nginx
    ports:
      - 8888:80
    links:
      - masterlab
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    volumes_from:
      - masterlab
    restart: always
```
运行 docker-compose up -d, 访问 http://ip:8888/install 进行安装流程.

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
