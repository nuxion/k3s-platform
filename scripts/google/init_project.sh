#!/bin/bash
set -o nounset
set -o errexit

source "${BASE_PATH}/scripts/common.sh"
ensure_var PROJECT_ID

readonly PROJECT_NUMBER=`gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)"`

google_apis(){
    apiurl="googleapis.com"
    # gcloud services list --available
    echo "==> Enabling google apis"
    APIS=(
        "compute"
        "servicemanagement"
        "storage-api"
        "dns"
        "storage"
        "artifactregistry"
    )
    for api in ${APIS[@]}; do
        echo "... enabling ${api}.${apiurl}"
        gcloud services enable ${api}.${apiurl}
    done
}

google_apis

source "${BASE_PATH}/scripts/google/packer.sh"
config_packer

source "${BASE_PATH}/scripts/google/postgres.sh"
config_postgres

source "${BASE_PATH}/scripts/google/terraform.sh"
config_terraform

source "${BASE_PATH}/scripts/google/k3s-installer.sh"
config_k3s_installer

