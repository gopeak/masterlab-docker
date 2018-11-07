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




