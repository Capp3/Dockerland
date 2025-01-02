#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
BACKUP_DIR="/usb_media_storage/backups"
DOCKER_DIR="/home/server/docker/knight0/data"
LOG_DIR="/var/log/restore_script"
LOG_FILE="$LOG_DIR/restore_$(date '+%Y%m%d_%H%M%S').log"

# Ensure the log directory exists and set permissions
sudo mkdir -p "$LOG_DIR"
sudo chmod 755 "$LOG_DIR"
sudo chown "$USER:$USER" "$LOG_DIR"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to restore a directory
restore_directory() {
    SOURCE_DIR="$BACKUP_DIR/$1"
    DEST_DIR="$DOCKER_DIR/$1"

    if [ -d "$SOURCE_DIR" ]; then
        log "Restoring $1 from $SOURCE_DIR to $DEST_DIR."

        # Clear the destination directory
        log "Clearing existing data in $DEST_DIR."
        sudo rm -rf "${DEST_DIR:?}/*"

        # Ensure the destination directory exists
        sudo mkdir -p "$DEST_DIR"

        # Copy files while preserving ownership and permissions
        sudo cp -R --preserve=all "$SOURCE_DIR"/* "$DEST_DIR"

        log "Restoration of $1 completed successfully."
    else
        log "WARNING: Backup directory $SOURCE_DIR does not exist. Skipping."
    fi
}

# Array of directories to restore
DIRECTORIES=(
    "authelia"
    "bazarr"
    "gluetun"
    "nginxpm"
    "letsencrypt"
    "overseerr"
    "portainer"
    "prowlarr"
    "radarr"
    "readarr"
    "sonarr"
)

# Start restoration
log "Starting restoration process."
for dir in "${DIRECTORIES[@]}"; do
    restore_directory "$dir"
done

log "Restoration process completed successfully."
