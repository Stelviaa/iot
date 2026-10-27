#!/bin/bash
CLUSTER=iot

k3d cluster list | grep -q "^$CLUSTER " || \
  k3d cluster create "$CLUSTER" -p "8888:8888@loadbalancer"

kubectl apply -f confs/namespaces.yaml

kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait -n argocd --for=condition=Available deployment --all --timeout=300s

kubectl apply -f confs/application.yaml