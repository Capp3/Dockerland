#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Docker Management TUI Helper (DMTH) - SSH Test${NC}"
echo "--------------------------------------------------------"

# Check if ssh is available
if ! command -v ssh &> /dev/null; then
    echo -e "${RED}Error: ssh is not installed${NC}"
    echo "Please install OpenSSH before proceeding."
    exit 1
fi

if ! command -v scp &> /dev/null; then
    echo -e "${RED}Error: scp is not installed${NC}"
    echo "Please install OpenSSH before proceeding."
    exit 1
fi

echo -e "${GREEN}✅ SSH and SCP found.${NC}"

# Interactive test
echo -e "\n${YELLOW}This test requires an SSH server to connect to.${NC}"
echo "You can press Ctrl+C at any time to cancel the test."

# Ask for SSH connection details
echo -e "\n${YELLOW}Enter SSH connection details:${NC}"
read -p "Hostname or IP: " TEST_HOST
read -p "Username: " TEST_USER
read -p "Port (default: 22): " TEST_PORT
TEST_PORT=${TEST_PORT:-22}

# Create a test file
TEST_FILE="/tmp/dmth_ssh_test_$(date +%s).txt"
echo "This is a test file from DMTH SSH test." > "$TEST_FILE"

# Test SSH connection
echo -e "\n${YELLOW}Testing SSH connection to $TEST_USER@$TEST_HOST:$TEST_PORT...${NC}"
if ssh -o BatchMode=no -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -p "$TEST_PORT" "$TEST_USER@$TEST_HOST" "echo 'SSH connection successful'" &> /dev/null; then
    echo -e "${GREEN}✅ SSH connection successful.${NC}"

    # Test command execution
    echo -e "\n${YELLOW}Testing remote command execution...${NC}"
    REMOTE_HOSTNAME=$(ssh -p "$TEST_PORT" "$TEST_USER@$TEST_HOST" "hostname" 2>/dev/null)
    if [ -n "$REMOTE_HOSTNAME" ]; then
        echo -e "${GREEN}✅ Remote command execution successful.${NC}"
        echo "Remote hostname: $REMOTE_HOSTNAME"

        # Test file transfer
        echo -e "\n${YELLOW}Testing SCP file transfer...${NC}"
        if scp -P "$TEST_PORT" "$TEST_FILE" "$TEST_USER@$TEST_HOST:/tmp/" &> /dev/null; then
            echo -e "${GREEN}✅ File transfer successful.${NC}"

            # Verify file exists and clean up
            REMOTE_FILE_CHECK=$(ssh -p "$TEST_PORT" "$TEST_USER@$TEST_HOST" "cat /tmp/$(basename "$TEST_FILE") && rm /tmp/$(basename "$TEST_FILE")" 2>/dev/null)
            if [[ "$REMOTE_FILE_CHECK" == *"This is a test file from DMTH SSH test."* ]]; then
                echo -e "${GREEN}✅ Remote file verification successful.${NC}"
            else
                echo -e "${RED}❌ Remote file verification failed.${NC}"
            fi
        else
            echo -e "${RED}❌ File transfer failed.${NC}"
            echo "Check permissions and connectivity."
        fi
    else
        echo -e "${RED}❌ Remote command execution failed.${NC}"
    fi
else
    echo -e "${RED}❌ SSH connection failed.${NC}"
    echo "Check your SSH settings and connectivity."
fi

# Clean up
rm -f "$TEST_FILE"

# Summary
echo -e "\n${YELLOW}SSH Test Summary${NC}"
echo "--------------------------------------------------------"
echo -e "${GREEN}SSH test completed.${NC}"
echo "If all tests passed, your SSH connectivity is working correctly."
echo "If any tests failed, check your SSH configuration and network connectivity."
