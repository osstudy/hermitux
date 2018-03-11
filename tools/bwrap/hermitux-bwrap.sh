#!/usr/bin/env bash
set -euo pipefail

# Set this variable to the base install path
HERMITUX_BASE=/home/pierre/Desktop/hermitux

# These should not need to be modified
PROXY=$HERMITUX_BASE/hermit-compiler/prefix/bin/proxy
KERNEL=$HERMITUX_BASE/hermit-compiler/prefix/x86_64-hermit/extra/tests/hermitux
TMP_FOLDER=/tmp/hermitux-bwrap

# Cleanup
rm -rf $TMP_FOLDER && mkdir $TMP_FOLDER

cp -f $PROXY $TMP_FOLDER
cp -f $KERNEL $TMP_FOLDER
cp -f $1 $TMP_FOLDER

(exec bwrap \
	  --ro-bind /usr /usr \
	  --ro-bind /lib /lib \
	  --dev-bind /dev /dev \
	  --ro-bind /lib64 /lib64 \
	  --bind $TMP_FOLDER /tmp \
      --dir /var \
      --proc /proc \
      --ro-bind /etc/resolv.conf /etc/resolv.conf \
      --unshare-all \
      --die-with-parent \
	  --setenv HERMIT_ISLE "uhyve" \
	  --setenv HERMIT_TUX "1" \
      /tmp/proxy /tmp/hermitux /tmp/syscall_asm) \
    11< <(getent passwd $UID 65534) \
    12< <(getent group $(id -g) 65534)

# cleanup
rm -rf $TMP_FOLDER
