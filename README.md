# K3s platform

Used for testing and prototyping

## How to start?

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

