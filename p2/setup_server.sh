#!/bin/bash

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

IP="192.168.56.110"

# Check if curl is installed, if not, install it
if ! command -v curl &> /dev/null
then
    echo "curl could not be found"
    echo "Installing curl..."
    sudo apt-get update && sudo apt-get install -y curl
fi

export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san cpaluszeS --bind-address=$IP --node-ip=$IP --advertise-address=$IP"

if curl -sfL https://get.k3s.io | sh -; then
    echo -e "${GREEN}K3s MASTER installation SUCCEEDED${RESET}"
else
    echo -e "${RED}K3s MASTER installation FAILED${RESET}"
fi

# Check if k3s service is running
while [ ! -f /var/lib/rancher/k3s/server/node-token ]
do
    sleep 2
done
echo -e "${GREEN}K3s is running${RESET}"

# Add entries to /etc/hosts
echo "192.168.56.110 app1.com" | sudo tee -a /etc/hosts
echo "192.168.56.110 app2.com" | sudo tee -a /etc/hosts
echo "192.168.56.110 app3.com" | sudo tee -a /etc/hosts

# Apply the manifests
kubectl apply -f /vagrant/manifests/service.yml
kubectl apply -f /vagrant/manifests/apps.yml
kubectl apply -f /vagrant/manifests/ingress.yml
