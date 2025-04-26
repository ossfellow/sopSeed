# sopSeed OCI Image ([Dockerfile](https://github.com/ossfellow/sopSeed/blob/main/Dockerfile))

## Features

The sopSeed OCI image provides:

* **Lightweight Design** - Minimal Alpine-based image with essential tools only

* **Security First** - Built-in vulnerability scanning using [Aqua Security's trivy](https://github.com/aquasecurity/trivy), failing builds if security issues are found

* **Production Ready** - Sensible defaults for both interactive use and automation

The sopSeed OCI images are signed and attested using SLSA provenance and Sigstore/Cosign attestations. Provenance can be verified using Cosign.

## Interactive Usage Examples

The sopSeed OCI image is published to [GitHub Packages registry](https://github.com/ossfellow/sopSeed/pkgs/container/sopseed).

> **Note**: In below examples, replace `{version}` with the desired version tag, e.g., `0.1.0`.

### Show GPG Version

```console
docker run --rm -it ghcr.io/ossfellow/sopseed:{version} gpg --version
```

### List GPG keys

```console
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg ghcr.io/ossfellow/sopseed:{version} gpg --list-keys
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg ghcr.io/ossfellow/sopseed:{version} gpg --list-secret-keys
```

### Generate a GPG key (ed25519/cv25519)

```console
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg ghcr.io/ossfellow/sopseed:{version} gpg --quick-gen-key --batch --passphrase "" "masoudbahar (test key)" future-default default never
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg ghcr.io/ossfellow/sopseed:{version} gpg --full-gen-key --expert
```

**Note**: ECDSA and RSA keys are supported too, but ECDH (ed25519/cv25519) is preferred.

### Get GPG key fingerprint

```console
KEY_FP=$(docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg ghcr.io/ossfellow/sopseed:{version} gpg --with-colons --fingerprint masoudbahar | grep fpr | cut -d ':' -f 10 | head -1)
```

### Export GPG public key

```console
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg -v $(pwd)/keys:/keys ghcr.io/ossfellow/sopseed:{version} gpg --export --armor "${KEY_FP}" > keys/public.asc
```

### Show Age version

```console
docker run --rm -it ghcr.io/ossfellow/sopseed:{version} age --version
```

### Generate an Age key (X25519)

```console
docker run --rm -it -v /local/age/keys/store:/home/secops/age ghcr.io/ossfellow/sopseed:{version} age-keygen -o /home/secops/age/age.agekey
```

### Export Age public key

```console
docker run --rm -it -v /local/age/keys/store:/home/secops/age ghcr.io/ossfellow/sopseed:{version} cat /home/secops/age/age.agekey | grep "public key:" | awk '{print $3}'
```

### Verify Image Authenticity

To verify the authenticity of the image using SLSA provenance and Cosign:

```console
cosign verify-attestation --type slsaprovenance ghcr.io/ossfellow/sopseed:{version}
```
