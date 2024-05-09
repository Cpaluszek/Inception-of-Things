#!/bin/bash

set -e

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl

# install docker
install_docker() {
    if ! command -v docker > /dev/null; then
        echo -e "${GREEN}Installing docker...${RESET}"
        # Add Docker's official GPG key:
        sudo apt-get update
        sudo apt-get install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update

        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        echo -e "${GREEN}Docker is already installed${RESET}"
    fi

    if ! id -nG $USER | grep -qw docker; then
        echo -e "${GREEN}adding current user to docker group${RESET}"
        # sudo usermod -aG docker $USER
    fi
}

install_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo -e "${GREEN}Installing kubectl...${RESET}"
        sudo snap install kubectl --classic
    else
        echo -e "${GREEN}kubectl is already installed.${RESET}"
    fi
}

install_k3d() {
    if ! command -v k3d &> /dev/null; then
        echo -e "${GREEN}Installing k3d...${RESET}"
        curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    else
        echo -e "${GREEN}k3d is already installed.${RESET}"
    fi
}

install_docker
install_kubectl
install_k3d
