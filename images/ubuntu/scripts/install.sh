#!/bin/bash

set -o errexit
set -o pipefail

NODE_VERSION="20.9.0"
GO_VERSION="1.21.3"

JQ_VERSION="1.7"

archstr=$(uname -m)
echo "Architecture: $archstr"
if [[ "$archstr" == "x86_64" ]]; then
  arch="amd64"
  arch_short="x64"
elif [[ "$archstr" == "aarch64" ]]; then
  arch="arm64"
  arch_short="arm64"
else
  echo "Unsupported architecture: $archstr"
  return 1
fi

export PATH="${PATH}:/usr/local/go/bin:/root/.cargo/bin:/root/.local/bin"

packages=(
  # buildpack packages
  autoconf
  automake
  bzip2
  dpkg-dev
  file
  g++
  gcc
  imagemagick
  libbz2-dev
  libc6-dev
  libcurl4-openssl-dev
  libdb-dev
  libevent-dev
  libffi-dev
  libgdbm-dev
  libglib2.0-dev
  libgmp-dev
  libjpeg-dev
  libkrb5-dev
  liblzma-dev
  libmagickcore-dev
  libmagickwand-dev
  libmaxminddb-dev
  libncurses5-dev
  libncursesw5-dev
  libpng-dev
  libpq-dev
  libreadline-dev
  libsqlite3-dev
  libssl-dev
  libtool
  libwebp-dev
  libxml2-dev
  libxslt-dev
  libyaml-dev
  make
  patch
  unzip
  xz-utils
  zlib1g-dev
  # end buildpack
  apt-transport-https
  build-essential
  ca-certificates
  curl
  libyaml-0-2
  sudo
  gawk
  gnupg
  gnupg-agent
  ssh
  software-properties-common
  wget
  zstd
  zip
  sqlite3
)

export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq -y upgrade
apt-get -qq -y install --no-install-recommends --no-install-suggests "${packages[@]}"

# Docker
echo "Installing Docker"
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
rm /etc/apt/sources.list.d/docker.list
rm /etc/apt/keyrings/docker.gpg
echo "Docker installed: $(docker --version)"
# End Docker

# Go
echo "Installing Go $GO_VERSION"
curl -L https://go.dev/dl/go$GO_VERSION.linux-$arch.tar.gz | tar -C /usr/local -xzf -
echo "Go installed: $(go version) at $(which go)"
# End Go

# Node
echo "Installing Node $NODE_VERSION"
curl https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$arch_short.tar.xz | tar --file=- --extract --xz --directory /usr/local/ --strip-components=1
echo "Node installed: $(node -v) at $(which node)"
# End Node

# Rust
echo "Installing Rust"
curl -fsSL https://sh.rustup.rs | sh -s -- -y --default-toolchain=stable --profile=minimal
echo "Rust installed: $(rustc --version) at $(which rustc)"
# End Rust

# Python
python -m pip install --user pipx
python -m pipx ensurepath
# End Python

# Ansible
echo "Installing Ansible"
python -m pipx install --include-deps ansible
python -m pipx install ansible-lint
echo "Ansible installed: $(ansible --version)"
echo "Ansible Lint installed: $(ansible-lint --version) at $(which ansible-lint)"
# End Ansible

# jq
echo "Installing jq"
curl -L https://github.com/jqlang/jq/releases/download/jq-$JQ_VERSION/jq-linux-$arch -o /usr/local/bin/jq
chmod +x /usr/local/bin/jq
echo "jq installed: $(jq --version) at $(which jq)"
# End jq

# typos
echo "Installing typos"
cargo install typos-cli
echo "typos installed: $(typos --version) at $(which typos)"
