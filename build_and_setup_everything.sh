#!/bin/sh

. ./kind_with_registry.sh

./get_forklift.sh

./patch_for_local_registry.sh

./build_forklift.sh

./deploy_local_forklift.sh

./k8s-deploy-kubevirt.sh

. ./grant_permissions.sh

echo "CLUSTER=$CLUSTER"
echo "TOKEN=$TOKEN"
