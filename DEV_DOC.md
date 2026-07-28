# Developer Documentation

## Prerequisites

- A Linux virtual machine (this project must run inside a VM, not directly
  on bare metal or in a container-only sandbox).
- Docker Engine + the Docker Compose plugin (`docker compose`, not the
  standalone `docker-compose` v1 binary).
- `make`.
- Root/sudo access, since named volumes are configured to store their data
  under `/home/<login>/data`, and `make fclean` removes that directory.

## Setting up the environment from scratch

1. Clone the repository onto the VM.
2. Replace every placeholder `login` (in `Makefile`, `srcs/.env`, `README.md`)
   with your actual 42 login. That value must also match the folder your
   volumes will be bound to: `/home/<login>/data`.
3. Add `127.0.0.1  login.42.fr` to `/etc/hosts`.
4. Set real passwords in the four files under `secrets/` (they ship with
   placeholder values — `changeme_*` — that must be replaced before first
   build). These files are gitignored and must never be committed.
5. Review `srcs/.env` for non-secret configuration: `DOMAIN_NAME`,
   `MYSQL_DATABASE`, `MYSQL_USER`, `WP_TITLE`, `WP_URL`, `WP_USER`,
   `WP_ADMIN_USER`. Note `WP_ADMIN_USER` must not contain "admin" (case
   insensitive) anywhere in it, per the subject's constraint.

## Building and launching with the Makefile / Docker Compose

```bash
make            # equivalent to `make up`: creates host data dirs, builds
                # images, and starts the stack in the background
make build      # (re)build images without starting containers
make down       # stop and remove containers (volumes/images kept)
make clean      # `make down` + prune dangling Docker resources
make fclean     # full teardown: containers, volumes, images, AND the
                # /home/<login>/data directory on the host
make re         # fclean then up, i.e. a totally fresh rebuild
```

Under the hood, each target calls `docker compose -f srcs/docker-compose.yml
...`. Each of the three services builds from its own Dockerfile under
`srcs/requirements/<service>/`, and each container's ENTRYPOINT script:

- On first run against an empty volume: performs one-time setup (DB schema
  and users for MariaDB, WordPress core download/config/install for
  WordPress, self-signed cert generation for NGINX).
- On every run: finishes with `exec` of the real foreground daemon
  (`mariadbd`, `php-fpm8.2 -F`, or `nginx -g "daemon off;"`) so that daemon
  becomes PID 1 — no `tail -f`, no background loops.

## Useful commands for managing containers and volumes

```bash
docker compose -f srcs/docker-compose.yml ps            # container status
docker compose -f srcs/docker-compose.yml logs -f <svc> # live logs
docker exec -it mariadb bash                             # shell into a container
docker exec -it mariadb mariadb -u root -p                # DB shell (enter root pw from secrets/)
docker volume ls                                          # list volumes
docker volume inspect srcs_db_data                        # inspect mount point
docker network ls                                          # confirm the inception network exists
```

## Where project data is stored and how it persists

- `db_data` volume → mounted at `/var/lib/mysql` inside `mariadb`,
  physically backed by `/home/<login>/data/mariadb` on the host.
- `wp_data` volume → mounted at `/var/www/html` inside both `wordpress`
  and `nginx` (WordPress needs write access, NGINX needs read access to
  serve static files directly), physically backed by
  `/home/<login>/data/wordpress` on the host.

Both are Docker **named volumes** (not bind mounts): Docker manages their
lifecycle, but the `driver_opts` in `docker-compose.yml` point their actual
storage at the required host path via a `none`/`bind` local driver. Because
the underlying data lives on the host, it survives `make down`, container
rebuilds, and VM reboots — it is only removed by `make fclean`.
