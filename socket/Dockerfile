FROM golang:1.12-stretch

ENV TZ=Asia/Shanghai

ENV APP_PORT        9002
ENV MYSQL_HOST      mysql
ENV MYSQL_PORT      3306
ENV MYSQL_DB_NAME   masterlab
ENV MYSQL_USER      root
ENV MYSQL_PASSWORD  123456

COPY sources.list /etc/apt/sources.list

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        rsync \
        bzip2 \
        cron

RUN set -ex; \
    mkdir /go/src/masterlab_socket; \
    mkdir /go/src/app; \
    git clone https://github.com/gopeak/masterlab_socket.git /go/src/masterlab_socket; \
    cd /go/src/masterlab_socket; \
    go build; \
    mv /go/src/masterlab_socket/masterlab_socket /go/src/app; \
    chmod +x /go/src/app/masterlab_socket; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /go/src/app
COPY entrypoint.sh /usr/local/bin/

RUN set -ex; \
    chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE $APP_PORT
CMD ["/go/src/app/masterlab_socket"]