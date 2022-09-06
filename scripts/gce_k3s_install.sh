#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
# https://bugs.launchpad.net/ubuntu/+source/man-db/+bug/1858777
touch /var/lib/man-db/auto-update
apt-get update -y

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

if ! command_exists "cscli" &> /dev/null
then
    curl -Ls https://raw.githubusercontent.com/nuxion/cloudscripts/main/install.sh | sh
fi

if ! command_exists "jq" &> /dev/null
then
    apt-get install -y jq
fi

if ! command_exists "git" &> /dev/null
then
    apt-get install -y git
fi

PROJECT=`curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=true" -H "Metadata-Flavor: Google" | jq .project | tr -d '"'`

K3S_VERSION=`curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=true" -H "Metadata-Flavor: Google" | jq .version | tr -d '"'`
K3S_NAME=`curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=true" -H "Metadata-Flavor: Google" | jq .clustername | tr -d '"'`
# Ex: stable-1-24
CSI_DISK=`curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=true" -H "Metadata-Flavor: Google" | jq .csidisk | tr -d '"'`

# gsutil cp gs://infra/${K3S_NAME}/config.yaml /etc/rancher/
if ! command_exists "kubectl" &> /dev/null
then
    
    mkdir -p /root/.gce
    gsutil cp gs://${PROJECT}-infra/${K3S_NAME}/cloud-sa.json /root/.gce/cloud-sa.json
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} sh -
    gsutil cp /var/lib/rancher/k3s/server/node-token gs://${PROJECT}-infra/${K3S_NAME}/node-token

    git clone --branch no-gopath --depth 1 https://github.com/nuxion/gcp-compute-persistent-disk-csi-driver /root/gcp-compute-persistent-disk-csi-driver
    cd /root/gcp-compute-persistent-disk-csi-driver
    DEPLOY_VERSION=$CSI_DISK GCE_PD_SA_DIR=/root/.gce ./deploy/kubernetes/deploy-driver.sh --skip-sa-check
fi
kubectl get pods -A -o wide
