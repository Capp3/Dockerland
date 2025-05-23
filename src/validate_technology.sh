#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}Docker Management TUI Helper (DMTH) - Technology Validation${NC}"
echo -e "${BLUE}==================================================${NC}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make all test scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

# Track overall status
OVERALL_STATUS=0
VALIDATION_RESULTS=()

# Function to run a test and track results
run_test() {
    local test_script=$1
    local test_name=$2
    local interactive=$3

    echo -e "\n${BLUE}==================================================${NC}"
    echo -e "${YELLOW}Running $test_name test...${NC}"
    echo -e "${BLUE}==================================================${NC}"

    if [ "$interactive" = true ]; then
        echo -e "${YELLOW}This is an interactive test. You'll need to provide input.${NC}"
        read -p "Press Enter to start the test, or type 'skip' to skip it: " choice

        if [[ "$choice" == "skip" ]]; then
            echo -e "${YELLOW}Skipping $test_name test...${NC}"
            VALIDATION_RESULTS+=("$test_name: ${YELLOW}SKIPPED${NC}")
            return 0
        fi
    fi

    # Run the test script
    "$SCRIPT_DIR/$test_script"
    local status=$?

    if [ $status -eq 0 ]; then
        VALIDATION_RESULTS+=("$test_name: ${GREEN}PASSED${NC}")
    else
        VALIDATION_RESULTS+=("$test_name: ${RED}FAILED${NC}")
        OVERALL_STATUS=1
    fi

    return $status
}

# Run all tests
run_test "check_dependencies.sh" "Dependency Check" false
run_test "test_whiptail.sh" "Whiptail Integration" true
run_test "test_docker.sh" "Docker and Docker Compose" false
run_test "test_permissions.sh" "File Permissions" false
run_test "test_ssh.sh" "SSH Connectivity" true

# Summary
echo -e "\n${BLUE}==================================================${NC}"
echo -e "${YELLOW}Technology Validation Summary${NC}"
echo -e "${BLUE}==================================================${NC}"

for result in "${VALIDATION_RESULTS[@]}"; do
    echo -e "$result"
done

echo -e "\n${BLUE}==================================================${NC}"
if [ $OVERALL_STATUS -eq 0 ]; then
    echo -e "${GREEN}All tests passed successfully! Your system is ready for DMTH.${NC}"
else
    echo -e "${RED}Some tests failed. Please address the issues before proceeding.${NC}"
fi
echo -e "${BLUE}==================================================${NC}"

exit $OVERALL_STATUS
