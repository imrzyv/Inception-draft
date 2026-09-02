# User Documentation

## What this provides

- A WordPress site at `https://imirzaev.42.fr`
- An admin panel at `https://imirzaev.42.fr/wp-admin`
- MariaDB stores the content; NGINX is the HTTPS-only entry point

## Starting and stopping

```bash
make up      # start everything
make stop    # stop containers without removing them
make start   # start them again
make down    # stop and remove containers (data kept)
make re      # full reset and rebuild
```

## Accessing the site

1. Make sure `imirzaev.42.fr` is in `/etc/hosts`.
2. Open `https://imirzaev.42.fr` — accept the certificate warning, it's self-signed and expected.
3. Log into `https://imirzaev.42.fr/wp-admin` with the admin account.
4. Plain `http://imirzaev.42.fr` won't work — only HTTPS on 443 does.

## Credentials

All passwords are plain text files in `secrets/`, never committed to git:

- `secrets/db_root_password.txt`
- `secrets/db_password.txt`
- `secrets/wp_admin_password.txt`
- `secrets/wp_user_password.txt`

To change a password, edit the file and run `make re`.

## Checking it's working

```bash
make ps       # container status
make logs     # live logs from all three containers
```

If `https://imirzaev.42.fr` shows the WordPress site (not the install
wizard), everything's healthy.