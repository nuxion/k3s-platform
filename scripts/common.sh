#!/bin/bash

CREDENTIALS="${HOME}/.ssh"

ensure_var()
{
    if [[ -z "${!1:-}" ]];
    then
        echo "${1} is unset"
        exit 1
    else
        echo "${1} is ${!1}"
    fi
}

apply(){
    SERVICE=$1
    PLATFORM="${2:-gcp}"
    NS="${3:-services}"

    echo "==> applying ${SERVICE}"

    if [ -f "manifests/${NS}/${SERVICE}.apply.sh" ];
    then
        ./manifests/${NS}/${SERVICE}.apply.sh $NS

    fi

    if [ -f "manifests/${NS}/${SERVICE}.config.yaml" ];
    then
        envsubst < manifests/${NS}/${SERVICE}.config.yaml | kubectl apply -n ${NS} -f - 
    fi


    if [ -f "manifests/${NS}/${SERVICE}.pvc.${PLATFORM}.yaml" ];
    then
        kubectl apply -n ${NS} -f manifests/${NS}/${SERVICE}.pvc.${PLATFORM}.yaml
    fi

    if [ -f "manifests/${NS}/${SERVICE}.secrets.yaml" ];
    then
        envsubst < manifests/${NS}/${SERVICE}.secrets.yaml | kubectl apply -n ${NS} -f -
    fi
    kubectl apply -n ${NS} -f manifests/${NS}/${SERVICE}.yaml
}

delete(){
    SERVICE=$1
    PLATFORM="${2:-gcp}"
    NS="${3:-services}"

    echo "==> deleting ${SERVICE}"
    kubectl delete -n ${NS} -f manifests/${NS}/${SERVICE}.yaml

    if [ -f "manifests/${NS}/${SERVICE}.secrets.yaml" ];
    then
        kubectl delete -n ${NS} -f manifests/${NS}/${SERVICE}.secrets.yaml
    fi
    if [ -f "manifests/${NS}/${SERVICE}.config.yaml" ];
    then
        kubectl delete -n ${NS} -f manifests/${NS}/${SERVICE}.config.yaml  
    fi

    if [ -f "manifests/${NS}/${SERVICE}.delete.sh" ];
    then
        ./manifests/${NS}/${SERVICE}.delete.sh $NS

    fi

    # pvc volumes aren't destroyed
    if [ -f "manifests/${NS}/${SERVICE}.pvc.${PLATFORM}.yaml" ];
    then
        echo " [W] There are volumes. These will not be deleted."
    fi
}

wait_kube(){
    ns=$1
    lt=$2
    running=`kubectl get pods -n ${ns} | grep Running | wc -l`
    while [ $running -lt $lt ]
    do
        echo "Waiting for NS: ${ns} to be readdy in kubernetes..."
        running=`kubectl get pods -n ${ns} | grep Running | wc -l`
        sleep $CHECK_EVERY
    done
    
}

sa_account_creator(){

    local ACCOUNT=$1
    local BIND_ROLES=$2
    echo "==> Configuring ${ACCOUNT}"
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
        echo "[i] ${IAM} already exist"
    fi

    echo "==> Giving permissions to ${IAM}"
    for role in ${BIND_ROLES[@]}; do
        echo "... $IAM}: ${role}"
        gcloud projects add-iam-policy-binding --quiet ${PROJECT_ID} \
               --member=serviceAccount:${IAM} \
               --role=${role}
    done

}

create_sa_account_key(){
    local ACCOUNT=$1
    local IAM="${ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com"

    sa_file=${CREDENTIALS}/${PROJECT_ID}/${ACCOUNT}.json
    if [ ! -f "${sa_file}" ]; then
        mkdir -p ${CREDENTIALS}/${PROJECT_ID}
        gcloud iam service-accounts keys create "${sa_file}" --iam-account "${IAM}" --project "${PROJECT_ID}"
    fi
    echo "==> ${ACCOUNT} sa file in ${sa_file}"

}
