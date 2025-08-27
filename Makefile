# Docker Management TUI Helper (DMTH) Makefile

# Automatic hostname detection
DETECTED_HOST := $(shell hostname)
HOST ?= $(DETECTED_HOST)

# Configuration
DATA_DIR ?= $(HOME)/.local/docker

# Targets
.PHONY: all install uninstall clean check-host create-data-dir pull push up down status host-logs logs exec restart list help

# Show help information
help:
	@echo "Docker Management TUI Helper (DMTH) - Available Commands:"
	@echo ""
	@echo "Container Management:"
	@echo "  make list          - List all containers (name and ID only)"
	@echo "  make status        - Show running containers for this host"
	@echo "  make logs <ID>     - Show logs for specific container (Ctrl+C to exit)"
	@echo "  make exec <ID>     - Execute shell inside specific container"
	@echo ""
	@echo "Service Management:"
	@echo "  make up            - Start services in background"
	@echo "  make down          - Stop services"
	@echo "  make restart       - Restart services"
	@echo "  make host-logs     - Show logs for host services (Ctrl+C to exit)"
	@echo ""
	@echo "Image Management:"
	@echo "  make pull          - Pull latest images"
	@echo "  make push          - Push images"
	@echo ""
	@echo "System Management:"
	@echo "  make create-data-dir - Create/verify data directory"
	@echo "  make clean         - Clean temporary files and Docker resources"
	@echo "  make help          - Show this help message"
	@echo ""
	@echo "  Current host: $(HOST)"
	@echo "  Data directory: $(DATA_DIR)"
	@echo ""
	@echo "  Override host: make <command> HOST=<hostname>"
	@echo "  Example: make up HOST=production"

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

host-logs: check-host
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

# List all containers showing only name and ID
list:
	@echo "Listing all containers (name and ID only):"
	@docker container ls --format "table {{.Names}}\t{{.ID}}"

# Show logs for a specific container
logs:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "Error: Please specify a container ID"; \
		echo "Usage: make logs <container_id>"; \
		echo "Use 'make list' to see available containers"; \
		exit 1; \
	fi
	@echo "Showing logs for container: $(filter-out $@,$(MAKECMDGOALS)) (Ctrl+C to exit)..."
	@docker logs -f $(filter-out $@,$(MAKECMDGOALS))

# Execute shell inside a specific container
exec:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "Error: Please specify a container ID"; \
		echo "Usage: make exec <container_id>"; \
		echo "Use 'make list' to see available containers"; \
		exit 1; \
	fi
	@echo "Executing shell inside container: $(filter-out $@,$(MAKECMDGOALS))"
	@echo "Type 'exit' to return to host shell"
	@docker exec -it $(filter-out $@,$(MAKECMDGOALS)) sh

