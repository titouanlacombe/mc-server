DATA_DIR="./data"
BACKUP_DIR="./backup"
COMPOSE_PROJECT_NAME="mc-waves"

default: start

mkdata:
	@mkdir -p $(DATA_DIR) $(BACKUP_DIR)

start: mkdata
	@echo "Starting server..."
	@docker-compose up -d

stop:
	@echo "Stopping server..."
	@docker-compose down

rcon:
	@docker-compose exec mc-server rcon-cli

backup: mkdata stop
	@echo "Backing up data..."
	@rsync -av --delete $(DATA_DIR)/ $(BACKUP_DIR)/
	@$(MAKE) start

load_backup: mkdata stop
	@echo "Loading backup..."
	@rsync -av --delete $(BACKUP_DIR)/ $(DATA_DIR)/
	@$(MAKE) start

logs:
	@docker-compose logs -f

restart: stop start
