# Define the source and destination directories
DATA_DIR="./data"
BACKUP_DIR="./backup"

COMPOSE_PROJECT_NAME="mc-waves"

default: start

mkdata:
	@mkdir -p $(DATA_DIR) $(BACKUP_DIR)

start_tunnel: stop_tunnel
	@echo "Starting tunnel..."
	@python3 tunnel.py &> tunnel.log & echo $$! > tunnel.pid

stop_tunnel:
	@if [ -f tunnel.pid ]; then \
		echo "Stopping tunnel..."; \
		kill -2 $$(cat tunnel.pid) 2>/dev/null || echo "Tunnel not running"; \
		rm tunnel.pid; \
	fi

start: mkdata
	@echo "Starting server..."
	@docker-compose up -d
	@$(MAKE) start_tunnel

stop:
	@echo "Stopping server..."
	@$(MAKE) stop_tunnel
	@docker-compose down

restart: stop start

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
