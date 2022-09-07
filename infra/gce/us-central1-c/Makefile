.EXPORT_ALL_VARIABLES:
# VERSION := $(shell git describe --tags)
# BUILD := $(shell git rev-parse --short HEAD)
# PROJECTNAME := $(shell basename "$(PWD)")
PROJECT := $(shell echo "${GCE_PROJECT}")
LOCATION := us-central1
ZONE := us-central1-c
BASE_PATH := $(shell git rev-parse --show-toplevel)

init:
	terraform init -backend-config "bucket=${PROJECT}-infra" -backend-config "prefix=terraform/state/${LOCATION}"

.PHONY: plan
plan:
	terraform plan -var 'zone=${ZONE}' -var 'location=${LOCATION}' -var 'project=${PROJECT}' -var 'base_path=${BASE_PATH}' -var-file="${LOCATION}.definitions.tfvars" -var 'credentials_file_path=~/.ssh/gce/${PROJECT}/infra.json' -out=terraform.plan 2>&1 | tee /tmp/tf-$(PROJECT)-${LOCATION}-plan.out

.PHONY: apply
apply:
	terraform apply terraform.plan

refresh:
	terraform apply -var-file="definitions.tfvars" -refresh-only

.PHONY: apply
destroy:
	terraform destroy -var 'zone=${ZONE}' -var 'location=${LOCATION}' -var 'project=${PROJECT}' -var 'base_path=${BASE_PATH}' -var 'credentials_file_path=~/.ssh/gce/${PROJECT}/infra.json' -var-file="${LOCATION}.definitions.tfvars"

.PHONY: force-unlock
force-unlock:
	#terraform force-unlock -var-file="definitions.tfvars" ${LOCK_ID}
	terraform force-unlock ${LOCK}
