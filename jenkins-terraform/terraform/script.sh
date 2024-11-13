#!/usr/bin/env bash

sudo apt-get update && sudo apt-get install docker -y
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# install docker-compose 
sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose