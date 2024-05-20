GREEN=\033[32m
RESET=\033[0m

.PHONY: install-dependencies setup-cluster setup_gitlab init_gitlab_repo

all: install-dependencies setup_gitlab setup-cluster

install-dependencies:
	@bash install_dependencies.sh
	@echo "$(GREEN)Dependencies installed successfully.$(RESET)"

setup-gitlab:
	@bash setup_gitlab.sh
	@echo "$(GREEN)Gitlab setup successfully.$(RESET)"
	@bash init_gitlab_repo.sh
	@echo "$(GREEN)Gitlab repo created successfully.$(RESET)"

setup-cluster:
	@bash setup_k3d_cluster.sh
	@echo "$(GREEN)k3d cluster setup successfully.$(RESET)"

infos:
	@echo "$(GREEN)Fetching Kubernetes information...$(RESET)"
	@echo "$(GREEN)Kubernetes namespaces:$(RESET)"
	@kubectl get namespaces
	@echo "$(GREEN)Kubernetes pods:$(RESET)"
	@kubectl get pods --all-namespaces
	@echo "$(GREEN)Kubernetes services:$(RESET)"
	@kubectl describe pod will -n dev
	@echo "$(GREEN)Argocd information:$(RESET)"
	@argocd app get will

curl:
	curl http://localhost:8888/

forward:
	@kubectl port-forward svc/will-app -n dev 8888:8888 &
	@echo "$(GREEN)Port forwarded successfully.$(RESET)"

clean:
	@echo "$(GREEN)Cleaning up...$(RESET)"
	@if kubectl get namespace argocd; then kubectl delete all --all -n argocd; fi
	@if kubectl get namespace dev; then kubectl delete all --all -n dev; fi
	@if kubectl get namespace gitlab; then kubectl delete all --all -n gitlab; fi
	@kubectl delete namespaces dev --ignore-not-found
	@kubectl delete namespaces argocd --ignore-not-found
	@kubectl delete namespaces gitlab --ignore-not-found
	@k3d cluster delete ci-cluster
	@echo "$(GREEN)Clean up completed successfully.$(RESET)"