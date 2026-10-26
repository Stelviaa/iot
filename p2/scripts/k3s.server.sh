#!/bin/bash
KUBECTL=/usr/local/bin/kubectl
SERVER_IP="$1"
K3S_TOKEN="$2"
IFACE=$(ip -o -4 addr show | awk -v ip="$SERVER_IP" '$4 ~ "^"ip"/" {print $2}')

systemctl disable firewalld --now

curl -sfL https://get.k3s.io -o /tmp/install-k3s.sh

K3S_TOKEN="$K3S_TOKEN" sh /tmp/install-k3s.sh server \
  --node-ip="$SERVER_IP" \
  --flannel-iface="$IFACE" \
  --write-kubeconfig-mode=644

$KUBECTL wait --for=condition=Ready node --all --timeout=120s
$KUBECTL apply -f /tmp/confs