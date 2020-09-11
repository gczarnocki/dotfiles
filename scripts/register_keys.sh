#!/bin/bash

echo "Start ssh-agent..."
eval "$(ssh-agent -s)"

for file in $(find . -type f -iname "id_rsa*" ! -iname "*.pub"); do
    echo "Registering key: ${file}..."
    ssh-add ${file}
done

echo "Done."
