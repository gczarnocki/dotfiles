#!/bin/bash

# Helpers

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

warn() {
    echo -e "${YELLOW}${*}${RESET}"
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

_test() {
    test -$1 $2
}

# Common return strings

_print_package_not_installed() {
    local package_name=${1:?"Package name must be specified."}
    warn "${package_name} package is not installed!"
}

_print_package_installing() {
    local package_name=${1:?"Package name must be specified."}
    info "Installing package: ${package_name}..."
}

_print_package_already_installed() {
    local package_name=${1:?"Package name must be specified."}
    success "${package_name} package is already installed! Skipping."
}

_print_package_detect_if_installed() {
    local package_name=${1:?"Package name must be specified."}
    info "Trying to detect if ${package_name} package is installed..."
}

# Package management

update_package_cache() {
    local proc_version=$(cat /proc/version)

    if [[ "${proc_version}" == *"Debian"* ]]; then
        apt-get update
    elif [[ "${proc_version}" == *"Red Hat"* ]]; then
        if _exists dnf; then
            dnf check-update
        elif _exists yum; then
            yum check-update
        fi
    else 
        echo "Here3"
    fi
}


upgrade_packages() {
    local proc_version=$(cat /proc/version)

    if [[ "${proc_version}" == *"Debian"* ]]; then
         sudo apt-get upgrade -y
    elif [[ "${proc_version}" == *"Red Hat"* ]]; then
        if _exists dnf; then
            sudo dnf upgrade -y
        elif _exists yum; then
            sudo yum upgrade -y
        fi
    fi
}

install_package() {
    package_name=${1:?"Package name(s) must be specified!"}

    if _exists brew; then
        brew install $@
    elif _exists apt; then
        sudo apt install -y $@
    elif _exists dnf; then
        sudo dnf install -y $@
    elif _exists yum; then
        sudo yum install -y $@
    fi
}
