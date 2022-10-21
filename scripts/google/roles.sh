#!/bin/bash
# docs: https://cloud.google.com/iam/docs/creating-custom-roles#editing_an_existing_custom_role

source "${BASE_PATH}/scripts/common.sh"
ROLES=("dbmanager")
ensure_var PROJECT_ID
ensure_role()
{
    ROLE=$1
    PRJ=$2
    # Create or Update Custom Role
    if gcloud iam roles describe ${ROLE} --project "${PRJ}";
    then
        gcloud iam roles update ${ROLE} --quiet \
                --project "${PRJ}" \
                --file "${BASE_PATH}/scripts/google/roles/${ROLE}.yaml"
    else
        gcloud iam roles create ${ROLE} --quiet \
               --project "${PRJ}" \
               --file "${BASE_PATH}/scripts/google/roles/${ROLE}.yaml"
    fi
   
}

for role in ${ROLES[@]}; do
    echo "=> Crating/Updating ${role}"
    ensure_role $role $PROJECT_ID
done

