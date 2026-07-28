#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Only run first-time setup if the data directory is empty (fresh named volume).
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[mariadb-entrypoint] Initializing data directory..."
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal > /dev/null

	# Start mariadbd temporarily, without networking, to run setup SQL.
	mariadbd --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
	TMP_PID=$!

	# Wait until the temporary server is ready to accept commands.
	until mariadb-admin --socket=/run/mysqld/mysqld.sock ping --silent 2>/dev/null; do
		sleep 1
	done

	mariadb --socket=/run/mysqld/mysqld.sock -u root <<-SQL
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
		FLUSH PRIVILEGES;
	SQL

	# Stop the temporary instance cleanly before handing off to the real one.
	mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" shutdown
	wait "$TMP_PID"
	echo "[mariadb-entrypoint] Initialization complete."
fi

# Hand off PID 1 to the real daemon, running in the foreground.
exec mariadbd --user=mysql
