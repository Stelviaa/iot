#!/bin/bash

SERVER_IP="$1"
WORKER_IP="$2"
K3S_TOKEN="$3"
IFACE=$(ip -o -4 addr show | awk -v ip="$WORKER_IP" '$4 ~ "^"ip"/" {print $2}')

systemctl disable firewalld --now

curl -sfL https://get.k3s.io -o /tmp/install-k3s.sh

K3S_URL="https://$SERVER_IP:6443" K3S_TOKEN="$K3S_TOKEN" sh /tmp/install-k3s.sh agent \
  --node-ip="$WORKER_IP" \
  --flannel-iface="$IFACE"