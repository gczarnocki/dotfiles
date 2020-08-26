#!/bin/bash

echo "Running this script will override files in your home directory."
read -p "Confirm? (y|n)" -n 1 ANSWER

if [[ "${ANSWER}" =~ y|Y ]]; then
    linkFile .bashrc
    linkFile .hushlogin
fi

function linkFile {
    pushd ~
    file=$1

    if [ -h "${file}" ]; then
        unlink ${file}
    else fi [ -f "${file}" ]; then
        rm ${file}
    fi

    ln -s ${file} ~/dotfiles/${file}

    popd
}