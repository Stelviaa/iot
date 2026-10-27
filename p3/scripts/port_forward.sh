#!/bin/bash
USER=admin

echo "User : $USER"
echo -n "password : "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
echo "Interface : https://localhost:8080"

kubectl port-forward svc/argocd-server -n argocd 8080:443