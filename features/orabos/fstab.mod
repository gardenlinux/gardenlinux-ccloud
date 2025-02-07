#!/usr/bin/env bash
set -Eeuo pipefail

currentfstab="$(cat)"

if [ -n "$currentfstab" ]; then
	# delete any predefinition of a var partition
	sed '/^[^[:space:]]\+[[:space:]]\+\/usr[[:space:]]\+/d' <<< "$currentfstab"
fi
