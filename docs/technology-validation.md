# Technology Validation Plan

This document outlines the verification process for the selected technology stack for the Docker Management TUI Helper (DMTH).

## Technology Stack Overview

- **Primary Language**: Bash/sh
- **Secondary Language**: Python (for complex operations)
- **TUI Library**: whiptail
- **Dependencies**: docker, docker-compose, ssh, scp, whiptail, hostname

## Validation Checklist

- [ ] Bash script initialization structure verified
- [ ] Required dependencies identification script created
- [ ] Whiptail integration proof of concept created
- [ ] SSH remote execution test verified
- [ ] Docker command execution validated
- [ ] File permissions handling tested

## Validation Steps

### 1. Dependency Verification Script

Create a script to check for all required dependencies:

```bash
#!/bin/bash

# Define required dependencies
DEPENDENCIES=("docker" "docker-compose" "ssh" "scp" "whiptail" "hostname")

# Check each dependency
missing_deps=()
for dep in "${DEPENDENCIES[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing_deps+=("$dep")
    fi
done

# Report results
if [ ${#missing_deps[@]} -eq 0 ]; then
    echo "✅ All dependencies are installed."
    exit 0
else
    echo "❌ Missing dependencies:"
    for dep in "${missing_deps[@]}"; do
        echo "   - $dep"
    done
    exit 1
fi
```

### 2. Whiptail Integration Test

Create a simple whiptail menu demonstration:

```bash
#!/bin/bash

# Test if whiptail is available
if ! command -v whiptail &> /dev/null; then
    echo "Error: whiptail is not installed"
    exit 1
fi

# Set terminal colors
TERM=ansi

# Simple menu test
option=$(whiptail --title "DMTH Test Menu" --menu "Choose an option:" 15 60 4 \
    "1" "Option 1" \
    "2" "Option 2" \
    "3" "Option 3" \
    "4" "Exit" 3>&1 1>&2 2>&3)

exit_status=$?

if [ $exit_status = 0 ]; then
    echo "You selected: $option"
else
    echo "You cancelled."
fi

# Test a message box
whiptail --title "Message Box Test" --msgbox "This is a test message box." 8 78

# Test an input box
name=$(whiptail --title "Input Box Test" --inputbox "What is your name?" 8 78 "User" 3>&1 1>&2 2>&3)
echo "Hello, $name!"
```

### 3. SSH Remote Execution Test

Test script for SSH connectivity and command execution:

```bash
#!/bin/bash

# Define test parameters
TEST_HOST="example.com"
TEST_USER="user"
TEST_PORT=22
TEST_COMMAND="hostname"

# Test SSH connection
echo "Testing SSH connection to $TEST_USER@$TEST_HOST:$TEST_PORT..."
if ssh -q -o BatchMode=yes -o ConnectTimeout=5 -p "$TEST_PORT" "$TEST_USER@$TEST_HOST" exit; then
    echo "✅ SSH connection successful."
    
    # Test command execution
    echo "Testing remote command execution..."
    result=$(ssh -p "$TEST_PORT" "$TEST_USER@$TEST_HOST" "$TEST_COMMAND")
    echo "Command result: $result"
    
    # Test file transfer
    echo "Testing SCP file transfer..."
    echo "Test content" > test_file.txt
    if scp -P "$TEST_PORT" test_file.txt "$TEST_USER@$TEST_HOST:/tmp/"; then
        echo "✅ File transfer successful."
        ssh -p "$TEST_PORT" "$TEST_USER@$TEST_HOST" "rm /tmp/test_file.txt"
    else
        echo "❌ File transfer failed."
    fi
    rm test_file.txt
else
    echo "❌ SSH connection failed."
fi
```

### 4. Docker Command Execution Test

Test script for Docker and Docker Compose command execution:

```bash
#!/bin/bash

# Test Docker
echo "Testing Docker..."
if docker info &> /dev/null; then
    echo "✅ Docker is running."
    
    # Test Docker container list
    docker ps -a
else
    echo "❌ Docker is not running or not accessible."
fi

# Test Docker Compose
echo "Testing Docker Compose..."
if docker-compose version &> /dev/null; then
    echo "✅ Docker Compose is available."
    
    # Test with a simple compose file if one exists
    if [ -f "docker-compose.yml" ]; then
        echo "Testing Docker Compose file..."
        docker-compose config
    fi
else
    echo "❌ Docker Compose is not available."
fi
```

### 5. File Permissions Test

Test script for file permissions handling:

```bash
#!/bin/bash

# Test directory
TEST_DIR="/tmp/dmth_test"
TEST_FILE="$TEST_DIR/secret.env"

# Create test directory
mkdir -p "$TEST_DIR"

# Test file creation with secure permissions
echo "Creating test file with secure permissions..."
echo "SECRET_VAR=secret_value" > "$TEST_FILE"
chmod 600 "$TEST_FILE"

# Verify permissions
file_perms=$(stat -c "%a" "$TEST_FILE")
if [ "$file_perms" = "600" ]; then
    echo "✅ File permissions set correctly: $file_perms"
else
    echo "❌ File permissions incorrect: $file_perms (expected 600)"
fi

# Clean up
rm -rf "$TEST_DIR"
```

## Integration Test

Final script to validate all components working together:

```bash
#!/bin/bash

# Source directory for the project
SOURCE_DIR=$(dirname "$(readlink -f "$0")")

# Create a temporary test configuration
TEST_CONFIG_DIR="/tmp/dmth_test_config"
mkdir -p "$TEST_CONFIG_DIR"

# Create test master.env
cat > "$TEST_CONFIG_DIR/master.env" << EOF
# General variables
TZ=Europe/Dublin
PUID=1000
PGID=1000

# Host-specific variables
TEST_HOST_DATA_DIR=/path/to/test/data
EOF
chmod 600 "$TEST_CONFIG_DIR/master.env"

# Simple whiptail menu that executes a docker command
if whiptail --title "DMTH Integration Test" --yesno "Run 'docker ps' command?" 8 78; then
    # Execute docker command
    result=$(docker ps --format "table {{.Names}}\t{{.Status}}")
    
    # Display result in whiptail
    whiptail --title "Docker Containers" --msgbox "$result" 15 78
fi

# Clean up
rm -rf "$TEST_CONFIG_DIR"

echo "Integration test completed."
```

## Cross-Platform Testing

Test the scripts on both Linux and macOS to ensure compatibility:

1. **Linux Test**
   - Ubuntu 20.04 LTS or newer
   - Check for bash differences
   - Verify whiptail appearance

2. **macOS Test**
   - Install dependencies via Homebrew
   - Check for bash/shell differences
   - Test terminal color handling

## Conclusion

The technology validation plan verifies that all required technologies are available and functioning correctly. After completing these tests, we can confidently proceed with the implementation of the DMTH tool.

Once these validation tests are successful, update the tasks.md file to mark "Technology validation complete" as done. 
