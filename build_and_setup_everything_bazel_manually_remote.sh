#!/bin/bash

set -e

export remote_docker_host=192.168.2.135

cleanup() {
    { [ -s /tmp/tunnel_id ] && [ -n "$(pgrep -f "$(cat /tmp/tunnel_id)")" ] ; } && \
    { echo "killing ssh PID $(pgrep -f "$(cat /tmp/tunnel_id)") " ; pkill -f "$(cat /tmp/tunnel_id)"; };
}

setup_tunnel(){
    remote_port=$(kind get kubeconfig | grep server |  awk -F '1:' '{print $2}')
    ssh -f -N \
    -L ${remote_port}:127.0.0.1:${remote_port} ${remote_docker_host} \
    -L 5001:127.0.0.1:5001 ${remote_docker_host} 
    echo $remote_port > /tmp/tunnel_id
    echo "running ssh port ${remote_port} PID $(pgrep -f "$(cat /tmp/tunnel_id)") "
}

export DOCKER_HOST="tcp://${remote_docker_host}:2376"


. ./kind_with_registry.sh || echo "skipping step"
setup_tunnel

trap cleanup ERR


./get_forklift_bazel.sh || echo "skipping step"

./k8s-deploy-kubevirt.sh || echo "skipping step"

./build_forklift_bazel.sh

./deploy_local_forklift_bazel.sh

./vmware/setup.sh

./ovirt/setup.sh

. ./grant_permissions.sh

echo "CLUSTER=$CLUSTER"
echo "TOKEN=$TOKEN"
echo "NODE_IP=$NODE_IP"
