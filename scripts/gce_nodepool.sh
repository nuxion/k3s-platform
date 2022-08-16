#!/bin/bash
NAME=$1
TAGS="labfunctions,k3s,k3s-workers"
LABELS="ns=test"
MACHINE="e2-micro"
NET="default"
gcloud compute instance-templates create ${NAME} \
    --machine-type=${MACHINE} \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type="pd-standard" \
    --network=${NET} \
    --tags=${TAGS} \
    --labels=${LABELS}
