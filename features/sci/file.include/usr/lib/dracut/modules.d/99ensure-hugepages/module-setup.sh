#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later


# Module dependency requirements.
depends() {
	echo "bash"
	return 0
}

# Install the required file(s) and directories for the module in the initramfs.
install() {
	inst_hook cmdline 00 "$moddir/ensure-hugepages.sh"
}
