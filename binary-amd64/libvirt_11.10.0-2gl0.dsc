Format: 3.0 (quilt)
Source: libvirt
Binary: libvirt-clients, libvirt-clients-qemu, libvirt-daemon, libvirt-daemon-common, libvirt-daemon-log, libvirt-daemon-lock, libvirt-daemon-driver-qemu, libvirt-daemon-driver-lxc, libvirt-daemon-driver-ch-gl, libvirt-daemon-driver-vbox, libvirt-daemon-driver-xen, libvirt-daemon-driver-storage, libvirt-daemon-driver-storage-disk, libvirt-daemon-driver-storage-gluster, libvirt-daemon-driver-storage-iscsi, libvirt-daemon-driver-storage-iscsi-direct, libvirt-daemon-driver-storage-logical, libvirt-daemon-driver-storage-mpath, libvirt-daemon-driver-storage-rbd, libvirt-daemon-driver-storage-scsi, libvirt-daemon-driver-storage-zfs, libvirt-daemon-driver-network, libvirt-daemon-driver-nwfilter, libvirt-daemon-driver-interface, libvirt-daemon-driver-nodedev, libvirt-daemon-driver-secret, libvirt-daemon-plugin-lockd, libvirt-daemon-plugin-sanlock, libvirt-daemon-system, libvirt-daemon-config-network, libvirt-daemon-config-nwfilter, libvirt0, libvirt-common, libvirt-l10n,
 libvirt-doc, libvirt-dev, libnss-libvirt, libvirt-ssh-proxy, libvirt-wireshark, libvirt-login-shell, libvirt-sanlock, libvirt-daemon-system-systemd,
 libvirt-daemon-system-sysv
Architecture: any all
Version: 11.10.0-2gl0
Maintainer: Debian Libvirt Maintainers <pkg-libvirt-maintainers@lists.alioth.debian.org>
Uploaders:  Guido Günther <agx@sigxcpu.org>, Andrea Bolognani <eof@kiyuko.org>,
Homepage: https://libvirt.org/
Standards-Version: 4.7.2
Vcs-Browser: https://salsa.debian.org/libvirt-team/libvirt
Vcs-Git: https://salsa.debian.org/libvirt-team/libvirt.git
Testsuite: autopkgtest
Testsuite-Triggers: build-essential, libxml2-utils, pkg-config, qemu-kvm, qemu-system
Build-Depends: debhelper-compat (= 13), dh-apparmor [linux-any], dh-sequence-installsysusers, augeas-tools [linux-any], bash-completion, libacl1-dev [linux-any], libapparmor-dev (>= 3.0.0) [linux-any], libattr1-dev [linux-any], libaudit-dev [linux-any], libblkid-dev [linux-any], libbsd-dev, libc-dev (>= 2.31-14~), libcap-ng-dev [linux-any], libcurl4-gnutls-dev [linux-any], libdevmapper-dev [linux-any], libfuse3-dev [linux-any], libglib2.0-dev, libglusterfs-dev [amd64 arm64 ia64 loong64 mips64el ppc64 ppc64el riscv64 s390x sparc64], libgnutls28-dev, libiscsi-dev [linux-any], libjson-c-dev [linux-any], libnl-3-dev [linux-any], libnl-route-3-dev [linux-any], libnuma-dev [linux-any], libparted-dev [linux-any], libpcap0.8-dev [linux-any], libpciaccess-dev [linux-any], librados-dev [amd64 arm64 loong64 mips64el ppc64el riscv64 s390x], librbd-dev [amd64 arm64 loong64 mips64el ppc64el riscv64 s390x], libreadline-dev, libsanlock-dev [linux-any], libsasl2-dev, libselinux1-dev [linux-any], libssh-dev, libssh2-1-dev, libtasn1-6-dev, libtirpc-dev, libudev-dev [linux-any], libwireshark-dev [alpha amd64 arm64 armel armhf hppa i386 loong64 mips64el powerpc ppc64 ppc64el riscv64 s390x sh4 sparc64], libxen-dev [amd64 arm64], libxml2-dev, libxml2-utils, meson, po-debconf, python3-docutils, python3:native, qemu-utils [amd64 arm64 armel armhf i386 loong64 mips64el mipsel powerpc ppc64 ppc64el riscv64 s390x sparc64 x32], systemtap-sdt-dev [linux-any], xsltproc
Package-List:
 libnss-libvirt deb admin optional arch=linux-any
 libvirt-clients deb admin optional arch=any
 libvirt-clients-qemu deb admin optional arch=all
 libvirt-common deb libs optional arch=any
 libvirt-daemon deb admin optional arch=linux-any
 libvirt-daemon-common deb admin optional arch=linux-any
 libvirt-daemon-config-network deb admin optional arch=all
 libvirt-daemon-config-nwfilter deb admin optional arch=all
 libvirt-daemon-driver-ch-gl deb admin optional arch=linux-any
 libvirt-daemon-driver-interface deb admin optional arch=linux-any
 libvirt-daemon-driver-lxc deb admin optional arch=linux-any
 libvirt-daemon-driver-network deb admin optional arch=linux-any
 libvirt-daemon-driver-nodedev deb admin optional arch=linux-any
 libvirt-daemon-driver-nwfilter deb admin optional arch=linux-any
 libvirt-daemon-driver-qemu deb admin optional arch=amd64,arm64,armel,armhf,i386,loong64,mips64el,mipsel,powerpc,ppc64,ppc64el,riscv64,s390x,sparc64,x32
 libvirt-daemon-driver-secret deb admin optional arch=linux-any
 libvirt-daemon-driver-storage deb admin optional arch=linux-any
 libvirt-daemon-driver-storage-disk deb admin optional arch=linux-any
 libvirt-daemon-driver-storage-gluster deb admin optional arch=amd64,arm64,ia64,loong64,mips64el,ppc64,ppc64el,riscv64,s390x,sparc64
 libvirt-daemon-driver-storage-iscsi deb admin optional arch=linux-any
 libvirt-daemon-driver-storage-iscsi-direct deb admin optional arch=linux-any
 libvirt-daemon-driver-storage-logical deb admin optional arch=linux-any
 libvirt-daemon-driver-storage-mpath deb admin optional arch=linux-any
 libvirt-daemon-driver-storage-rbd deb admin optional arch=amd64,arm64,loong64,mips64el,ppc64el,riscv64,s390x
 libvirt-daemon-driver-storage-scsi deb admin optional arch=linux-any
 libvirt-daemon-driver-storage-zfs deb admin optional arch=linux-any
 libvirt-daemon-driver-vbox deb admin optional arch=amd64,i386
 libvirt-daemon-driver-xen deb admin optional arch=amd64,arm64
 libvirt-daemon-lock deb admin optional arch=linux-any
 libvirt-daemon-log deb admin optional arch=linux-any
 libvirt-daemon-plugin-lockd deb admin optional arch=linux-any
 libvirt-daemon-plugin-sanlock deb admin optional arch=linux-any
 libvirt-daemon-system deb admin optional arch=amd64,arm64,armel,armhf,i386,loong64,mips64el,mipsel,powerpc,ppc64,ppc64el,riscv64,s390x,sparc64,x32
 libvirt-daemon-system-systemd deb admin optional arch=all
 libvirt-daemon-system-sysv deb admin optional arch=all
 libvirt-dev deb libdevel optional arch=any
 libvirt-doc deb doc optional arch=all
 libvirt-l10n deb localization optional arch=all
 libvirt-login-shell deb admin optional arch=linux-any
 libvirt-sanlock deb admin optional arch=linux-any
 libvirt-ssh-proxy deb admin optional arch=linux-any
 libvirt-wireshark deb admin optional arch=alpha,amd64,arm64,armel,armhf,hppa,i386,loong64,mips64el,powerpc,ppc64,ppc64el,riscv64,s390x,sh4,sparc64
 libvirt0 deb libs optional arch=any
Checksums-Sha1:
 6e77acfa414e3add4c55d43158745bfaa5ddbc04 10751916 libvirt_11.10.0.orig.tar.xz
 eb496230c2d4b70c96851f5658ebc5e631bf1518 96048 libvirt_11.10.0-2gl0.debian.tar.xz
Checksums-Sha256:
 ca8add144a7a554860586e6001a56f666fc47ced4b1c8cab484d998a45587fa7 10751916 libvirt_11.10.0.orig.tar.xz
 77b799c221d6dad2f0f5773e51109cfffecbdcb1a8fdd967215f9eb8b59c6ba2 96048 libvirt_11.10.0-2gl0.debian.tar.xz
Files:
 84cc9f9e7aca4470b154e280884da8eb 10751916 libvirt_11.10.0.orig.tar.xz
 ad39ba9575dc6435980f9627ac63841e 96048 libvirt_11.10.0-2gl0.debian.tar.xz
