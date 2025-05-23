#!/bin/bash

# =================================================================
# DMTH Template Manager
# Handles deployment of standard templates to host directories
# =================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
TEMPLATE_DIR="../templates"
STANDARD_TEMPLATE_DIR="$TEMPLATE_DIR/standard-stack"

# Print log message with timestamp
log() {
    local log_type=$1
    local message=$2
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    case $log_type in
        info)
            echo -e "[${timestamp}] ${GREEN}INFO:${NC} $message"
            ;;
        warn)
            echo -e "[${timestamp}] ${YELLOW}WARNING:${NC} $message"
            ;;
        error)
            echo -e "[${timestamp}] ${RED}ERROR:${NC} $message" >&2
            ;;
        *)
            echo -e "[${timestamp}] $message"
            ;;
    esac
}

# Check if directories exist
check_directories() {
    if [ ! -d "$TEMPLATE_DIR" ]; then
        log "error" "Template directory not found: $TEMPLATE_DIR"
        return 1
    fi

    if [ ! -d "$STANDARD_TEMPLATE_DIR" ]; then
        log "error" "Standard template directory not found: $STANDARD_TEMPLATE_DIR"
        return 1
    fi

    return 0
}

# Deploy template to host directory
# Parameters:
# $1 - Host name
# $2 - Target directory
deploy_template() {
    local host_name=$1
    local target_dir=$2

    if [ -z "$host_name" ]; then
        log "error" "No host name specified"
        return 1
    fi

    if [ -z "$target_dir" ]; then
        log "error" "No target directory specified"
        return 1
    fi

    # Create target directory if it doesn't exist
    if [ ! -d "$target_dir" ]; then
        log "info" "Creating target directory: $target_dir"
        mkdir -p "$target_dir"
    fi

    # Copy template files
    log "info" "Deploying standard stack template to $target_dir"

    # Check if docker-compose.yml already exists
    if [ -f "$target_dir/docker-compose.yml" ]; then
        log "warn" "docker-compose.yml already exists in $target_dir"
        read -p "Overwrite? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "info" "Deployment cancelled"
            return 1
        fi
    fi

    # Copy docker-compose.yml and replace placeholders
    cp "$STANDARD_TEMPLATE_DIR/docker-compose.yml" "$target_dir/"

    # Replace {{HOST_NAME}} with actual host name
    sed -i "s/{{HOST_NAME}}/$host_name/g" "$target_dir/docker-compose.yml"

    log "info" "Template deployed successfully to $target_dir"
    return 0
}

# List available templates
list_templates() {
    log "info" "Available templates:"

    if [ -d "$TEMPLATE_DIR" ]; then
        for template in "$TEMPLATE_DIR"/*; do
            if [ -d "$template" ]; then
                echo "- $(basename "$template")"
            fi
        done
    else
        log "error" "Template directory not found: $TEMPLATE_DIR"
        return 1
    fi

    return 0
}

# Show usage information
show_usage() {
    echo "Usage: template_manager.sh [OPTIONS] [COMMAND]"
    echo
    echo "Commands:"
    echo "  deploy [HOST_NAME] [TARGET_DIR]   Deploy standard template to target directory"
    echo "  list                             List available templates"
    echo
    echo "Options:"
    echo "  -h, --help                       Show this help message"
    echo
}

# Main function
main() {
    # Parse arguments
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi

    # Check directories
    check_directories || exit 1

    # Process commands
    case "$1" in
        deploy)
            if [ $# -lt 3 ]; then
                log "error" "Not enough arguments for deploy command"
                show_usage
                exit 1
            fi
            deploy_template "$2" "$3"
            ;;
        list)
            list_templates
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            log "error" "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
