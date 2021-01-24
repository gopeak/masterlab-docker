

### 第一步，安装依赖工具

- Git  // yum install git
- Docker [https://docs.docker.com/install/]
- Docker-compose [https://docs.docker.com/compose/install/#install-compose]

### 第二步，获取Docker项目代码

```
$ git clone https://github.com/gopeak/masterlab-docker.git
```
   
### 第三步，获取Masterlab程序

```
$ cd ./www
$ git clone https://github.com/gopeak/masterlab.git
$ unzip vendor.zip          // 解压依赖的类库
```
   
### 第三步，运行容器编排

```
$ cd masterlab-docker   // 进入项目根目录
$ docker-compose up -d   // 容器编排命令
```

启用服务，第一次需要构建镜像

### 第五步，赋予权限

```
$ cd docker ps   // 查看运行的php容器id,加入id为 
$ docker exec -it f291c3543c54 /bin/bash   // 进入php
$ chown -R www-data:www-data ./   // 进入php
```


### 第六步，访问/install 进行图形安装界面

http://127.0.0.1/install （可配置强制跳转 https）

注: 连接数据库的地址，用户名,密码分别为  
172.100.0.5 root 123456


 
### 第七步，启动Swoole服务访问(未测试)

- 首先，自定义构建 `PHP-CLI` 镜像，安装 `Git`，`Composer`，`Swoole` 等扩展和工具

```shell
# 构建镜像
docker build -t php2-cli ./php-cli/php72
```



- 启动 `Swoole` 进程
```
 docker run -it --rm --name www-data \
    -p 9002:9002 \
    -v "$PWD":/var/www/html/masterlab/app/bin \
    -w /var/www/html/masterlab/app/bin \
    php2-cli \
    php  swoole_server.php
```

	