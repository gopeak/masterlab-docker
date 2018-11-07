FROM redis

COPY ./redis.conf /usr/local/etc/redis/redis.conf

RUN chmod 777 /usr/local/etc/redis/redis.conf
RUN chown redis:redis /usr/local/etc/redis/redis.conf

RUN chmod 777 -R /data
RUN chown redis:redis -R /data

EXPOSE 6379

CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]