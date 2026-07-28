# =============================================================================
#  Inception - Makefile
#  Wraps docker compose so the whole stack can be built/launched/torn down
#  with simple make targets.
# =============================================================================

LOGIN        := imirzaev
DATA_DIR     := /home/$(LOGIN)/data
COMPOSE      := docker compose -f srcs/docker-compose.yml
ENV_FILE     := srcs/.env

all: up

# Create the host directories the named volumes will bind to, then build+run.
up: data_dirs
	$(COMPOSE) up --build -d

build:
	$(COMPOSE) build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart: down up

# Stop and remove containers, networks. Volumes and images kept.
clean: down
	docker system prune -f

# Full wipe: containers, volumes, images related to this project, and host data.
fclean: clean
	$(COMPOSE) down -v --rmi all
	sudo rm -rf $(DATA_DIR)

re: fclean up

data_dirs:
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

.PHONY: all up build down stop start restart clean fclean re data_dirs logs ps
