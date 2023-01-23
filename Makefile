
PROVIDER=gce
NAME=default
export IPV4=192.168.1.150

up:
	./scripts/k3dup.sh

apply:
	./scripts/control.sh apply local

delete:
	./scripts/control.sh delete local

destroy:
	k3d cluster delete ${NAME} 
	docker stop registry2

debug:
	# kubectl run -i --tty --rm debug --image=debian:11.5-slim --restart=Never -- bash
	kubectl run -i --tty --rm debug --image=nuxion/k8-client --restart=Never -- bash

run:
	kubectl exec --stdin --tty ${POD} -- /bin/sh

dask:
	kubectl run -i --tty --rm dask-client  --overrides='{ "spec": { "serviceAccount": "dask-sa" }  }' --restart=Never --image=ghcr.io/dask/dask:2022.10.2-py3.8 -- /bin/bash

events:
	kubectl get events --sort-by=.metadata.creationTimestamp

pods:
	kubectl get pods -A -o wide

postgres:
	kubectl port-forward service/postgres 5432:5432

redis:
	kubectl port-forward service/redis 6379:6379

grafana:
	kubectl port-forward svc/prometheus-grafana 8080:80 -n prom

pgadmin:
	kubectl port-forward svc/pgadmin 8080:80 -n services

build-client:
	docker build . -t nuxion/k8-client:latest -f dockerfiles/Dockerfile.k8-client

client:
	./scripts/k3dclient.sh ${NAME}

postgres-check:
	kubectl exec -n services --stdin --tty ${POD} --  su - postgres -c "pgbackrest --stanza=main --log-level-console=info check"
