# act-images

[![Release](https://github.com/harryzcy/act-images/actions/workflows/release.yml/badge.svg)](https://github.com/harryzcy/act-images/actions/workflows/release.yml)
[![Build](https://github.com/harryzcy/act-images/actions/workflows/build.yml/badge.svg)](https://github.com/harryzcy/act-images/actions/workflows/build.yml)

The image infrastructure for Gitea Action workflows.

This repository provides Docker images that can be used for [act](https://github.com/nektos/act) and [act runner](https://gitea.com/gitea/act_runner). It follows a daily release schedule, and are tags with the following syntax:

- `22.04`, `24.04`: rolling tags, always point to latest build for that OS release
- `22.04-YYYYMMDD`, `24.04-YYYYMMDD`: pinned tags that never changes

## Images

| OS | Image | Installed Packages |
| ----- | ----- | ----- |
| Ubuntu 22.04 | `ghcr.io/harryzcy/ubuntu:22.04` | [images/ubuntu/22.04](images/ubuntu/22.04/README.md) |
| Ubuntu 24.04 | `ghcr.io/harryzcy/ubuntu:24.04` | [images/ubuntu/24.04](images/ubuntu/24.04/README.md) |

## Release Schedule

The images are build and released daily. You can find the releases [here](https://github.com/harryzcy/act-images/pkgs/container/ubuntu).

## Building

```shell
docker build -t ubuntu images/ubuntu/24.04
```

## Contributing

Contributions are welcome, please submit a Pull Request.
