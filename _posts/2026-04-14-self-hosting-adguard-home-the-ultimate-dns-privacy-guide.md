---
layout: post
title: 'Self-Hosting AdGuard Home: The Ultimate DNS Privacy Guide'
date: 2026-04-14 14:58 +0530
description:
image:
category:
tags:
---


I’m a big advocate for taking back control of your network traffic. Today, we’re moving beyond standard DNS.

We are deploying **AdGuard Home** inside an LXC container on Proxmox. We’ll be using Docker Compose for the deployment and, most importantly, securing our queries with **DNS-over-TLS (DoT)** and **DNS-over-HTTPS (DoH)** using the domain `guard.dns.puvvadi.net`.

### Why AdGuard Home?

While Pi-hole is classic, AdGuard Home provides a more modern UI and native support for encrypted DNS protocols without needing extra proxies like Cloudflared or Unbound.

### Prerequisites

* A Proxmox LXC container (Ubuntu/Debian).
* Docker and the latest Docker Compose installed.
* A domain (we're using `puvvadi.net`).
* Your local DNS records managed (mine are at `10.10.10.10` via Bind9).

### 1. Obtaining SSL Certificates (DNS-01 Challenge)

To run DoH or DoT, you need valid SSL certificates. Since this is a homelab, we’ll use the **DNS-01 challenge**. This allows Let’s Encrypt to verify ownership via a DNS `TXT` record, so you don't have to open port 80 to the internet.

I use Cloudflare for my DNS. Here’s the quick setup:

1.  **Install Certbot:**

    ```bash
    apt update && apt install certbot python3-certbot-dns-cloudflare
    ```

2.  **Configure Credentials:**

    Create `/etc/letsencrypt/cloudflare.ini` and add your API token:

    ```ini
    dns_cloudflare_api_token = YOUR_CLOUDFLARE_API_TOKEN
    ```

    Change permissions 600 for less acceseble. 

    `chmod 600 /etc/letsencrypt/cloudflare.ini`

3.  **Fetch the Cert:**

    ```bash
    certbot certonly --dns-cloudflare \
      --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
      -d guard.dns.puvvadi.net
    ```

### 2. The Docker Compose Setup

Now, let’s define our service. Note that we are mounting the Let's Encrypt folders directly so AdGuard can access the certificates.

```yaml
services:
  adguardhome:
    image: adguard/adguardhome:latest
    container_name: adguardhome
    restart: unless-stopped
    volumes:
      - ./work:/opt/adguardhome/work
      - ./config:/opt/adguardhome/conf
      - /etc/letsencrypt:/opt/adguardhome/ssl:ro
    network_mode: host
    dns:
      - 127.0.0.1
      - 10.10.10.10
```

Deploy with: `docker compose up -d`


### 3. Split DNS with Bind9

Since my internal lab records live on a **Bind9** instance at `10.10.10.10`, we need AdGuard to respect those while still blocking ads.

1.  Open the UI at `https://guard.dns.puvvadi.net`.
2.  Go to **Settings -> DNS Settings**.
3.  In **Upstream DNS Servers**, add your local resolver for our domain:

    ```dns
    [/puvvadi.net/]10.10.10.10
    [/10.in-addr.arpa/]10.10.10.10
    https://dns.cloudflare.com/dns-query
    ```

### 4. Enabling DoT and DoH

Finally, let's encrypt the traffic. Navigate to **Settings -> Encryption Settings**.

* **Enable Encryption:** Checked.
* **Server Name:** `guard.dns.puvvadi.net`
* **Certificates:** Use the paths we mapped in the volumes:
    * **Certificate path:** `/opt/adguardhome/ssl/live/guard.dns.puvvadi.net/fullchain.pem`
    * **Private key path:** `/opt/adguardhome/ssl/live/guard.dns.puvvadi.net/privkey.pem`

Once you hit save, AdGuard Home will begin listening for encrypted queries on ports 443 and 853.

### 5. Testing the Setup with Doggo

Once everything is up and running, you shouldn't just assume it’s working. Let’s use `doggo` to test our new encrypted endpoints.

#### Install Doggo

If you don't have it yet, you can grab the latest version

```bash
go install github.com/mr-karan/doggo/cmd/doggo@latest
```

#### Test DNS-over-TLS (DoT)
Run a query against your new server on port 853. We’ll use the --tls-hostname flag to ensure the certificate matches.

```bash
$ doggo google.com @tls://guard.dns.puvvadi.net
NAME         TYPE  CLASS  TTL    ADDRESS                 NAMESERVER
google.com.  A     IN     2163s  142.250.207.142         guard.dns.puvvadi.net:853
google.com.  AAAA  IN     2163s  2404:6800:4003:c05::64  guard.dns.puvvadi.net:853
google.com.  AAAA  IN     2163s  2404:6800:4003:c05::71  guard.dns.puvvadi.net:853
google.com.  AAAA  IN     2163s  2404:6800:4003:c05::66  guard.dns.puvvadi.net:853
google.com.  AAAA  IN     2163s  2404:6800:4003:c05::8b  guard.dns.puvvadi.net:853
```

#### Test DNS-over-HTTPS (DoH)

To test the HTTPS endpoint, simply point doggo to your resolver URL:

```bash
$ doggo google.com @https://guard.dns.puvvadi.net/dns-query
NAME         TYPE  CLASS  TTL    ADDRESS                 NAMESERVER
google.com.  A     IN     1609s  142.250.207.142         https://guard.dns.puvvadi.net/dns-query
google.com.  AAAA  IN     1609s  2404:6800:4003:c05::64  https://guard.dns.puvvadi.net/dns-query
google.com.  AAAA  IN     1609s  2404:6800:4003:c05::71  https://guard.dns.puvvadi.net/dns-query
google.com.  AAAA  IN     1609s  2404:6800:4003:c05::66  https://guard.dns.puvvadi.net/dns-query
google.com.  AAAA  IN     1609s  2404:6800:4003:c05::8b  https://guard.dns.puvvadi.net/dns-query
```

#### Test Local Record Resolution

Finally, verify that AdGuard is correctly talking to your Bind9 instance (10.10.10.10) by querying a local homelab record:

```bash
$ doggo home.puvvadi.net @https://guard.dns.puvvadi.net/dns-query -t A
NAME               TYPE  CLASS  TTL     ADDRESS      NAMESERVER
home.puvvadi.net.  A     IN     80540s  10.20.20.68  https://guard.dns.puvvadi.net/dns-query
```

If you see your internal IP returned in the "Answers" section, congratulations! Your split-DNS setup is fully operational and secured.

### Conclusion

Your homelab now has a centralized, privacy-respecting DNS gateway. No more ISP snooping, and no more ads—all while keeping your local hostnames resolvable. 

[Au revoir](#conclusion).
