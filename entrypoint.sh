#!/bin/bash
set -euo pipefail
GROUP() {
    echo "::group::${*}"
    set -x
}
ENDGROUP() {
    set +x
    echo "::endgroup::"
}
pv() {
    if command -v pv &> /dev/null; then
        command pv -f "${@}"
    else
        dd if="${1}" bs=1M status=progress
    fi
}

GROUP "Set up environment..."
STREAM="${STREAM:-${DEFAULT_STREAM:-stable}}"
DISK_FORMAT="${DISK_FORMAT:-${DEFAULT_DISK_FORMAT:-qcow2.xz}}"
ARCH="${ARCH:-${DEFAULT_ARCH:-x86_64}}"
STOCK_PLATFORM="${STOCK_PLATFORM:-${DEFAULT_STOCK_PLATFORM:-qemu}}"
EMERGING_PLATFORM="${1:-${EMERGING_PLATFORM:-${DEFAULT_EMERGING_PLATFORM:-proxmoxve}}}"
ENDGROUP

GROUP "Download CoreOS image..."
source="$(coreos-installer download -s "${STREAM}" -p "${STOCK_PLATFORM}" -f "${DISK_FORMAT}" -a "${ARCH}" -d | tee ./download.log)" # stdout is the filename
ENDGROUP

GROUP "Convert CoreOS image (to ${EMERGING_PLATFORM})..."
dest="${source//"${STOCK_PLATFORM}"/"${EMERGING_PLATFORM}"}" # replace qemu with the target platform

sudo chmod -R a+r /boot
export LIBGUESTFS_DEBUG=1 LIBGUESTFS_TRACE=1

cp --reflink=auto "${source}" "${dest}"
guestfish -a "${dest}" <<EOF
run
mount /dev/sda3 /
download /loader/entries/ostree-1.conf tmp.loader.entries.ostree-1.conf
<! sed -i "s/ignition.platform.id=qemu/ignition.platform.id=${EMERGING_PLATFORM}/" tmp.loader.entries.ostree-1.conf
upload tmp.loader.entries.ostree-1.conf /loader/entries/ostree-1.conf
EOF

rm -v ./tmp.loader.entries.ostree-1.conf

ENDGROUP

GROUP "Compress converted CoreOS image..."
pv "${dest}" | xz -z --fast --stdout > "${dest}.xz"
ENDGROUP

GROUP "Record metadata..."
set +u # Just in case we're not running in GHA, don't exit on unset var
{
# let's parse/hack the version number out of the filename of the source image
PRODUCT="fedora-coreos"
PREFIX="./${PRODUCT}-"
#STOCK_PLATFORM="qemu"
#ARCH="x86_64"
#DISK_FORMAT="qcow2.xz"
COMPRESSION=".xz"
SUFFIX="-${STOCK_PLATFORM}.${ARCH}.${DISK_FORMAT%"${COMPRESSION}"}"
version="${source#"${PREFIX}"}"
version="${version%"${SUFFIX}"}"

echo "dest=${dest#./}.xz"
echo "version=${version}"
echo "tag=${version}.$(date -I)"
} | tee -a "${GITHUB_OUTPUT:-/dev/null}"
set -u
ENDGROUP