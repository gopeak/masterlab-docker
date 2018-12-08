FROM mysql:5.7

ENV MYSQL_ALLOW_EMPTY_PASSWORD yes

COPY privileges.sql /tmp/privileges.sql
COPY masterlab.sql /tmp/masterlab.sql
COPY dbinit.sh /tmp/dbinit.sh

RUN echo "sql_mode=NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER" >> /etc/mysql/mysql.conf.d/mysqld.cnf ;\
    echo "ngram_token_size=2" >> /etc/mysql/mysql.conf.d/mysqld.cnf

CMD ["sh", "/tmp/dbinit.sh"]