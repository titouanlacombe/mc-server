BACKUPS_DIR=./backups
DATA_DIR=./data
SERVER_DIR=$(DATA_DIR)/mc-server
COMPOSE=docker compose -p mc-waves
TAR_ARGS=--use-compress-program=pigz

export

default: up

mkdata:
	@mkdir -p $(BACKUPS_DIR) $(SERVER_DIR)

up: mkdata
	@echo "Starting server..."
	@$(COMPOSE) up -d

down:
	@echo "Stopping server..."
	@$(COMPOSE) down

restart: down up

logs:
	@$(COMPOSE) logs -f

rcon:
	@$(COMPOSE) exec mc-server rcon-cli

tunnel:
	@supervisord -c supervisord.conf

backup: mkdata down
	@echo "Backing up data..."
	@tar $(TAR_ARGS) -cf $(BACKUPS_DIR)/backup-$(shell date +%Y-%m-%d-%H:%M:%S).tar.gz -C $(SERVER_DIR) .

backup_up: backup up

load_backup: mkdata down
	@echo "Loading backup..."
	@if [ -z "$(BACKUP)" ]; then \
		echo "Usage: make load_backup BACKUP=backup.tar.gz"; \
		exit 1; \
	fi
	@tar $(TAR_ARGS) -xf $(BACKUPS_DIR)/$(BACKUP) -C $(SERVER_DIR)

load_backup_up: load_backup up
