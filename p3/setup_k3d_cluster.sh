#!/bin/bash
set -e
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

CLUSTER_NAME="ci-cluster"

if k3d cluster list | grep -q "${CLUSTER_NAME}" > /dev/null; then
    echo -e "${GREEN} k3d cluster ${CLUSTER_NAME} exists.${RESET}"
else
    echo -e "${GREEN} Creating k3d cluster ${CLUSTER_NAME}...${RESET}"
    k3d cluster create ${CLUSTER_NAME}
    echo -e "${GREEN} Creating k3d cluster ${CLUSTER_NAME}...${RESET}"
    kubectl get nodes
fi
