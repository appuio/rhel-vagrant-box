#!/bin/bash

set -e

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tmp_dir=$(mktemp -d)
trap "rm -rf $tmp_dir" EXIT

if [ $# -ne 2 ]; then
  echo ""
  echo "$(basename $0) usage:"
  echo "  $(basename $0) RHEL_CLOUD_IMAGE VAGRANT_BOX_TARBALL"

  exit 1
fi

case "$2" in
  *.xz)
    if command -v pxz >/dev/null 2>&1; then
      compress_command="pxz"
    else
      compress_command="xz"
    fi
    ;;
  *.bz2)
    if command -v pbzip2 >/dev/null 2>&1; then
      compress_command="pbzip2"
    else
      compress_command="bzip2"
    fi
    ;;
  *)
    export GZIP=-9
    if command -v pigz >/dev/null 2>&1; then
      compress_command="pigz"
    else
      compress_command="gzip"
    fi
    ;;
esac

ln -s $(readlink -f "$1") "${tmp_dir}/box.img"
ln -s "${script_dir}/box/Vagrantfile" "${script_dir}/box/metadata.json" "${tmp_dir}"

(cd cloud-init && genisoimage -no-pad -output ${tmp_dir}/cloud-init.iso -volid cidata -joliet -rock user-data meta-data)
(cd ${tmp_dir} && tar cvhf - .) | $compress_command > "$2"
