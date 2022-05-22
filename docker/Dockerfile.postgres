FROM alpine 


RUN apk add postgresql && \ 
    mkdir /run/postgresql && \
    chown postgres:postgres /run/postgresql/

USER postgres

ENV PGDATA /var/lib/postgresql/data

RUN mkdir /var/lib/postgresql/data && \
    chmod 0700 /var/lib/postgresql/data && \ 
    initdb  /var/lib/postgresql/data && \
    echo "host all all 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf && \
    echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf && \
    pg_ctl start  && \
    psql -U postgres -c "CREATE DATABASE mediacms" && \
    psql -c "CREATE USER mediacms WITH ENCRYPTED PASSWORD 'mediacms'" && \
    psql -c "GRANT ALL PRIVILEGES ON DATABASE mediacms TO mediacms"

VOLUME /var/lib/postgresql/data

EXPOSE 5432

CMD ["postgres"]