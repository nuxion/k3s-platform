#!/bin/bash

CREDENTIALS="~/.ssh"

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

ensure_role()
{
    ROLE=$1
    PRJ=$2
    # Create or Update Custom Role
    if gcloud iam roles describe ${ROLE} --project "${PRJ}";
    then
    gcloud iam roles update ${ROLE} --quiet \
            --project "${PRJ}"                                                     \
            --file "${BASE_PATH}/scripts/${ROLE}.yaml"
    else
    gcloud iam roles create ${ROLE} --quiet \
        --project "${PRJ}"                                                           \
        --file "${BASE_PATH}/scripts/${ROLE}.yaml"
    fi
   
}

