#!/bin/bash
NS=$1
kubectl delete secret pg-secrets-files -n ${NS}

