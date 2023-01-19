# Storage

Storage implemmentation is based on the [gcp-compute-persistent-disk-csi-driver](https://github.com/kubernetes-sigs/gcp-compute-persistent-disk-csi-driver/blob/master/docs/kubernetes/user-guides/driver-install.md)

The installation requires several steps. The firts one is setting up IAM permissions for the CSI driver. A `setup-project.sh` script could be useful for the initial setup of roles and SA Accounts. If roles need to be created, the user who runs the script should have permissions to create roles. 

A fork is made because the original repository include windows drivers, and also it uses GOPATH as variable for unrelated executions of deployment scripts. 

Check: https://github.com/nuxion/gcp-compute-persistent-disk-csi-driver/tree/no-gopath

The deployment scripts is kustomize to build the final manifest depending on the version of Kubernetes, and create the secrets for the SAAccount.   



