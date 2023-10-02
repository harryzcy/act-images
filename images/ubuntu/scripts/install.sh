#!/bin/bash

NODE_VERSION="20.7.0"
GO_VERSION="1.21.1"
PYTHON_VERSION="3.11.5"

GIT_VERSION="2.42.0"
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
  # required for building git
  install-info
  dh-autoreconf
  libcurl4-gnutls-dev
  libexpat1-dev
  gettext
  libz-dev
  # end
  ssh
  gawk
  curl
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

)

export DEBIAN_FRONTEND=noninteractive
apt-get -q update
apt-get -qq -y install --no-install-recommends --no-install-suggests "${packages[@]}"
apt-get -q -y upgrade

# git (build from source)
echo "Installing git"
pushd /tmp || exit >/dev/null
curl -OL https://mirrors.edge.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.gz
tar -xzvf git-$GIT_VERSION.tar.gz >/dev/null
pushd git-$GIT_VERSION/ || exit
make configure
./configure --prefix=/usr/local
make all
sudo make install
popd || exit
popd || exit
echo "git installed: $(git --version)"
# End git

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

# Python
echo "Installing Python $PYTHON_VERSION"
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
echo "Python installed: $(python --version) at $(which python)"
# End Python

# Node
echo "Installing Node $NODE_VERSION"
curl https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$arch_short.tar.xz | tar --file=- --extract --xz --directory /usr/local/ --strip-components=1
echo "Node installed: $(node -v) at $(which node)"
# End Node

# Go
echo "Installing Go $GO_VERSION"
curl -L https://go.dev/dl/go$GO_VERSION.linux-$arch.tar.gz | tar -C /usr/local -xzf -
echo "Go installed: $(go version) at $(which go)"
# End Go

# Rust
echo "Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
echo "Rust installed: $(rustc --version) at $(which rustc)"
# End Rust

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
# End jq
