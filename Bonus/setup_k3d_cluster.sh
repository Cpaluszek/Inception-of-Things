#!/bin/bash
set -e
GREEN="\033[32m"
RESET="\033[0m"

CLUSTER_NAME="ci-cluster"

create_cluster() {
    if ! k3d cluster list | grep -q "${CLUSTER_NAME}"; then
        echo -e "${GREEN} Creating k3d cluster ${CLUSTER_NAME}...${RESET}"
        k3d cluster create ${CLUSTER_NAME}
        echo -e "${GREEN} Creating k3d namespaces...${RESET}"
        kubectl create namespace dev
        kubectl create namespace argocd
        kubectl get namespaces
    fi
}

wait_for_argocd_pods() {
    desired_ready_count=$(kubectl get pods -n argocd --no-headers=true | awk '/Running/ && /1\/1/ {++count} END {print count}')
    total_pods=$(kubectl get pods -n argocd --no-headers=true | wc -l)

    while [[ "$desired_ready_count" -ne "$total_pods" ]]; do
        echo "Waiting for all pods to be ready..."
        desired_ready_count=$(kubectl get pods -n argocd --no-headers=true | awk '/Running/ && /1\/1/ {++count} END {print count}')
        total_pods=$(kubectl get pods -n argocd --no-headers=true | wc -l)
        sleep 5
    done
}

setup_argo() {
    echo -e "${GREEN} Installing argocd pod...${RESET}"
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    if ! command -v argocd &> /dev/null; then
        echo -e "${GREEN} Downloading argocd cli...${RESET}"
        curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
        sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
        rm argocd-linux-amd64
    else
        sleep 5
    fi

    wait_for_argocd_pods

    if sudo netstat -tulpn | grep -q :8080; then
        echo "Port 8080 is already in use. Trying to kill the process..."
        sudo pkill -f 'kubectl port-forward svc/argocd-server'
    fi

    echo -e "${GREEN} Exposing argocd API Server...${RESET}"
    kubectl port-forward svc/argocd-server -n argocd 8080:443 &>/dev/null &

    while ! curl -s http://localhost:8080 > /dev/null; do
        echo "Waiting for port-forwarding for argocd-server to be ready..."
        sleep 2
    done

    ARGO_PSW=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo -e "${GREEN} argocd admin password: ${ARGO_PSW}${RESET}"

    argocd login localhost:8080 --insecure --username admin --password "$ARGO_PSW"
}

create_argocd_app() {
    echo -e "${GREEN} Creating argocd application...${RESET}"
    # [`argocd app create` Command Reference - Argo CD - Declarative GitOps CD for Kubernetes](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_app_create/)
    argocd app create will --repo http://localhost/root/gitlab_cpalusze.git --path app --dest-server https://kubernetes.default.svc --dest-namespace dev --upsert

    argocd app get will --grpc-web
    argocd app set will --sync-policy automated
    argocd app set will --auto-prune --allow-empty --grpc-web

    while ! (argocd app get will --grpc-web | grep -q "Service.*Healthy" && argocd app get will --grpc-web | grep -q "Deployment.*Healthy"); do
        echo "Waiting for the app to become healthy..."
        sleep 2
    done
    echo "Both service and deployment are healthy"

    if sudo lsof -i :8888 -sTCP:LISTEN -t | grep -q 'kubectl'; then
        sudo pkill -f 'kubectl.*port-forward.*8888'
        sleep 5
    fi

    echo "Starting port forwarding for will-app..."
    kubectl port-forward svc/will-app -n dev 8888:8888 &

    while ! curl -s http://localhost:8888 > /dev/null; do
        echo "Waiting for port-forwarding for will-app to be ready..."
        sleep 2
    done

    echo -e "${GREEN} will-app is online ${RESET}"
}

print_infos() {
    argocd app get will
    kubectl get pods -n dev
    kubectl describe pod will -n dev
}

create_cluster
setup_argo
create_argocd_app
print_infos

