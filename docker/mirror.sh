#!/bin/bash
set -euo pipefail

IMAGES_FILE="${IMAGES_FILE:-/shared/images.txt}"
COPIED=0
SKIPPED=0
FAILED=0

src_creds="--src-creds=${SOURCE_USERNAME}:${SOURCE_PASSWORD}"
dst_creds="--dest-creds=${TARGET_USERNAME}:${TARGET_PASSWORD}"
src_tls="--src-tls-verify=${SRC_TLS_VERIFY:-true}"
dst_tls="--dest-tls-verify=${DEST_TLS_VERIFY:-true}"
inspect_creds="--creds=${TARGET_USERNAME}:${TARGET_PASSWORD}"
inspect_tls="--tls-verify=${DEST_TLS_VERIFY:-true}"

total=$(wc -l < "$IMAGES_FILE")
echo "==> Mirroring ${total} images to ${TARGET_REGISTRY}"
echo

while IFS= read -r src_image; do
  [[ -z "$src_image" ]] && continue

  # Strip registry hostname from the source image to build the target path.
  # A registry segment contains '.' or ':', or equals 'localhost'.
  first_segment="${src_image%%/*}"
  if [[ "$first_segment" =~ [.:]  || "$first_segment" == "localhost" ]]; then
    if [[ "${STRIP_NAMESPACE:-false}" == "true" ]] ; then
      image_path="${src_image##*/}"
    else
      image_path="${src_image#*/}"
    fi
  else
    image_path="$src_image"
  fi

  dst_image="${TARGET_REGISTRY}/${image_path}"

  echo "  src: ${src_image}"
  echo "  dst: ${dst_image}"

  if [[ "${SKIP_IF_EXISTS:-false}" == "true" ]]; then
    if skopeo inspect \
        "${inspect_creds}" \
        "${inspect_tls}" \
        "docker://${dst_image}" &>/dev/null; then
      echo "  [SKIPPED] already exists in target registry"
      SKIPPED=$((SKIPPED + 1))
      echo
      continue
    fi
  fi

  if skopeo copy \
      "${src_creds}" \
      "${dst_creds}" \
      "${src_tls}" \
      "${dst_tls}" \
      --retry-times 3 \
      "docker://${src_image}" \
      "docker://${dst_image}"; then
    echo "  [OK]"
    COPIED=$((COPIED + 1))
  else
    echo "  [FAILED]" >&2
    FAILED=$((FAILED + 1))
  fi
  echo
done < "$IMAGES_FILE"

echo "==========================================================="
echo "Copied: ${COPIED}  Skipped: ${SKIPPED}  Failed: ${FAILED}"
echo "==========================================================="

[[ "$FAILED" -eq 0 ]]
