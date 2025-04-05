#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get all host directories
mapfile -t HOSTS < <(find . -maxdepth 1 -type d -name "*[0-9]" | sed 's|^\./||' | sort)

# Function to print usage
usage() {
    echo "Usage: $0 [command] [host]"
    echo "Commands:"
    echo "  up        - Start containers"
    echo "  down      - Stop containers"
    echo "  pull      - Pull latest images"
    echo "  status    - Show container status"
    echo "  logs      - Show container logs"
    echo "  prune     - Remove unused containers, networks, images"
    echo "  volumes   - List volumes"
    echo "  system    - Show system-wide information"
    echo "  restart   - Restart containers"
    echo "  build     - Build or rebuild services"
    echo "Hosts:"
    echo "  all       - Apply to all hosts"
    echo "  [host]    - Apply to specific host (e.g., castle0, knight0)"
    echo ""
    echo "Examples:"
    echo "  $0 up all"
    echo "  $0 status castle0"
    echo "  $0 pull knight0"
    echo "  $0 prune all"
}

# Function to execute docker-compose command
execute_command() {
    local host=$1
    local cmd=$2
    local compose_file="$host/docker-compose.yml"
    
    if [ ! -f "$compose_file" ]; then
        echo -e "${RED}Error: docker-compose.yml not found in $host${NC}"
        return 1
    fi

    echo -e "${YELLOW}Executing '$cmd' for $host...${NC}"
    cd "$host" || return 1
    
    case $cmd in
        "up")
            docker compose up -d
            ;;
        "down")
            docker compose down
            ;;
        "pull")
            docker compose pull
            ;;
        "status")
            docker compose ps
            ;;
        "logs")
            docker compose logs -f
            ;;
        "prune")
            docker compose down
            docker system prune -af --volumes
            ;;
        "volumes")
            docker volume ls
            ;;
        "system")
            docker system df
            echo -e "\n${YELLOW}Container Status:${NC}"
            docker compose ps
            echo -e "\n${YELLOW}Volume Usage:${NC}"
            docker system df -v
            ;;
        "restart")
            docker compose restart
            ;;
        "build")
            docker compose build --no-cache
            ;;
    esac
    
    cd - > /dev/null || return 1
}

# Main script
if [ $# -lt 2 ]; then
    usage
    exit 1
fi

COMMAND=$1
TARGET=$2

case $TARGET in
    "all")
        for host in "${HOSTS[@]}"; do
            execute_command "$host" "$COMMAND"
        done
        ;;
    *)
        # Check if the specified host exists
        if [[ " ${HOSTS[*]} " =~ ${TARGET} ]]; then
            execute_command "$TARGET" "$COMMAND"
        else
            echo -e "${RED}Error: Host '$TARGET' not found${NC}"
            echo "Available hosts: ${HOSTS[*]}"
            exit 1
        fi
        ;;
esac 