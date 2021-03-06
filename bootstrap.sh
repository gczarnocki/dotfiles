#!/bin/bash

source scripts/common.sh

set -e

GITHUB_REPO_URL="https://github.com/gczarnocki/dotfiles"

DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)"
DOCKER_COMPOSE_BASHCOMPLETION_URL="https://raw.githubusercontent.com/docker/compose/1.26.2/contrib/completion/bash/docker-compose"
ZPLUG_INSTALLER_URL="https://raw.githubusercontent.com/zplug/installer/master/installer.zsh"
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
GOLANG_INSTALL_URL="https://golang.org/dl/go1.15.1.linux-amd64.tar.gz"
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh"

export DOTFILES=${1:-"${HOME}/.dotfiles"}

on_start() {
    info "         __      __  _____ __         "
    info "    ____/ /___  / /_/ __(_) /__  _____"
    info "   / __  / __ \/ __/ /_/ / / _ \/ ___/"
    info " _/ /_/ / /_/ / /_/ __/ / /  __(__  ) "
    info "(_)__,_/\____/\__/_/ /_/_/\___/____/  "
    info "                                      "
    info "             @gczarnocki				"
    echo
}

on_finish() {
    info "         __                 __"
    info "    ____/ /___  ____  ___  / /"
    info "   / __  / __ \/ __ \/ _ \/ / "
    info " _/ /_/ / /_/ / / / /  __/_/  "
    info "(_)__,_/\____/_/ /_/\___(_)   "
    info "                              "
    echo
}

install_homebrew() {
    _print_package_detect_if_installed "Homebrew"

    HOMEBREW_EXECUTABLE_PATH=/home/linuxbrew/.linuxbrew/bin/brew

    # TODO: check better for Brew presence
    if _test f $HOMEBREW_EXECUTABLE_PATH; then
        eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
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
    if [[ "${proc_version}" == *"Debian"* || "${proc_version}" == *"Ubuntu"* ]]; then
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    # RHEL, Fedora, CentOS
    elif [[ "${proc_version}" == *"Red Hat"* ]]; then
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
        import_vscode_repository
        update_package_cache
        install_package apt-transport-https
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
    if _exists apt-get; then
        sudo apt-get update
        sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
    # RHEL, Fedora, CentOS
    # TODO: Fix this installation for Fedora 32
    elif [[ "${proc_version}" =~ *"Red Hat"* ]]; then
        warn "'docker-ce' repository for Fedora 32 is not present, use 'moby-engine' instead!"
        # sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    fi

    finish
}

install_docker_package() {
    local proc_version=$(cat /proc/version)

    info "Installing Docker package repository..."

    # Debian (Ubuntu, Mint)
    if [[ "${proc_version}" == *"Debian"* || "${proc_version}" == *"Ubuntu"* ]]; then
        install_package docker-ce docker-ce-cli containerd.io
    # RHEL, Fedora, CentOS
    elif [[ "${proc_version}" == *"Red Hat"* ]]; then
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

    _print_package_detect_if_installed "${package_name}"

    if ! _exists 'docker-compose'; then
        sudo curl -L "${DOCKER_COMPOSE_URL}" -o /usr/local/bin/docker-compose
    else
        _print_package_already_installed "${package_name}"
    fi

    if ! _test f /etc/bash_completion.d/docker-compose; then
        _print_package_installing "docker-compose Bash completion"
        sudo curl -L "${DOCKER_COMPOSE_BASHCOMPLETION_URL}" -o /etc/bash_completion.d/docker-compose
    else
        _print_package_already_installed "docker-compose Bash completion"
    fi

    finish
}

install_golang() {
    local package_name="go"

    # TODO: check if Go is installed
    _print_package_detect_if_installed "${package_name}"

    if ! _exists go; then
        _print_package_installing "${package_name}"

        pushd ~
        wget "${GOLANG_INSTALL_URL}"
        sudo rm -rf /usr/local/go
        tar -C /usr/local -xzf go*.linux-amd64.tar.gz
        popd
    else
        _print_package_already_installed "${package_name}"
    fi

    finish
}

install_nvm() {
    local package_name="nvm"

    _print_package_detect_if_installed ${package_name}

    # FIXME
    if ! _exists ${package_name}; then
        _print_package_installing ${package_name}
        # https://github.com/nvm-sh/nvm#installing-and-updating
        curl -o- ${NVM_INSTALL_URL} | bash
    else
        _print_package_already_installed ${package_name}
    fi

    finish
}

install_node() {
    local name="Node, NPM @ LTS version"
    _print_package_detect_if_installed "${name}"
        
    local NVM_DIR="$HOME/.nvm"
    if _test s "$NVM_DIR/nvm.sh"; then
        info "Sourcing $NVM_DIR/nvm.sh..."
        . "$NVM_DIR/nvm.sh"

        if ! _exists node; then
            nvm install --lts --latest-npm
        else
            _print_package_already_installed "${name}"
        fi
    else
        _print_package_already_installed "${name}"
    fi

    finish
}

install_base_packages() {
    for pkg in $(cat packages.list); do
        if ! _exists $pkg; then
            read -p "Do you want to install $pkg? [y/N] " -n 1 answer
            echo

            if [ "${answer}" != "y" ]; then
                continue
            fi

            _print_package_installing $pkg
            install_package $pkg
        else
            _print_package_already_installed $pkg
        fi
    done

    finish
}

on_start

install_git
install_homebrew
install_vscode
install_zsh
install_zplug
install_powerline_fonts
install_docker
install_docker_compose
install_golang
install_nvm
install_node
install_base_packages

# bootstrap

on_finish
