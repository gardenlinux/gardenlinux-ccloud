#!/usr/bin/env bash
set -Eeuo pipefail

currentfstab="$(cat)"

if [ -n "$currentfstab" ]; then
	# Expand the UEFI partition and do not create a /usr partition (for now)
	sed \
	  -e'/type=uefi/ s/$/,size=511M/' \
	  -e '/^[^[:space:]]\+[[:space:]]\+\/usr[[:space:]]\+/d' \
	  <<< "$currentfstab"
fi
