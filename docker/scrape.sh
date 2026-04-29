#!/bin/bash

IMAGES_FILE="${IMAGES_FILE:-/shared/images.txt}"

kubectl get pods --all-namespaces \
    -o jsonpath='{range .items[*].spec.containers[*]}{.image}{"\n"}{end}{range .items[*].spec.initContainers[*]}{.image}{"\n"}{end}' \
    | grep -E "^${SOURCE_FILTER}"
    | sort -u \
    | tee $IMAGES_FILE

echo "Found $(wc -l < $IMAGES_FILE) unique images."
