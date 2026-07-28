FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        nginx \
        openssl \
        gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY tools/nginx-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

RUN mkdir -p /etc/nginx/ssl

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]
