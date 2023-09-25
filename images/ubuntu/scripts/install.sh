#!/bin/bash

NODE_VERSION="20.7.0"
GO_VERSION="1.21.1"

archstr=$(uname -m)
go_arch="amd64"
echo "Architecture: $archstr"
if [[ "$archstr" == "x86_64" ]]; then
  arch="x64"
  go_arch="amd64"
elif [[ "$archstr" == "arm64" || "$archstr" == "arm" || "$archstr" == "aarch64" ]]; then
  arch="arm64"
  go_arch="arm64"
else
  echo "Unsupported architecture: $archstr"
  return 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq -y upgrade

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
  sqlite3
  python3-pip
  python3-venv
  pipx
  build-essential
  git
)

apt-get -qq -y install --no-install-recommends --no-install-suggests "${packages[@]}"

curl https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$arch.tar.xz | tar --file=- --extract --xz --directory /usr/local/ --strip-components=1
# End Node

# Go
curl -L https://go.dev/dl/go$GO_VERSION.linux-$go_arch.tar.gz | tar -C /usr/local -xzf -
# End Go

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# End Rust

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
# End Docker

# Ansible
pipx install --include-deps ansible
pipx install ansible-lint
# End Ansible
