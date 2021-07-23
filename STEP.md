
### 安装必备，安装以下命令行工具

- git unzip  
- docker [https://docs.docker.com/install/]
- docker-compose [https://docs.docker.com/compose/install/#install-compose]



### 配置镜像加速器（可选） 
Linux操作系统针对Docker客户端版本大于 1.10.0 的用户
您可以通过修改daemon配置文件/etc/docker/daemon.json来使用加速器 
```
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://c9jzs6ju.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl restart docker
```
其他操作系统 请参考 `https://www.runoob.com/docker/docker-mirror-acceleration.html`



### 第一步，获取Masterlab和Docker代码

```
 mkdir /data/
 cd /data
 git clone https://gitee.com/firego/masterlab-docker.git
 # 海外网络请用 https://github.com/gopeak/masterlab-docker.git

 cd ./masterlab-docker/www
 git clone https://gitee.com/firego/masterlab.git
 # 海外网络请用 https://github.com/gopeak/masterlab.git
 cd ./masterlab
 unzip ./vendor.zip          
 cd /data/masterlab-docker
```



### 第二步 设置网络
```
docker network create --subnet=172.18.0.0/24 masterlab_docker_net
```


### 第三步 拉取镜像并启动容器 
```
# mysql5.7 
docker pull mysql:5.7

docker run -d --name mysql  -p 3306:3306 --network masterlab_docker_net --ip 172.18.0.5 \
 -v /data/masterlab-docker/conf/mysql/my.cnf:/etc/mysql/my.cnf \
 -v /data/masterlab-docker/mysql/:/var/lib/mysql/ \
 -v /data/masterlab-docker/log/mysql/:/var/log/mysql/ \
 -e MYSQL_ROOT_PASSWORD=123456 \
 mysql:5.7
 
 
# redis 
docker pull redis:latest

docker run -d --name redis -p 10379:10379 --network masterlab_docker_net --ip 172.18.0.6 redis:latest
 

# php-fpm7.4 
docker pull gopeak/masterlab:php-fpm-74

docker run -d --name php74 --expose=9000 -p 9000:9000 --network masterlab_docker_net --ip 172.18.0.4  --link mysql:mysql --link redis:redis  \
 -v /data/masterlab-docker/www/:/var/www/html/ \
 -v /data/masterlab-docker/conf/php/php74.ini:/usr/local/etc/php/php.ini \
 -v /data/masterlab-docker/conf/php/php-fpm.d/www74.conf:/usr/local/etc/php-fpm.d/www.conf \
 -v /data/masterlab-docker/log/php-fpm/:/var/log/php-fpm/ \
  gopeak/masterlab:php-fpm-74
 
  
  
# nginx 
docker pull nginx:alpine

docker run -d --name nginx -p 80:80 -p 443:443 --network masterlab_docker_net --ip 172.18.0.2 --link php74:fpm74 \
 -v /data/masterlab-docker/www/:/var/www/html/ \
 -v /data/masterlab-docker/conf/nginx/conf.d:/etc/nginx/conf.d/ \
 -v /data/masterlab-docker/conf/nginx/nginx.conf:/etc/nginx/nginx.conf \
 -v /data/masterlab-docker/log/nginx/:/var/log/nginx/ \
 -e "TZ=Asia/Shanghai" \
 nginx:alpine
 
# 启动Swoole异步服务
docker pull gopeak/masterlab:php-cli-74

docker run -d -it --rm --name php74-cli  --network masterlab_docker_net  --ip 172.18.0.8 \
    -p 9002:9002 \
    -v "$PWD"/www/masterlab:/usr/workspaces/project \
    -w /usr/workspaces/project \
    gopeak/masterlab:php-cli-74 \
    php  ./bin/swoole_server.php
 
 
```
 
	  

### 第四步，赋予权限

```
 docker ps                                   // 查看运行已经运行的容器,找到php的容器id如
 docker exec -it ee84df733af6 /bin/bash      // 进入php 
 chown -R www-data:www-data ./               // 赋予读写权限，执行完 ctrl + d 退出
 # 按键 ctrl + d 退出
```


### 第五步，访问 /install  进行图形安装界面

http://www.masterlab.com/install （先在hosts里追加：你的服务器ip www.masterlab.com ，成功后修改为你实际的域名）

注: 连接数据库的地址，用户名,密码分别为  
```
172.18.0.5 root 123456
```
注:MasterlabSocket异步服务器的地址和端口为： 
```
172.18.0.8  9002
```

安装结束后 将 ./conf/nginx/conf.d/masterlab.conf 里的www.masterlab.com为你自己的域名即可

 
 
 
	
