#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq -y upgrade

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
  git
)

apt-get -qq -y install --no-install-recommends --no-install-suggests "${packages[@]}"

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
dpkg_arch="$(dpkg --print-architecture)"
codename="$(lsb_release -cs)"
echo \
  "deb [arch=$dpkg_arch signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $codename stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null
apt-get -qq update
apt-get -qq -y install --no-install-recommends --no-install-suggests docker-ce-cli

# Ansible
pipx install --include-deps ansible
pipx install ansible-lint
