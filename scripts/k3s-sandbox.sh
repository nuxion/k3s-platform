#!/bin/bash
NAME=${1:-k3s}
python3 scripts/gce_instance.py create --name ${NAME} --disk-size=10 --network default --project earthflow --tags k3s --image projects/debian-cloud/global/images/debian-11-bullseye-v20220719 --sa k3s-installer

gcloud compute instances add-metadata ${NAME} --metadata=project=earthflow,version=v1.24.4+k3s1,clustername=default,csidisk=stable-1-24,server=https://k3s.us-central1-c.cloud:6443,location=us-central1

