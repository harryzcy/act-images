#!/bin/bash

set -o errexit
set -o pipefail

PYTHON_VERSION="3.13.0"

PIP_VERSION="24.3.1"
GIT_VERSION="2.47.1"

BASEDIR=$(dirname $0)

# shellcheck disable=SC2034
IFS='.' read -r PYTHON_MAJOR PYTHON_MINOR PYTHON_PATCH <<<"$PYTHON_VERSION"
PYTHON_VERSION_MAJOR_MINOR="${PYTHON_MAJOR}.${PYTHON_MINOR}"

packages=(
  ca-certificates
  curl
  # required by python
  build-essential
  gdb
  lcov
  pkg-config
  libbz2-dev
  libffi-dev
  libgdbm-dev
  libgdbm-compat-dev
  liblzma-dev
  libncurses5-dev
  libreadline6-dev
  libsqlite3-dev
  libssl-dev
  lzma
  lzma-dev
  tk-dev
  uuid-dev
  zlib1g-dev
  # required by git
  install-info
  dh-autoreconf
  libexpat1-dev
  gettext
  libz-dev
  libcurl4-openssl-dev
  # end
)

export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq -y upgrade
apt-get -qq -y install --no-install-recommends --no-install-suggests "${packages[@]}"

# git (build from source)
echo "Installing git"
pushd /tmp || exit >/dev/null
curl -OL https://mirrors.edge.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.gz
tar -xzvf git-$GIT_VERSION.tar.gz >/dev/null
pushd git-$GIT_VERSION/ || exit
make -j "$(nproc)" configure
./configure --prefix=/usr/local
make -j "$(nproc)" all
make -j "$(nproc)" install
popd || exit
popd || exit
rm -rf /tmp/git-$GIT_VERSION
echo "git installed: $(git --version)"
# End git

# Python
echo "Installing Python $PYTHON_VERSION"
pushd /tmp || exit >/dev/null
curl -sSOL https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
tar -xzvf Python-$PYTHON_VERSION.tgz >/dev/null
pushd Python-$PYTHON_VERSION/ || exit

./configure --enable-optimizations >/dev/null
make -j "$(nproc)" && make -j "$(nproc)" altinstall

ln -s "/usr/local/bin/python$PYTHON_VERSION_MAJOR_MINOR" /usr/local/bin/python
ln -s "/usr/local/bin/python$PYTHON_VERSION_MAJOR_MINOR" /usr/local/bin/python3
ln -s "/usr/local/bin/pip$PYTHON_VERSION_MAJOR_MINOR" /usr/local/bin/pip
ln -s "/usr/local/bin/pip$PYTHON_VERSION_MAJOR_MINOR" /usr/local/bin/pip3

# Upgrade pip
pip install --require-hashes -r "$BASEDIR/requirements-pip.txt"

popd || exit
popd || exit
rm -rf /tmp/Python-$PYTHON_VERSION
echo "Python installed: $(python --version) at $(which python)"
# End Python
