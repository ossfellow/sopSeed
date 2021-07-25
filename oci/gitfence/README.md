# GitFence OCI Image ([Dockerfile](https://github.com/masoudbahar/gitfence/blob/main/oci/gitfence/Dockerfile))

The GitFence OCI image attempts to achieve the following objectives:

- Be Minimalistic and lightweight.
- Ensure build security, by adding [Aqua Security's trivy](https://github.com/aquasecurity/trivy) image vulnerability scanner, which would fail the build, if the OS or any of the utilized packages have known vulnerabilities.
- Set sane defaults, making it usable as an standalone container, or for automation, such as this Helm chart.

## Interactive Usage Examples

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
