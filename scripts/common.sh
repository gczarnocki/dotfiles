#!/bin/bash

e='\033'
RESET="${e}[0m"
BOLD="${e}[1m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
YELLOW="${e}[0;93m"
GREEN="${e}[0;92m"

info() {
    echo -e "${CYAN}${*}${RESET}"
}

error() {
    echo -e "${RED}${*}${RESET}"
}

success() {
    echo -e "${GREEN}${*}${RESET}"
}

finish() {
    success "Done!"
    echo
    sleep 1
}

_exists() {
    command -v $1 > /dev/null 2>&1
}
