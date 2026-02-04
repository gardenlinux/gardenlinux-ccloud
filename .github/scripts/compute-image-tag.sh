#!/bin/bash
# Computes the OCI image tag for Garden Linux ccloud images
#
# This script centralizes the image tag format computation to ensure consistency
# across all workflows (nightly, dev, upload_oci).
#
# Usage:
#   ./compute-image-tag.sh <version> [flavor]
#
# Arguments:
#   version - The version for the tag (e.g., "1877.10.1", "pr-123")
#   flavor  - The image flavor (e.g., "metal-sci-usi-amd64"). Defaults to "metal-sci-usi-amd64".
#
# Environment:
#   GITHUB_SHA - Git commit SHA (required, set automatically by GitHub Actions)
#
# Output:
#   Prints the computed image tag to stdout
#
# Tag format:
#   {version}-{flavor}-{dashed_version}-{commit_sha_short}
#
# Examples:
#   ./compute-image-tag.sh "1877.10.1"
#   # Output: 1877.10.1-metal-sci-usi-amd64-1877-10-1-abcd1234
#
#   ./compute-image-tag.sh "pr-123" "metal-capi-amd64"
#   # Output: pr-123-metal-capi-amd64-pr-123-abcd1234

set -euo pipefail

VERSION="${1:?Error: VERSION argument required}"
FLAVOR="${2:-metal-sci-usi-amd64}"

if [ -z "${GITHUB_SHA:-}" ]; then
    echo "Error: GITHUB_SHA environment variable is required" >&2
    exit 1
fi

COMMIT_SHA="${GITHUB_SHA::8}"
DASHED_VERSION="${VERSION//./-}"

IMAGE_TAG="${VERSION}-${FLAVOR}-${DASHED_VERSION}-${COMMIT_SHA}"

echo "$IMAGE_TAG"
