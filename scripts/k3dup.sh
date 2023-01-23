#!/bin/bash

CLUSTER_NAME="${1:-default}"
source ./scripts/common.sh
source ./scripts/registry.sh
CHECK_EVERY=5

ensure_var IPV4

run_registry $IPV4

k3d cluster create --config config/k3d.${CLUSTER_NAME}.yaml  --registry-create registry.local  --registry-config config/registries.yaml  -p "8089:80@loadbalancer"

kubectl apply -f manifests/nginx-ingress/deploy.yaml
wait_kube ingress-nginx 1

# kubectl wait --for condition=established crd clusters.postgresql.cnpg.io
# kubectl wait --for condition=established crd poolers.postgresql.cnpg.io
# kubectl wait --for condition=established crd backups.postgresql.cnpg.io

# kubectl create namespace prom
# helm install prometheus prometheus-community/kube-prometheus-stack --namespace prom

./scripts/apply.sh apply local
