FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        php8.2-fpm \
        php8.2-mysqli \
        php8.2-gd \
        php8.2-curl \
        php8.2-xml \
        php8.2-mbstring \
        php8.2-zip \
        curl \
        default-mysql-client \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS -o /usr/local/bin/wp \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wp-entrypoint.sh /usr/local/bin/wp-entrypoint.sh
RUN chmod +x /usr/local/bin/wp-entrypoint.sh

RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-entrypoint.sh"]
