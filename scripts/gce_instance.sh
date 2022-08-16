#!/bin/bash
NAME=$1
TAGS=$2
MACHINE_TYPE=${3:-e2-small}
PROJECT=${4:-algorinfo99}
NETWORK=default
DISK=15
IMAGE=projects/debian-cloud/global/images/debian-11-bullseye-v20220719
ZONE=us-central1-a

gcloud compute instances create ${NAME} --project=${PROJECT} --zone=${ZONE} \
	--machine-type=${MACHINE_TYPE} --network-interface=network-tier=PREMIUM,subnet=${NETWORK} \
	--maintenance-policy=MIGRATE --provisioning-model=STANDARD \
	--create-disk=auto-delete=yes,boot=yes,device-name=${NAME},image=${IMAGE},mode=rw,size=${DISK},type=projects/${PROJECT}/zones/${ZONE}/diskTypes/pd-balanced \
	--no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any \
	--tags ${TAGS}


--service-account=425822237207-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=core,prod
