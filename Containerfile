FROM ghcr.io/gardenlinux/builder:d6d24ba1aec66889a2acab83aedcb00e869abfcd

RUN sed 's/version="$2"/version=\$(echo \$2 | cut -d. -f 1-2)/' -i /builder/bootstrap
