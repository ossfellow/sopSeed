# GitFence OCI Image ([Dockerfile](https://github.com/masoudbahar/gitfence/blob/main/oci/gitfence/Dockerfile))

The GitFence OCI image attempts to achieve the following objectives:

- Be Minimalistic and lightweight.
- Ensure clean builds, by adding [Aqua Security's trivy](https://github.com/aquasecurity/trivy) image vulnerability scanner, which would fail the build, if the OS or any of the utilized packages have known vulnerabilities.
- Set sane defaults, making it usable as an standalone container, or for automation, such as this Helm chart.

The GitFence OCI images are signed by a [sigstore/cosign](https://github.com/sigstore/cosign) key, and the audit trail is stored in its public transparency log. The [public key](https://github.com/masoudbahar/gitfence/blob/main/cosign.pub) could be used to verify the authenticity of the image:

```console
cosign verify -key /path/to/cosign.pub ghcr.io/masoudbahar/gitfence
```

## Interactive Usage Examples

The GitFence OCI image is published to [GitHub](https://github.com/features/packages) and [Docker Hub](https://hub.docker.com) image registries. The examples below assume the Docker Hub hosted image is used:

- Show GPG version

```console
docker run --rm -it masoudbahar/gitfence gpg --version
```

- List GPG keys

```console
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg masoudbahar/gitfence gpg --list-keys
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg masoudbahar/gitfence gpg --list-secret-keys
```

- Generate a GPG key (ed25519/cv25519)<sup>1<sup>

```console
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg masoudbahar/gitfence gpg --quick-gen-key --batch --passphrase ""  "masoudbahar (test key)" future-default default never
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg masoudbahar/gitfence gpg --full-gen-key --expert
```

**1**: ECDSA and RSA keys are supported too, but ECDH (ed25519/cv25519) is preferred.

- Get GPG key fingerprint

```console
KEY_FP=$(docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg masoudbahar/gitfencegpg --with-colons --fingerprint masoudbahar | grep fpr | cut -d ':' -f 10 | head -1)
```

- Export GPG public key

```console
docker run --rm -it -v /local/gpg/keys/store:/home/secops/.gnupg -v $(pwd)/keys:/keys gpg --export --armor "${KEY_FP}"
```

- Show Age version

```console
docker run --rm -it masoudbahar/gitfence age --version
```

- Generate an Age key (X25519)

```console
docker run --rm -it -v /local/age/keys/store:/home/secops/.age masoudbahar/gitfence age-keygen -o /home/secops/.age/agekey.txt
```
