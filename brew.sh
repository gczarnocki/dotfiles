# Installation script for Brew

source scripts/common.sh

info "Brew: update..."
brew update

info "Brew: upgrade..."
brew upgrade

brew "gcc"
brew "tmux"
brew "stow"
brew "tree"
brew "zsh"
