#!/bin/bash
NS=$1
SECRET=$(kubectl get secret sa-postgres-backup --ignore-not-found -n ${NS})
echo $SECRET
if [ -z "${SECRET}" ]; then
    kubectl create secret generic sa-postgres-backup -n ${NS} \
            --from-file=sakey=${PG_SA_KEYFILE}
else
    echo "Secret already exist"
fi

