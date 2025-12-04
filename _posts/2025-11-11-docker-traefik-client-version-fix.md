---
title: "Docker v29, Fix: Traefik Error — Client Version Too Old"
description: "Fix 'Error response from daemon: client version 1.24 is too old. Minimum supported API version is 1.44' when Traefik fails to connect to Docker. Quick fix for Traefik failing with ‘client version 1.24 is too old’ after Docker update"
date: 2025-11-11
updated: 2025-11-11
author: kdpuvvadi
tags: ["docker", "traefik", "fix", "devops"]
categories: ["infrastructure", "devops"]
image: "/assets/img/docker-traefik-issue.png"
canonical_url: "https://puvvadi.net/blog/docker-traefik-client-version-fix"
---

After a recent Docker update, Traefik started failing to connect to the Docker daemon and shows this error:

```shell
Error response from daemon: client version 1.24 is too old. Minimum supported API version is 1.44, please upgrade your client to a newer version" providerName=docker
```

This happens because Docker now expects a higher minimum API version, while Traefik is still using an older one.

### Solution

Edit the Docker service configuration:

```shell
sudo systemctl edit docker.service
```

Add the following lines above the line `### Lines below this comment will be discarded:`

```conf
[Service]
Environment=DOCKER_MIN_API_VERSION=1.24
```

Save and exit the editor, then restart Docker:

```shell
sudo systemctl restart docker
```

## Update 

> traefik released new version `v3.6.x` with Docker API version auto negotiation. Just bump the version of treafik deployment to `v3.6.x`.
{: .prompt-info }
