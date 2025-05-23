#!/usr/bin/env bash
# User Interface functions for Docker Management TUI Helper

# Show the main menu
show_main_menu() {
    # Get local hostname
    local hostname=$(get_local_hostname)

    while true; do
        local choice
        choice=$(whiptail --title "Docker Management TUI Helper (Host: $hostname)" --menu "Main Menu" 15 60 4 \
            "1" "Docker Stack Management" \
            "2" "Environment File Management" \
            "3" "Docker Compose Standardization" \
            "Q" "Quit" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            # User pressed ESC or Cancel
            exit_application
        fi

        case "$choice" in
            1)
                show_docker_menu
                ;;
            2)
                show_env_main_menu
                ;;
            3)
                show_standardization_menu
                ;;
            Q)
                exit_application
                ;;
        esac
    done
}

# Exit the application
exit_application() {
    if whiptail --title "Confirm Exit" --yesno "Are you sure you want to exit?" 8 40; then
        clear
        echo "Thank you for using Docker Management TUI Helper!"
        exit 0
    fi
}

# Show environment file management main menu
show_env_main_menu() {
    while true; do
        local choice
        choice=$(whiptail --title "Environment Management" --menu "Choose an option:" 15 60 3 \
            "1" "Edit Master Environment File" \
            "2" "Create New Environment File" \
            "B" "Back to Main Menu" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return
        fi

        case "$choice" in
            1)
                edit_env_file "$MASTER_ENV"
                ;;
            2)
                # Get target directory
                local target_dir
                target_dir=$(whiptail --title "Create Environment File" --inputbox "Enter the target directory path:" 8 70 "$HOME/docker" 3>&1 1>&2 2>&3)

                if [ $? -ne 0 ] || [ -z "$target_dir" ]; then
                    continue
                fi

                if [ ! -d "$target_dir" ]; then
                    if whiptail --title "Directory Not Found" --yesno "Directory does not exist. Create it?" 8 60; then
                        mkdir -p "$target_dir"
                    else
                        continue
                    fi
                fi

                create_env_file "$target_dir"
                whiptail --title "Environment File" --msgbox "Environment file created successfully in $target_dir" 8 70
                ;;
            B)
                return
                ;;
        esac
    done
}

# Show Docker Compose standardization menu
show_standardization_menu() {
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
        choice=$(whiptail --title "Docker Compose Standardization: $hostname" --menu "Choose an option:" 15 60 4 \
            "1" "Select Docker Compose Files" \
            "2" "Configure Standardization Rules" \
            "3" "Run Standardization" \
            "B" "Back to Main Menu" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return
        fi

        case "$choice" in
            1)
                select_standardization_files "$host_dir"
                ;;
            2)
                configure_standardization_rules
                ;;
            3)
                run_standardization
                ;;
            B)
                return
                ;;
        esac
    done
}

# Variables for standardization
STANDARDIZE_FILES=()
STANDARDIZE_RULES=("version" "logging" "volumes" "network")
STANDARDIZE_ENABLED=("ON" "ON" "ON" "ON")

# Select files for standardization
select_standardization_files() {
    # Use provided host dir or ask for base directory
    local base_dir="$1"
    if [ -z "$base_dir" ]; then
        base_dir=$(whiptail --title "Docker Compose Directory" --inputbox "Enter directory containing Docker Compose files:" 8 70 "$HOME/docker" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ] || [ -z "$base_dir" ]; then
            return
        fi
    fi

    if [ ! -d "$base_dir" ]; then
        whiptail --title "Error" --msgbox "Directory not found: $base_dir" 8 60
        return
    fi

    # Find Docker Compose files
    local compose_files=()
    while IFS= read -r -d '' file; do
        compose_files+=("$file")
    done < <(find "$base_dir" -maxdepth 2 -type f \( -name "docker-compose.yml" -o -name "docker-compose.yaml" \) -print0)

    if [ ${#compose_files[@]} -eq 0 ]; then
        whiptail --title "Error" --msgbox "No Docker Compose files found in $base_dir" 8 70
        return
    fi

    # Create menu items for selection
    local menu_items=()
    for file in "${compose_files[@]}"; do
        # Check if file is in the selected list
        local selected="OFF"
        for selected_file in "${STANDARDIZE_FILES[@]}"; do
            if [ "$selected_file" = "$file" ]; then
                selected="ON"
                break
            fi
        done

        menu_items+=("$file" "$(basename "$(dirname "$file")")/$(basename "$file")" "$selected")
    done

    # Display checklist
    local selected_files
    selected_files=$(whiptail --title "Select Docker Compose Files" --checklist "Choose files to standardize:" 20 80 15 \
        "${menu_items[@]}" 3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        return
    fi

    # Parse selected files and store them
    STANDARDIZE_FILES=()
    for file in $selected_files; do
        # Remove quotes
        file="${file//\"/}"
        STANDARDIZE_FILES+=("$file")
    done

    whiptail --title "Files Selected" --msgbox "Selected ${#STANDARDIZE_FILES[@]} files for standardization." 8 60
}

# Configure standardization rules
configure_standardization_rules() {
    # Create menu items
    local menu_items=(
        "version" "Check/Update Version to 3.8" "${STANDARDIZE_ENABLED[0]}"
        "logging" "Configure Proper Logging" "${STANDARDIZE_ENABLED[1]}"
        "volumes" "Set Data Volumes as External" "${STANDARDIZE_ENABLED[2]}"
        "network" "Add Standard Network Configuration" "${STANDARDIZE_ENABLED[3]}"
    )

    # Display checklist
    local selected_rules
    selected_rules=$(whiptail --title "Configure Standardization Rules" --checklist "Select rules to apply:" 15 70 4 \
        "${menu_items[@]}" 3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        return
    fi

    # Update enabled rules
    for i in "${!STANDARDIZE_RULES[@]}"; do
        STANDARDIZE_ENABLED[$i]="OFF"
    done

    for rule in $selected_rules; do
        # Remove quotes
        rule="${rule//\"/}"
        for i in "${!STANDARDIZE_RULES[@]}"; do
            if [ "${STANDARDIZE_RULES[$i]}" = "$rule" ]; then
                STANDARDIZE_ENABLED[$i]="ON"
                break
            fi
        done
    done

    # Count enabled rules
    local enabled_count=0
    for enabled in "${STANDARDIZE_ENABLED[@]}"; do
        if [ "$enabled" = "ON" ]; then
            ((enabled_count++))
        fi
    done

    whiptail --title "Rules Configured" --msgbox "Enabled $enabled_count standardization rules." 8 60
}

# Run standardization
run_standardization() {
    if [ ${#STANDARDIZE_FILES[@]} -eq 0 ]; then
        whiptail --title "Error" --msgbox "No files selected for standardization. Please select files first." 8 70
        return
    fi

    # Check if any rules are enabled
    local rule_enabled=false
    for enabled in "${STANDARDIZE_ENABLED[@]}"; do
        if [ "$enabled" = "ON" ]; then
            rule_enabled=true
            break
        fi
    done

    if [ "$rule_enabled" = false ]; then
        whiptail --title "Error" --msgbox "No standardization rules enabled. Please configure rules first." 8 70
        return
    fi

    # Confirm standardization
    if ! whiptail --title "Confirm Standardization" --yesno "This will standardize ${#STANDARDIZE_FILES[@]} Docker Compose files.\n\nDo you want to continue?" 10 70; then
        return
    fi

    # Build command arguments
    local args=()
    for i in "${!STANDARDIZE_RULES[@]}"; do
        if [ "${STANDARDIZE_ENABLED[$i]}" = "ON" ]; then
            args+=("--${STANDARDIZE_RULES[$i]}")
        fi
    done

    # Run standardization for each file
    local success_count=0
    local error_count=0
    local results=""

    for file in "${STANDARDIZE_FILES[@]}"; do
        results+="Processing: $file\n"

        # Execute standardization command
        if "${SCRIPT_DIR}/src/standardize_compose.sh" "${args[@]}" "$file" > /dev/null 2>&1; then
            results+="✅ Standardization successful\n\n"
            ((success_count++))
        else
            results+="❌ Standardization failed\n\n"
            ((error_count++))
        fi
    done

    # Show results
    results+="\nSummary: $success_count successful, $error_count failed"
    whiptail --title "Standardization Results" --scrolltext --msgbox "$results" 20 80
}
