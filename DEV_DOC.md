# Developer Documentation

## Prerequisites

- A Linux VM with Docker and the Docker Compose plugin installed
- `make`
- sudo access (needed for `/home/imirzaev/data` and `make fclean`)

## Setting up from scratch

1. Clone the repository onto the VM.
2. Add `127.0.0.1  imirzaev.42.fr` to `/etc/hosts`.
3. Set real passwords in the four files under `secrets/` (replace the
   `changeme_*` placeholders). These files are gitignored.
4. Check `srcs/.env` if you want to change any non-secret config
   (domain, database name, usernames). `WP_ADMIN_USER` must not contain
   "admin" anywhere in it.

## Building and running

```bash
make            # build images and start everything
make build      # rebuild images only
make down       # stop and remove containers (data kept)
make clean      # down + prune dangling Docker resources
make fclean     # full wipe: containers, volumes, images, and host data
make re         # fclean then up (fresh rebuild)
```

Each service builds from its own Dockerfile in `srcs/requirements/<service>/`.
On first run, each container's entrypoint script does one-time setup
(creating the database, installing WordPress, generating a TLS cert), then
hands off to the real process (`mariadbd`, `php-fpm8.2 -F`, `nginx`) running
in the foreground as PID 1.

## Useful commands

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f <service>
docker exec -it mariadb bash
docker exec -it mariadb mariadb -u root -p
docker volume ls
docker volume inspect srcs_db_data
docker network ls
```

## Where data is stored

- MariaDB data → `/home/imirzaev/data/mariadb`
- WordPress files → `/home/imirzaev/data/wordpress`

Both are Docker named volumes, physically stored at those host paths. Data
survives `make down` and VM reboots — only `make fclean` removes it.