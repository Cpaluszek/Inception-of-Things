# Inception-of-Things
K3d and K3s with Vagrant.

## Part 1: K3s and Vagrant
Setup 2 machines:
- Server
- ServerWorker

Debian 12 Bookworm box: [Vagrant box debian/bookworm64 - Vagrant Cloud](https://app.vagrantup.com/debian/boxes/bookworm64)

## Part 2: K3s and 3 simple applications
- One server node running the kubernetes cluster.
- 3 pods, one for each app using the `paulbouwer/hello-kubernetes:1.10` image

### Manifests overview:
- Ingress - manage HTTP routing to the appropriate services based on the incoming request's host.
- Deployment - Defines the desired state for ou application pods, including the container image, replicas, and necessary configurations.
- Service - Exposes our application pods to other services withing the Kubernetes cluset.

When applying multiple Kubernetes manifests, it's generally best to follow this order:
- Namespace: apply the namespace manifest first to ensure that subsequent resources are created within the correct namespace.
- Service: ensure that the services are available for use by other resources.
- Deployment/StatefulSet/DaemonSet: these resources manage the creation and scaling of pods.
- Ingress: manage external access to your services.

### Check the state of the k3s cluster
```
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get ingress

kubectl lgos <pod-name>

kubectl describe deployment/pod/service/ingress <name>
```

## Part 3: k3d and ArgoCD
- [k3d](https://k3d.io/v5.6.3/)
- [Argo CD - Declarative GitOps CD for Kubernetes](https://argo-cd.readthedocs.io/en/stable/)


## References
- [Quick Start | Vagrant | HashiCorp Developer](https://developer.hashicorp.com/vagrant/tutorials/getting-started)
- [Quick-Start Guide | K3s](https://docs.k3s.io/quick-start)
