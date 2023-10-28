---
layout: post
title: Troubleshooting pihole gravity update
date: 2023-10-28 14:30 +0530
# image:
tags: [pi-hole, dns, troubleshoot, tailscale]
categories: [pi-hole, dns, troubleshoot, tailscale]
authors: [kdpuvvadi]
---

I've been running [pi-hole](https://pi-hole.net/) as DNS server for my homelab for years now. Never had any with it. Started on [Pi Zero](https://www.raspberrypi.com/products/raspberry-pi-zero/) with Ethernet and a SD card to currently running on docker in Proxmox Cluster.

But since couple of days, unable to update the ad list with gravity. But DNS resolution is working and also blocking of existing list is working. But updating is throwing errors as `DNS resolution is currently unavailable` when i try to update the gravity from GUI. Counts down 120 and shows `DNS resolution is not available` after that.

```shell
[✗] DNS resolution is currently unavailable
[✗] DNS resolution is not available
```

Tried doing same with docker exec shell. 

```shell
$ docker exec -it pi-hole pihole -g
[✗] DNS resolution is currently unavailable
[✗] DNS resolution is not available
```

Recently switched my VPN from WireGuard to tailscale. I should have installed tailscale on the Proxmox lxc container. I was lazy and installed on the docker host. Regarding DNS issues, There are numerous on tailscale's GitHub repo sunch as this issue [#3817](https://github.com/tailscale/tailscale/issues/3817) stating resolver at `/etc/resolv.conf` stuck at `100.100.100.100`(tailscale's DNS resolver). I've checked the contents of the `/etc/resolv.conf` on the host vm.

```conf
nameserver 127.0.0.1
nameserver 100.100.100.100
nameserver tailnet....
```
{: file="/etc/resolv.conf" }

Removed all the contents of `resolv.conf` and rebooted the vm. After reboot, only added cloudflare's DNS server as the nameserver and rebooted.

```conf
nameserver 1.1.1.1
```
{: file="/etc/resolv.conf" }

Still the same error. It should work but, No. 

```shell
$ docker exec -it pi-hole pihole -g
[✗] DNS resolution is currently unavailable
[✗] DNS resolution is not available
```

Let's continue this tomorrow. Wifi still works for the wife. So, no urgency from that end. I can still add domains manually.

