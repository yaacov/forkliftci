#!/bin/sh

. ./kind_with_registry.sh

./get_forklift_bazel.sh
￼
./patch_for_local_registry_bazel.sh

./build_forklift_bazel.sh

./deploy_local_forklift_bazel.sh

./k8s-deploy-kubevirt.sh

. ./grant_permissions.sh

echo "CLUSTER=$CLUSTER"
echo "TOKEN=$TOKEN"
