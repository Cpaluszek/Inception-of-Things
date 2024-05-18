GREEN=\033[32m
RESET=\033[0m

.PHONY: install-dependencies setup-cluster

all: install-dependencies setup-cluster

install-dependencies:
	@echo "$(GREEN)Installing dependencies...$(RESET)"
	@bash install_dependencies.sh
	@echo "$(GREEN)Dependencies installed successfully.$(RESET)"

setup-cluster:
	@echo "$(GREEN)Setting up k3d cluster...$(RESET)"
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
	@echo "$(GREEN)Making a curl request to http://localhost:8888/...$(RESET)"
	@curl http://localhost:8888/

forward:
	@echo "$(GREEN)Forwarding port...$(RESET)"
	@kubectl port-forward svc/will-app -n dev 8888:8888 &
	@sudo netstat -tulpn | grep :8888
	@echo "$(GREEN)Port forwarded successfully.$(RESET)"

clean:
	@echo "$(GREEN)Cleaning up...$(RESET)"
	@if kubectl get namespace argocd; then kubectl delete --all -n argocd; fi
	@if kubectl get namespace dev; then kubectl delete --all -n dev; fi
	@kubectl delete namespaces dev --ignore-not-found
	@kubectl delete namespaces argocd --ignore-not-found
	@echo "$(GREEN)Clean up completed successfully.$(RESET)"