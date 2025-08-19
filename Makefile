# Docker Management TUI Helper (DMTH) Makefile

# Configuration
DESTDIR ?= /usr/local/bin
CONFIG_DIR ?= $(HOME)/.dmth
PROJECT_DIR := $(shell pwd)
SCRIPT_NAME := dockermenu

# Targets
.PHONY: all install uninstall clean

all:
	@echo "Available targets:"
	@echo "  install    - Install the Docker Management TUI Helper"
	@echo "  uninstall  - Uninstall the Docker Management TUI Helper"
	@echo "  clean      - Remove temporary files"

install: $(SCRIPT_NAME)
	@echo "Installing Docker Management TUI Helper..."
	@mkdir -p $(CONFIG_DIR)
	@test -f "$(CONFIG_DIR)/master.env" || \
		cp -n .env.sample "$(CONFIG_DIR)/master.env" && \
		chmod 600 "$(CONFIG_DIR)/master.env"
	@mkdir -p $(DESTDIR)
	@sudo ln -sf "$(PROJECT_DIR)/$(SCRIPT_NAME)" "$(DESTDIR)/$(SCRIPT_NAME)"
	@sudo chmod +x "$(PROJECT_DIR)/$(SCRIPT_NAME)"
	@echo "Installation complete! You can now run '$(SCRIPT_NAME)' from anywhere."

uninstall:
	@echo "Uninstalling Docker Management TUI Helper..."
	@sudo rm -f "$(DESTDIR)/$(SCRIPT_NAME)"
	@echo "Uninstallation complete. Configuration directory $(CONFIG_DIR) was preserved."
	@echo "To completely remove all configuration, run: rm -rf $(CONFIG_DIR)"

clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.tmp" -delete
	@find . -name "*.bak" -delete
	@echo "Cleaning complete."
