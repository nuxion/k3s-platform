#!/bin/bash

# https://cloud.google.com/iam/docs/understanding-roles#cloud-storage-roles
BIND_ROLES=("roles/storage.objectAdmin")

config_k3s_installer(){

    local ACCOUNT="k3s-installer"
    echo "==> Configuring k3s installer"
    local IAM="${ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com"
    local SA_JSON=$(gcloud iam service-accounts list --filter="name:${IAM}" --format="json")
    if [ "[]" = "${SA_JSON}" ];
    then
        echo "==> Creating ${ACCOUNT} account as ${IAM}"
        gcloud iam service-accounts create ${ACCOUNT} \
        --project $PROJECT_ID \
        --description="${ACCOUNT} Service Account" \
        --display-name="${ACCOUNT}"
    else
        echo "(x) ${IAM} already exist"
    fi

    echo "==> Giving permissions to ${IAM}"
    for role in ${BIND_ROLES[@]}; do
        echo "... $IAM}: ${role}"
        gcloud projects add-iam-policy-binding --quiet ${PROJECT_ID} \
               --member=serviceAccount:${IAM} \
               --role=${role}
    done

}

