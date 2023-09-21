#!/bin/bash

archstr=$(uname -m)
if [[ "$archstr" == "x86_64" ]]; then
  arch="x64"
elif [[ "$archstr" == "arm64" || "$archstr" == "arm" || "$archstr" == "aarch64" ]]; then
  arch="arm64"
else
  echo "Unsupported architecture: $archstr"
  return 1
fi

NODE_VERSION=18.8.0
curl https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$arch.tar.xz | tar --file=- --extract --xz --directory /usr/local/ --strip-components=1
