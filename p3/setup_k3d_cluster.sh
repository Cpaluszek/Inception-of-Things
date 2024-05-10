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
    echo -e "${GREEN} Installing argocd...${RESET}"
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    echo -e "${GREEN} Downloading argocd cli...${RESET}"
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64

    echo -e "${GREEN} Exposing argocd API Server...${RESET}"
    kubectl port-forward svc/argocd-server -n argocd 8080:443 &>/dev/null &
    sudo netstat -tulpn | grep :8080

    ARGO_PSW=$(argocd admin initial-password -n argocd)
    echo -e "${GREEN} argocd admin password: ${ARGO_PSW}${RESET}"

    echo -e "${GREEN} Login to argocd server...${RESET}"
    argocd login localhost:8080 --insecure --username admin --password SHaFgJ1ltuYLv6GJ
}

create_argocd_app() {
    echo -e "${GREEN} Creating argocd application...${RESET}"

}

create_cluster
setup_argo
create_argocd_app

