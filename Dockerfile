# Expand the SBOM scanning scope to include the build context and additional stages
ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
FROM alpine:3 as base
ARG BUILDKIT_SBOM_SCAN_STAGE=true

# Set user attributes
ENV SOC_USER_ID=1000 \
    SOC_GROUP_ID=1000 \
    SOC_HOME="/home/secops"

# Set GPG environment variables
ENV GPG_TTY="/dev/console" \
    GNUPGHOME="${SOC_HOME}/.gnupg"

# Create the user and add the required packages
# WARNING: Age only supports amd64, arm64 and arm architectures
RUN addgroup --gid ${SOC_GROUP_ID} secops && \
    adduser -D --uid ${SOC_USER_ID} -G secops -h ${SOC_HOME} -s /bin/sh secops && \
    apk --update add gnupg jq tini && \
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
    KUBE_VERSION=$(wget -q https://dl.k8s.io/release/stable.txt -O -) && \
    wget https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl -O /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    AGE_VERSION=$(wget -q --header="Accept: application/vnd.github.v3+json" https://api.github.com/repos/FiloSottile/age/tags -O - | jq -r '. | first | .name') && \
    if ${AGE_ARCH}; then wget https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xz --strip 1 -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/age /usr/local/bin/age-keygen; fi && \
    apk del jq

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
