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

## Day 1

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

## Day 2

Skipping day 2 (Weekend)

## Day 3

To my surprice tailscale updated the `resolv.conf` to 

```conf
nameserver 1.1.1.1
nameserver 100.100.100.100
```

Decided to tailscale from docker host to proxmox lxc container. Uninstalled tailscale, rebooted the vm. But still not working.

Went through pihole docker logs for good 2 hours. Pulling my hair at this. Why don't this work. Finally decided to repull the image and update container with new image 

```shell
$ docker pull pihole/pihole:latest
latest: Pulling from pihole/pihole
docker: Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp: lookup registry-1.docker.io on 127.0.0.1:53: no such host.
See 'docker run --help'.
```

Not sure why is this happening, with dig it's working

```shell
$ dig registry-1.docker.io
;
;; QUESTION SECTION:
;registry-1.docker.io.          IN      A

;; ANSWER SECTION:
registry-1.docker.io.   38      IN      A       52.1.184.176
registry-1.docker.io.   38      IN      A       34.194.164.123
registry-1.docker.io.   38      IN      A       18.215.138.58

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;
```

But unable to pull the images from the registry. Let's try with GitHub registry

```
docker pull ghcr.io/pi-hole/pihole:latest
.
.
docker: Error response from daemon: Get https://docker.pkg.github.com/: dial tcp: lookup https://docker.pkg.github.com/ on 127.0.0.1:53: no such host.
See 'docker run --help'.
```
Same error.

Just crossed 12 O'Clock. Burning midnight oil now. Consuming `Thums Up` to stay awake.

Time is now 1:45, barely up, Brains about shutdown. 

Time is now 2:01, i think i found my culprit. For some reason, i was looking at docker compose file and i feel very very dumb now. 

```yaml
dns:
  - 10.20.20.23
  - 1.1.1.1
```

I was running pi-hole on my `Pi Zero W` before. Before retiring that old friend, migrated pi-hole from that to my docker host. Re-used the compose file. IP of that pi was `10.20.20.23`. At that time, that service was still running. Never had any issues after that. `watchtower` was managing the updates. But for some god forsacker reason, After watchtower updated the pi-hole container, problem occured.

Changed the ip to loopback address,

```yaml
dns:
  - 127.0.0.1
  - 1.1.1.1
```

Now everythings fine i think. Pulling images went through. Updated the container. It went through. Let's try updating the gravity.

```
$ docker exec -it pi-hole pihole -g
  [i] Neutrino emissions detected...
  [✓] Pulling blocklist source list into range

  [✓] Preparing new gravity database
  [✓] Creating new gravity databases
  [i] Using libz compression

  [i] Target: https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
  [✓] Status: Retrieval successful
  [✓] Parsed 148940 exact domains and 0 ABP-style domains (ignored 1 non-domain entries)
      Sample of non-domain entries:
        - "0.0.0.0"

  [i] List stayed unchanged

  [i] Target: https://raw.githubusercontent.com/kdpuvvadi/pihole-list/main/ransomeware.txt
  [✓] Status: Retrieval successful
  [✓] Parsed 1904 exact domains and 0 ABP-style domains (ignored 0 non-domain entries)
  [i] List stayed unchanged

  [i] Target: https://raw.githubusercontent.com/kdpuvvadi/pihole-list/main/scams.txt
  [✓] Status: Retrieval successful
  [✓] Parsed 29 exact domains and 0 ABP-style domains (ignored 0 non-domain entries)
  [i] List stayed unchanged

  [i] Target: https://raw.githubusercontent.com/kdpuvvadi/pihole-list/main/blocklist.txt
  [✓] Status: Retrieval successful
  [✓] Parsed 110 exact domains and 0 ABP-style domains (ignored 0 non-domain entries)
  [i] List stayed unchanged

  [i] Target: https://raw.githubusercontent.com/kdpuvvadi/pihole-list/main/tracking.txt
  [✓] Status: Retrieval successful
  [✓] Parsed 50 exact domains and 0 ABP-style domains (ignored 0 non-domain entries)
  [i] List stayed unchanged

  [i] Target: https://github.com/kdpuvvadi/pihole-list/raw/main/firetv.txt
  [✓] Status: Retrieval successful
  [✓] Parsed 14 exact domains and 0 ABP-style domains (ignored 0 non-domain entries)
  [i] List stayed unchanged

  [✓] Building tree
  [✓] Swapping databases
  [✓] The old database remains available
  [i] Number of gravity domains: 151047 (151023 unique domains)
  [i] Number of exact blacklisted domains: 0
  [i] Number of regex blacklist filters: 0
  [i] Number of exact whitelisted domains: 176
  [i] Number of regex whitelist filters: 0
  [✓] Flushing DNS cache
  [✓] Cleaning up stray matter

  [✓] FTL is listening on port 53
     [✓] UDP (IPv4)
     [✓] TCP (IPv4)
     [✓] UDP (IPv6)
     [✓] TCP (IPv6)

  [✓] Pi-hole blocking is enabled
```

It freaking worked.

## Conclusion

Adios, my friends. Adios. I'm big dumb idot. 
