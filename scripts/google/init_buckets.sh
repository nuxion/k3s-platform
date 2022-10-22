#!/bin/bash
set -o nounset
set -o errexit

source "${BASE_PATH}/scripts/common.sh"
ensure_var PROJECT_ID
# see: https://cloud.google.com/storage/docs/locations
ensure_var PLATFORM_BUCKET_LOC

readonly PLATFORM_BUCKET="${PROJECT_ID}-platform"

BUCKETS=($PLATFORM_BUCKET)

bucket_exist(){
    gsutil ls | grep $1
}   

for bucket in ${BUCKETS[@]};
do
    if ! bucket_exist $bucket &> /dev/null
    then
        echo "=> Creating bucket ${bucket}"
        # see:
        # https://cloud.google.com/storage/docs/creating-buckets#storage-create-bucket-gcloud
        gcloud alpha storage buckets create gs://${bucket} --location us
    fi
done
