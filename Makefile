LOGIN        := imirzaev
DATA_DIR     := /home/$(LOGIN)/data
COMPOSE      := docker compose -f srcs/docker-compose.yml

all: up

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

clean:
	$(COMPOSE) down -v --rmi all
	docker system prune -f

fclean: clean
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