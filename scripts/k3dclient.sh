#!/bin/bash
CLUSTER=$1
k3dfile=$(k3d kubeconfig write ${CLUSTER})
docker run --rm -it --network host \
       -v ${k3dfile}:/workspace/kubeconfig.yaml \
       -e KUBECONFIG=/workspace/kubeconfig.yaml nuxion/k8-client
