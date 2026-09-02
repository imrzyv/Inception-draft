*This project has been created as part of the 42 curriculum by imirzaev.*

# Inception

## Description

Inception is a system administration project that builds a small, TLS-only
web infrastructure entirely with Docker. Three custom-built images —
**NGINX**, **WordPress + php-fpm**, and **MariaDB** — each run in their own
container, wired together by Docker Compose over a dedicated bridge network.
WordPress's files and database are kept in named volumes so data survives
container rebuilds. NGINX is the only container exposed to the host, and it
only accepts HTTPS (TLSv1.2/TLSv1.3) on port 443.

The goal is to practice core Docker/system-administration skills: writing
Dockerfiles from a minimal base image rather than pulling pre-built images,
managing multi-container applications with Compose, handling persistent
storage with named volumes, isolating services on a private network, and
keeping credentials out of the image layers and out of git.


## Instructions

1. **Set up a Virtual Machine.** This project must run inside a VM (install
   VirtualBox, create a Debian or Ubuntu VM with at least 2 GB RAM and
   20 GB disk, install the OS normally).

2. **Install Docker inside the VM:**
```bash
   sudo apt update
   sudo apt install -y docker.io docker-compose-v2
   sudo usermod -aG docker $USER
```
   Log out and back in after this.

3. **Clone the repository:**
```bash
   git clone <this-repository>
   cd inception
```

4. **Point the domain at the VM:**
```bash
   echo "127.0.0.1   imirzaev.42.fr" | sudo tee -a /etc/hosts
```

5. **Build and start everything:**
```bash
   make
```

6. **Open the site:** go to `https://imirzaev.42.fr` in a browser. You'll
   get a certificate warning — that's expected, click through it.

## Resources

- Docker documentation: https://docs.docker.com/
- Docker Compose file reference: https://docs.docker.com/compose/compose-file/
- WP-CLI handbook: https://developer.wordpress.org/cli/commands/
- NGINX documentation: https://nginx.org/en/docs/
- MariaDB Knowledge Base: https://mariadb.com/kb/en/

**AI usage:** Claude (Anthropic) was used to help to write and rephrase the documentation (README.md, USER_DOC.md, DEV_DOC.md)
and explain certain concepts like bridge network or Docker volumes.

## Project design choices

**Base images:** both custom images that need a full OS use
`debian:bookworm` — the penultimate stable Debian release (13 "trixie" is
current stable at the time of writing). Pinning to a specific major version
(rather than `latest`) keeps builds reproducible.

**Virtual Machines vs Docker**
A VM virtualizes an entire machine, including its own kernel, which makes it
heavier to boot and slower to provision but very strongly isolated. A Docker
container shares the host kernel and only packages the application and its
dependencies, so it starts in a fraction of a second and uses far less disk
and memory — at the cost of weaker isolation than a full VM. This project
uses Docker *inside* a VM: the VM provides the required 42-campus isolation
boundary, and Docker provides fast, reproducible, per-service packaging
inside it.

**Secrets vs Environment Variables**
Values in `srcs/.env` are visible in `docker inspect` output and to any
process that can read the container's environment, so they're only used for
non-sensitive configuration (domain name, database name, usernames). Actual
passwords are passed as Docker secrets: they're mounted read-only as files
under `/run/secrets/` inside the container and are never baked into an
image layer or exposed via `docker inspect`.

**Docker Network vs Host Network**
`network: host` makes a container share the host's network namespace
directly, exposing every port the container binds to and removing the
isolation between containers. This project instead defines a private bridge
network (`inception`) so the three containers can resolve each other by
service name (`mariadb`, `wordpress`, `nginx`) and only NGINX's port 443 is
published to the host.

**Docker Volumes vs Bind Mounts**
A bind mount points directly at a path on the host filesystem, so its
permissions, format, and existence depend entirely on the host. A named
volume is managed by Docker itself, has a defined lifecycle independent of
any particular host path, and is the mechanism required by this subject for
persistent WordPress/MariaDB storage — while still being configured (via
`driver_opts`) to physically store its data under `/home/login/data`.
