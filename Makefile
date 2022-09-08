
PROVIDER=gce

init:
	terraform -chdir=infra/${PROVIDER} init --backend-config="bucket=${TF_BUCKET}" --backend-config="prefix=${TF_PREFIX}"
.PHONY: tf-plan
tf-plan:
	terraform -chdir=infra/${PROVIDER} plan -var-file="${BASE_PATH}/definitions.tfvars" -out=terraform.plan 2>&1 | tee /tmp/tf-$(PROJECTNAME)-plan.out

.PHONY: tf-apply
tf-apply:
	terraform -chdir=infra/${PROVIDER} apply terraform.plan

.PHONY: tf-refresh
tf-refresh:
	terraform -chdir=infra/${PROVIDER} apply -var-file="definitions.tfvars" -refresh-only

.PHONY: tf-destroy
tf-destroy:
	terraform -chdir=infra/${PROVIDER} destroy -var-file="definitions.tfvars"

.PHONY: tf-unlock
tf-unlock:
	#terraform force-unlock -var-file="definitions.tfvars" ${LOCK_ID}
	terraform -chdir=infra/${PROVIDER} force-unlock ${LOCK_ID}
