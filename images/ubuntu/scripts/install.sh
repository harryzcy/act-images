#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

packages=(
  ssh
  gawk
  curl
  jq
  wget
  sudo
  gnupg
  gnupg-agent
  ca-certificates
  software-properties-common
  apt-transport-https
  libyaml-0-2
  zstd
  zip
  unzip
  xz-utils
  python3-pip
  python3-venv
  pipx
)

apt-get -yq install --no-install-recommends --no-install-suggests "${packages[@]}"

archstr=$(uname -m)
if [[ "$archstr" == "x86_64" ]]; then
  arch="x64"
elif [[ "$archstr" == "arm64" || "$archstr" == "arm" || "$archstr" == "aarch64" ]]; then
  arch="arm64"
else
  echo "Unsupported architecture: $archstr"
  return 1
fi

NODE_VERSION="20.7.0"
curl https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$arch.tar.xz | tar --file=- --extract --xz --directory /usr/local/ --strip-components=1

# Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null
apt-get update
apt-get -yq install --no-install-recommends --no-install-suggests docker-ce-cli
