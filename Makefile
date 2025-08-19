# Docker Management TUI Helper (DMTH) Makefile

# Automatic hostname detection
DETECTED_HOST := $(shell hostname)
HOST ?= $(DETECTED_HOST)

# Configuration
DATA_DIR ?= $(HOME)/.local/docker

# Targets
.PHONY: all install uninstall clean check-host create-data-dir pull push up down status logs restart help

# Show help information
help:
	@echo "Docker Management TUI Helper (DMTH) - Available Commands:"
	@echo ""
	@echo "  make help          - Show this help message"
	@echo "  make status        - Show running containers for this host"
	@echo "  make up            - Start services in background"
	@echo "  make down          - Stop services"
	@echo "  make restart       - Restart services"
	@echo "  make pull          - Pull latest images"
	@echo "  make push          - Push images"
	@echo "  make logs          - Show container logs"
	@echo "  make create-data-dir - Create/verify data directory"
	@echo "  make clean         - Clean temporary files and Docker resources"
	@echo ""
	@echo "  Current host: $(HOST)"
	@echo "  Data directory: $(DATA_DIR)"
	@echo ""
	@echo "  Override host: make <command> HOST=<hostname>"

# Check if host configuration exists
check-host:
	@if [ ! -d "hosts/$(HOST)" ]; then \
		echo "Error: Host configuration 'hosts/$(HOST)' not found!"; \
		echo "Available hosts:"; \
		ls -1 hosts/ 2>/dev/null || echo "  No host configurations found"; \
		echo ""; \
		echo "Usage: make <target> HOST=<hostname>"; \
		echo "Or create a configuration directory for this host: hosts/$(HOST)"; \
		exit 1; \
	fi
	@echo "Using host configuration: $(HOST)"

create-data-dir:
	@echo "Checking data directory: $(DATA_DIR)"
	@if [ ! -d "$(DATA_DIR)" ]; then \
		echo "Creating data directory..."; \
		mkdir -p $(DATA_DIR); \
		echo "Data directory created successfully."; \
	else \
		echo "Data directory already exists."; \
	fi
	@echo "Setting permissions to 775..."
	@chmod 775 $(DATA_DIR)
	@echo "Data directory ready: $(DATA_DIR)"

status: check-host
	@echo "Container status for host: $(HOST)"
	@docker compose -f hosts/$(HOST)/docker-compose.yml ps

pull: check-host
	@echo "Pulling latest images for host: $(HOST)..."
	@docker compose -f hosts/$(HOST)/docker-compose.yml pull
	@echo "Pull complete."

push: check-host
	@echo "Pushing images for host: $(HOST)..."
	@docker compose -f hosts/$(HOST)/docker-compose.yml push
	@echo "Push complete."

up: check-host
	@echo "Starting services for host: $(HOST)..."
	@docker compose -f hosts/$(HOST)/docker-compose.yml up -d
	@echo "Services started successfully."

down: check-host
	@echo "Stopping services for host: $(HOST)..."
	@docker compose -f hosts/$(HOST)/docker-compose.yml down
	@echo "Services stopped successfully."

restart: check-host
	@echo "Restarting services for host: $(HOST)..."
	@docker compose -f hosts/$(HOST)/docker-compose.yml restart
	@echo "Services restarted successfully."

logs: check-host
	@echo "Showing logs for host: $(HOST) (Ctrl+C to exit)..."
	@docker compose -f hosts/$(HOST)/docker-compose.yml logs -f

clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.tmp" -delete
	@find . -name "*.bak" -delete
	@find . -name "*.log" -delete
	@docker system prune -f
	@docker volume prune -f
	@docker image prune -f
	@echo "Cleaning complete."
