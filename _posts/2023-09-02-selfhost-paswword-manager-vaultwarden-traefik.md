---
layout: post
title: Selfhosted password manager with Vaultwarden and Traefik
date: 2023-09-02 11:44 +0530
image: /assets/img/vaultwarden-selfhosted.webp
tags: 
  - vaultwarden
  - docker
  -  proxy
  - traefik
categories: 
  - password-manager
  - self-hosted
  - traefik
  - docker
authors:
  - kdpuvvadi
description: Selfhosted Vaultwarden behind traefik proxy with automated ssl tls certificate management and access the secure password manager over https  
---

Vaultwarden is light weight feature rich drop in replacement for Bitwarden server. It's essentially debloated version of the Bitwarden.

To use Vaultwarden, SSL is required. Otherwise, singing in to the server is impossible. That's where traefik comes in. Here I'm assuming you have a domain, cloudflare account & domain added to your account, and docker is already set up and ready to go.

## Cloudflare

Please keep cloudflare's `Email`, `API KEY` or `API TOKEN` ready.

## Traefik setup

Create required files

### directory structure

```shell
touch compose.yaml
touch config.yaml
mkdir data && cd data
touch acme.json
touch traefik.yaml
```

Directory structure should be like this

```shell
|── compose.yaml
├── config.yaml
└── data
    ├── acme.json
    └── traefik.yaml
```

### Docker network

Create a network with following 

```shell
docker network create -d bridge proxy
```

### Docker compose

First open `compose.yaml`  and add following

```yaml
services:
  traefik:
    image: traefik:latest
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    ports:
      - 80:80
      - 443:443
    dns:
      - 1.1.1.1
      - 8.8.8.8
    environment:
      - CF_API_EMAIL=email@example.com
    # - CF_API_KEY= # use either api key or api token based on you usecase
    #   - CF_API_TOKEN=
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /home/user/traefik/data/traefik.yaml:/traefik.yaml:ro
      - /home/user/traefik/data/acme.json:/acme.json
      - /home/user/traefik/config.yaml:/config.yaml:ro
    labels:
      - "traefik.enable=true"
      # http entrypoint
      - "traefik.http.routers.traefik.entrypoints=http"
      # Dashboard
      - "traefik.http.routers.traefik.rule=Host(`traefik.internal.example.net`)"
      # To create a user:password pair, the following command can be used:
      # echo $(htpasswd -nb user password) | sed -e s/\\$/\\$\\$/g
      - "traefik.http.middlewares.traefik-auth.basicauth.users=<user & password>"
      # redirect middleware
      - "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.http.routers.traefik.middlewares=traefik-https-redirect"
      # https entrypoint
      - "traefik.http.routers.traefik-secure.entrypoints=https"
      - "traefik.http.routers.traefik-secure.rule=Host(`traefik.internal.example.net`)"
      - "traefik.http.routers.traefik-secure.middlewares=traefik-auth"
      - "traefik.http.routers.traefik-secure.tls=true"
      - "traefik.http.routers.traefik-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.traefik-secure.tls.domains[0].main=internal.example.net"
      - "traefik.http.routers.traefik-secure.tls.domains[0].sans=*.internal.example.net"
      - "traefik.http.routers.traefik-secure.service=api@internal"

networks:
  proxy:
    external: true
```
{: file="compose.yaml" .nolineno }

> DNS records should already pointed to you docker host. e.g. if docker host ip is `10.20.20.5` A record for `traeif.internal` should point to `10.20.20.5`.
{: .prompt-info }

### traefik config

```yml
api:
  dashboard: true
  debug: true
entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
  https:
    address: ":443"
serversTransport:
  insecureSkipVerify: true
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    filename: /config.yml
certificatesResolvers:
  cloudflare:
    acme:
      email: email@example.net
      storage: acme.json
      dnsChallenge:
        provider: cloudflare
        disablePropagationCheck: true
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"
```
{: file="data/traefik.yaml" .nolineno}

To spin up the traefik docker container, run

```shell
docker compose up -d
```

Once docker container created, traefik will generate ssl certs for `internel.example.net` & wildcard cert for `*.internel.example.net`. traefik dashboard will be available at `traefik.internal.example.net`.

## Vaultwarden


### Volume

I'm using named volumes here for the sake. You can use any directory on the host and bind that. 

```shell
docker volume create vaultwarden
```

Reason for creating volume outside the compose file, in case, container destroyed with `rm`, data would be still available from the volume.

### Docker compose

Create a new directory in your home `vaultwarden` and add new file `compose.yaml`. 


```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    user: root
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - vaultwarden:/data
    environment:
      - DOMAIN=https://vaultwarden.internal.example.net
      - SMTP_HOST=smtp.example.com
      - SMTP_FROM=email@example.com
      - SMTP_FROM_NAME=Vaultwarden
      - SMTP_SECURITY=SECURITYMETHOD
      - SMTP_PORT=XXXX
      - SMTP_USERNAME=email@example.com
      - SMTP_PASSWORD=YourReallyStrongPasswordHere
      - SMTP_AUTH_MECHANISM="Mechanism"
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=proxy"
      - "traefik.http.routers.vaultwarden.entrypoints=https"
      - "traefik.http.routers.vaultwarden.rule=Host(`https://vaultwarden.internal.example.net`)"
      - "traefik.http.routers.vaultwarden-http.middlewares=redirect-https"
      - "traefik.http.routers.vaultwarden.tls=true"
      - "traefik.http.routers.vaultwarden.service=vaultwarden"
      - "traefik.http.services.vaultwarden.loadbalancer.server.scheme=http"
      - "traefik.http.services.vaultwarden.loadbalancer.server.port=80"

networks:
  proxy:
    external: true

volumes:
  vaultwarden:
    external: true
```
{: file='compose.yaml' .nolineno }

> dns records should already pointed to you docker host. e.g. if docker host ip is `10.20.20.5` A record for `vaultwarden.internal` should point to `10.20.20.5`.
{: .prompt-info }

> in the previouse version of the guide, websocket service for vaultwarden was running on different port and that is not required anymore. Hence, removed. Read more [here](https://github.com/dani-garcia/vaultwarden/issues/4024)
{: .prompt-info }

To spin up the vaultwarden docker container, run

```shell
docker up -d
```

Vaultwarden should now be available at the given `FQDN` and can be accessed from the network. 

## Conclusion

For more details and documentation, visit Official [github](https://github.com/dani-garcia/vaultwarden) repo. Any queries, feel free to drop a comment. `Au Revoir`.
