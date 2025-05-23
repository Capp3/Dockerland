#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Docker Management TUI Helper (DMTH) - File Permissions Test${NC}"
echo "--------------------------------------------------------"

# Test directory
TEST_DIR="/tmp/dmth_test"
TEST_FILE="$TEST_DIR/secret.env"
TEST_CONFIG_DIR="$TEST_DIR/config"
TEST_CONFIG_FILE="$TEST_CONFIG_DIR/master.env"

# Clean up any previous test directories
if [ -d "$TEST_DIR" ]; then
    echo "Cleaning up previous test directory..."
    rm -rf "$TEST_DIR"
fi

# Create test directory
echo "Creating test directory structure..."
mkdir -p "$TEST_DIR"
mkdir -p "$TEST_CONFIG_DIR"

# Test file creation with secure permissions
echo -e "\n${YELLOW}Testing file permissions...${NC}"

# Create test file
echo "Creating test file with secure permissions..."
echo "SECRET_VAR=secret_value" > "$TEST_FILE"
chmod 600 "$TEST_FILE"

# Verify permissions
file_perms=$(stat -c "%a" "$TEST_FILE" 2>/dev/null || stat -f "%p" "$TEST_FILE" 2>/dev/null | cut -c 3-5)
if [ "$file_perms" = "600" ]; then
    echo -e "${GREEN}✅ File permissions set correctly: $file_perms${NC}"
else
    echo -e "${RED}❌ File permissions incorrect: $file_perms (expected 600)${NC}"
    echo "This might indicate an issue with your file system or permissions model."
fi

# Test config directory with master.env
echo -e "\n${YELLOW}Testing config directory permissions...${NC}"
echo "Creating test config file..."

# Create master.env test file
cat > "$TEST_CONFIG_FILE" << EOF
# General variables
TZ=Europe/Dublin
PUID=1000
PGID=1000

# Host-specific variables
TEST_HOST_DATA_DIR=/path/to/test/data
EOF

# Set permissions
chmod 600 "$TEST_CONFIG_FILE"
chmod 700 "$TEST_CONFIG_DIR"

# Verify permissions
config_perms=$(stat -c "%a" "$TEST_CONFIG_FILE" 2>/dev/null || stat -f "%p" "$TEST_CONFIG_FILE" 2>/dev/null | cut -c 3-5)
dir_perms=$(stat -c "%a" "$TEST_CONFIG_DIR" 2>/dev/null || stat -f "%p" "$TEST_CONFIG_DIR" 2>/dev/null | cut -c 3-5)

if [ "$config_perms" = "600" ]; then
    echo -e "${GREEN}✅ Config file permissions set correctly: $config_perms${NC}"
else
    echo -e "${RED}❌ Config file permissions incorrect: $config_perms (expected 600)${NC}"
fi

if [ "$dir_perms" = "700" ]; then
    echo -e "${GREEN}✅ Config directory permissions set correctly: $dir_perms${NC}"
else
    echo -e "${RED}❌ Config directory permissions incorrect: $dir_perms (expected 700)${NC}"
fi

# Test file reading
echo -e "\n${YELLOW}Testing file reading...${NC}"
if [ -r "$TEST_CONFIG_FILE" ]; then
    echo -e "${GREEN}✅ Test file is readable by current user${NC}"
else
    echo -e "${RED}❌ Test file is not readable by current user${NC}"
fi

# Simulate environment variable extraction
echo -e "\n${YELLOW}Testing variable extraction...${NC}"
TZ_VALUE=$(grep "^TZ=" "$TEST_CONFIG_FILE" | cut -d= -f2)
if [ "$TZ_VALUE" = "Europe/Dublin" ]; then
    echo -e "${GREEN}✅ Variable extraction successful: TZ=$TZ_VALUE${NC}"
else
    echo -e "${RED}❌ Variable extraction failed${NC}"
fi

# Clean up
echo -e "\n${YELLOW}Cleaning up...${NC}"
rm -rf "$TEST_DIR"
echo -e "${GREEN}✅ Test files removed${NC}"

# Summary
echo -e "\n${YELLOW}File Permissions Test Summary${NC}"
echo "--------------------------------------------------------"
echo -e "${GREEN}File permissions test completed.${NC}"
echo "If all tests passed, your system supports the required file permission operations."
echo "If any tests failed, you may need to adjust the permissions handling in the script."
