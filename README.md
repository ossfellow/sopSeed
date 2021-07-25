# GitFence

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/masoudbahar/gitfence?style=plastic)](https://github.com/masoudbahar/gitfence/releases) [![GitHub](https://img.shields.io/github/license/masoudbahar/gitfence?style=plastic)](https://github.com/masoudbahar/gitfence/blob/main/LICENSE)
[![Open in Visual Studio Code](https://open.vscode.dev/badges/open-in-vscode.svg)](https://open.vscode.dev/masoudbahar/gitfence)

If [the core idea of GitOps](https://www.gitops.tech/#what-is-gitops) is declarative description of the desired configuration of infrastructure and applications, then wouldn't it make sense to declaratively generate and store keys, used for encryption of sensitive GitOps data?

GitFence does exactly that, in a secure, and minimalistic way.

It creates either a [GPG](https://gnupg.org) key ([ed25519](https://en.wikipedia.org/wiki/EdDSA#Ed25519)/[cv25519](https://en.wikipedia.org/wiki/Curve25519)), or an [Age](https://github.com/FiloSottile/age) key ([X25519](https://en.wikipedia.org/wiki/Curve25519)), inside a Kubernetes cluster, and stores the private and public keys, as [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/). The kubectl command for retrieving the public key is printed to console, when the Helm chart is installed (the retrieval template is in [NOTES.txt](https://github.com/masoudbahar/gitfence/blob/main/templates/NOTES.txt)).

While the Helm chart, or the OCI image, could be used for a variety of use cases, GitFence is primarily built for improving the security and simplicity of encryption key setup, in GitOps pipelines such as [Flux v2](https://fluxcd.io/docs/), for [managing Kubernetes secrets with Mozilla SOPS](https://toolkit.fluxcd.io/guides/mozilla-sops/).

As a security tool, and to promote security best practices, the [Aqua Security's trivy](https://github.com/aquasecurity/trivy) image vulnerability scanner is incorporated into the [Dockerfile](https://github.com/masoudbahar/gitfence/blob/main/oci/gitfence/README.md) image build instructions, which would fail the build, if the OS or any of the utilized packages have known vulnerabilities.

GitFence also comes with multi-tenancy, and multi-arch support.

## Introduction

This chart initiates a [Kubernetes job](https://kubernetes.io/docs/concepts/workloads/controllers/job/), which creates either a GPG key, which is default, or Age key, and stores its private and public keys, as Kubernetes secrets. The notable features of this chart include:

- Execution of the [Init Container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) ensures enough entropy is available, for generation of strong encryption keys.
- GPG and Age keys use Ed25519 and Curve25519, which provide compact, high performance, strong, encryption keys.
- The passphrase is not set, so, the key could be used by tools like [Mozilla SOPS](https://github.com/mozilla/sops).
- Only the Init Container requires privileged access, to use /dev/random, /dev/urandom, and /dev/zero devices. It could be disabled, for complete unprivileged execution.

## Prerequisites

- Kubernetes 1.19+
- Helm 3+
- Privileged execution for adding entropy bits, using rngd daemon (if Init Container is [enabled](https://github.com/masoudbahar/gitfence/blob/main/values.yaml))

## Installing the Chart

To install the chart with the release name `flux-sops`:

```console
~> helm repo add gitfence https://github.com/masoudbahar/gitfence
~> helm install flux-sops gitfence --namespace flux-system --create-namespace --atomic
```

These commands deploy gitfence on your Kubernetes cluster, with the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `flux-sops` chart:

```console
~> helm delete flux-sops --namespace flux-system
```

The command removes all the Kubernetes components associated with the chart and deletes the release. Adding the option `--purge` to the above command would delete all history as well.
> <span style="color:brown"> The generated GPG or Age private and public keys, stored as Kubernetes secrets, are preserved. </span>

## Parameters

The following table lists the configurable parameters of the gitfence chart and their default values.

| Parameter                          | Description                                                  | Default                          |
| ---------------------------------- | ------------------------------------------------------------ | -------------------------------- |
| `global.home`                      | Home directory of the default user; will set GNUPGHOME       | `/home/secops`                   |
| `image.registry`                   | gitfence image registry                                      | `ghcr.io`                      |
| `image.repository`                 | gitfence image name                                          | `masoudbahar/gitfence`           |
| `image.pullPolicy`                 | gitfence image pull policy                                   | `IfNotPresent`                   |
| `image.PullSecrets`                | Image registry secret names as an array                      | `[]`                             |
| `nameOverride`                     | Partially overrides the name of the chart                    | `""`                             |
| `fullnameOverride`                 | Fully overrides the name of the chart                        | `""`                             |
| `resources`                        | CPU and Memory resource requests/limits                      | `{}`                             |
| `initContainers.enabled`           | Whether init container should be executed                    | `true`                           |
| `initContainers.entropyWatermark`  | Minimum available entropy for GPG or Age key generation      | `1024`<sup>1</sup>               |
| `initContainers.timeToLive`        | Limiting the execution time, on slow nodes                   | `10m`                            |
| `gpg.enabled`                      | Whether GPG keys should be created (default)                 | `true`<sup>2</sup>              |
| `gpg.name`                         | Name associated with the generated GPG key                   | `gitops.example.com`             |
| `gpg.comment`                      | Comment added with the generated GPG key                     | `flux SOPS secrets`              |
| `gpg.overwriteKey`                 | Whether previously generated GPG key should be overwritten   | `false`<sup>3</sup>            |
| `age.enabled`                      | Whether Age keys should be created                           | `false`                          |
| `age.overwriteKey`                 | Whether previously generated GPG key should be overwritten   | `false`<sup>3</sup>            |

> **1**: To balance speed and reliability of encryption key generation, set value of entropyWatermark between 2048 and 512.</br>
> **2**: GPG is the default and, irrespective of the value of gpg.enabled, is always selected, unless age.enabled is set to true.</br>
> **3**: If the previous key was used for data encryption, setting overwriteKey to true could make such data inaccessible.</br>

Overwrite the default parameters using the `--set key=value[,key=value]` argument of `helm install`. For example:

```console
~> helm install flux-sops --set initContainers.entropyWatermark=512 gitfence --namespace flux-system --create-namespace --atomic
```

Alternatively, provide a YAML file that specifies the values for the parameters while installing the chart. For example:

```console
~> helm install flux-sops -f gpg-values.yaml gitfence --namespace flux-system --create-namespace --atomic
```

> **Tip**: You can use the default [values.yaml](https://github.com/masoudbahar/gitfence/blob/main/values.yaml)
