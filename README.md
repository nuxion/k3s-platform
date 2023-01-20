# K3s platform

Used for testing and prototyping

## Working locally (aka localhost)

This project uses [k3d](https://k3d.io/v5.4.4/)
For installation you can refer to k3d site or use some of the following:

Option 1: 
```
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

Option 2:
```
git clone https://github.com/nuxion/k3s-platform
cd k3s-platform
./scripts/k3d-install.sh
```
The use of a local registry is recommended in this kind of setup. So 
```
./scripts/registry.sh <your ip>
```

Finally a cluster should be created. But first, you should review `config/registries.yaml` file:

```
k3d cluster create --registry-config config/registries.yaml
```
As a shortcut you can use Makefile: 


```
make up NAME=<clustername> IPV4=<ip for the registry>
```

For GPU Support:
```
k3d cluster create gputest24 --image=nuxion/k3s:v1.24.4-k3s1-cuda --gpus=all
```


## Environment

```
export KUBECONFIG="$(k3d kubeconfig write k3s-default)"
export PROJECT_ID=<PROJECT ID>
```

## Services

Services are deployed in a seperated namespace called `services`. 

Specs are in [manifests/services/](manifests/services/)

### PostgreSQL & PGAdmin

There are two version of postgresql, both are standalone versions. But one allows to configurate an object storage as buckup option, and the other one uses the default postgresql image from docker. 

Variables needed:

- `PGADMIN_USER_PLAIN`: used for pgadmin service. 
- `PGADMIN_PASS_PLAIN`: the password to be used. 
- `PGPASS_PLAIN`: Password to be used for the default `postgres` user. 
- `PG_SA_KEYFILE`: A valid fullpath with a service account key to be used by pgbackrest. Check: [scripts/sa_postgres.sh](scripts/sa_postgres.sh)
- `PG_STANZA_NAME`: (example: main) an stanza name. 
- `PG_BUCKET`: Name of the bucket to be used, without the protocol. If the bucket is: `gs://my-bucket`, then you should use `my-bucket`. 


**Note**: all the variables that ends with `_PLAIN` are encoded as base64 strings when each secret is created. 


To create a key for a service account check:
`scripts/gce_auth_key.sh`
