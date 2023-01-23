#!/bin/bash
NS=$1
SECRET=$(kubectl get secret pg-secrets-files --ignore-not-found -n ${NS})
echo $SECRET
if [ -z "${SECRET}" ]; then
    kubectl create secret generic pg-secrets-files -n ${NS} \
            --from-file=sakey=${PG_SA_KEYFILE}
else
    echo "Secret already exist"
fi

