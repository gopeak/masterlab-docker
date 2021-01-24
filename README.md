![demo-portainer.jpg](demo-portainer.jpg)

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


### 第五步，测试服务访问

http://127.0.0.1/ （可配置强制跳转 https）



 
### 第六步，启动Swoole服务访问
- 启动 `Swoole` 进程

 