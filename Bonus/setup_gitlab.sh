#!/bin/bash
set -e
GREEN="\033[32m"
RESET="\033[0m"

CLUSTER_NAME="ci-cluster"

if ! kubectl get namespace gitlab > /dev/null 2>&1; then
    kubectl create namespace gitlab
fi
kubectl get namespaces

if ! command -v helm &> /dev/null; then
    echo -e "${GREEN}Installing Helm...${RESET}"
    sudo snap install helm --classic
fi

# Add host entry
HOST_ENTRY="127.0.0.1 gitlab.k3d.gitlab.com"
HOSTS_FILE="/etc/hosts"

if ! grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo -e "${GREEN}Adding host entry to $HOSTS_FILE${RESET}"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi

# Deploy GitLab using Helm
echo -e "${GREEN}Deploying GitLab using Helm...${RESET}"
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# [GitLab Helm Charts](https://charts.gitlab.io/)
# minikube runs a single-node Kubernetes cluster
# sudo kubectl config view --raw > ~/.kube/config

helm upgrade --install gitlab gitlab/gitlab \
    -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
    -n gitlab \
    --set global.hosts.domain=k3d.gitlab.com \
    --set global.hosts.externalIP=0.0.0.0 \
    --set global.hosts.https=false \
    --timeout 600s

# Wait for GitLab to be ready
echo -e "${GREEN}Waiting for GitLab to be ready...${RESET}"
kubectl wait --for=condition=ready --timeout=1500s pod -l app=webservice -n gitlab

# Retrieve GitLab initial root password
GITLAB_PSW=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d)
echo -e "${GREEN}GitLab root password: ${GITLAB_PSW}${RESET}"

# Set up port forwarding for GitLab
if [ -n "$(sudo lsof -i :80)" ]; then
    echo "Port forwarding already running, recreating..."
    sudo pkill -f "kubectl.*port-forward.*80:8181"
fi

echo -e "${GREEN}Setting up port forwarding for GitLab...${RESET}"
sudo kubectl port-forward svc/gitlab-webservice-default -n gitlab 80:8181 2>&1 >/dev/null &
#localhost:80 - login=root
