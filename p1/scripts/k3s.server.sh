#!/bin/bash

SERVER_IP="$1"
K3S_TOKEN="$2"
IFACE=$(ip -o -4 addr show | grep -F "$SERVER_IP/" | awk '{print $2}')

systemctl disable firewalld --now

curl -sfL https://get.k3s.io -o /tmp/install-k3s.sh

K3S_TOKEN="$K3S_TOKEN" sh /tmp/install-k3s.sh server \
  --node-ip="$SERVER_IP" \
  --flannel-iface="$IFACE" \
  --write-kubeconfig-mode=644