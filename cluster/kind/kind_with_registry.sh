#!/usr/bin/bash
echo "Running $0"

set -o errexit
[ -z "${REMOTE_DOCKER_HOST}" ] || . ./cluster/kind/setup_remote_docker_kind.sh

go install sigs.k8s.io/kind@v0.15.0

# add go bin to path
echo "export PATH=$HOME/go/bin:$PATH" >> ~/.bashrc 
source ~/.bashrc 

[ "$(type -P kind)" ] || ( echo "kind is not in PATH" ;  exit 2 )


mkdir -p /var/tmp/kind_storage
chmod 777 /var/tmp/kind_storage

# test for container command
CONTAINER_CMD=docker
if [ -x "$(type -P podman)" ]; then
  CONTAINER_CMD=podman
fi
[ "$(type -P ${CONTAINER_CMD})" ] || ( echo "${CONTAINER_CMD} is not in PATH" ;  exit 2 )

# create registry container unless it already exists
reg_name='kind-registry'
reg_port='5001'
if [ "$(${CONTAINER_CMD} inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
  ${CONTAINER_CMD} run \
    -d --restart=always -p "127.0.0.1:${reg_port}:5000" -e REGISTRY_STORAGE_DELETE_ENABLED=true --name "${reg_name}" \
     --network bridge \
    registry:2
fi

# create a cluster with the local registry enabled in containerd
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraMounts:
    - hostPath: /var/tmp/kind_storage
      containerPath: /data
featureGates:
  LegacyServiceAccountTokenNoAutoGeneration: false      
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_name}:5000"]
EOF

kind get kubeconfig > /tmp/kubeconfig

# connect the registry to the cluster network if not already connected
if [ "$(${CONTAINER_CMD} inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
  ${CONTAINER_CMD} network connect "kind" "${reg_name}"
fi

[ -z "${REMOTE_DOCKER_HOST}" ] || { setup_kind_sshtunnel  ; trap cleanup_kind_sshtunnel ERR ;  } 

# Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

kubectl apply -f cluster/manifests/add_pv.yaml

export CLUSTER=`kind get kubeconfig | grep server | cut -d ' ' -f6`
export NODE_IP=`kubectl get nodes -o wide | grep control-plane | awk '{print $6}'`
