---
layout: post
title: Home Assistant Reverse Proxy with Traefik
date: 2023-09-29 12:09 +0530
image: 
tags: [traefik, homeassistant, proxy]
categories: [homeassistant, proxy, traefik]
authors: [kdpuvvadi]
---

This post assumes `Traefik` is up and running on the docker and `Home Assistant` is running on another host on a VM. 

## Traefik 

### file config

Traefik `providers` config should looks like this in `traefik.yml`

```yml
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    directory: /config
    watch: true
```
{: file="traefik/traefik.yml" }

### docker-compose volumes 

```yml
volumes:
    - /etc/localtime:/etc/localtime:ro
    - /var/run/docker.sock:/var/run/docker.sock:ro
    - /home/user/traefik/traefik.yml:/traefik.yml:ro
    - /home/user/traefik/data/acme.json:/acme.json
    - /home/user/traefik/data/config:/config:ro
```
{: file="traefik/docker-compose.yml" }

traefik would watch any change of files in `traefik/data/config` (Mounted at `/config` directory inside the traefik container) and make changes accordingly.

## Home Assistant

### traefik config

Create a new file `hass.yml` at `/home/user/traefik/data/config/` with the following

```yml
http:
  routers:
    ha-router:
      entryPoints:
        - "https"
      service: ha-service
      rule: "Host(`hass.example.net`)"
      tls: {}
      middlewares:
        - default-headers
        - https-redirect
  services:
    ha-service:
      loadBalancer:
        servers:
          - url: http://10.20.20.23:8123

  middlewares:
    https-redirect:
      redirectScheme:
        scheme: https
        permanent: true

    default-headers:
      headers:
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 15552000
        customFrameOptionsValue: SAMEORIGIN
        customRequestHeaders:
          X-Forwarded-Proto: https

    default-whitelist:
      ipWhiteList:
        sourceRange:
        - "10.0.0.0/8"
        - "192.168.0.0/16"
        - "172.16.0.0/12"
        - "100.64.0.0/10"

    secured:
      chain:
        middlewares:
        - default-headers
```
{: file="traefik/data/config/hass.yml" }


Make necessary changes such as `url`, `ip` of the `Home Assistant` and `ipWhiteList` according to your network. Headers are curtesy of [Techno Time](https://technotim.live/). 

home assistant will be available are the given url e.g. `hass.example.net`. But hass throws `Bad Request` error. Reason being it only allows reverse proxying from whitelisted ip ranges.

### configuration

Add following `http` config to `configuration.yaml`

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 10.20.20.0/24
    - 192.168.0.0/24
    - 172.30.33.0/24
```
{: file="configuration.yaml" }

Please add required networks and docker network both to the `trusted_proxies` and restart the hass instance.

After few minutes `Home Assistant` will be available at `https:?/hass.example.net`.

## Conclusion

Any queries, feel free to drop a comment. `Au Revoir`.
