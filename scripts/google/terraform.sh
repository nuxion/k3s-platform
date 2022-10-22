#!/bin/bash

BIND_ROLES=("roles/compute.instanceAdmin.v1" "roles/iam.serviceAccountUser")

config_terraform(){

    local ACCOUNT="terraform"

    echo "==> Configuring ${ACCOUNT}"
    local IAM="${ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com"
    local SA_JSON=$(gcloud iam service-accounts list --filter="name:${IAM}" --format="json")
    if [ "[]" = "${SA_JSON}" ];
    then
        echo "==> Creating ${ACCOUNT} account as ${IAM}"
        gcloud iam service-accounts create $ACCOUNT \
        --project $PROJECT_ID \
        --description="${ACCOUNT} Service Account" \
        --display-name="${ACCOUNT}"
    else
        echo "(x) ${IAM} already exist"
    fi

    echo "==> Giving permissions to ${IAM}"
    for role in ${BIND_ROLES[@]}; do
        echo "... ${IAM}: ${role}"
        gcloud projects add-iam-policy-binding --quiet ${PROJECT_ID} \
               --member=serviceAccount:${IAM} \
               --role=${role}
    done

    local sa_file=${CREDENTIALS}/${PROJECT_ID}/${ACCOUNT}.json
    if [ ! -f "$sa_file" ]; then
        mkdir -p ${CREDENTIALS}/${PROJECT_ID}
        gcloud iam service-accounts keys create "${sa_file}" \
               --iam-account "${IAM}" --project "${PROJECT_ID}"
    fi
    echo "==> ${ACCOUNT} SA file in ${sa_file}"
}

