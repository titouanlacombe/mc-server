DATA_DIR=./data
BACKUP_DIR=./backup
COMPOSE=docker compose -p mc-waves

default: start

mkdata:
	@mkdir -p $(DATA_DIR) $(BACKUP_DIR)

start: mkdata
	@echo "Starting server..."
	@$(COMPOSE) up -d

stop:
	@echo "Stopping server..."
	@$(COMPOSE) down

rcon:
	@$(COMPOSE) exec mc-server rcon-cli

backup: mkdata stop
	@echo "Backing up data..."
	@rsync -qca --delete $(DATA_DIR)/ $(BACKUP_DIR)/

backup_start: backup start

load_backup: mkdata stop
	@echo "Loading backup..."
	@rsync -qca --delete $(BACKUP_DIR)/ $(DATA_DIR)/

load_backup_start: load_backup start

logs:
	@$(COMPOSE) logs -f

tunnel:
	supervisord -c supervisord.conf

restart: stop start
