#!/bin/bash
set -euo pipefail

SERVER_IP="$1"
K3S_TOKEN="$2"
KUBECTL=/usr/local/bin/kubectl

IFACE=$(ip -o -4 addr show | awk -v ip="$SERVER_IP" '$4 ~ "^"ip"/" {print $2}')

systemctl disable firewalld --now 2>/dev/null || true

curl -sfL https://get.k3s.io -o /tmp/install-k3s.sh

K3S_TOKEN="$K3S_TOKEN" sh /tmp/install-k3s.sh server \
  --node-ip="$SERVER_IP" \
  --flannel-iface="$IFACE" \
  --write-kubeconfig-mode=644

until $KUBECTL get nodes 2>/dev/null | grep -q " Ready"; do
  echo "[server] Waiting for nodes"
  sleep 3
done

$KUBECTL apply -f /tmp/confs

$KUBECTL wait --for=condition=Available deployment --all --timeout=300s

DEADLINE=$((SECONDS + 300))
for HOST in app1.com app2.com app3.com; do
  until curl -sf -H "Host: $HOST" "http://$SERVER_IP" > /dev/null; do
    if [ "$SECONDS" -ge "$DEADLINE" ]; then
      echo "[server] ERROR : $HOST" >&2
      exit 1
    fi
    echo "[server] Waiting for $HOST..."
    sleep 5
  done
  echo "[server] $HOST working"
done