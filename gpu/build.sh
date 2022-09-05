#!/bin/bash

set -euxo pipefail

K3S_TAG=${K3S_TAG:="v1.24.4-k3s1"} # replace + with -, if needed
# K3S_TAG=${K3S_TAG:="v1.23.8-k3s1"} # replace + with -, if needed
UBUNTU=${UBUNTU:="ubuntu18.04"} 
CUDA_TAG=${CUDA_TAG:="11.7.0-base-ubuntu18.04"} 
IMAGE_REGISTRY=${IMAGE_REGISTRY:="docker.io"}
IMAGE_REPOSITORY=${IMAGE_REPOSITORY:="nuxion/k3s"}
IMAGE_TAG="$K3S_TAG-cuda"
IMAGE=${IMAGE:="$IMAGE_REGISTRY/$IMAGE_REPOSITORY:$IMAGE_TAG"}
# check with: apt-cache madison nvidia-container-runtime
NVIDIA_CONTAINER_RUNTIME_VERSION=${NVIDIA_CONTAINER_RUNTIME_VERSION:="3.10.0-1"}

echo "IMAGE=$IMAGE"

# due to some unknown reason, copying symlinks fails with buildkit enabled
DOCKER_BUILDKIT=0 docker build \
  --build-arg K3S_TAG=$K3S_TAG \
  --build-arg NVIDIA_CONTAINER_RUNTIME_VERSION=$NVIDIA_CONTAINER_RUNTIME_VERSION \
  --build-arg UBUNTU=$UBUNTU \
  -t $IMAGE .
docker push $IMAGE
echo "Done!"
