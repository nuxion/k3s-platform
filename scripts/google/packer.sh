#!/bin/bash

config_packer(){

    echo "==> Configuring packer"
    readonly PACKER_IAM="packer@${PROJECT_ID}.iam.gserviceaccount.com"
    SA_JSON=$(gcloud iam service-accounts list --filter="name:${PACKER_IAM}" --format="json")
    if [ "[]" = "${SA_JSON}" ];
    then
        echo "==> Creating packer account as ${PACKER_IAM}"
        gcloud iam service-accounts create packer \
        --project $PROJECT_ID \
        --description="Packer Service Account" \
        --display-name="Packer Service Account"

        echo "==> Giving permissions to ${PACKER_IAM}"

        echo "... ${PACKER_IAM}: roles/iam.serviceAccountUser"
        gcloud projects add-iam-policy-binding --quiet ${PROJECT_ID} \
        --member=serviceAccount:${PACKER_IAM} \
        --role=roles/iam.serviceAccountUser

        echo "... ${PACKER_IAM}: roles/compute.instanceAdmin.v1"
        gcloud projects add-iam-policy-binding --quiet ${PROJECT_ID} \
        --member=serviceAccount:${PACKER_IAM} \
        --role=roles/compute.instanceAdmin.v1

        # echo "... ${PACKER_IAM}: roles/iap.tunnelResourceAccessor"
        # gcloud projects add-iam-policy-binding --quiet ${PROJECT_ID} \
        # --member=serviceAccount:${PACKER_IAM} \
        # --role=roles/iap.tunnelResourceAccessor

        packer_sa=${CREDENTIALS}/${PROJECT_ID}/packer.json
        if [ ! -f "$packer_sa" ]; then
            mkdir -p ${CREDENTIALS}/${PROJECT_ID}
            gcloud iam service-accounts keys create "${packer_sa}" --iam-account "${PACKER_IAM}" --project "${PROJECT_ID}"
        fi
        echo "==> packer sa file in ${packer_sa}"
    else
        packer_sa=${CREDENTIALS}/${PROJECT_ID}/packer.json
        if [ ! -f "$packer_sa" ]; then
            mkdir -p ${CREDENTIALS}/${PROJECT_ID}
            gcloud iam service-accounts keys create "${packer_sa}" --iam-account "${PACKER_IAM}" --project "${PROJECT_ID}"
        fi

        echo "(x) ${PACKER_IAM} already exist"
        echo "==> packer sa file in ${packer_sa}"
    fi

}

