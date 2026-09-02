#!/bin/bash
set -e

envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

if [ ! -f /etc/nginx/ssl/inception.key ]; then
	echo "[nginx-entrypoint] Generating self-signed TLS certificate for ${DOMAIN_NAME}..."
	openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-subj "/C=FR/ST=IDF/L=Paris/O=42/OU=inception/CN=${DOMAIN_NAME}"
fi

exec nginx -g "daemon off;"
