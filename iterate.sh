#!/bin/bash
set -euxo pipefail
# This is to make local development/iteration easier.
# It's not meant to be used in CI/CD, but rather as a way to quickly iterate on the container build process.

echo clean work
rm -fR ./work
mkdir -p ./work

DEPENDENCIES_HASH=$(sha256sum ./Containerfile.dependencies | awk '{print $1}')
DEPENDENCIES_IMAGE_TAG="coreos-restamper-dependencies:${DEPENDENCIES_HASH}"
if ! podman image exists "${DEPENDENCIES_IMAGE_TAG}"; then
    echo build dependencies container
    #podman build -t "${DEPENDENCIES_IMAGE_TAG}" -f Containerfile.dependencies .
    buildah build -t "${DEPENDENCIES_IMAGE_TAG}" -f Containerfile.dependencies .
fi

echo build container
buildah build --build-arg "image=${DEPENDENCIES_IMAGE_TAG}" -t coreos-restamper:latest .
podman run -it --rm -v ./work:/work:z coreos-restamper:latest
