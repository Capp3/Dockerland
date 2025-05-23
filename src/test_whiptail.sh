#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Docker Management TUI Helper (DMTH) - Whiptail Test${NC}"
echo "--------------------------------------------------------"

# Test if whiptail is available
if ! command -v whiptail &> /dev/null; then
    echo -e "${RED}Error: whiptail is not installed${NC}"
    echo "Please install whiptail before proceeding."
    exit 1
fi

echo -e "${GREEN}Whiptail found. Running interactive tests...${NC}"

# Set terminal colors
export TERM=ansi

# Function to handle test results
show_result() {
    local name=$1
    local status=$2

    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ $name test successful${NC}"
    else
        echo -e "${RED}❌ $name test cancelled or failed${NC}"
    fi
}

# Test 1: Simple menu
echo -e "\n${YELLOW}Test 1: Menu - Select an option or press Cancel/ESC${NC}"
option=$(whiptail --title "DMTH Test Menu" --menu "Choose an option:" 15 60 4 \
    "1" "Option 1" \
    "2" "Option 2" \
    "3" "Option 3" \
    "4" "Exit" 3>&1 1>&2 2>&3)

exit_status=$?
show_result "Menu" $exit_status

if [ $exit_status = 0 ]; then
    echo "You selected option: $option"
fi

# Test 2: Message box
echo -e "\n${YELLOW}Test 2: Message Box - Press OK to continue${NC}"
whiptail --title "Message Box Test" --msgbox "This is a test message box.\n\nPress OK to continue." 10 60
show_result "Message Box" $?

# Test 3: Yes/No dialog
echo -e "\n${YELLOW}Test 3: Yes/No Dialog - Select Yes or No${NC}"
whiptail --title "Yes/No Dialog Test" --yesno "Is whiptail working correctly?" 8 60
show_result "Yes/No Dialog" $?

# Test 4: Input box
echo -e "\n${YELLOW}Test 4: Input Box - Enter some text or press Cancel${NC}"
name=$(whiptail --title "Input Box Test" --inputbox "Enter your name:" 8 60 "User" 3>&1 1>&2 2>&3)
input_status=$?
show_result "Input Box" $input_status

if [ $input_status = 0 ]; then
    echo "You entered: $name"
fi

# Test 5: Password box
echo -e "\n${YELLOW}Test 5: Password Box - Enter some text or press Cancel${NC}"
pass=$(whiptail --title "Password Box Test" --passwordbox "Enter a password:" 8 60 3>&1 1>&2 2>&3)
pass_status=$?
show_result "Password Box" $pass_status

if [ $pass_status = 0 ]; then
    echo "Password entered successfully (not displayed for security)"
fi

# Summary
echo -e "\n${YELLOW}Whiptail Test Summary${NC}"
echo "--------------------------------------------------------"
echo -e "${GREEN}All whiptail components tested.${NC}"
echo "If all tests completed successfully, whiptail is working correctly."
echo "If any tests failed, check your terminal configuration."
