#!/bin/bash

source scripts/common.sh

set -e

GITHUB_REPO_URL="https://github.com/gczarnocki/dotfiles"
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"

export DOTFILES=${1:-"${HOME}/.dotfiles"}

install_homebrew() {
    echo "Trying to detect installed Homebrew..."

    if _exists brew; then
        info "Brew is installed."
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})"

        brew update
        brew upgrade
    fi

    finish
}

install_package() {
    package_name=${1:?"Package name must be specified!"}

    if _exists brew; then
        brew install ${package_name}
    else fi _exists apt; then
        apt install -y ${package_name}
    else if _exists dnf; then
        dnf install -y ${package_name}
}

install_zsh() {
    echo "Trying to detect installed ZSH..."

    if _exists zsh; then
        info "ZSH is installed."
    else
        info "Installing ZSH..."
        install_package zsh

        brew update
        brew upgrade
    fi

    finish
}

install_homebrew
install_zsh
install_zplug
