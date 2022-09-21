#!/bin/sh
echo "Running $0"

# Change the dir to FORKLIFT_DIR (default forklift)
cd ${FORKLIFT_DIR:-forklift}

export REGISTRY=localhost:5001
export REGISTRY_TAG=latest
export REGISTRY_ACCOUNT=""

bazel run push-forklift-operator
bazel run push-forklift-operator-bundle
bazel run push-forklift-operator-index --action_env REGISTRY=${REGISTRY} --action_env REGISTRY_TAG=${REGISTRY_TAG} --action_env OPM_OPTS="--use-http"
bazel run push-forklift-controller
bazel run push-forklift-validation
