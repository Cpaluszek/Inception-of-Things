#!/bin/bash

kubectl delete pods,deployments,services,configmaps,secrets,namespaces --all --all-namespaces
k3d cluster delete ci-cluster
