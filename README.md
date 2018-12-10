----
# MasterLab-Docker
Docker + Linux + Nginx + Mysql5.7 + PHP7 + Redis

----
## docker安装及docker-compose安装
参考官方文档自行安装

----
## 目录结构
```bash
masterlab-docker
├── app
│   └── masterlab
|   └── hornet-framework
├── mysql
│   └── conf
|   └── data
|   └── logs
├── nginx
│   ├── Dockerfile
│   ├── logs
│   └── conf
│       └── conf.d
├── php-fpm
│   ├── Dockerfile
│   ├── conf
│   ├── logs
│   ├── php-fpm.conf
│   ├── sources.list
│   ├── phpredis-php7.tar.gz
└── redis
    └── Dockerfile
    └── redis.conf
    └── data
```

----
## 使用

- 创建masterlab虚拟专用网络
```bash
docker network create --gateway 172.24.0.1 --subnet 172.24.0.0/24 masterlab
```

- 构建镜像
```bash
docker-compose build
```

- 启动masterlab的运行环境
```bash
docker-compose up -d
```

- 关闭masterlab的运行环境
```bash
docker-compose down
```

- 进入正在运行的容器
```bash
docker exec -it CONTAINER_NAME /bin/bash
```



## FAQ
1. 在windows下使用 DockerToolbox ， mysql数据挂载到本地（共享目录到window主机磁盘上） 会出现权限问题
解决办法：
挂载到DockerToolbox上并给目录777权限，不要挂载到共享目录里
```
    volumes:
      - /home/docker/data:/var/lib/mysql
```

2. docker-compose up 启动阶段masterlab报 standard_init_linux.go:178: exec user process caused "no such file or directory"
解决办法：vi entrypoint.sh  重新保存一下