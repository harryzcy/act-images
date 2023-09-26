#!/bin/bash

# Languages
echo "node $(node -v) $(which node)"
echo "$(go version) $(which go)"
echo "$(python --version) $(which python)"
echo "$(rustc --version) $(which rustc)"

# Package Managers
echo "$(cargo --version) $(which cargo)"
echo "npm $(npm -v) $(which npm)"
echo "$(pip -V) $(which pip)"
echo "$(pip3 -V) $(which pip3)"
echo "$(pipx --version) $(which pipx)"

# Tools
ansible --version
ansible-lint --version
awk --version | head -n 1
curl --version
echo "$(docker -v) $(which docker)"
echo "$(git --version) $(which git)"
echo "sqlite3 $(sqlite3 --version) $(which sqlite3)"
jq --version
wget --version | head -n 1
xz --version
zip --version | head -n 2
zstd --version
