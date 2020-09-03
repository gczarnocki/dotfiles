#
# ~/.zshrc
#

# Initialize Zplug
source ~/.zplug/init.zsh

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/home/nc-gcz/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Dependencies

# Zplug self-management
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# Oh-My-Zsh core
zplug "lib/*", from:oh-my-zsh

# Oh-My-Zsh plugins
zplug "plugins/history-substring-search", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/npm", from:oh-my-zsh
zplug "plugins/nvm", from:oh-my-zsh

# Improvements
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "hlissner/zsh-autopair", defer:2

zplug "denysdovhan/spaceship-prompt", as:theme, use:"spaceship.zsh"

if ! zplug check --verbose; then
  zplug install
fi

zplug load
