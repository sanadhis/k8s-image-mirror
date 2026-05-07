#!/bin/bash

IMAGES_FILE="${IMAGES_FILE:-/shared/images.txt}"

kubectl get pods --all-namespaces \
    -o jsonpath='{range .items[*].spec.containers[*]}{.image}{"\n"}{end}{range .items[*].spec.initContainers[*]}{.image}{"\n"}{end}' \
    | grep -E "^${SOURCE_FILTER}" \
    > "$IMAGES_FILE"_tmp

kubectl get jobs --all-namespaces \
    -o jsonpath='{range .items[*].spec.template.spec.containers[*]}{.image}{"\n"}{end}{range .items[*].spec.template.spec.initContainers[*]}{.image}{"\n"}{end}' \
    | grep -E "^${SOURCE_FILTER}" \
    >> "$IMAGES_FILE"_tmp

kubectl get cronjobs --all-namespaces \
    -o jsonpath='{range .items[*].spec.jobTemplate.spec.template.spec.containers[*]}{.image}{"\n"}{end}{range .items[*].spec.jobTemplate.spec.template.spec.initContainers[*]}{.image}{"\n"}{end}' \
    | grep -E "^${SOURCE_FILTER}" \
    >> "$IMAGES_FILE"_tmp

sort -u "$IMAGES_FILE"_tmp | tee "$IMAGES_FILE"

echo "Found $(wc -l < $IMAGES_FILE) unique images."
