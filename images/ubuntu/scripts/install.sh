#!/bin/bash

NODE_VERSION="20.7.0"
GO_VERSION="1.21.1"
PYTHON_VERSION="3.11.5"

archstr=$(uname -m)
echo "Architecture: $archstr"
if [[ "$archstr" == "x86_64" ]]; then
  arch="amd64"
  arch_short="x64"
elif [[ "$archstr" == "arm64" || "$archstr" == "arm" || "$archstr" == "aarch64" ]]; then
  arch="arm64"
  arch_short="arm64"
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
  build-essential
  git
)

apt-get -qq -y install --no-install-recommends --no-install-suggests "${packages[@]}"

# Node
curl https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$arch_short.tar.xz | tar --file=- --extract --xz --directory /usr/local/ --strip-components=1
# End Node

# Go
curl -L https://go.dev/dl/go$GO_VERSION.linux-$arch.tar.gz | tar -C /usr/local -xzf -
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

# Python
pushd /tmp || exit >/dev/null
wget -q https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
tar -xzvf Python-$PYTHON_VERSION.tgz >/dev/null
pushd Python-$PYTHON_VERSION/ || exit

./configure --enable-optimizations >/dev/null
make -j "$(nproc)" && make -j "$(nproc)" altinstall

ln -s /usr/local/bin/python3.11 /usr/local/bin/python
ln -s /usr/local/bin/python3.11 /usr/local/bin/python3
ln -s /usr/local/bin/pip3.11 /usr/local/bin/pip
ln -s /usr/local/bin/pip3.11 /usr/local/bin/pip3

python -m pip install --user pipx
python -m pipx ensurepath

popd || exit
popd || exit
rm -rf /tmp/Python-$PYTHON_VERSION
# End Python

# Ansible
python -m pipx install --include-deps ansible
python -m pipx install ansible-lint
# End Ansible
