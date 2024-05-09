#!/bin/bash

set -e

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

IP="192.168.56.110"

install_curl() {
    if ! command -v curl &> /dev/null; then
        echo "curl could not be found"
        echo "Installing curl..."
        sudo apt-get update && sudo apt-get install -y curl
    fi
}

install_k3s() {
    export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san cpaluszeS --bind-address=$IP --node-ip=$IP"

    if curl -sfL https://get.k3s.io | sh -; then
        echo -e "${GREEN}K3s MASTER installation SUCCEEDED${RESET}"
    else
        echo -e "${RED}K3s MASTER installation FAILED${RESET}"
        exit 1
    fi
}

check_k3s() {
    echo "Checking if K3s is running..."
    for i in {1..30}; do
        if [ -f /var/lib/rancher/k3s/server/node-token ]; then
            echo -e "${GREEN}K3s is running${RESET}"
            return
        fi
        sleep 2
    done
    echo -e "${RED}K3s did not start in time${RESET}"
    exit 1
}

update_hosts() {
    echo "Updating /etc/hosts file..."
    echo "192.168.56.110 app1.com" | sudo tee -a /etc/hosts
    echo "192.168.56.110 app2.com" | sudo tee -a /etc/hosts
    echo "192.168.56.110 app3.com" | sudo tee -a /etc/hosts
}

apply_manifests() {
    echo "Applying Kubernetes manifests..."
    kubectl apply -f /vagrant/manifests/service.yml
    kubectl apply -f /vagrant/manifests/apps.yml
    kubectl apply -f /vagrant/manifests/ingress.yml
}

install_curl
install_k3s
check_k3s
update_hosts
apply_manifests

echo -e "${GREEN}Setup completed successfully!${RESET}"