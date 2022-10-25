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

Finally a cluster should be create. But first, you should review `config/registries.yaml` file:

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

```
export KUBECONFIG="$(k3d kubeconfig write k3s-default)"
```

# Google Cloud

based on the [flyte guide](https://docs.flyte.org/en/latest/deployment/gcp/manual.html#deployment-gcp-manual) between other scripts around kubernetes ecosystem.

First of all a few manual steps are required but some scripts are provided to help you. 

1. A GCE account with a `PROJECT_ID` created. 
2. A bucket with the following convention: <PROJECT_ID>-infra this bucket will be used for importation sharing beetween control plane and agents
3. A role and SA Account should be created for K3S installer `scripts/gce_k3s_installer_roles.sh`. This SA account called k3s-installer is used by k3s to put sensible information into the bucket created in the step 2. 
4. Another role and SA Account should be created for the csi-disk-driver, this will be used by kubernetes to request volumes dynamically to GCE check [storage](/storage/gce/README.md) for more information. 




Define the following env variables:

```
export BASE_PATH=${PWD}
export ANSIBLE_CONFIG=${BASE_PATH}/ansible.cfg
export ANSIBLE_LIBRARY=${ANSIBLE_LIBRARY}:${BASE_PATH}/ansible_modules
export DEFAULT_ROLES_PATH=${BASE_PATH}/roles
export INFRA_SECRETS=${BASE_PATH}/.secrets
export GOOGLE_APPLICATION_CREDENTIALS=${INFRA_SECRETS}/gce.json
export TF_VAR_credentials_file_path=${GOOGLE_APPLICATION_CREDENTIALS}
export TF_BUCKET="..."
export TF_PREFIX="terraform/state/platform"

export PROJECT_ID="<YOUR GCP PROJECT>"
```

To create a key for a service account check:
`scripts/gce_auth_key.sh`


## Development

Tools:
- Unix like SO
- https://direnv.net/
- Terraform
- Packer
- Ansible
- Poetry
- Python ~3.8
- Docker
