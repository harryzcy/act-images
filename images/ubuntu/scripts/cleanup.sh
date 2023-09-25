#!/bin/bash

apt-get -qq -y autoremove
apt-get -qq -y clean
rm -rf /var/lib/apt/lists/*
