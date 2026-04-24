---
layout: post
title: Self-Hosting GitHub alternative Forgejo with SSH access
date: 2026-04-24 12:39 +0530
description: Learn how to self-host Forgejo on a Debian LXC with valid HTTPS. This guide covers using Caddy with the Cloudflare DNS-01 challenge to get SSL on private IPs without exposing your homelab to the internet and git operations with ssh with Openssh passthough.
image:
categories: [Homelab, DevOps]
tags: [Forgejo, Debian, Caddy, SSL, Cloudflare, LXC, Self-Hosting, Git, GitHub, Gitea, ssh]
---

In this guide, we’re going to walk through setting up `Forgejo`—the community-driven fork of Gitea—on a `Debian` LXC container. To keep it professional and accessible over a local network with valid HTTPS, we’ll use `Caddy` with a `Cloudflare` DNS challenge. 

This setup is ideal for a homelab environment where your instance lives on a private IP (like `10.20.20.x`) but you still want a "green padlock" without exposing your container to the public internet. If you want, you can access the instance from anywhere with `tailscale`.

## Server Setup

First, update your Debian LXC and install the base dependencies. We’ll use `SQLite` for the database to keep the footprint minimal.

```bash
apt update && apt upgrade -y
apt install -y git sqlite3 gnupg2 curl wget
```

Create a dedicated system user `git` for Forgejo:

```bash
adduser --system --shell /bin/bash --group --disabled-password --home /home/git git
```

## Installing Forgejo

We’ll fetch the latest binary directly from Codeberg to ensure we are on the cutting edge.

```bash
# Fetch latest version tag and download binary
LATEST_VERSION=$(curl -s https://codeberg.org/api/v1/repos/forgejo/forgejo/releases | grep -oP '"tag_name":\s*"\K[^"]+' | head -n 1)

# Download the binary
wget -O /usr/local/bin/forgejo https://codeberg.org/forgejo/forgejo/releases/download/${LATEST_VERSION}/forgejo-${LATEST_VERSION#v}-linux-amd64

# make the binary executable
chmod +x /usr/local/bin/forgejo

# Create directory structure
mkdir -p /var/lib/forgejo/{custom,data,log}
mkdir /etc/forgejo
chown -R git:git /var/lib/forgejo/
chown root:git /etc/forgejo
chmod -R 750 /var/lib/forgejo/
chmod 770 /etc/forgejo
```

### The Systemd Service

Create `/etc/systemd/system/forgejo.service`:

```ini
[Unit]
Description=Forgejo
After=network.target

[Service]
User=git
Group=git
WorkingDirectory=/var/lib/forgejo/
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/forgejo/
ExecStart=/usr/local/bin/forgejo web -c /etc/forgejo/app.ini
Restart=always

[Install]
WantedBy=multi-user.target
```
{: file="/etc/systemd/system/forgejo.service" }

## Configuring SSH

Instead of using Forgejo's built-in SSH server on a custom port, we’ll use the system’s OpenSSH's Port `22` for a cleaner experience.

### ssh directory setup

Ensure the `.ssh` directory exists for the `git` user:

```bash
mkdir -p /home/git/.ssh
chmod 700 /home/git/.ssh
touch /home/git/.ssh/authorized_keys
chmod 600 /home/git/.ssh/authorized_keys
chown -R git:git /home/git/.ssh
```

## Configuration Settings

Start Forgejo and Run Web Installer

```bash
systemctl daemon-reload
systemctl enable --now forgejo
```

Now, find your LXC's IP address (ip addr) and navigate to it in your browser: `http://<LXC_IP>:3000`

Set following as the configuration in the web installer

- Database Type: `SQLite3`
- Path: `/var/lib/forgejo/data/forgejo.db` (Ensure the git user has write access here).
- Repository Root Path: `/home/git/forgejo-repositories`
- Run As Username: `git`

Do not forget to create a admin account. 

> If you are using Proxmox or a similar hypervisor for your LXC, SQLite is fine for small teams/personal use, but ensure your LXC storage backend (ZFS, LVM, etc.) is reliable. If you plan to store many large repositories, consider adding a mount point to the LXC from your main storage pool to keep the root disk slim.
{: .prompt-info }

After web installer isdone and login with admin credentials, go to **Site Admin > Dashboard > Maintenance operations** and click **"Update the `.ssh/authorized_keys` file with Forgejo SSH keys."**. This allows Forgejo to manage SSH keys through the Web UI while using the system daemon.

## Caddy setup

Since our LXC is on a private IP, standard HTTP validation will fail. We need to build Caddy with the Cloudflare DNS plugin.

### Install Go & xcaddy

```bash
# Install Go (latest stable)
wget https://go.dev/dl/go1.26.1.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.26.1.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin

# Install xcaddy and build
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1G 'https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-xcaddy-archive-keyring.gpg
curl -1G 'https://dl.cloudsmith.io/public/caddy/xcaddy/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-xcaddy.list
apt update && apt install xcaddy

# Build caddy with xcaddy and cloudflare plugin
xcaddy build --with github.com/caddy-dns/cloudflare
mv caddy /usr/bin/caddy
```

### Configure Caddyfile

Edit `/etc/caddy/Caddyfile`

```
git.example.com {
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        propagation_delay 2m
        resolvers 1.1.1.1
    }
    reverse_proxy localhost:3000
}
```
{: file="/etc/caddy/Caddyfile" }

> Note: Use `systemctl edit caddy` to add your `CLOUDFLARE_API_TOKEN` as an environment variable.
{: .prompt-info }

## Finalizing Forgejo Config

Update `/etc/forgejo/app.ini` to reflect your new domain and HTTPS status:

```ini
[server]
PROTOCOL         = http
DOMAIN           = git.example.com
ROOT_URL         = https://git.example.com/
HTTP_ADDR        = 127.0.0.1
HTTP_PORT        = 3000
SSH_DOMAIN       = git.example.com
SSH_PORT         = 22
```
{: file="/etc/forgejo/app.ini" }

Restart your services:

```bash
systemctl restart forgejo
systemctl restart caddy
```

You can access `forgejo` 

## Conclusion
You now have a production-ready Forgejo instance. By combining the simplicity of SQLite with the power of Caddy's automatic SSL, you've built a robust git environment that respects privacy and follows best practices for homelab networking. 

Happy forging!
