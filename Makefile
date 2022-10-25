
PROVIDER=gce
NAME=default
IPV4=192.168.1.150

up:
	scripts/registry.sh ${IPV4}
	k3d cluster create --config config/k3d.yaml --registry-config config/registries.yaml  -p "8089:80@loadbalancer"
	kubectl apply -f manifests/nginx-ingress/deploy.yaml
	kubectl apply -k manifests/postgresql/
	kubectl apply -k manifests/pgadmin4/

destroy:
	k3d cluster delete ${NAME} 
	docker stop registry2

debug:
	kubectl run -i --tty --rm debug --image=debian:11.5-slim --restart=Never -- bash

events:
	kubectl get events --sort-by=.metadata.creationTimestamp

pods:
	kubectl get pods -A -o wide

postgres:
	kubectl port-forward service/postgres 5432:5432

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
