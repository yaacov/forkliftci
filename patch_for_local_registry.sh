#!/bin/sh
echo "Running $0"

# Patch file matched:
# forklift-controller ec424f2483862b643c0ce59027b9375e51ef0832
# forklift-validation 547d3193a39329e1862092d82c300c2ba3107a2b
# forklift-operator   4c8ec07c6cebb89afc3c6f17c94b424dc71ac34c

patch -p0 < patch_file
