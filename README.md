# K3s platform

Used for testing and prototyping

## How to start a local env?

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


# Cloud env

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
