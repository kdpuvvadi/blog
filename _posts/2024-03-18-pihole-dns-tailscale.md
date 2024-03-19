---
title: "Use local DNS everywhere ft pihole & Tailscale"
date: "2024-03-18T10:13:30+05:30"
author: kdpuvvadi
tags: [dns, pihole, tailscale, vpn, proxmox]
categories: [networking, tailscale, vpn]
---

I've been using Pi-hole for years now and Slowly migrating to [BIND 9](https://www.isc.org/bind/). Recently [migrated](/posts/omada-sdn-controller-ubuntu-22-04/) from [WireGuard](https://www.wireguard.com/) to tailscale for accessing my home network with VPN.

Usually, by simply pointing my DNS records at my internal DNS Resolver. Most probably i'm doing this wrong but that's how I used to do it. With Tailscale's DNS service, it was streamlined.

## tailscale and installation 

First, Install tailscale on the machine running on DNS server. In my case it's Proxmox VM. Tailscale installation instruction can be find [here](https://tailscale.com/kb/installation).

## Connect to tailscale

After Installation and Authentication, Machine get's IP from the [tailnet](https://tailscale.com/kb/1136/tailnet) with `100.64.0.0/10` CGNAT range.

Get the IP of the machine by running(On works on tailscale version 1.8)

```bash
tailscale ip --4
```

## Nameserver

Now, go to `Admin Console` of tailscale and click `DNS` Tab. Scroll down to `Nameservers`. Under `Global nameservers` Click on `Add nameserver` and Select `Custom`. Add your Machine IP address. 

> Make sure to select `Override local DNS`.
{: .prompt-info }

I've local services running on `*.local.puvvadi.net`, `*.dns.puvvadi.net` and `*.host.puvvadi.net`. All the services are running behind `traefik` proxy except for the devices hostname.

> Please use FQDN otherwise issuing certs will be difficult and dns resolution will be bit wonky and might not work on all the devices.
{: .prompt-warning }

## Testing DNS 

### Local Windows Machine

Test laptop is running windows 10 and testing DNS on PowerShell with `Resolve-DnsName`

```powershell
Resolve-DnsName dns.local.puvvadi.net -Server 10.20.20.130

Name                           Type   TTL   Section    NameHost
----                           ----   ---   -------    --------
dns.local.puvvadi.net          CNAME  0     Answer     local.puvvadi.net

Name       : local.puvvadi.net
QueryType  : A
TTL        : 0
Section    : Answer
IP4Address : 10.20.20.130
```

### Local Debian/Linux Machine

and on a `Debian 12` machine with `dig`

```bash
$ dig local.puvvadi.net
;; QUESTION SECTION:
;local.puvvadi.net.             IN      A

;; ANSWER SECTION:
local.puvvadi.net.      0       IN      A       10.20.20.130

;; Query time: 0 msec
;; SERVER: 10.20.20.132#53(10.20.20.132) (UDP)
;; MSG SIZE  rcvd: 62
```

### Remote windows machine

To test outside the network, i'm connecting `Windows 11` machine to `5G` and Test it.

### Tailnet Status

Check tailnet status with 

```powershell
tailscale netcheck

Report:
        * UDP: true
        * IPv4: yes, xxx.xxx.xxx:51533
        * IPv6: no, but OS has support
        * MappingVariesByDestIP: false
        * HairPinning: false
        * PortMapping:
        * CaptivePortal: false
        * Nearest DERP: Bangalore
        * DERP latency:
                - blr: 24ms    (Bangalore)
                - sin: 69ms    (Singapore)
```

### Network Details

And local network details 

```powershell
ipconfig

Ethernet adapter Ethernet 2:

  Connection-specific DNS Suffix  . :
  IPv4 Address. . . . . . . . . . . : 192.168.100.54
  Subnet Mask . . . . . . . . . . . : 255.255.255.0
  Subnet Mask . . . . . . . . . . . : 255.255.0.0
  Default Gateway . . . . . . . . . : 192.168.100.1
```

### DNS Resolving from tailnet

Now test dns with `Resolve-DnsName`

```powershell
Resolve-DnsName dns.local.puvvadi.net -Server 100.106.xxx.xxx

Name                           Type   TTL   Section    NameHost
----                           ----   ---   -------    --------
dns.local.puvvadi.net          CNAME  0     Answer     local.puvvadi.net

Name       : local.puvvadi.net
QueryType  : A
TTL        : 0
Section    : Answer
IP4Address : 10.20.20.130
```

By explicitly using `Server` argument with tailnet IP and response comes from actual dns server running in the home lab which is the same device.

### On mobile

Testing the same with Mobile device on LTE. Device Status

![iPhone 13 connected to tailnet](/assets/img/tailnet-dns.jpg){: width="300" height="300" }
_iPhone 13 connected to tailnet_

Resolving dns on mobile with dig (Dig Deep app)

![](/assets/img/tailnet-dns-dig-mobile.png){: width="500" height="500" }
_iPhone 13 connected to tailnet_

## Conclusion

With this, local DNS can be used anywhere on any network including spotty mobile networks to edge device. All you need is connect to tailnet. [Au revoir](#conclusion).
