# Monitoring

## Installing stack

https://fabianlee.org/2022/07/02/prometheus-installing-kube-prometheus-stack-on-k3s-cluster/

Review how to configure volumes
https://github.com/fabianlee/k3s-cluster-kvm/blob/main/roles/kube-prometheus-stack/files/prom-sparse.expanded.yaml

Another guide which talsk how to expose service and other thing (out-dated):

https://github.com/cablespaghetti/k3s-monitoring



## Prometheus access

```
kubectl port-forward svc/prometheus-grafana 8080:80 -n prometheus
```

secrets:

```
kubectl get secret prometheus-grafana -n prometheus --template='{{index .data "admin-password" | base64decode }}'
```

```
kubectl get secret prometheus-grafana -n prometheus --template='{{index .data "admin-user" | base64decode }}'
```
