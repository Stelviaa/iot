#!/bin/bash
command -v docker > /dev/null || {
  sudo apt-get update
  sudo apt-get install -y docker.io curl
  sudo usermod -aG docker "$USER"
}

command -v kubectl > /dev/null || {
  curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
}

command -v k3d > /dev/null || curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash