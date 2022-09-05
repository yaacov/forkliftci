#!/bin/sh

go install sigs.k8s.io/kind@v0.15.0

kind create cluster

export CLUSTER=`kind get kubeconfig | grep server | cut -d ' ' -f6`
