# sopSeed

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/ossfellow/sopSeed?style=plastic)](https://github.com/ossfellow/sopSeed/releases) [![GitHub](https://img.shields.io/github/license/ossfellow/sopSeed?style=plastic)](https://github.com/ossfellow/sopSeed/blob/main/LICENSE)
[![Open in Visual Studio Code](https://img.shields.io/badge/Open%20in%20VS%20Code-blue?logo=visual-studio-code)](https://open.vscode.dev/ossfellow/sopSeed)

## Purpose

sopSeed enhances the security and simplicity of encryption key setup in GitOps pipelines, such as [Flux v2](https://fluxcd.io/docs/) and [ArgoCD](https://argo-cd.readthedocs.io/), by generating and storing encryption keys directly within a Kubernetes cluster. It supports both [GPG](https://gnupg.org) keys ([ed25519](https://en.wikipedia.org/wiki/EdDSA#Ed25519)/[cv25519](https://en.wikipedia.org/wiki/Curve25519)) and [Age](https://github.com/FiloSottile/age) keys ([X25519](https://en.wikipedia.org/wiki/Curve25519)).

## Key Features

- **Secure Key Generation**: Generates GPG or Age keys inside a Kubernetes cluster and stores them as [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/).
- **GitOps Integration**: Ideal for use with GitOps pipelines, such as Flux v2 and ArgoCD, for managing Kubernetes secrets with CNCF SOPS.
- **Minimalistic and Lightweight**: Ensures clean builds with [Aqua Security's trivy](https://github.com/aquasecurity/trivy) image vulnerability scanner.
- **Authenticity**: Guarantees the authenticity of OCI images using Docker's SBOM and provenance features.
- **Multi-Tenancy and Multi-Arch Support**: Supports multiple tenants and architectures.

## Introduction

This chart initiates a [Kubernetes job](https://kubernetes.io/docs/concepts/workloads/controllers/job/) to create either a GPG key (default) or an Age key and stores the private and public keys as Kubernetes secrets. Notable features include:

- **Strong Encryption**: Uses Ed25519 and Curve25519 for GPG and Age keys, providing compact, high-performance, strong encryption keys.
- **Passphrase-Free**: Keys are generated without a passphrase, making them suitable for tools like [CNCF SOPS](https://github.com/mozilla/sops).
- **.sops.yaml Generation**: Automatically generates a `.sops.yaml` file covering Talos and Kubernetes-related secret encryption patterns, printed out in the `NOTES.txt` after chart installation.

## Prerequisites

- Kubernetes 1.27+
- Helm 3.8+

## Installing the Chart

To install the chart with the release name `sopseed-gpg`:

```console
~> helm repo add sopSeed https://github.com/ossfellow/sopSeed
~> helm upgrade --install \
    sopseed-gpg \
    --namespace flux-system \
    --create-namespace \
    --values https://raw.githubusercontent.com/ossfellow/sopSeed/main/chart/values.yaml \
    oci://ghcr.io/ossfellow/sopSeed:{version} \
    --dependency-update \
    --atomic
```

This will create an ed25519/cv25519 GPG key and store it as a Kubernetes secret, named `sopseed-gpg` in the `flux-system` namespace. The output of the installation will include the `.sops.yaml` file, which can be used to encrypt Talos, and Kubernetes secrets in your GitOps repository.

You can pass the `global.sopsMasterPubKey` value to the helm chart installation command to get a ready-to-use `.sops.yaml` for the targeted k8s cluster. Adding a secondary encryption key is a best practice to ensure, in the event of cluster SOPS key loss, the master key can still decrypt the secrets.

> Whenever needed, you can see the output of the helm installation command by running `helm get notes sopseed-gpg`.
>
> Please replace `{version}` with the desired chart version (e.g., `0.1.0`), before running the helm installation command.

### Verify Image Authenticity

To verify the authenticity of the image using Docker's SBOM and provenance features:

```console
docker sbom ghcr.io/ossfellow/sopSeed:{version}
docker trust inspect --pretty ghcr.io/ossfellow/sopSeed:{version}
```

## Using the sopSeed OCI Image Directly

If you prefer to use the sopSeed OCI image directly for generating and managing GPG and Age keys without deploying the Helm chart, please refer to its [README](./helpers/README.md) file. It provides detailed instructions and usage examples for interacting with the image in standalone mode.

## Helm Values

The following table lists the configurable parameters of the sopSeed chart and their default values.

| Parameter                          | Description                                                  | Default                          |
| ---------------------------------- | ------------------------------------------------------------ | -------------------------------- |
| `global.home`                      | Home directory of the default user; will set GNUPGHOME       | `/home/secops`                   |
| `global.sopsMasterPubKey`          | SOPS master public key for the targeted k8s cluster          | `"YOUR SOPS MASTER PUBLIC KEY"`  |
| `image.registry`                   | sopSeed image registry                                       | `ghcr.io`                        |
| `image.repository`                 | sopSeed image name                                           | `ossfellow/sopSeed`              |
| `image.pullPolicy`                 | sopSeed image pull policy                                    | `IfNotPresent`                   |
| `image.PullSecrets`                | Image registry secret names as an array                      | `[]`                             |
| `nameOverride`                     | Partially overrides the name of the chart                    | `""`                             |
| `fullnameOverride`                 | Fully overrides the name of the chart                        | `""`                             |
| `resources`                        | CPU and Memory resource requests/limits                      | `{}`                             |
| `initContainers.enabled`           | Whether init container should be executed                    | `true`                           |
| `initContainers.entropyWatermark`  | Minimum available entropy for GPG or Age key generation      | `1024`<sup>1</sup>               |
| `initContainers.timeToLive`        | Limiting the execution time, on slow nodes                   | `10m`                            |
| `gpg.enabled`                      | Whether GPG keys should be created (default)                 | `true`<sup>2</sup>               |
| `gpg.name`                         | Name associated with the generated GPG key                   | `gitops.example.com`             |
| `gpg.comment`                      | Comment added with the generated GPG key                     | `sopSeed GPG key`                |
| `gpg.overwriteKey`                 | Whether previously generated GPG key should be overwritten   | `false`<sup>3</sup>              |
| `age.enabled`                      | Whether Age keys should be created                           | `false`                          |
| `age.overwriteKey`                 | Whether previously generated GPG key should be overwritten   | `false`<sup>3</sup>              |

> **1**: To balance speed and reliability of encryption key generation, set value of entropyWatermark between 2048 and 512.</br>
> **2**: GPG is the default and, irrespective of the value of gpg.enabled, is always selected, unless age.enabled is set to true.</br>
> **3**: If the previous key was used for data encryption, setting overwriteKey to true could make such data inaccessible.</br>
