#!/bin/bash
set -e
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

CLUSTER_NAME="ci-cluster"

create_cluster() {
    if k3d cluster list | grep -q "${CLUSTER_NAME}" > /dev/null; then
        echo -e "${GREEN} k3d cluster ${CLUSTER_NAME} exists.${RESET}"
    else
        echo -e "${GREEN} Creating k3d cluster ${CLUSTER_NAME}...${RESET}"
        k3d cluster create ${CLUSTER_NAME}
        echo -e "${GREEN} Creating k3d namespaces...${RESET}"
        kubectl create namespace dev
        kubectl create namespace argocd
        kubectl get namespaces
    fi
}

setup_argo() {
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
}

create_cluster
setup_argo
