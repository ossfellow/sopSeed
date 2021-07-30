FROM alpine:3 as base

# OCI annotations arguments
ARG VERSION
ARG LICENSE
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Set OCI Annotations (https://github.com/opencontainers/image-spec/blob/master/annotations.md)
LABEL org.opencontainers.image.title="GitFence" \
    org.opencontainers.image.authors="masoudbahar@gmail.com" \
    org.opencontainers.image.description="gitfence generates compact, strong, GPG (ed25519/cv25519), or Age (X25519) keys, for GitOps, and other use cases." \
    org.opencontainers.image.documentation="${VCS_URL}/oci/gitfence/README.md" \
    org.opencontainers.image.url="${VCS_URL}" \
    org.opencontainers.image.source="${VCS_URL}/oci/gitfence/Dockerfile" \
    org.opencontainers.image.licenses="${LICENSE}" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.created="${BUILD_DATE}"

# Set user attributes
ENV SOC_USER_ID=1000 \
    SOC_GROUP_ID=1000 \
    SOC_HOME="/home/secops"

# Set GPG and Age environment variables
ENV AGE_VERSION="v1.0.0-rc.3" \
    GPG_TTY="/dev/console" \
    GNUPGHOME="${SOC_HOME}/.gnupg"

#    apk cache clean && \

# Create the user and add the required packages
# WARNING: Age only supports amd64, arm64 and arm architectures
RUN addgroup --gid ${SOC_GROUP_ID} secops && \
    adduser -D --uid ${SOC_USER_ID} -G secops -h ${SOC_HOME} -s /bin/sh secops && \
    apk --update add expect gnupg rng-tools tini && \
    AGE_ARCH=true; \
    PLATFORM="$(apk --print-arch)"; \
    case "${PLATFORM}" in \
        armhf) ARCH='arm' ;; \
        armv7) ARCH='arm' ;; \
        aarch64) ARCH='arm64' ;; \
        x86_64) ARCH='amd64' ;; \
        x86) ARCH='386'; AGE_ARCH=false ;; \
        *) echo >&2 "error: unsupported platform architecture: ${PLATFORM}"; exit 121 ;; \
    esac && \
    KUBE_VERSION=$(wget https://dl.k8s.io/release/stable.txt -O -) && \
    wget https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl -O /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    if ${AGE_ARCH}; then wget https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xz --strip 1 -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/age /usr/local/bin/age-keygen; fi

# Scan the image filesystem for vulnerabilities
FROM base as vulnscan

RUN wget https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh -O - | sh -s -- -b /usr/local/bin && \
    trivy filesystem --exit-code 1 --no-progress /

# If the vulnerability scan passed, create the final image, without trivy and scan logs
FROM base as run

# Set user and group, as declared in base image
USER ${SOC_USER_ID}:${SOC_GROUP_ID}

# Set the default ENTRYPOINT and CMD
CMD ["/bin/sh"]
