#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if HOST environment variable is set
if [ -z "$HOST" ]; then
    echo -e "${RED}Error: HOST environment variable is not set${NC}"
    echo "Please set the HOST environment variable before running this script"
    echo "Example: export HOST=castle0"
    exit 1
fi

# Function to execute docker-compose command
execute_command() {
    local cmd=$1
    local compose_file="./$HOST/docker-compose.yml"
    
    if [ ! -f "$compose_file" ]; then
        echo -e "${RED}Error: docker-compose.yml not found in ./$HOST/${NC}"
        return 1
    fi

    echo -e "${YELLOW}Executing '$cmd' for $HOST...${NC}"
    cd "./$HOST" || return 1
    
    case $cmd in
        "stats")
            docker compose stats
            ;;
        "logs")
            docker compose logs -f
            ;;
        "restart")
            docker compose restart
            ;;
        "down")
            docker compose down
            ;;
        "up")
            docker compose up -d
            ;;
        "pull")
            docker compose pull
            ;;
    esac
    
    cd - > /dev/null || return 1
}

# Function to display menu
show_menu() {
    clear
    echo -e "${YELLOW}Docker Stack Management Menu for $HOST${NC}"
    echo "--------------------------------"
    echo "1. Docker Stack Stats"
    echo "2. Docker Stack Logs"
    echo "3. Docker Stack Restart"
    echo "4. Docker Stack Down"
    echo "5. Docker Stack Up"
    echo "6. Docker Stack Pull"
    echo "7. Exit"
    echo "--------------------------------"
    echo -n "Enter your choice [1-7]: "
}

# Main script
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            execute_command "stats"
            ;;
        2)
            execute_command "logs"
            ;;
        3)
            execute_command "restart"
            ;;
        4)
            execute_command "down"
            ;;
        5)
            execute_command "up"
            ;;
        6)
            execute_command "pull"
            ;;
        7)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    
    echo -e "\nPress Enter to continue..."
    read -r
done 