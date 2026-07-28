# Debian 12 "bookworm" = penultimate stable Debian release (13 "trixie" is current stable)
FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        mariadb-server \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb-entrypoint.sh /usr/local/bin/mariadb-entrypoint.sh
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

RUN mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld \
    && rm -rf /var/lib/mysql/*

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]