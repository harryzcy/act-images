#!/bin/bash

# Languages
echo "node $(node -v) $(which node)"
echo "$(go version) $(which go)"
echo "$(python --version) $(which python)"
echo "$(rustc --version) $(which rustc)"

# Package Managers
echo "$(cargo --version) $(which cargo)"
echo "$(rustup --version 2>/dev/null) $(which rustup)"
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
docker buildx version
echo "$(git --version) $(which git)"
echo "sqlite3 $(sqlite3 --version) $(which sqlite3)"
echo "$(typos --version) $(which typos)"
echo "$(jq --version) $(which jq)"
wget --version | head -n 1
xz --version
zip --version | head -n 2
zstd --version
