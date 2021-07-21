Docker hub 上的 gopeak/masterlab 镜像已经失效，请勿使用；目前只支持Masterlab3.0的版本  

### 第一步，安装依赖工具

- dit unzip 
- docker [https://docs.docker.com/install/]
- docker-compose [https://docs.docker.com/compose/install/#install-compose]


### 第二步，获取Docker项目代码

```
 git clone https://gitee.com/firego/masterlab-docker.git
# 国外网络请用 https://github.com/gopeak/masterlab-docker.git

```
   
### 第三步，获取Masterlab程序

```
 cd ./masterlab-docker/www
 git clone https://gitee.com/firego/masterlab.git
 cd ./masterlab
 unzip vendor.zip          // 解压依赖的类库
```


### 第三步 配置镜像加速器（可选）
针对Docker客户端版本大于 1.10.0 的用户
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

   
### 第四步，运行容器编排

```
 cd ../../              // 回到asterlab-docker的根目录
 docker-compose up -d   // 容器编排命令，如果下载镜像很慢，建议使用国内的加速镜像
```

启用服务，第一次需要构建镜像

### 第五步，赋予权限

```
 docker ps                                   // 查看运行的php容器id,假如id为 f4e5af6b62d8
 docker exec -it f4e5af6b62d8 /bin/bash      // 进入php 
 chown -R www-data:www-data ./               // 赋予读写权限，执行完 ctrl + d 退出
```


### 第六步，访问 /install  进行图形安装界面

http://www.masterlab.com/install （先在hosts里追加：你的服务器ip www.masterlab.com ，成功后修改为你实际的域名）

注: 连接数据库的地址，用户名,密码分别为  
172.100.0.5 root 123456

安装成功后 将 ./conf/nginx/conf.d/masterlab.conf 里的www.masterlab.com为你自己的域名即可

 
### 第七步，启动Swoole服务
- 首先，自定义构建 `PHP-CLI` 镜像，安装 `Git`，`Composer`，`Swoole` 等扩展和工具

```shell
# 构建镜像
docker build -t php2-cli ./php-cli/php72
```



- 启动 `Swoole` 进程
 

```shell
docker run -d  -it --rm --name www-data  --network masterlab-docker_docker_net  --ip 172.100.0.8 \
    -p 9002:9002 \
    -v "$PWD"/www/masterlab:/usr/workspaces/project \
    -w /usr/workspaces/project \
    php2-cli \
    php  ./bin/swoole_server.php
```

	
