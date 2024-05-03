#!/bin/bash

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

# Check if curl is installed, if not, install it
if ! command -v curl &> /dev/null
then
    echo "curl could not be found"
    echo "Installing curl..."
    sudo apt-get update && sudo apt-get install -y curl
fi

# Retrieve k3s token from the master node
K3S_TOKEN=$(cat /vagrant/token)

export INSTALL_K3S_EXEC="agent --server https://192.168.56.110:6443 --token $K3S_TOKEN --node-ip=192.168.56.111"

# Download k3s installer and install k3s agent
if curl -sfL https://get.k3s.io | sh -; then
    echo -e "${GREEN}K3s AGENT installation SUCCEEDED${RESET}"
else
    echo -e "${RED}K3s AGENT installation FAILED${RESET}"
fi