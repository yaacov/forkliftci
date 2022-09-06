#!/bin/bash

# There should be 4 containers running, when forklift is started.
# This script just waits until that is the case.

while true
do
  running=`kubectl get pod -n konveyor-forklift | grep -cE 'forklift.*Running'`
  if [ "$running" -eq 4 ]; then
    echo "All expected forklift containers Up"
    break
  fi
  sleep 3
done
