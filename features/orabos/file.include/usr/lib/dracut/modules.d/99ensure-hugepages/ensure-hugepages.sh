#!/bin/bash
# This file is part of dracut ensure-hugepages module.
# SPDX-License-Identifier: MIT

hugepages=$(getarg hugepages=) || hugepages=0

mem_total_mb=$(($(sed -rn 's/MemTotal:\s+(.*) kB/\1/p' /proc/meminfo) / 1024 ))
hugepagesize_mb=$(($(sed -rn 's/Hugepagesize:\s+(.*) kB/\1/p' /proc/meminfo) / 1024 ))

function adopt_watermark_scale_factor() {
  # On a 3TiB host, the default watermark_scale_factor=10 was exactly that
  # that the kswapd0 was running permanently. Setting it to 5 was solving the
  # issue, but is likely a suboptimal value, but a first start.
  # The value 500 reproduces exactly that value for that scale, and hopefully
  # also holds for larger hosts.
  max_watermark_scale_factor=$(($non_hugepages_mb * 500 / $mem_total_mb))
  watermark_scale_factor=$(</proc/sys/vm/watermark_scale_factor)
  if [ $max_watermark_scale_factor -lt $watermark_scale_factor ]; then
    echo $max_watermark_scale_factor > /proc/sys/vm/watermark_scale_factor
  fi
}

if [ ${hugepages:-0} -gt 0 ]; then
  hugepages_mb=$(($hugepages * $hugepagesize_mb))
  non_hugepages_mb=$(($mem_total_mb - $hugepages_mb))
  adopt_watermark_scale_factor
  exit 0
fi


non_hugepages_pm=$(getarg rd.non_hugepages_pm=) || non_hugepages_pm=50
non_hugepages_mb=$(( ($mem_total_mb * $non_hugepages_pm) / 1000 ))
hugepages=$(( ($mem_total_mb - $non_hugepages_mb ) / $hugepagesize_mb ))

if [ $hugepages -le 0 ]; then
  exit 0
fi


echo $hugepages > /proc/sys/vm/nr_hugepages
# might get more hugepages and faster with the kernel cmdline, but like this you avoid a kexec reboot.


#cmdline="$(</proc/cmdline) hugepages=$hugepages"
#release=$(uname -r)

#NEWROOT=${NEWROOT:-/sysroot}

#kexec \
#  -l $NEWROOT/boot/vmlinuz-${release} \
#  --initrd=$NEWROOT/boot/initrd.img-${release} \
#  --command-line="$cmdline"

#kexec -e --reset-vga
