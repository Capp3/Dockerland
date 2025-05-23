#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Docker Management TUI Helper (DMTH) - Dependency Check${NC}"
echo "--------------------------------------------------------"

# Define required dependencies
DEPENDENCIES=("docker" "ssh" "scp" "whiptail" "hostname")

# Check each dependency
missing_deps=()
for dep in "${DEPENDENCIES[@]}"; do
    echo -n "Checking for $dep... "
    if command -v "$dep" &> /dev/null; then
        echo -e "${GREEN}Found${NC}"
    else
        echo -e "${RED}Not found${NC}"
        missing_deps+=("$dep")
    fi
done

# Special check for docker compose (new syntax)
echo -n "Checking for docker compose... "
if docker compose version &> /dev/null; then
    echo -e "${GREEN}Found${NC}"
else
    echo -e "${RED}Not found${NC}"
    missing_deps+=("docker compose")
fi

echo "--------------------------------------------------------"

# Report results
if [ ${#missing_deps[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All dependencies are installed.${NC}"
    exit 0
else
    echo -e "${RED}❌ Missing dependencies:${NC}"
    for dep in "${missing_deps[@]}"; do
        echo "   - $dep"
    done

    echo -e "\n${YELLOW}Please install missing dependencies before proceeding.${NC}"

    # Provide installation hints
    echo -e "\nInstallation hints:"
    echo "  - docker: https://docs.docker.com/get-docker/"
    echo "  - docker compose: Included with recent Docker Desktop or Engine installations"
    echo "  - ssh & scp: Install OpenSSH package for your system"
    echo "  - whiptail: Usually part of newt or libnewt package"
    echo "  - hostname: Usually pre-installed on most systems"

    exit 1
fi
