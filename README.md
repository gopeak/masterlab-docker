当前项目是以Docker方式部署项目管理工具：Masterlab, 目前只支持Masterlab3.0以上版本。  
Masterlab的运行依赖于 Mysql Nginx|Apache PHP环境，Mysql和Nginx直接使用DockerHub的镜像版本，   
PHP则需要我们构建FPM和Cli镜像，已push到DockerHub上。  
```
# 镜像仓库
https://hub.docker.com/repository/docker/gopeak/masterlab
# FPM和Cli镜像，主要是编译和加载了swoole,redis扩展
gopeak/masterlab:php-fpm-74
gopeak/masterlab:php-cli-74

```

提供 Docker Run 和 Docker-compose 两种部署方式。

建议使用Docker-compose部署，要使用Docker Run方式的请访问 https://github.com/gopeak/masterlab-docker/blob/master/STEP.md



## Docker-compose 安装步骤

### 安装准备，先安装以下命令行工具

- git unzip 
- docker [https://docs.docker.com/install/]
- docker-compose [https://docs.docker.com/compose/install/#install-compose]


### 第一步，获取Docker和Masterlab程序

```
 git clone https://gitee.com/firego/masterlab-docker.git
 # 海外网络请用 https://github.com/gopeak/masterlab-docker.git

 cd ./masterlab-docker/www
 git clone https://gitee.com/firego/masterlab.git
 # 海外网络请用 https://github.com/gopeak/masterlab.git
 cd ./masterlab
 unzip ./vendor.zip          // 解压依赖的类库
```
   
### 第二步，运行容器编排
首先应配置镜像加速器（可选）:  
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
其他操作系统 请参考 https://www.runoob.com/docker/docker-mirror-acceleration.html  

加速镜像配置完毕后，启用服务，第一次需要构建镜像
```
 cd ../../              // 回到masterlab-docker的根目录
 docker-compose up -d   // 容器编排命令
```
容器编排成功后，以后可以使用以下命令控制服务
```
 docker-compose ps           // 查看运行的容器
 docker-compose stop         // 停止服务
 docker-compose start        // 启动服务
 docker-compose restart      // 重启服务
 docker-compose start nginx  // 单独启动nginx服务
 docker-compose stop nginx   // 单独停止nginx服务
 docker-compose logs         // 查看服务日志输出
 docker-compose kill nginx   // 通过发送 SIGKILL 信号来停止指定服务的容器
 docker-compose logs         // 查看服务日志输出
 docker-compose up           // 构建并启动服务
 docker-compose build        // 构建或者重新构建服务
 docker network ls           // 查看docker的网络配置

```


### 第三步，赋予权限

```
 # 查看运行已经运行的容器,找到php的容器id如ee84df733af6 
 docker ps          
 # 进入php
 docker exec -it ee84df733af6 /bin/bash       
 #  赋予读写权限，执行完 ctrl + d 退出
 chown -R www-data:www-data ./              
 # 按键 ctrl + d 退出
```


### 第四步，访问 /install  进行图形安装界面

http://www.masterlab.com/install （先在hosts里追加：你的服务器ip www.masterlab.com ，成功后修改为你实际的域名）

注: 连接数据库的地址，用户名,密码分别为  
172.100.0.5 root 123456

安装结束后 将 ./conf/nginx/conf.d/masterlab.conf 里的www.masterlab.com为你自己的域名即可

 
### 第五步，启动Swoole服务
- 首先，自定义构建 `PHP-CLI` 镜像，安装 `Git`，`Composer`，`Swoole` 等扩展和工具

```shell
# 构拉取php-cli镜像
docker pull gopeak/masterlab:php-cli-74
```

- 修改masterlab的配置文件 config.yml,找到 `socket/host`节点，将`127.0.0.1`修改为`0.0.0.0`
```
socket:
  host: '0.0.0.0'
  port: '9002'
  port_websocket: 9003
 
```


- 启动 `Swoole` 进程
 

```shell
docker run -d  -it --rm --name www-data  --network masterlab-docker_docker_net  --ip 172.100.0.8 \
    -p 9002:9002 \
    -v "$PWD"/www/masterlab:/usr/workspaces/project \
    -w /usr/workspaces/project \
    gopeak/masterlab:php-cli-74 \
    php  ./bin/swoole_server.php
```
如果network报错，请执行 `docker network ls`查看网络名称,替换掉即可。

- 最后以管理账号登录masterlab,在管理页面"系统设置/邮件配置/修改"，将`MasterlabSocket服务器地址`修改为`172.100.0.8`,`服务器类型`修改为`swoole`  
  然后回到管理主界面 '/admin/main',查看MasterlabSocket服务的连接状态是否成功。

 

	
