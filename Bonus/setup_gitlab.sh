#!/bin/bash
set -e

GREEN="\033[32m"
RESET="\033[0m"

# Install Helm
echo -e "${GREEN}Installing Helm...${RESET}"
sudo snap install helm --classic

# Add host entry
HOST_ENTRY="127.0.0.1 k3d.gitlab.com"
HOSTS_FILE="/etc/hosts"

if ! grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo -e "${GREEN}Adding host entry to $HOSTS_FILE${RESET}"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi

# Create GitLab namespace
kubectl create namespace gitlab

# Deploy GitLab using Helm
echo -e "${GREEN}Deploying GitLab using Helm...${RESET}"
helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
    -n gitlab \
    --version 8.0.0 \
    --timeout 600s \
    --set global.hosts.domain=k3d.gitlab.com \
    --set global.hosts.externalIP=0.0.0.0 \
    --set global.hosts.https=false

# Wait for GitLab to be ready
echo -e "${GREEN}Waiting for GitLab to be ready...${RESET}"
kubectl wait --for=condition=ready --timeout=1200s pod -l app=webservice -n gitlab

# Retrieve GitLab initial root password
GITLAB_PSW=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d)
echo -e "${GREEN}GitLab root password: ${GITLAB_PSW}${RESET}"

# Set up port forwarding for GitLab
if sudo lsof -i :80 | grep -q 'kubectl'; then
    echo -e "${GREEN}Port 80 is already being used, killing the process...${RESET}"
    sudo pkill -f 'kubectl port-forward svc/gitlab-webservice-default'
fi

echo -e "${GREEN}Setting up port forwarding for GitLab...${RESET}"
sudo kubectl port-forward svc/gitlab-webservice-default -n gitlab 80:8181 2>&1 >/dev/null &
