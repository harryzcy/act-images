#!/bin/bash

PYTHON_VERSION="3.11.5"

GIT_VERSION="2.42.0"

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
apt-get -qq update
apt-get -qq -y upgrade
apt-get -qq -y install --no-install-recommends --no-install-suggests "${packages[@]}"

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
rm -rf /tmp/git-$GIT_VERSION
echo "git installed: $(git --version)"
# End git

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

popd || exit
popd || exit
rm -rf /tmp/Python-$PYTHON_VERSION
echo "Python installed: $(python --version) at $(which python)"
# End Python