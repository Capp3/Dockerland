#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
BACKUP_DIR="/usb_media_storage/backups"
DOCKER_DIR="/home/server/docker/knight0/data"
OWNER="server:server"
LOG_DIR="/var/log/backup_script"
LOG_FILE="$LOG_DIR/backup_$(date '+%Y%m%d_%H%M%S').log"

# Ensure the log directory exists and set permissions
sudo mkdir -p "$LOG_DIR"
sudo chmod 755 "$LOG_DIR"
sudo chown "$USER:$USER" "$LOG_DIR"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Ensure the backup directory exists
log "Ensuring backup directory exists."
sudo mkdir -p "$BACKUP_DIR"

# Clear Backup directory
log "Clearing backup directory."
sudo rm -rf "${BACKUP_DIR:?}/*"

# Set directory permissions
log "Setting permissions on backup directory."
sudo chmod -R 755 "$BACKUP_DIR"
sudo chown -R "$OWNER" "$BACKUP_DIR"

# Array of directories to back up
declare -A BACKUP_PATHS=(
    ["authelia"]="$DOCKER_DIR/authelia"
    ["bazarr"]="$DOCKER_DIR/bazarr"
    ["gluetun"]="$DOCKER_DIR/glueton"
    ["nginxpm"]="$DOCKER_DIR/nginxpm"
    ["letsencrypt"]="$DOCKER_DIR/letsencrypt"
    ["overseerr"]="$DOCKER_DIR/overseerr"
    ["portainer"]="$DOCKER_DIR/portainer"
    ["prowlarr"]="$DOCKER_DIR/portainer"
    ["radarr"]="$DOCKER_DIR/radarr"
    ["readarr"]="$DOCKER_DIR/readarr"
    ["sonarr"]="$DOCKER_DIR/sonarr"
)

# Perform backups
log "Starting backup process."
for key in "${!BACKUP_PATHS[@]}"; do
    SOURCE_DIR="${BACKUP_PATHS[$key]}"
    DEST_DIR="$BACKUP_DIR/$key"
    
    # Clear existing data in destination directory
    log "Clearing existing data in $DEST_DIR."
    sudo rm -rf "${DEST_DIR:?}/*"

    # Ensure destination directory exists
    log "Creating destination directory for $key."
    sudo mkdir -p "$DEST_DIR"

    # Copy files while preserving ownership and permissions
    if [ -d "$SOURCE_DIR" ]; then
        log "Backing up $key to $DEST_DIR while preserving ownership and permissions."
        sudo cp -R --preserve=all "$SOURCE_DIR"/* "$DEST_DIR"
    else
        log "WARNING: Source directory $SOURCE_DIR does not exist. Skipping."
    fi
done

log "Backup process completed successfully."
