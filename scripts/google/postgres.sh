#!/bin/bash

DBMANAGER_ROLE="dbmanager"
BIND_ROLES=("projects/$PROJECT_ID/roles/$DBMANAGER_ROLE")

config_postgres(){

    local ACCOUNT="dbmanager"
    echo "==> Configuring postgresql"
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

