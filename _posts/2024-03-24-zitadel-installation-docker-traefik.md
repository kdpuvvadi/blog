---
title: "Installing Zitadel with Docker behind traefik"
date: "2024-03-18T10:13:30+05:30"
updated: "2024-04-05T14:27:3405:30"
author: kdpuvvadi
tags: [zitadel, openid, docker, vpn, identity]
categories: [zitadel, docker, vpn, identity, OIDC, oAuth]
---

Wanted an Open-Source Self-Hosted Identity provider for my homelab. Tried and tired of lot of them but Zitadel solved lot of my problems. Documentation is bit spotty and as I'm writing this, stable version is having problems with traefik and I'm going with latest version(`v2.48.3`).

## Networks

In my homelab, docker server is running traefik with network `proxy`. We don't need to expose all the containers with same network. They should be running under their own network (In my opinion). 

Create `zitadel` network with

```shell
docker network create zitadel
```

## Volumes

Let's create few directories to store the date persistently.

```shell
mkdir certs zitadel-certs data 
```

## Certificates & Database

zitadel uses `cockroach db` for SQL and it also supports `postgres`. 

### Compose for db & certs

```yaml
services:
  certs:
    image: cockroachdb/cockroach:latest
    container_name: certs
    entrypoint: ["/bin/bash", "-c"]
    command:
      [
        "cp /certs/* /zitadel-certs/ && cockroach cert create-client --overwrite --certs-dir /zitadel-certs/ --ca-key /zitadel-certs/ca.key zitadel_user && chown 1000:1000 /zitadel-certs/*",
      ]
    volumes:
      - ./certs:/certs:ro
      - ./zitadel-certs:/zitadel-certs:rw
    depends_on:
      cockroach-db:
        condition: "service_healthy"
    networks:
      - zitadel

  cockroach-db:
    container_name: cockroach-db
    image: cockroachdb/cockroach:latest
    command: "start-single-node --advertise-addr cockroach-db"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://cockroach-db:8080/health?ready=1"]
      interval: "10s"
      timeout: "30s"
      retries: 5
      start_period: "20s"
    ports:
      - 9090:8080
      - 26257:26257
    volumes:
      - ./certs:/cockroach/certs:rw
      - ./data:/cockroach/cockroach-data:rw
    restart: always
    networks:
      - zitadel
```
{: file='compose.yaml'}

## zitadel

Let's deploy zitadel with docker

### docker compose

```yaml
services:
  zitadel:
    image: ghcr.io/zitadel/zitadel:latest
    container_name: zitadel
    command: 'start-from-init --config /zitadel-config.yaml --config /zitadel-secrets.yaml --steps /zitadel-init-steps.yaml --masterkey "SAcD5TY0QPp89ip28bZPfEA5WDxqmobx" --tlsMode external'
    depends_on:
      certs:
        condition: "service_completed_successfully"
    environment:
      ZITADEL_FIRSTINSTANCE_ORG_HUMAN_USERNAME: ${ZITADEL_FIRSTINSTANCE_ORG_HUMAN_USERNAME}
      ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD: ${ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD}
    ports:
      - 8080:8080
    volumes:
      - ./zitadel-config.yaml:/zitadel-config.yaml:ro
      - ./zitadel-secrets.yaml:/zitadel-secrets.yaml:ro
      - ./zitadel-init-steps.yaml:/zitadel-init-steps.yaml:ro
      - ./zitadel-certs:/crdb-certs:ro
    restart: always
    networks:
      - zitadel
      - proxy
```
{: file='compose.yaml'}

As you can seen here, only zitadel container is exposed to proxy network and zitadel network.

### DNS

I'm running bind9 as my DNS resolver. Let's add DNS records for domain

```zone
id        IN      CNAME   local.puvvadi.net
```
{: file='puvvadi-net.zone'}


Here I'm adding `CNAME` record for `id.puvvadi.net` pointing to `local.puvvadi.net` which is pointed to `traefik` server instance.

One thing I've missed here is no DNS resolver added to compose file and zitadel instance refused to start but throwing non-descriptive errors. 

```yaml
dns:
  - 10.20.20.132
```

### traefik labels

```yaml
- traefik.enable=true
- traefik.http.routers.zitadel.entrypoints=http
- traefik.http.routers.zitadel.rule=Host(`id.domain.net`) || HostRegexp(`{subdomain:[a-z]+}.id.domain.net`)
- traefik.http.middlewares.zitadel-https-redirect.redirectscheme.scheme=https
- traefik.http.routers.zitadel.middlewares=zitadel-https-redirect
- traefik.http.routers.zitadel-secure.entrypoints=https
- traefik.http.routers.zitadel-secure.rule=Host(`id.domain.net`) || HostRegexp(`{subdomain:[a-z]+}.id.domain.net`)
- traefik.http.routers.zitadel-secure.tls=true
- traefik.http.routers.zitadel-secure.service=zitadel
- traefik.http.services.zitadel.loadbalancer.server.scheme=h2c
- traefik.http.services.zitadel.loadbalancer.passHostHeader=true
- traefik.http.services.zitadel.loadbalancer.server.port=8080
- traefik.docker.network=proxy
```

Here we are exposing `id.domain.net` and all the wild card sub domains to traefik. DNS records should be added to your resolver either as wildcard or individual `CNAME` records.

## compose.yaml

```yaml

services:
  zitadel:
    image: ghcr.io/zitadel/zitadel:latest
    container_name: zitadel
     # for ZITADEL_MASTERKEY run tr -dc A-Za-z0-9 </dev/urandom | head -c 32
    command: start-from-init --config /zitadel-config.yaml --config /zitadel-secrets.yaml --steps /zitadel-init-steps.yaml --masterkey ${ZITADEL_MASTERKEY} --tlsMode external
    depends_on:
      certs:
        condition: service_completed_successfully
    environment:
      ZITADEL_FIRSTINSTANCE_ORG_HUMAN_USERNAME: ${ZITADEL_FIRSTINSTANCE_ORG_HUMAN_USERNAME}
      ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD: ${ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD}
    ports:
      - 8080:8080
    volumes:
      - ./zitadel-config.yaml:/zitadel-config.yaml:ro
      - ./zitadel-secrets.yaml:/zitadel-secrets.yaml:ro
      - ./zitadel-init-steps.yaml:/zitadel-init-steps.yaml:ro
      - ./zitadel-certs:/crdb-certs:ro
    labels:
      - traefik.enable=true
      - traefik.http.routers.zitadel.entrypoints=http
      - traefik.http.routers.zitadel.rule=Host(`id.domain.net`) || HostRegexp(`{subdomain:[a-z]+}.id.domain.net`)
      - traefik.http.middlewares.zitadel-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.zitadel.middlewares=zitadel-https-redirect
      - traefik.http.routers.zitadel-secure.entrypoints=https
      - traefik.http.routers.zitadel-secure.rule=Host(`id.domain.net`) || HostRegexp(`{subdomain:[a-z]+}.id.domain.net`)
      - traefik.http.routers.zitadel-secure.tls=true
      - traefik.http.routers.zitadel-secure.service=zitadel
      - traefik.http.services.zitadel.loadbalancer.server.scheme=h2c
      - traefik.http.services.zitadel.loadbalancer.passHostHeader=true
      - traefik.http.services.zitadel.loadbalancer.server.port=8080
      - traefik.docker.network=proxy
    restart: always
    networks:
      - zitadel
      - proxy
    dns:
      - 10.20.20.132 # replace it with local dns resolver
      - 127.0.0.1

  certs:
    image: cockroachdb/cockroach:latest
    container_name: certs
    entrypoint:
      - /bin/bash
      - -c
    command:
      - cp /certs/* /zitadel-certs/ && cockroach cert create-client --overwrite --certs-dir /zitadel-certs/ --ca-key /zitadel-certs/ca.key zitadel_user && chown 1000:1000 /zitadel-certs/*
    volumes:
      - ./certs:/certs:ro
      - ./zitadel-certs:/zitadel-certs:rw
    depends_on:
      cockroach-db:
        condition: service_healthy
    networks:
      - zitadel

  cockroach-db:
    container_name: cockroach-db
    image: cockroachdb/cockroach:latest
    command: start-single-node --advertise-addr cockroach-db
    healthcheck:
      test:  ["CMD", "curl", "-f", "http://cockroach-db:8080/health?ready=1"]
      interval: 10s
      timeout: 30s
      retries: 5
      start_period: 20s
    ports:
      - 9090:8080
      - 26257:26257
    volumes:
      - ./certs:/cockroach/certs:rw
      - ./data:/cockroach/cockroach-data:rw
    restart: always
    networks:
      - zitadel
networks:
  zitadel:
    external: true
  proxy:
    external: true
```
{: file='compose.yaml'}

## config

Let's create few config files from zitadel and only add mandatory items.

Init file

```yaml
# All possible options and their defaults: https://github.com/zitadel/zitadel/blob/main/cmd/setup/steps.yaml
FirstInstance:
  Org:
    Human:
      # use the loginname root@zitadel.domain
      Username: 'root'
      Password: 'RootPassword1!'
```
{: file='zitadel-init-steps.yaml'}

Secrets file

```yaml
# All possible options and their defaults: https://github.com/zitadel/zitadel/blob/main/cmd/defaults.yaml

Database:
  cockroach:
    User:
      # If the user doesn't exist already, it is created
      Username: 'zitadel_user'
    Admin:
      Username: 'root'

```
{: file='zitadel-secrets.yaml'}

and config with certs, custom domain for exposing via traefik etc

```yaml
# All possible options and their defaults: https://github.com/zitadel/zitadel/blob/main/cmd/defaults.yaml
Log:
  Level: 'info'

ExternalSecure: true
ExternalDomain: id.puvvadi.net # change this to your domain
ExternalPort: 443

Database:
  cockroach:
    Host: 'cockroach-db'
    User:
      SSL:
        Mode: 'verify-full'
        RootCert: "/crdb-certs/ca.crt"
        Cert: "/crdb-certs/client.zitadel_user.crt"
        Key: "/crdb-certs/client.zitadel_user.key"
    Admin:
      SSL:
        Mode: 'verify-full'
        RootCert: "/crdb-certs/ca.crt"
        Cert: "/crdb-certs/client.root.crt"
        Key: "/crdb-certs/client.root.key"
```
{: file='zitadel-config.yaml'}

## Secrets

To prevent exposing secrets from exposing when committed into version control system such as git, it is safe to use a `vault` or simply using `.env` file to store the files and adding it to `.gitignore`.

```ini
ZITADEL_MASTERKEY=
ZITADEL_FIRSTINSTANCE_ORG_HUMAN_USERNAME=
ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD=
```
{: file='.env'}

Master can be generated with 

```shell
tr -dc A-Za-z0-9 </dev/urandom | head -c 32
```

Make sure also add username and password for initial user.

## Deploy

To deploy, simply run

```shell
docker compose up -d
```

Now instance is available at `id.puvvadi.net` or domain of your choice. Login with the username and password set in `.env` file.

![zitadel login page](/assets/img/zitadel-login.png){: width="500" height="500" }
_zitadel login page with Google and GitHub oAuth_

## Conclusion
Zitadel can now be used as identity provider for your homelab needs. Make sure to add other ways of login in case of service down as it is only running as single instance not in High Availability mode. We'll explore HA is future. If don't want to Self-Host, Hosted version with free tier is available and it's more than enough for the most Homelabers. [Au revoir](#conclusion).
