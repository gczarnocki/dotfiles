#!/bin/bash

# Path traversal
alias "~"="cd $HOME"
alias ".."="cd .."
alias "..."="cd ../../"
alias "...."="cd ../../../"
alias "....."="cd ../../../../"

alias "dot"="cd ~/dotfiles && vi ."
alias "bashrc"=". ~/.bashrc && echo \".bashrc has been reloaded.\""
