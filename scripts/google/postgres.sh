#!/bin/bash

DBMANAGER_ROLE="dbmanager"
BIND_ROLES=("projects/{$PROJECT_ID}/roles/${DBMANAGER_ROLE}")

config_postgres(){

    echo "==> Configuring postgresql"
    readonly DB_IAM="dbmanager@${PROJECT_ID}.iam.gserviceaccount.com"
    SA_JSON=$(gcloud iam service-accounts list --filter="name:${DB_IAM}" --format="json")
    if [ "[]" = "${SA_JSON}" ];
    then
        echo "==> Creating db manager account as ${DB_IAM}"
        gcloud iam service-accounts create packer \
        --project $PROJECT_ID \
        --description="DB Manager Service Account" \
        --display-name="DBManager"
    else
        echo "(x) ${DB_IAM} already exist"
    fi

    echo "==> Giving permissions to ${DB_IAM}"
    for role in ${BIND_ROLES[@]}; do
        echo "... ${DB_IAM}: roles/iam.serviceAccountUser"
        gcloud projects add-iam-policy-binding --quiet ${PROJECT_ID} \
               --member=serviceAccount:${DB_IAM} \
               --role=${role}
    done

}

