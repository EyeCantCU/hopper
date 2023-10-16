# Hopper Containerfile

ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS hopper

# Copy system files to root
COPY system_files /

# Install Rocky Linux kernel
RUN wget -q https://download.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-9 -P /etc/pki/rpm-gpg/ && \
    rpm-ostree cliwrap install-to-root / && \
    rpm-ostree override replace \
    --experimental \
    --from repo=rocky \
        kernel \
        kernel-core \
        kernel-modules \
        kernel-modules-core \
        kernel-modules-extra && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rocky.repo

# Cleanup and finalize container
RUN rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp
