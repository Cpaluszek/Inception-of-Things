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

export K3s_INSTALLER="--bind-address=192.168.56.110 --https-listen-port 6443"

# Download k3s installer
if curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=$INSTALL_K3S_EXEC sh -; then
    echo -e "${GREEN}K3s MASTER installation SUCCEEDED${RESET}"
else
    echo -e "${RED}K3s MASTER installation FAILED${RESET}"
fi

# Copy the vagrant token to the shared folder
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/token
echo -e "${GREEN}Token copied to /vagrant/token${RESET}"