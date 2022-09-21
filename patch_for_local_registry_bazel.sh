#!/bin/sh
echo "Running $0"

sed -i "s|quay.io/konveyor|localhost:5001|g" forklift/.bazelrc

cat <<EOF >> forklift/BUILD.bazel
container_push(
    name = "push-forklift-validation",
    format = "Docker",
    image = "//validation:forklift-validation-image",
    registry = "\$\${REGISTRY:-quay.io}",
    repository = "\$\${REGISTRY_ACCOUNT}\$\${REGISTRY_ACCOUNT:+/}forklift-operator",
    tag = "\$\${REGISTRY_TAG:-devel}",
)
EOF
