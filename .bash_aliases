#!/bin/bash

# Enable aliases to be sudo’ed
# http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '

# cmd-like clear
alias clr='clear'

# Path traversal
alias "~"="cd $HOME"
alias ".."="cd .."
alias "..."="cd ../../"
alias "...."="cd ../../../"
alias "....."="cd ../../../../"

alias "dot"="cd ~/dotfiles && vi ."
alias "bashrc"=". ~/.bashrc && echo \".bashrc has been reloaded.\""

alias myip="dig +short myip.opendns.com @resolver1.opendns.com"

# ${PATH} in readable format
alias path="echo ${PATH//:/\\n}"

alias dotfiles="cd ${DOTFILES}"
