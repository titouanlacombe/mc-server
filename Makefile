DATA_DIR=./data
BACKUP_DIR=./backup
COMPOSE=docker compose -p mc-waves

default: up

mkdata:
	@mkdir -p $(DATA_DIR) $(BACKUP_DIR)

up: mkdata
	@echo "Starting server..."
	@$(COMPOSE) up -d

down:
	@echo "Stopping server..."
	@$(COMPOSE) down

rcon:
	@$(COMPOSE) exec mc-server rcon-cli

backup: mkdata down
	@echo "Backing up data..."
	@rsync -qca --delete $(DATA_DIR)/ $(BACKUP_DIR)/

backup_up: backup up

load_backup: mkdata down
	@echo "Loading backup..."
	@rsync -qca --delete $(BACKUP_DIR)/ $(DATA_DIR)/

load_backup_up: load_backup up

logs:
	@$(COMPOSE) logs -f

tunnel:
	supervisord -c supervisord.conf

restart: down up
