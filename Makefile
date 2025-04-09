# Create .env file if it does not exist
$(shell ./setup_env.sh 1>&2)

PUID=$(shell id -u)
PGID=$(shell id -g)

DATA_DIR=./data
SERVER_DIR=$(DATA_DIR)/app
BACKUPS_DIR=$(DATA_DIR)/backups
COMPOSE=docker compose -p mc-waves

include .env
export

APP=app
COMPOSE=docker compose

default: up

mkdata:
	@for dir in $(BACKUPS_DIR) $(SERVER_DIR); do \
		mkdir -p $$dir; \
	done

deps: mkdata

up: deps
	@echo "Starting server..."
	@$(COMPOSE) up -d

down:
	@echo "Stopping server..."
	@$(COMPOSE) down

pullup: deps
	@$(COMPOSE) up -d --pull always

recreate: deps
	@echo "Recreating server..."
	@$(COMPOSE) up -d --force-recreate

restart:
	@echo "Restarting server..."
	@$(COMPOSE) restart $(APP)

logs:
	@$(COMPOSE) logs -f --tail=100 $(APP)

config:
	@$(COMPOSE) config

ps:
	@$(COMPOSE) ps

stats:
	@$(COMPOSE) stats

attach:
	@${COMPOSE} exec $(APP) bash

attach-root:
	@${COMPOSE} exec --user root $(APP) bash

rcon:
	@$(COMPOSE) exec $(APP) rcon-cli

tunnel:
	@echo "Not implemented yet"

backup: deps down
	@echo "Backing up data..."
	@BACKUP=$(BACKUPS_DIR)/backup-$(shell date +%Y-%m-%d-%H:%M:%S).tar.zst && \
		tar "-I zstd -3 -T0" -cf $$BACKUP -C $(SERVER_DIR) . && \
		echo "Backup saved to $(BACKUP)"

backup_up: backup up

load_backup: deps down
	@echo "Loading backup..."
	@if [ -z "$(BACKUP)" ]; then \
		echo "Usage: make load_backup BACKUP=backup.tar.zst"; \
		exit 1; \
	fi
	@tar -xf $(BACKUP) -C $(SERVER_DIR)

load_backup_up: load_backup up
