#!/bin/bash
# This file is part of dracut ensure-hugepages module.
# SPDX-License-Identifier: MIT

hugepages=$(getarg hugepages=) || hugepages=-1	# -1 for unset

mem_total_mb=$(($(sed -rn 's/MemTotal:\s+(.*) kB/\1/p' /proc/meminfo) / 1024 ))
hugepagesize_mb=$(($(sed -rn 's/Hugepagesize:\s+(.*) kB/\1/p' /proc/meminfo) / 1024 ))

if [ $hugepages -lt 0 ]; then	# presumably unset, derive it from rdnon_hugepages or from default
  non_hugepages_pm=$(getarg rd.non_hugepages_pm=) || non_hugepages_pm=45
  non_hugepages_mb=$(( ($mem_total_mb * $non_hugepages_pm) / 1000 ))
  hugepages=$(( ($mem_total_mb - $non_hugepages_mb ) / $hugepagesize_mb ))
fi


if [ ${hugepages:-0} -lt 0 ]; then
  exit 0
fi

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

# Only after having set the above, we an actually reserve the hugepages
echo $hugepages > /proc/sys/vm/nr_hugepages
