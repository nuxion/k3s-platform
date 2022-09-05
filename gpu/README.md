# GPU Support

Giving GPU support to a kubernetes cluster is very complicated because it depends on different components which should match in versions: containerd, nvidia-driver, nvdia-container-runtime, and kubernetes itself. 

In the case of K3D an extra layer of compatibility is added. 
For this to work a custom image of k3d is required. 

Refer to https://github.com/k3d-io/k3d/issues/1108 and https://k3d.io/v5.4.6/usage/advanced/cuda/ for details. 

Also two image were already made and published to the official docker hub:
nuxion/k3s:v1.23.8-k3s1-cuda
nuxion/k3s:v1.24.4-k3s1-cuda

Some recommendations:

1. Use the official deployment file from [nvidia](https://github.com/NVIDIA/k8s-device-plugin#quick-start). 
2. It takes time to run, be patient, run `kubectl get events --sort-by=.metadata.creationTimestamp` and wait until the driver container is started. 
