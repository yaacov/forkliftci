#!/bin/sh
echo "Running $0"

echo "Building forklift-operator:"
cd forklift-operator
make docker-build docker-push bundle-build bundle-push catalog-build catalog-push
cd ..

echo "Building forklift-controller:"
cd forklift-controller
make docker-build docker-push
cd ..

echo "Building forklift-validation:"
cd forklift-validation
make docker-build docker-push
cd ..

echo "Pushing images to local registry:"
docker push localhost:5001/forklift-operator:latest
docker push localhost:5001/forklift-operator-bundle:latest
docker push localhost:5001/forklift-operator-index:latest
docker push localhost:5001/forklift-controller:latest
docker push localhost:5001/konveyor/forklift-validation:latest
