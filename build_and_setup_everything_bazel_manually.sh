#!/bin/sh

. ./kind_with_registry.sh

./get_forklift_bazel.sh

./build_forklift_bazel.sh

./vmware/setup.sh

./deploy_local_forklift_bazel.sh

./ovirt/setup.sh

./k8s-deploy-kubevirt.sh

. ./grant_permissions.sh

echo "CLUSTER=$CLUSTER"
echo "TOKEN=$TOKEN"
