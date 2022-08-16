#!/bin/bash
NAME=$1
TPL=${2:-test}
BASE_NAME=mig
SIZE=${3:-1}
MACHINE_TYPE=${3:-e2-small}
PROJECT=${4:-earthflow}
DISK=15
IMAGE=projects/debian-cloud/global/images/debian-11-bullseye-v20220719
ZONE=us-central1-a
NETWORK=default

gcloud compute instance-groups managed create ${NAME} \
    --size ${SIZE} \
    --template ${TPL} \
    --zone ${ZONE} \
    --base-instance-name mig
	
