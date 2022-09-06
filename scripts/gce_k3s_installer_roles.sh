#!/bin/bash
set -o nounset
set -o errexit

readonly BASE_PATH=`git rev-parse --show-toplevel`
source "${BASE_PATH}/scripts/common.sh"

ensure_var PROJECT
ensure_var GCE_PD_SA_NAME
ensure_var BUCKET_LOCATION
BUCKET_NAME="infra"

# Allow the user to pass CREATE_SA_KEY=false to skip the SA key creation
# Ensure the SA directory set, if we're creating the SA_KEY
CREATE_SA_KEY="${CREATE_SA_KEY:-true}"
if [ "${CREATE_SA_KEY}" = true ]; then
  ensure_var GCE_PD_SA_DIR
fi

# If the project id includes the org name in the format "org-name:project", the
# gCloud api will format the project part of the iam email domain as
# "project.org-name"
if [[ $PROJECT == *":"* ]]; then
  IFS=':' read -ra SPLIT <<< "$PROJECT"
  readonly IAM_PROJECT="${SPLIT[1]}.${SPLIT[0]}"
else
  readonly IAM_PROJECT="${PROJECT}"
fi

readonly K3S_OBJ_ROLES="gcp_k3s_object_access_role"
function get_k3s_roles()
{
	echo "roles/iam.serviceAccountUser projects/${PROJECT}/roles/${K3S_OBJ_ROLES}"
}

readonly K3S_BIND_ROLES=$(get_k3s_roles)
readonly IAM_NAME="${GCE_PD_SA_NAME}@${IAM_PROJECT}.iam.gserviceaccount.com"
readonly PROJECT_NUMBER=`gcloud projects describe ${PROJECT} --format="value(projectNumber)"`


# Check if SA exists
CREATE_SA=true
SA_JSON=$(gcloud iam service-accounts list --filter="name:${IAM_NAME}" --format="json")
if [ "[]" != "${SA_JSON}" ];
then
	CREATE_SA=false
	echo "Service account ${IAM_NAME} exists. Would you like to create a new one (y) or reuse the existing one (n)"
	read -p "(y/n)" -n 1 -r REPLY
	echo
    if [[ ${REPLY} =~ ^[Yy]$ ]];
	then
		CREATE_SA=true
    fi
fi

if [ "${CREATE_SA}" = true ];
then
	# Delete Service Account Key, if applicable
	if [ "${CREATE_SA_KEY}" = true ]; then
		if [ -f "${GCE_PD_SA_DIR}/k3s-cloud-sa.json" ];
		then
		  rm "${GCE_PD_SA_DIR}/k3s-cloud-sa.json"
		fi
	fi

	# Delete ALL EXISTING Bindings
	gcloud projects get-iam-policy "${PROJECT}" --format json > "${BASE_PATH}/scripts/iam.json"
	sed -i "/serviceAccount:${IAM_NAME}/d" "${BASE_PATH}/scripts/iam.json"
	gcloud projects set-iam-policy "${PROJECT}" "${BASE_PATH}/scripts/iam.json"
	rm -f "${BASE_PATH}/scripts/iam.json"
	# Delete Service Account
	gcloud iam service-accounts delete "${IAM_NAME}" --project "${PROJECT}" --quiet || true

	# Create new Service Account
	gcloud iam service-accounts create "${GCE_PD_SA_NAME}" --project "${PROJECT}"
fi

ensure_role ${K3S_OBJ_ROLES} ${PROJECT}

# Bind service account to roles
for role in ${K3S_BIND_ROLES}
do
  gcloud projects add-iam-policy-binding "${PROJECT}" --member serviceAccount:"${IAM_NAME}" --role "${role}"
done

# Export key if needed
if [ "${CREATE_SA}" = true ] && [ "${CREATE_SA_KEY}" = true ];
then
  gcloud iam service-accounts keys create "${GCE_PD_SA_DIR}/k3s-cloud-sa.json" --iam-account "${IAM_NAME}" --project "${PROJECT}"
fi


# gsutil mb -p ${PROJECT} -c STANDARD -l ${BUCKET_LOCATION} -b on gs://${BUCKET_NAME}
# gsutil cp "${GCE_PD_SA_DIR}/k3s-cloud-sa.json"
