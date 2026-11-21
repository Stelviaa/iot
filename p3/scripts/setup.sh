#!/bin/bash
CLUSTER=iot

REGISTRY_ARGS=()
if [ -n "$DOCKERHUB_USER" ] && [ -n "$DOCKERHUB_TOKEN" ]; then
  echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USER" --password-stdin || exit 1
  cat > /tmp/iot-registries.yaml <<EOF
mirrors:
  docker.io:
    endpoint:
      - "https://index.docker.io/v2"
configs:
  "https://index.docker.io/v2":
    auth:
      username: "$DOCKERHUB_USER"
      password: "$DOCKERHUB_TOKEN"
EOF
  chmod 600 /tmp/iot-registries.yaml
  REGISTRY_ARGS=(--registry-config /tmp/iot-registries.yaml)
fi

k3d cluster list | grep -q "^$CLUSTER " || \
  k3d cluster create "$CLUSTER" -p "8888:8888@loadbalancer" "${REGISTRY_ARGS[@]}"

kubectl apply -f confs/namespaces.yaml

kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait -n argocd --for=condition=Available deployment --all --timeout=300s

kubectl apply -f confs/application.yaml