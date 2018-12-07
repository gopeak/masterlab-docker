FROM gopeak/masterlab_db:0


EXPOSE 3306 33060

COPY entrypoint.sh /usr/local/bin/

RUN set -ex; \
    chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["mysqld"]