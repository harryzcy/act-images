#!/bin/bash

set -o errexit
set -o pipefail

NODE_VERSION="20.11.0"
GO_VERSION="1.21.6"

ANSIBLE_VERSION="9.2.0"
ANSIBLE_CORE_VERSION="2.16.3"
ANSIBLE_LINT_VERSION="6.22.2"
JQ_VERSION="1.7.1"
PIPX_VERSION="1.4.3"
TYPOS_CLI_VERSION="1.18.1"
RUFF_VERSION="0.2.1"

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
  chktex # for latex
  curl
  libyaml-0-2
  lsof # for killing processes
  sudo
  gawk
  gnupg
  gnupg-agent
  ssh
  software-properties-common
  wget
  zstd
  zip
  zsh
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
apt-get -qq -y install --no-install-recommends --no-install-suggests docker-ce-cli docker-buildx-plugin
rm /etc/apt/sources.list.d/docker.list
rm /etc/apt/keyrings/docker.gpg
echo "Docker installed: $(docker --version)"
echo "Docker buildx installed: $(docker buildx version)"
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
python -m pip install --user "pipx==$PIPX_VERSION"
python -m pipx ensurepath
# End Python

# ansible
echo "Installing ansible"
python -m pipx install "ansible-core==$ANSIBLE_CORE_VERSION"
python -m pipx install --include-deps "ansible==$ANSIBLE_VERSION"
python -m pipx install "ansible-lint==$ANSIBLE_LINT_VERSION"
echo "ansible installed: $(ansible --version)"
echo "ansible-lint installed: $(ansible-lint --version) at $(which ansible-lint)"
# End ansible

# jq
echo "Installing jq"
curl -L https://github.com/jqlang/jq/releases/download/jq-$JQ_VERSION/jq-linux-$arch -o /usr/local/bin/jq
chmod +x /usr/local/bin/jq
echo "jq installed: $(jq --version) at $(which jq)"
# End jq

# typos
echo "Installing typos"
cargo install typos-cli --version "$TYPOS_CLI_VERSION"
rm -rf /root/.cargo/registry
echo "typos installed: $(typos --version) at $(which typos)"

# ruff
echo "Installing ruff"
python -m pipx install "ruff==$RUFF_VERSION"
echo "ruff installed: $(ruff --version) at $(which ruff)"
