#!/bin/bash

source scripts/common.sh

set -e

GITHUB_REPO_URL="https://github.com/gczarnocki/dotfiles"

DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)"
DOCKER_COMPOSE_BASHCOMPLETION_URL="https://raw.githubusercontent.com/docker/compose/1.26.2/contrib/completion/bash/docker-compose"
ZPLUG_INSTALLER_URL="https://raw.githubusercontent.com/zplug/installer/master/installer.zsh"
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"

export DOTFILES=${1:-"${HOME}/.dotfiles"}

install_homebrew() {
    echo "Trying to detect installed Homebrew..."

    if _exists brew; then
        info "Brew is installed."
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})"

        eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
        brew update
        brew upgrade
    fi

    finish
}

install_zsh() {
    local name="ZSH"
    local package_name="zsh"

    _print_package_detect_if_installed $name

    if ! _exists zsh; then
        _print_package_not_installed $name
        read -p "Do you want to install $name? [y/N]" -n 1 answer
        echo

        if [ "${answer}" != "y" ]; then
            exit 1
        fi

        _print_package_installing $name
        install_package $package_name
    else
        _print_package_already_installed $package_name
    fi

    finish
}

import_vscode_repository() {
    local proc_version=$(cat /proc/version)

    info "Installing Visual Studio Code package repository..."

    # Debian (Ubuntu, Mint)
    if [[ "${proc_version}" =~ *"Debian"* ]]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    # RHEL, Fedora, CentOS
    elif [[ "${proc_version}" =~ *"Red Hat"* ]]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    fi

    finish
}

install_vscode() {
    local name="Visual Studio Code"
    local package_name="code"

    _print_package_detect_if_installed "${name}"

    if ! _exists ${package_name}; then
        _print_package_installing "${name}"
        import_vscode_repository
        update_package_cache    
        install_package code
    else
        _print_package_already_installed "${name}"
    fi

    finish
}

install_git() {
    local name="Git"
    local package_name="git"

    _print_package_detect_if_installed $name

    if ! _exists git; then
        _print_package_not_installed $name

        read -p "Do you want to install $name? [y/N] " -n 1 answer
        echo

        if [ "${answer}" != "y" ]; then
            exit 1
        fi

        _print_package_installing $name
        install_package git
    else
        _print_package_already_installed $name
    fi

    finish
}

install_zplug() {
    local name="zplug"

    _print_package_detect_if_installed $name

    # Check if directory exists
    if ! _test d "${HOME}/.zplug"; then
        # https://github.com/zplug/zplug
        curl -sL --proto-redir -all,https ${ZPLUG_INSTALLER_URL} | zsh
    else
        _print_package_already_installed $name
    fi

    finish
}

install_powerline_fonts() {
    local fonts_dir="${HOME}/.local/share/fonts"
    local package_name="Powerline Fonts"

    _print_package_detect_if_installed "${package_name}"

    if ! [ "$(ls -1 ${fonts_dir} | grep -i "Powerline" | wc -l)" -gt "0" ]; then
        _print_package_installing "${package_name}"

        # https://github.com/powerline/fonts#quick-installation
        pushd ~
        git clone https://github.com/powerline/fonts.git --depth=1
        pushd fonts
        ./install.sh
        popd
        rm -rf fonts
        popd

        finish
    else
        _print_package_already_installed "${package_name}"
    fi

    finish
}

delete_previous_docker_installations() {
    local proc_version=$(cat /proc/version)

    info "Removing previous Docker installations..."

    # Debian (Ubuntu, Mint)
    if [[ "${proc_version}" =~ *"Debian"* ]]; then
        sudo apt-get remove docker docker-engine docker.io containerd runc
    # RHEL, Fedora, CentOS
    elif [[ "${proc_version}" =~ *"Red Hat"* ]]; then
        sudo dnf remove -y docker-* containerd runc
        sudo dnf config-manager --disable docker-*
    fi
    
    finish
}

install_docker_repository() {
    local proc_version=$(cat /proc/version)

    info "Installing Docker package repository..."

    # Debian (Ubuntu, Mint)
    if [[ "${proc_version}" =~ *"Debian"* ]]; then
        sudo apt-get update
        sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
    # RHEL, Fedora, CentOS
    elif [[ "${proc_version}" =~ *"Red Hat"* ]]; then
        warn "'docker-ce' repository for Fedora 32 is not present, use 'moby-engine' instead!"
        # sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    fi

    finish
}

install_docker_package() {
    ocal proc_version=$(cat /proc/version)

    info "Installing Docker package repository..."

    # Debian (Ubuntu, Mint)
    if [[ "${proc_version}" =~ *"Debian"* ]]; then
        install_package docker-ce docker-ce-cli containerd.io
    # RHEL, Fedora, CentOS
    elif [[ "${proc_version}" =~ *"Red Hat"* ]]; then
        install_package moby-engine
    fi

    finish       
}

install_docker() {
    # https://fedoramagazine.org/docker-and-fedora-32/
    # Fedora 32 doesn't support Docker OOTB at the moment
    local name="Docker"
    local proc_version=$(cat /proc/version)

    _print_package_detect_if_installed "${name}"

    if ! _exists docker; then
        delete_previous_docker_installations
        install_docker_repository
        install_docker_package
        
        sudo systemctl enable docker
        sudo systemctl start docker

        sudo docker run hello-world

        sudo groupadd docker
        sudo usermod -aG docker $USER
    else
        _print_package_already_installed ${name}
    fi

    finish
}

install_docker_compose() {
    local name="Docker Compose"
    local package_name="docker-compose"

    if ! _exists 'docker-compose'; then
        sudo curl -L "${DOCKER_COMPOSE_URL}" -o /usr/local/bin/docker-compose
        sudo curl -L "${DOCKER_COMPOSE_BASHCOMPLETION_URL}" -o /etc/bash_completion.d/docker-compose
    else
        _print_package_already_installed "${name}"
    fi

    finish
}

install_homebrew
install_git
install_vscode
install_zsh
install_zplug
install_powerline_fonts
install_docker
install_docker_compose