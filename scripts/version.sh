#!/bin/bash

echo "$(git --version) $(which git)"
echo "$(docker -v) $(which docker)"
echo "node $(node -v) $(which node)"
echo "$(python --version) $(which python)"
echo "$(go version) $(which go)"
echo "$(rustc --version) $(which rustc)"
echo "npm $(npm -v) $(which npm)"
ansible --version
ansible-lint --version
