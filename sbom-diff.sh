#!/usr/bin/env bash
#
# sbom-diff.sh - Compare SBOMs (package manifests) between two GardenLinux OCI images
#
# Usage: sbom-diff.sh <tag1> <tag2>
# Example: sbom-diff.sh pr-152-metal-sci-usi-amd64-pr-152-0cf809c5 2061.0.0-metal-sci-usi-amd64-2061-0-0-4a12b903

set -euo pipefail

# Configuration
REGISTRY="ghcr.io/gardenlinux/gardenlinux-ccloud"
TEMP_DIR=$(mktemp -d)

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

usage() {
    echo "Usage: $0 <tag1> <tag2> [options]"
    echo ""
    echo "Compare package manifests between two GardenLinux OCI image tags"
    echo ""
    echo "Options:"
    echo "  --registry <url>    Registry URL (default: ghcr.io/gardenlinux/gardenlinux-ccloud)"
    echo "  --format <format>   Output format: summary|diff|added|removed|changed (default: summary)"
    echo "  --output <file>     Write output to file instead of stdout"
    echo ""
    echo "Examples:"
    echo "  $0 tag1 tag2"
    echo "  $0 tag1 tag2 --format diff"
    echo "  $0 tag1 tag2 --format added --output added-packages.txt"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

TAG1="$1"
TAG2="$2"
shift 2

OUTPUT_FORMAT="summary"
OUTPUT_FILE=""

# Parse additional options
while [ $# -gt 0 ]; do
    case "$1" in
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        --format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Function to fetch manifest blob from OCI image
fetch_manifest() {
    local tag="$1"
    local output_file="$2"
    
    echo "Fetching manifest for ${REGISTRY}:${tag}..." >&2
    
    # Get the OCI manifest to find the manifest blob digest
    local manifest_digest=$(oras manifest fetch "${REGISTRY}:${tag}" 2>/dev/null | \
        jq -r '.layers[] | select(.mediaType == "application/io.gardenlinux.manifest") | .digest')
    
    if [ -z "$manifest_digest" ]; then
        echo "Error: No manifest layer found in ${REGISTRY}:${tag}" >&2
        echo "Available layers:" >&2
        oras manifest fetch "${REGISTRY}:${tag}" 2>/dev/null | \
            jq -r '.layers[] | .mediaType' >&2
        exit 1
    fi
    
    echo "Found manifest digest: $manifest_digest" >&2
    
    # Fetch the manifest blob
    oras blob fetch "${REGISTRY}@${manifest_digest}" --output "$output_file" 2>/dev/null
    
    echo "Manifest saved to $output_file ($(wc -l < "$output_file") packages)" >&2
}

# Function to parse package manifest into associative array
parse_manifest() {
    local file="$1"
    
    # Output format: package=version
    while IFS=' ' read -r package version; do
        echo "${package}=${version}"
    done < "$file"
}

# Fetch both manifests
MANIFEST1="${TEMP_DIR}/manifest1.txt"
MANIFEST2="${TEMP_DIR}/manifest2.txt"

fetch_manifest "$TAG1" "$MANIFEST1"
fetch_manifest "$TAG2" "$MANIFEST2"

# Parse manifests into sorted lists
PARSED1="${TEMP_DIR}/parsed1.txt"
PARSED2="${TEMP_DIR}/parsed2.txt"

parse_manifest "$MANIFEST1" | sort > "$PARSED1"
parse_manifest "$MANIFEST2" | sort > "$PARSED2"

# Create package-only lists for set operations
cut -d'=' -f1 "$PARSED1" | sort > "${TEMP_DIR}/packages1.txt"
cut -d'=' -f1 "$PARSED2" | sort > "${TEMP_DIR}/packages2.txt"

# Find differences
ADDED="${TEMP_DIR}/added.txt"
REMOVED="${TEMP_DIR}/removed.txt"
COMMON="${TEMP_DIR}/common.txt"
CHANGED="${TEMP_DIR}/changed.txt"

comm -13 "${TEMP_DIR}/packages1.txt" "${TEMP_DIR}/packages2.txt" > "$ADDED"
comm -23 "${TEMP_DIR}/packages1.txt" "${TEMP_DIR}/packages2.txt" > "$REMOVED"
comm -12 "${TEMP_DIR}/packages1.txt" "${TEMP_DIR}/packages2.txt" > "$COMMON"

# Find version changes
> "$CHANGED"
while read -r package; do
    ver1=$(grep "^${package}=" "$PARSED1" | cut -d'=' -f2)
    ver2=$(grep "^${package}=" "$PARSED2" | cut -d'=' -f2)
    
    if [ "$ver1" != "$ver2" ]; then
        echo "${package}: ${ver1} -> ${ver2}" >> "$CHANGED"
    fi
done < "$COMMON"

# Output function
output() {
    if [ -n "$OUTPUT_FILE" ]; then
        cat > "$OUTPUT_FILE"
    else
        cat
    fi
}

# Generate output based on format
case "$OUTPUT_FORMAT" in
    summary)
        {
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "SBOM Diff: ${TAG1} vs ${TAG2}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Tag 1: ${TAG1}"
            echo "  Total packages: $(wc -l < "$MANIFEST1")"
            echo ""
            echo "Tag 2: ${TAG2}"
            echo "  Total packages: $(wc -l < "$MANIFEST2")"
            echo ""
            echo "Changes:"
            echo "  Added packages:   $(wc -l < "$ADDED")"
            echo "  Removed packages: $(wc -l < "$REMOVED")"
            echo "  Changed versions: $(wc -l < "$CHANGED")"
            echo "  Unchanged:        $(($(wc -l < "$COMMON") - $(wc -l < "$CHANGED")))"
            echo ""
            
            if [ -s "$ADDED" ]; then
                echo -e "${GREEN}━━━ Added Packages ($(wc -l < "$ADDED")) ━━━${NC}"
                while read -r pkg; do
                    version=$(grep "^${pkg}=" "$PARSED2" | cut -d'=' -f2)
                    echo -e "${GREEN}+ ${pkg} ${version}${NC}"
                done < "$ADDED"
                echo ""
            fi
            
            if [ -s "$REMOVED" ]; then
                echo -e "${RED}━━━ Removed Packages ($(wc -l < "$REMOVED")) ━━━${NC}"
                while read -r pkg; do
                    version=$(grep "^${pkg}=" "$PARSED1" | cut -d'=' -f2)
                    echo -e "${RED}- ${pkg} ${version}${NC}"
                done < "$REMOVED"
                echo ""
            fi
            
            if [ -s "$CHANGED" ]; then
                echo -e "${YELLOW}━━━ Changed Versions ($(wc -l < "$CHANGED")) ━━━${NC}"
                while IFS=':' read -r pkg versions; do
                    echo -e "${YELLOW}~ ${pkg}:${versions}${NC}"
                done < "$CHANGED"
                echo ""
            fi
        } | output
        ;;
        
    diff)
        {
            echo "--- ${TAG1}"
            echo "+++ ${TAG2}"
            diff -u "$PARSED1" "$PARSED2" || true
        } | output
        ;;
        
    added)
        {
            while read -r pkg; do
                version=$(grep "^${pkg}=" "$PARSED2" | cut -d'=' -f2)
                echo "${pkg} ${version}"
            done < "$ADDED"
        } | output
        ;;
        
    removed)
        {
            while read -r pkg; do
                version=$(grep "^${pkg}=" "$PARSED1" | cut -d'=' -f2)
                echo "${pkg} ${version}"
            done < "$REMOVED"
        } | output
        ;;
        
    changed)
        cat "$CHANGED" | output
        ;;
        
    *)
        echo "Unknown format: $OUTPUT_FORMAT"
        usage
        ;;
esac

# Print summary to stderr if output goes to file
if [ -n "$OUTPUT_FILE" ]; then
    echo "Output written to: $OUTPUT_FILE" >&2
    echo "Added: $(wc -l < "$ADDED"), Removed: $(wc -l < "$REMOVED"), Changed: $(wc -l < "$CHANGED")" >&2
fi
