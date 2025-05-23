#!/usr/bin/env bash
# Docker and Docker Compose Operations

# Check if Docker and Docker Compose are available
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        return 1
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running or current user lacks permissions"
        return 1
    fi

    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose plugin is not installed or not in PATH"
        return 1
    fi

    return 0
}

# Function to get Docker Compose command (standardized to docker compose)
get_docker_compose_cmd() {
    # Always use the Docker Compose plugin (new approach)
    echo "docker compose"
    return 0
}

# Run Docker Compose command with progress
run_compose_cmd() {
    local stack_dir="$1"
    local cmd="$2"
    local args="${@:3}"
    local compose_cmd

    if ! compose_cmd=$(get_docker_compose_cmd); then
        return 1
    fi

    log_info "Running: $compose_cmd $cmd $args in $stack_dir"

    # Save current directory
    local current_dir
    current_dir=$(pwd)

    # Change to stack directory
    cd "$stack_dir" || {
        log_error "Failed to change to directory: $stack_dir"
        return 1
    }

    # Run the command
    if [ -t 1 ]; then
        # Interactive terminal
        $compose_cmd $cmd $args
        local status=$?
    else
        # Non-interactive - capture output
        local output
        output=$($compose_cmd $cmd $args 2>&1)
        local status=$?
        echo "$output"
    fi

    # Return to original directory
    cd "$current_dir" || log_warning "Failed to return to original directory: $current_dir"

    if [ $status -eq 0 ]; then
        log_success "Docker Compose command completed successfully"
    else
        log_error "Docker Compose command failed with status: $status"
    fi

    return $status
}

# Start stack (docker compose up -d)
start_stack() {
    local stack_dir="$1"
    local target_env_file="${stack_dir}/.env"

    # Check if .env file exists, create if needed
    if [ ! -f "$target_env_file" ]; then
        log_warning "No .env file found for this stack. Creating one from master."
        create_env_file "$stack_dir"
    fi

    run_compose_cmd "$stack_dir" "up" "-d"
    return $?
}

# Stop stack (docker compose down)
stop_stack() {
    local stack_dir="$1"
    local remove_volumes=false

    # Ask if volumes should be removed
    if whiptail --title "Stop Stack" --yesno "Do you want to remove volumes when stopping the stack?" 8 60; then
        remove_volumes=true
    fi

    if [ "$remove_volumes" = true ]; then
        run_compose_cmd "$stack_dir" "down" "-v"
    else
        run_compose_cmd "$stack_dir" "down"
    fi

    return $?
}

# Update stack - pull, down, then up
update_stack() {
    local stack_dir="$1"
    local target_env_file="${stack_dir}/.env"

    # Check if .env file exists, create if needed
    if [ ! -f "$target_env_file" ]; then
        log_warning "No .env file found for this stack. Creating one from master."
        create_env_file "$stack_dir"
    fi

    # Pull latest images
    log_info "Pulling latest images..."
    if ! run_compose_cmd "$stack_dir" "pull"; then
        log_error "Failed to pull latest images"
        return 1
    fi

    # Stop stack
    log_info "Stopping stack..."
    if ! run_compose_cmd "$stack_dir" "down"; then
        log_error "Failed to stop stack"
        return 1
    fi

    # Start stack
    log_info "Starting stack with latest images..."
    if ! run_compose_cmd "$stack_dir" "up" "-d"; then
        log_error "Failed to start stack"
        return 1
    fi

    log_success "Stack updated successfully"
    return 0
}

# View stack status
view_stack_status() {
    local stack_dir="$1"

    # Get temporary file for output
    local temp_file
    temp_file=$(mktemp)

    # Run ps command and capture output
    local compose_cmd
    if ! compose_cmd=$(get_docker_compose_cmd); then
        return 1
    fi

    # Save current directory
    local current_dir
    current_dir=$(pwd)

    # Change to stack directory
    cd "$stack_dir" || {
        log_error "Failed to change to directory: $stack_dir"
        return 1
    }

    # Run the command
    $compose_cmd ps > "$temp_file" 2>&1
    local status=$?

    # Return to original directory
    cd "$current_dir" || log_warning "Failed to return to original directory: $current_dir"

    # Display output
    if [ $status -eq 0 ]; then
        whiptail --title "Stack Status: $(basename "$stack_dir")" --textbox "$temp_file" 20 80
    else
        log_error "Failed to get stack status"
        cat "$temp_file"
    fi

    # Clean up
    rm -f "$temp_file"

    return $status
}

# View stack logs
view_stack_logs() {
    local stack_dir="$1"
    local service="$2"
    local lines="100"

    # If service is not specified, get a list of services and let user select
    if [ -z "$service" ]; then
        # Get a list of services
        local compose_cmd
        if ! compose_cmd=$(get_docker_compose_cmd); then
            return 1
        fi

        # Save current directory
        local current_dir
        current_dir=$(pwd)

        # Change to stack directory
        cd "$stack_dir" || {
            log_error "Failed to change to directory: $stack_dir"
            return 1
        }

        # Get services
        local services_raw
        services_raw=$($compose_cmd config --services 2>/dev/null)

        # Return to original directory
        cd "$current_dir" || log_warning "Failed to return to original directory: $current_dir"

        if [ -z "$services_raw" ]; then
            log_error "No services found in this stack"
            return 1
        fi

        # Convert to array
        IFS=$'\n' read -r -d '' -a services <<< "$services_raw"

        # Create menu items
        local menu_items=()
        for svc in "${services[@]}"; do
            menu_items+=("$svc" "View logs for $svc")
        done
        menu_items+=("ALL" "View logs for all services")

        # Display menu
        service=$(whiptail --title "Select Service" --menu "Choose a service to view logs:" 20 60 10 \
            "${menu_items[@]}" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return 0
        fi
    fi

    # Ask for number of lines
    lines=$(whiptail --title "Log Lines" --inputbox "Enter number of lines to show:" 8 60 "100" 3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        return 0
    fi

    # View logs
    if [ "$service" = "ALL" ]; then
        # View all services logs
        run_compose_cmd "$stack_dir" "logs" "--tail=$lines" "-f"
    else
        # View specific service logs
        run_compose_cmd "$stack_dir" "logs" "--tail=$lines" "-f" "$service"
    fi

    return $?
}

# Show Docker stack management menu
show_stack_menu() {
    local stack_dir="$1"
    local stack_name=$(basename "$stack_dir")

    while true; do
        local choice
        choice=$(whiptail --title "Stack Management: $stack_name" --menu "Choose an operation:" 18 70 10 \
            "1" "Start Stack (up -d)" \
            "2" "Stop Stack (down)" \
            "3" "Update Stack (pull, down, up -d)" \
            "4" "View Stack Status" \
            "5" "View Stack Logs" \
            "6" "Manage .env File" \
            "B" "Back to Previous Menu" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return
        fi

        case "$choice" in
            1)
                start_stack "$stack_dir"
                whiptail --title "Start Stack" --msgbox "Stack start operation completed." 8 60
                ;;
            2)
                stop_stack "$stack_dir"
                whiptail --title "Stop Stack" --msgbox "Stack stop operation completed." 8 60
                ;;
            3)
                if whiptail --title "Update Stack" --yesno "This will pull latest images, stop the stack, and restart it. Continue?" 8 70; then
                    update_stack "$stack_dir"
                    whiptail --title "Update Stack" --msgbox "Stack update operation completed." 8 60
                fi
                ;;
            4)
                view_stack_status "$stack_dir"
                ;;
            5)
                view_stack_logs "$stack_dir"
                ;;
            6)
                show_env_management_menu "$stack_dir"
                ;;
            B)
                return
                ;;
        esac
    done
}

# Get local hostname
get_local_hostname() {
    hostname | tr '[:upper:]' '[:lower:]'
}

# Ensure host directory exists
ensure_host_directory() {
    local base_dir="$1"
    local hostname=$(get_local_hostname)
    local host_dir="${base_dir}/hosts/${hostname}"

    if [ ! -d "$host_dir" ]; then
        log_info "Creating directory for local host: $hostname"
        mkdir -p "$host_dir"
    fi

    # Return the host directory
    echo "$host_dir"
}

# Create a basic Docker Compose file if none exists
create_basic_compose_file() {
    local host_dir="$1"
    local compose_file="${host_dir}/docker-compose.yml"

    if [ ! -f "$compose_file" ]; then
        log_info "Creating basic Docker Compose file in $host_dir"

        mkdir -p "$host_dir"

        cat > "$compose_file" << EOF
version: '3.8'

services:
  # Add your services here
  # example:
  # web:
  #   image: nginx:latest
  #   ports:
  #     - "8080:80"
  #   volumes:
  #     - ./web:/usr/share/nginx/html

networks:
  default:
    driver: bridge

# volumes:
#   data:
#     external: true
EOF

        chmod 644 "$compose_file"
        log_success "Created basic Docker Compose file: $compose_file"
    fi

    echo "$compose_file"
}

# Select a Docker Compose stack based on local hostname or subdirectories
select_stack() {
    local base_dir="$1"

    if [ -z "$base_dir" ]; then
        log_error "No base directory provided"
        return 1
    fi

    # Get local hostname and ensure directory exists
    local hostname=$(get_local_hostname)
    local host_dir="${base_dir}/hosts/${hostname}"

    # Create host directory if it doesn't exist
    if [ ! -d "$host_dir" ]; then
        log_info "Creating directory for local host: $hostname"
        mkdir -p "$host_dir"
    fi

    # Create a basic compose file if none exists
    if ! find "$host_dir" -maxdepth 1 -name "docker-compose.yml" -o -name "docker-compose.yaml" | grep -q .; then
        log_info "Creating basic Docker Compose file in: $host_dir"
        create_basic_compose_file "$host_dir"
    fi

    # Look for docker-compose files in the host directory or its subdirectories
    local compose_files=()
    local compose_dirs=()

    # First check if there's a docker-compose.yml directly in the host directory
    if [ -f "${host_dir}/docker-compose.yml" ] || [ -f "${host_dir}/docker-compose.yaml" ]; then
        compose_dirs+=("$host_dir")
    fi

    # Then look for subdirectories with docker-compose files
    while IFS= read -r -d '' file; do
        local dir=$(dirname "$file")
        if [ "$dir" != "$host_dir" ]; then # Skip the root one we already found
            compose_dirs+=("$dir")
        fi
    done < <(find "$host_dir" -maxdepth 2 -type f \( -name "docker-compose.yml" -o -name "docker-compose.yaml" \) -print0 2>/dev/null || true)

    if [ ${#compose_dirs[@]} -eq 0 ]; then
        whiptail --title "Error" --msgbox "No Docker Compose stacks found for host: $hostname" 8 70
        return 1
    fi

    # If there's only one stack, return it without asking
    if [ ${#compose_dirs[@]} -eq 1 ]; then
        echo "${compose_dirs[0]}"
        return 0
    fi

    # If there are multiple stacks, let the user select one
    local menu_items=()
    for dir in "${compose_dirs[@]}"; do
        local stack_name
        if [ "$dir" = "$host_dir" ]; then
            stack_name="$hostname (root)"
        else
            stack_name="$hostname/$(basename "$dir")"
        fi
        menu_items+=("$dir" "$stack_name")
    done

    # Display menu
    local selected
    selected=$(whiptail --title "Select Stack for $hostname" --menu "Choose a Docker Compose stack:" 20 70 10 \
        "${menu_items[@]}" 3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        return 1
    fi

    echo "$selected"
    return 0
}

# Show Docker menu
show_docker_menu() {
    local base_dir

    # Ask for base directory if not set
    if [ -z "$DOCKER_BASE_DIR" ]; then
        base_dir=$(whiptail --title "Docker Base Directory" --inputbox "Enter the base directory for Docker Compose projects:" 8 70 "$HOME/docker" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return 1
        fi

        DOCKER_BASE_DIR="$base_dir"
    else
        base_dir="$DOCKER_BASE_DIR"
    fi

    # Ensure base directory exists
    if [ ! -d "$base_dir" ]; then
        if whiptail --title "Create Directory" --yesno "Directory $base_dir does not exist. Create it?" 8 70; then
            mkdir -p "$base_dir"
        else
            return 1
        fi
    fi

    # Ensure hosts directory exists
    if [ ! -d "${base_dir}/hosts" ]; then
        mkdir -p "${base_dir}/hosts"
    fi

    while true; do
        local hostname=$(get_local_hostname)

        local choice
        choice=$(whiptail --title "Docker Management: ${hostname}" --menu "Choose an option:" 15 60 5 \
            "1" "Manage Docker Compose Stack" \
            "2" "View All Running Containers" \
            "3" "System Prune" \
            "4" "Change Base Directory" \
            "B" "Back to Main Menu" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return
        fi

        case "$choice" in
            1)
                local stack_dir
                stack_dir=$(select_stack "$base_dir")

                if [ $? -eq 0 ] && [ -n "$stack_dir" ]; then
                    show_stack_menu "$stack_dir"
                fi
                ;;
            2)
                # View all running containers
                local temp_file
                temp_file=$(mktemp)

                docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}" > "$temp_file"

                whiptail --title "Running Containers" --textbox "$temp_file" 20 80

                rm -f "$temp_file"
                ;;
            3)
                # System prune
                if whiptail --title "Docker System Prune" --yesno "This will remove all stopped containers, unused networks, dangling images, and build cache.\n\nAre you sure you want to continue?" 12 70; then
                    local temp_file
                    temp_file=$(mktemp)

                    docker system prune -f > "$temp_file"

                    whiptail --title "System Prune Result" --textbox "$temp_file" 15 70

                    rm -f "$temp_file"
                fi
                ;;
            4)
                # Change base directory
                base_dir=$(whiptail --title "Docker Base Directory" --inputbox "Enter the base directory for Docker Compose projects:" 8 70 "$base_dir" 3>&1 1>&2 2>&3)

                if [ $? -eq 0 ]; then
                    DOCKER_BASE_DIR="$base_dir"
                    log_info "Base directory updated to: $base_dir"
                fi
                ;;
            B)
                return
                ;;
        esac
    done
}
