#!/bin/bash

source ./scripts/common.sh
source ./scripts/registry.sh
CHECK_EVERY=5

wait_kube(){
    ns=$1
    lt=$2
    running=`kubectl get pods -n ${ns} | grep Running | wc -l`
    while [ $running -lt $lt ]
    do
        echo "Waiting for NS: ${ns} to be readdy in kubernetes..."
        running=`kubectl get pods -n ${ns} | grep Running | wc -l`
        sleep $CHECK_EVERY
    done
    
}

ensure_var IPV4

run_registry $IPV4

k3d cluster create --config config/k3d.yaml --registry-config config/registries.yaml  -p "8089:80@loadbalancer"

kubectl apply -f manifests/nginx-ingress/deploy.yaml
wait_kube ingress-nginx 1
kubectl apply -f manifests/pg-operator/cnpg-1.17.1.yaml
kubectl apply -f manifests/postgresql/pg-cluster.yaml

PG_ROOT_PASS=$(kubectl get secret pg-cluster-superuser --template={{.data.password}} | base64 --decode)
PG_ROOT=$(kubectl get secret pg-cluster-superuser --template={{.data.username}} | base64 --decode)

echo "Postgresql user/pass: ${PG_ROOT} / ${PG_ROOT_PASS}"
