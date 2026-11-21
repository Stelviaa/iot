#!/bin/bash
# if docker limit reached:
# export DOCKERHUB_USER=olmayt DOCKERHUB_TOKEN=<token> before up
if [ -z "$DOCKERHUB_USER" ] || [ -z "$DOCKERHUB_TOKEN" ]; then
  echo "[dockerhub] no credentials: anonymous pulls"
  exit 0
fi

CODE=$(curl -s -o /dev/null -w '%{http_code}' -u "$DOCKERHUB_USER:$DOCKERHUB_TOKEN" \
  "https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/alpine:pull")
if [ "$CODE" != "200" ]; then
  echo "[dockerhub] ERROR: login failed for $DOCKERHUB_USER (HTTP $CODE)" >&2
  exit 1
fi

mkdir -p /etc/rancher/k3s
cat > /etc/rancher/k3s/registries.yaml <<EOF
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
chmod 600 /etc/rancher/k3s/registries.yaml
echo "[dockerhub] pulls authenticated as $DOCKERHUB_USER"
