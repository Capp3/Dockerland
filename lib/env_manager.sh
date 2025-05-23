#!/usr/bin/env bash
# Environment Variable Management for Docker Compose stacks

# Configuration
MASTER_ENV="${CONFIG_DIR}/master.env"

# Create a local .env file for a specific stack
create_env_file() {
    local stack_dir="$1"
    local target_env_file="${stack_dir}/.env"

    log_info "Creating .env file in: ${stack_dir}"

    # Check if master env exists
    if [ ! -f "$MASTER_ENV" ]; then
        log_error "Master environment file not found: $MASTER_ENV"
        if whiptail --title "Missing Master Environment" --yesno "Master environment file not found. Would you like to create it?" 10 60; then
            touch "$MASTER_ENV"
            chmod 600 "$MASTER_ENV"
            edit_env_file "$MASTER_ENV"
        else
            return 1
        fi
    fi

    # Create or overwrite the target .env file
    cp "$MASTER_ENV" "$target_env_file"
    chmod 600 "$target_env_file"

    log_success "Created .env file in stack directory"
    return 0
}

# Edit an environment file
edit_env_file() {
    local env_file="$1"

    log_info "Editing environment file: $env_file"

    # Select editor based on what's available
    local editor=""
    if command -v nano &> /dev/null; then
        editor="nano"
    elif command -v vim &> /dev/null; then
        editor="vim"
    elif command -v vi &> /dev/null; then
        editor="vi"
    else
        log_error "No suitable text editor found (nano, vim, vi)"
        return 1
    fi

    # Open the editor
    $editor "$env_file"

    log_success "Environment file edited"
    return 0
}

# Update a local .env file with values from master
update_env_file() {
    local stack_dir="$1"
    local target_env_file="${stack_dir}/.env"

    log_info "Updating .env file in: ${stack_dir}"

    # Check if target exists
    if [ ! -f "$target_env_file" ]; then
        log_warning "Target .env file not found. Creating new one."
        create_env_file "$stack_dir"
        return $?
    fi

    # Backup the existing .env file
    cp "$target_env_file" "${target_env_file}.bak"

    # Merge files (with master taking precedence)
    if whiptail --title "Environment Update" --yesno "Do you want to overwrite the stack's .env with master .env? Select 'No' to merge them instead." 10 70; then
        # Overwrite
        cp "$MASTER_ENV" "$target_env_file"
        log_success "Overwritten .env file with master values"
    else
        # Merge (preserving stack-specific values not in master)
        # This is a simple merge - for production consider using a more sophisticated merge
        local temp_merged=$(mktemp)
        cat "$target_env_file" > "$temp_merged"

        # Add/update values from master
        while IFS='=' read -r key value; do
            # Skip empty lines and comments
            [[ -z "$key" || "$key" =~ ^# ]] && continue

            # Remove existing key and add the new one
            sed -i "/^${key}=/d" "$temp_merged"
            echo "${key}=${value}" >> "$temp_merged"
        done < "$MASTER_ENV"

        # Replace the target with the merged result
        mv "$temp_merged" "$target_env_file"
        chmod 600 "$target_env_file"
        log_success "Merged .env file with master values"
    fi

    return 0
}

# Show .env management menu
show_env_management_menu() {
    local stack_dir="$1"

    if [ -z "$stack_dir" ]; then
        log_error "No stack directory provided"
        return 1
    fi

    local target_env_file="${stack_dir}/.env"
    local env_exists=$([[ -f "$target_env_file" ]] && echo "YES" || echo "NO")

    while true; do
        local choice
        choice=$(whiptail --title "Environment Management" --menu "Manage .env for stack: $(basename "$stack_dir")\nStack .env exists: $env_exists" 18 70 6 \
            "1" "Create/Overwrite .env file from master" \
            "2" "Update .env file from master" \
            "3" "Edit stack .env file" \
            "4" "Edit master .env file" \
            "5" "View current stack .env file" \
            "B" "Back to previous menu" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return
        fi

        case "$choice" in
            1)
                create_env_file "$stack_dir"
                env_exists=$([[ -f "$target_env_file" ]] && echo "YES" || echo "NO")
                ;;
            2)
                update_env_file "$stack_dir"
                ;;
            3)
                if [ -f "$target_env_file" ]; then
                    edit_env_file "$target_env_file"
                else
                    whiptail --title "Error" --msgbox "No .env file exists for this stack yet. Create it first." 8 70
                fi
                ;;
            4)
                edit_env_file "$MASTER_ENV"
                ;;
            5)
                if [ -f "$target_env_file" ]; then
                    whiptail --title "Stack .env File" --textbox "$target_env_file" 20 80
                else
                    whiptail --title "Error" --msgbox "No .env file exists for this stack yet. Create it first." 8 70
                fi
                ;;
            B)
                return
                ;;
        esac
    done
}

# Show environment file management main menu
show_env_main_menu() {
    local hostname=$(get_local_hostname)
    local base_dir

    # Ask for base directory if not set
    if [ -z "$DOCKER_BASE_DIR" ]; then
        base_dir=$(whiptail --title "Docker Base Directory" --inputbox "Enter the base directory for Docker Compose projects:" 8 70 "$HOME/docker" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return
        fi

        DOCKER_BASE_DIR="$base_dir"
    else
        base_dir="$DOCKER_BASE_DIR"
    fi

    # Ensure host directory exists
    local host_dir="${base_dir}/hosts/${hostname}"
    if [ ! -d "$host_dir" ]; then
        log_info "Creating directory for local host: $hostname"
        mkdir -p "$host_dir"
    fi

    while true; do
        local choice
        choice=$(whiptail --title "Environment Management: $hostname" --menu "Choose an option:" 15 60 3 \
            "1" "Edit Master Environment File" \
            "2" "Manage Host Environment File" \
            "B" "Back to Main Menu" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return
        fi

        case "$choice" in
            1)
                edit_env_file "$MASTER_ENV"
                ;;
            2)
                show_env_management_menu "$host_dir"
                ;;
            B)
                return
                ;;
        esac
    done
}
