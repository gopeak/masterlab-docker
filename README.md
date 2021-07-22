当前项目是以Docker方式安装项目管理工具：Masterlab。目前只支持Masterlab3.0以上版本。
支持 Docker Run 和 Docker-compos R 两种方式。

建议使用Docker-compose部署，要使用Docker Run方式的请访问 Docker-Run [https://github.com/gopeak/masterlab-docker/blob/master/STEP.md]



## Docker-compose 安装步骤

### 第一步，首先安装以下命令行工具

- git unzip 
- docker [https://docs.docker.com/install/]
- docker-compose [https://docs.docker.com/compose/install/#install-compose]


### 第二步，获取Docker项目代码

```
 git clone https://gitee.com/firego/masterlab-docker.git
# 海外网络请用 https://github.com/gopeak/masterlab-docker.git

```
   
### 第三步，获取Masterlab程序

```
 cd ./masterlab-docker/www
 git clone https://gitee.com/firego/masterlab.git
 # 海外网络请用 https://github.com/gopeak/masterlab.git
 cd ./masterlab
 unzip vendor.zip          // 解压依赖的类库
```


### 第三步 配置镜像加速器（可选）
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
   
### 第四步，运行容器编排
启用服务，第一次需要构建镜像
```
 cd ../../              // 回到masterlab-docker的根目录
 docker-compose up -d   // 容器编排命令，如果下载镜像很慢，建议使用国内的加速镜像
```
容器编排成功后，以后可以使用以下命令控制服务
```
 docker-compose stop      // 停止服务
 docker-compose start     // 启动服务
 docker-compose restart   // 重启服务

```


### 第五步，赋予权限

```
 docker ps                                   // 查看运行已经运行的容器
 docker exec -it masterlab-docker_php74_1 /bin/bash      // 进入php ,注：中间的masterlab-docker_php74_1可以使用容器id代替
 chown -R www-data:www-data ./               // 赋予读写权限，执行完 ctrl + d 退出
```


### 第六步，访问 /install  进行图形安装界面

http://www.masterlab.com/install （先在hosts里追加：你的服务器ip www.masterlab.com ，成功后修改为你实际的域名）

注: 连接数据库的地址，用户名,密码分别为  
172.100.0.5 root 123456

安装结束后 将 ./conf/nginx/conf.d/masterlab.conf 里的www.masterlab.com为你自己的域名即可

 
### 第七步，启动Swoole服务
- 首先，自定义构建 `PHP-CLI` 镜像，安装 `Git`，`Composer`，`Swoole` 等扩展和工具

```shell
# 构建镜像
docker build -t php4-cli ./php-cli/php74
```



- 启动 `Swoole` 进程
 

```shell
docker run -d  -it --rm --name www-data  --network masterlabdocker_docker_net  --ip 172.100.0.8 \
    -p 9002:9002 \
    -v "$PWD"/www/masterlab:/usr/workspaces/project \
    -w /usr/workspaces/project \
    php4-cli \
    php  ./bin/swoole_server.php
```

	
