#!/bin/bash


TAG=$(curl -s https://api.github.com/repos/goharbor/harbor/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
URI="https://github.com/goharbor/harbor/releases/download/${TAG}/harbor-online-installer-${TAG}.tgz"
wget $URI
tar xzfv harbor-online-installer-${TAG}.tgz


TAG=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
sudo curl -L "https://github.com/docker/compose/releases/download/${TAG}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
