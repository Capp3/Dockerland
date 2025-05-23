#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Docker Management TUI Helper (DMTH) - Docker Test${NC}"
echo "--------------------------------------------------------"

# Test Docker
echo -e "${YELLOW}Testing Docker...${NC}"
if docker info &> /dev/null; then
    echo -e "${GREEN}✅ Docker is running and accessible.${NC}"

    # Test Docker container list
    echo -e "\n${YELLOW}Running 'docker ps -a' to list all containers:${NC}"
    docker ps -a
else
    echo -e "${RED}❌ Docker is not running or not accessible.${NC}"
    echo "Please ensure Docker daemon is running before proceeding."
    exit 1
fi

# Test Docker Compose
echo -e "\n${YELLOW}Testing Docker Compose...${NC}"
if docker compose version &> /dev/null; then
    echo -e "${GREEN}✅ Docker Compose is available.${NC}"

    # Find a docker-compose.yml file to test with
    compose_files=()

    # Check current directory
    if [ -f "docker-compose.yml" ]; then
        compose_files+=("./docker-compose.yml")
    fi

    # Check subdirectories
    for dir in */; do
        if [ -f "${dir}docker-compose.yml" ]; then
            compose_files+=("${dir}docker-compose.yml")
        fi
    done

    if [ ${#compose_files[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}Found ${#compose_files[@]} docker-compose.yml file(s):${NC}"

        for file in "${compose_files[@]}"; do
            echo "- $file"
        done

        # Test with first found compose file
        test_file="${compose_files[0]}"
        echo -e "\n${YELLOW}Testing Docker Compose with $test_file${NC}"

        echo -e "\n${YELLOW}Running 'docker compose -f $test_file config' to validate configuration:${NC}"
        if docker compose -f "$test_file" config &> /dev/null; then
            echo -e "${GREEN}✅ Docker Compose configuration is valid.${NC}"
        else
            echo -e "${RED}❌ Docker Compose configuration has issues. Details:${NC}"
            docker compose -f "$test_file" config
        fi
    else
        echo -e "${YELLOW}No docker-compose.yml files found for testing.${NC}"
    fi
else
    echo -e "${RED}❌ Docker Compose is not available.${NC}"
    echo "Please install Docker Compose before proceeding."
    exit 1
fi

# Summary
echo -e "\n${YELLOW}Docker Test Summary${NC}"
echo "--------------------------------------------------------"
echo -e "${GREEN}Docker test completed.${NC}"
if docker info &> /dev/null && docker compose version &> /dev/null; then
    echo "Docker and Docker Compose are working correctly."
    exit 0
else
    echo "There were issues with Docker or Docker Compose."
    exit 1
fi
