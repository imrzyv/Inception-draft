#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

WP_PATH=/var/www/html
export WP_CLI_ALLOW_ROOT=1

# Wait for MariaDB to accept connections before doing anything else.
echo "[wp-entrypoint] Waiting for MariaDB at mariadb:3306..."
until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
	sleep 2
done
echo "[wp-entrypoint] MariaDB is up."

# Only run first-time install if this is a fresh volume (no wp-config.php yet).
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
	echo "[wp-entrypoint] Downloading WordPress core..."
	wp core download --path="${WP_PATH}" --allow-root

	echo "[wp-entrypoint] Writing wp-config.php..."
	wp config create \
		--path="${WP_PATH}" \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost="mariadb:3306" \
		--allow-root

	echo "[wp-entrypoint] Installing WordPress..."
	wp core install \
		--path="${WP_PATH}" \
		--url="${WP_URL}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root

	echo "[wp-entrypoint] Creating second (non-admin) user..."
	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
		--path="${WP_PATH}" \
		--role=editor \
		--user_pass="${WP_USER_PASSWORD}" \
		--allow-root

	chown -R www-data:www-data "${WP_PATH}"
	echo "[wp-entrypoint] WordPress install complete."
fi

# Hand off PID 1 to php-fpm, running in the foreground.
exec php-fpm8.2 -F
