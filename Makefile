
PROVIDER=gce
NAME=default
export IPV4=192.168.1.150

up:
	./scripts/k3dup.sh


destroy:
	k3d cluster delete ${NAME} 
	docker stop registry2

debug:
	kubectl run -i --tty --rm debug --image=debian:11.5-slim --restart=Never -- bash

run:
	kubectl exec --stdin --tty ${POD} -- /bin/sh

events:
	kubectl get events --sort-by=.metadata.creationTimestamp

pods:
	kubectl get pods -A -o wide

postgres:
	kubectl port-forward service/postgres 5432:5432

build-client:
	docker build . -t nuxion/k8-client:latest -f dockerfiles/Dockerfile.k8-client

client:
	./scripts/k3dclient.sh ${NAME}
