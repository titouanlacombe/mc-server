# Define the source and destination directories
DATA_DIR="./data"
BACKUP_DIR="./backup"

# Cloud server username and IP address
USERNAME=$(shell cat secrets/username)
SERVER_IP=$(shell cat secrets/server_ip)

COMPOSE_PROJECT_NAME="mc-waves"

default: start

.PHONY: start stop backup ssh_tunnel

mkdata:
	@mkdir -p $(DATA_DIR) $(BACKUP_DIR)

stop_tunnel:
	@if [ -f ssh_tunnel.pid ]; then \
		kill `cat ssh_tunnel.pid` || echo "No SSH tunnel process found"; \
		rm ssh_tunnel.pid; \
	fi

# Tunel port for the Minecraft server, Voice chat
start_tunnel: stop_tunnel
	@ssh -nNT \
		-R 25565:localhost:25565 \
		-R 24454:localhost:24454 \
		$(USERNAME)@$(SERVER_IP) &> tunnel.log & echo $$! > ssh_tunnel.pid

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
