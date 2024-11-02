# sopSeed OCI Image ([Dockerfile](https://github.com/ossfellow/sopSeed/blob/main/Dockerfile))

## Features

The sopSeed OCI image provides:

* **Lightweight Design** - Minimal Alpine-based image with essential tools only

* **Security First** - Built-in vulnerability scanning using [Aqua Security's trivy](https://github.com/aquasecurity/trivy), failing builds if security issues are found

* **Production Ready** - Sensible defaults for both interactive use and automation

The sopSeed OCI images are signed and attested using Docker's SBOM and provenance features. The SBOM and provenance can be verified using Docker's built-in tools.

## Interactive Usage Examples

The sopSeed OCI image is published to [GitHub Packages registry](https://github.com/ossfellow/sopSeed/pkgs/container/images/sopseed).

> **Note**: In below examples, replace `{version}` with the desired version tag, e.g., `0.1.0`.

### Show GPG Version

```console
docker run --rm -it ghcr.io/ossfellow/images/sopseed:{version} gpg --version
```

### List GPG keys

```console
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg ghcr.io/ossfellow/images/sopseed:{version} gpg --list-keys
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg ghcr.io/ossfellow/images/sopseed:{version} gpg --list-secret-keys
```

### Generate a GPG key (ed25519/cv25519)

```console
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg ghcr.io/ossfellow/images/sopseed:{version} gpg --quick-gen-key --batch --passphrase "" "masoudbahar (test key)" future-default default never
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg ghcr.io/ossfellow/images/sopseed:{version} gpg --full-gen-key --expert
```

**Note**: ECDSA and RSA keys are supported too, but ECDH (ed25519/cv25519) is preferred.

### Get GPG key fingerprint

```console
KEY_FP=$(docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg ghcr.io/ossfellow/images/sopseed:{version} gpg --with-colons --fingerprint masoudbahar | grep fpr | cut -d ':' -f 10 | head -1)
```

### Export GPG public key

```console
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg -v $(pwd)/keys:/keys ghcr.io/ossfellow/images/sopseed:{version} gpg --export --armor "${KEY_FP}" > keys/public.asc
```

### Show Age version

```console
docker run --rm -it ghcr.io/ossfellow/images/sopseed:{version} age --version
```

### Generate an Age key (X25519)

```console
docker run --rm -it -v /local/age/keys/store:/home/secops/age ghcr.io/ossfellow/images/sopseed:{version} age-keygen -o /home/secops/age/age.agekey
```

### Export Age public key

```console
docker run --rm -it -v /local/age/keys/store:/home/secops/age ghcr.io/ossfellow/images/sopseed:{version} cat /home/secops/age/age.agekey | grep "public key:" | awk '{print $3}'
```

### Verify Image Authenticity

To verify the authenticity of the image using Docker's SBOM and provenance features:

```console
docker sbom ghcr.io/ossfellow/images/sopseed:{version}
docker trust inspect --pretty ghcr.io/ossfellow/images/sopseed:{version}
```
