ARG image=registry.fedoraproject.org/fedora:41
# ARG image=coreos-restamper-dependencies
FROM ${image}
ARG DEFAULT_STREAM
ENV DEFAULT_STREAM=${DEFAULT_STREAM:-stable}
ENV STREAM=${STREAM:-${DEFAULT_STREAM}}
ARG DEFAULT_DISK_FORMAT
ENV DEFAULT_DISK_FORMAT=${DEFAULT_DISK_FORMAT:-qcow2.xz}
ENV DISK_FORMAT=${DISK_FORMAT:-${DEFAULT_DISK_FORMAT}}
ARG DEFAULT_ARCH
ENV DEFAULT_ARCH=${DEFAULT_ARCH:-x86_64}
ENV ARCH=${ARCH:-${DEFAULT_ARCH}}
ARG DEFAULT_STOCK_PLATFORM
ENV DEFAULT_STOCK_PLATFORM=${DEFAULT_STOCK_PLATFORM:-qemu}
ENV STOCK_PLATFORM=${STOCK_PLATFORM:-${DEFAULT_STOCK_PLATFORM}}
ARG DEFAULT_EMERGING_PLATFORM
ENV DEFAULT_EMERGING_PLATFORM=${DEFAULT_EMERGING_PLATFORM:-proxmoxve}
ENV EMERGING_PLATFORM=${EMERGING_PLATFORM:-${DEFAULT_EMERGING_PLATFORM}}
ARG DEFAULT_LIBGUESTFS_BACKEND
ENV DEFAULT_LIBGUESTFS_BACKEND=${DEFAULT_LIBGUESTFS_BACKEND:-direct}
ENV LIBGUESTFS_BACKEND=${LIBGUESTFS_BACKEND:-${DEFAULT_LIBGUESTFS_BACKEND}}
RUN dnf install -y coreos-installer guestfish pv
RUN mkdir /work
COPY entrypoint.sh /entrypoint.sh
WORKDIR /work
CMD [ "/entrypoint.sh" ]
#CMD ["${DEFAULT_EMERGING_PLATFORM}"]