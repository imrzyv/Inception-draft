# User Documentation

## What services does this stack provide?

- **A WordPress website**, reachable at `https://login.42.fr`, for
  publishing and managing pages/posts.
- **A WordPress administration panel**, reachable at
  `https://login.42.fr/wp-admin`, for managing users, pages, and settings.
- Behind the scenes, a **MariaDB database** stores all WordPress content,
  and **NGINX** is the secure (HTTPS-only) front door to everything.

## Starting and stopping the project

From the root of the repository:

```bash
make up      # build (if needed) and start everything in the background
make stop    # stop the containers without removing them
make start   # start previously-stopped containers again
make down    # stop and remove the containers (data is kept, in the volumes)
make re      # full reset: wipe everything, including host data, and rebuild
```

## Accessing the website and the administration panel

1. Make sure `login.42.fr` resolves to `127.0.0.1` (or your VM's IP) — this
   is normally set up once in `/etc/hosts`.
2. Open `https://login.42.fr` in your browser for the public site.
3. Your browser will warn about the certificate — that's expected, it's
   self-signed. Accept/continue past the warning.
4. Open `https://login.42.fr/wp-admin` and log in with the administrator
   account to reach the dashboard.
5. Plain `http://login.42.fr` (port 80) is not served; only HTTPS on 443
   works, by design.

## Locating and managing credentials

All passwords live as plain text files in the `secrets/` folder at the root
of the repository (never committed to git):

- `secrets/db_root_password.txt` — MariaDB root password
- `secrets/db_password.txt` — WordPress database user password
- `secrets/wp_admin_password.txt` — WordPress administrator password
- `secrets/wp_user_password.txt` — WordPress second (editor) user password

Non-sensitive settings (domain name, database name, usernames, WordPress
title) are in `srcs/.env`.

To change a password: edit the relevant file in `secrets/`, then run
`make re` so the containers pick it up (WordPress/MariaDB only apply these
values on first initialization of their volumes).

## Checking that services are running correctly

```bash
make ps       # shows each container's status (should say "running"/"Up")
make logs     # tails logs from all three containers, Ctrl+C to stop
```

You can also check a specific container directly, e.g.:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

If `https://login.42.fr` loads and shows the WordPress site (not the
WordPress installation wizard), the stack is healthy.
