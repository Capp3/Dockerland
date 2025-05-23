#!/usr/bin/env bash
# Docker Compose Standardization Script
# This script helps standardize Docker Compose files to follow best practices
# and ensures they use version 3.8

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if yq is installed (for YAML processing)
check_dependencies() {
    log_info "Checking dependencies..."

    # Check for yq (YAML processor)
    if ! command -v yq &> /dev/null; then
        log_error "Missing dependency: yq"
        echo "Please install yq (YAML processor) and try again."
        echo "Installation instructions: https://github.com/mikefarah/yq#install"
        exit 1
    fi

    # Check for docker compose
    if ! docker compose version &> /dev/null; then
        log_error "Missing dependency: docker compose"
        echo "Please install docker compose and try again."
        exit 1
    fi

    log_success "All dependencies are installed."
}

# Validate Docker Compose file
validate_compose_file() {
    local file="$1"

    log_info "Validating Docker Compose file: $file"

    if [ ! -f "$file" ]; then
        log_error "File does not exist: $file"
        return 1
    fi

    # Check Docker Compose syntax
    if ! docker compose -f "$file" config > /dev/null 2>&1; then
        log_error "Docker Compose file has syntax errors: $file"
        docker compose -f "$file" config
        return 1
    fi

    log_success "Docker Compose file is valid: $file"
    return 0
}

# Check Docker Compose version
check_compose_version() {
    local file="$1"

    log_info "Checking Docker Compose version in: $file"

    local version
    version=$(yq eval '.version' "$file")

    if [ "$version" = "null" ]; then
        log_warning "No version specified in $file"
        return 1
    elif [ "$version" != "3.8" ]; then
        log_warning "Docker Compose version is $version, should be 3.8"
        return 1
    fi

    log_success "Docker Compose version is 3.8"
    return 0
}

# Update Docker Compose version to 3.8
update_compose_version() {
    local file="$1"

    log_info "Updating Docker Compose version to 3.8 in: $file"

    # Create backup
    cp "$file" "${file}.bak"

    # Update version
    yq eval '.version = "3.8"' -i "$file"

    log_success "Updated Docker Compose version to 3.8"
}

# Ensure logging configuration is present
ensure_logging_config() {
    local file="$1"

    log_info "Checking logging configuration in: $file"

    local services
    services=$(yq eval '.services | keys | .[]' "$file")

    for service in $services; do
        if ! yq eval ".services.$service.logging" "$file" | grep -q "driver"; then
            log_warning "Adding logging configuration to service: $service"
            yq eval ".services.$service.logging = {\"driver\": \"json-file\", \"options\": {\"max-size\": \"10m\", \"max-file\": \"3\"}}" -i "$file"
        fi
    done

    log_success "Logging configuration validated"
}

# Configure external volumes for data persistence
configure_external_volumes() {
    local file="$1"

    log_info "Checking volume configuration in: $file"

    # Check if volumes section exists
    if [ "$(yq eval '.volumes' "$file")" = "null" ]; then
        log_warning "No volumes defined in $file"
        return 0
    fi

    # Get volumes that should be external
    local volumes
    volumes=$(yq eval '.volumes | keys | .[]' "$file")

    for volume in $volumes; do
        # Check if volume name contains "data" or "db"
        if [[ "$volume" == *data* ]] || [[ "$volume" == *db* ]]; then
            if [ "$(yq eval ".volumes.$volume.external" "$file")" = "null" ]; then
                log_warning "Setting volume $volume as external for backup purposes"
                yq eval ".volumes.$volume.external = true" -i "$file"
            fi
        fi
    done

    log_success "Volume configuration validated"
}

# Add standard network configuration
add_standard_network() {
    local file="$1"

    log_info "Checking network configuration in: $file"

    # Check if networks section exists
    if [ "$(yq eval '.networks' "$file")" = "null" ]; then
        log_warning "No networks defined in $file, adding default network"
        yq eval '.networks.default = { "driver": "bridge" }' -i "$file"
    fi

    log_success "Network configuration validated"
}

# Standardize a Docker Compose file
standardize_compose_file() {
    local file="$1"

    log_info "Standardizing Docker Compose file: $file"

    # Validate file first
    if ! validate_compose_file "$file"; then
        log_error "Cannot standardize invalid Docker Compose file: $file"
        return 1
    fi

    # Create backup
    cp "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)"

    # Check and update version
    if ! check_compose_version "$file"; then
        update_compose_version "$file"
    fi

    # Ensure proper logging configuration
    ensure_logging_config "$file"

    # Configure external volumes
    configure_external_volumes "$file"

    # Add standard network
    add_standard_network "$file"

    log_success "Docker Compose file standardized: $file"

    # Validate the updated file
    validate_compose_file "$file"
}

# Get local hostname
get_local_hostname() {
    hostname | tr '[:upper:]' '[:lower:]'
}

# Main function
main() {
    if [ $# -eq 0 ]; then
        echo "Usage: $(basename "$0") <docker-compose.yml> [docker-compose2.yml ...]"
        echo "Standardizes Docker Compose files to follow best practices"
        echo ""
        echo "Without arguments, will standardize all Docker Compose files in the hostname directory"

        # Get local hostname and create directory path
        local hostname=$(get_local_hostname)
        local host_dir="./hosts/${hostname}"

        if [ -d "$host_dir" ]; then
            echo "Searching for Docker Compose files in $host_dir"
            local compose_files=()
            while IFS= read -r -d '' file; do
                compose_files+=("$file")
            done < <(find "$host_dir" -maxdepth 2 -type f \( -name "docker-compose.yml" -o -name "docker-compose.yaml" \) -print0)

            if [ ${#compose_files[@]} -eq 0 ]; then
                echo "No Docker Compose files found in $host_dir"
                exit 1
            fi

            # Process each file
            for file in "${compose_files[@]}"; do
                echo "Processing: $file"
                standardize_compose_file "$file"
                echo ""
            done

            log_success "All Docker Compose files have been standardized."
            exit 0
        else
            echo "Host directory not found: $host_dir"
            exit 1
        fi
    fi

    # Check dependencies
    check_dependencies

    # Process each file
    for file in "$@"; do
        standardize_compose_file "$file"
        echo ""
    done

    log_success "All Docker Compose files have been standardized."
}

# Run main function
main "$@"
