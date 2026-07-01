---
title: "Install Omada SDN Controller on Ubuntu 26.04, Debian 13"
description: "Step-by-step guide to install TP-Link Omada SDN Controller on Ubuntu 26.04 LTS and Debian 13 with notes on MongoDB 7 with error 132 on kvm"
date: "2026-07-01T12:12:20+05:30"
author: kdpuvvadi
tags:
  - ubuntu
  - ubuntu-26.04
  - ubuntu-2604
  - debian-13
  - tp-link
  - sdn
  - mongodb
  - networking
categories: [networking, omada, sdn]
image: /assets/img/install-omada-ubuntu-2604.png
canonical_url: "https://puvvadi.net/posts/omada-sdn-controller-ubuntu-26-04/"
---

Previous guides walked through install Omada Controller on Debian 11 & 12, Ubuntu 20.04, 22.04 and 24.04. Debian 12 is already EOL and Ubuntu 22.04. If you are on Ubuntu 24.04, no need to hurry but if you are going with fresh install, Better to with either Debian 13 or Ubuntu 26.04. Personally, I recomened installing on Debian 13. 

The TP-Link Omada SDN Controller lets you centrally manage access points, switches, and gateways with ease. This guide walks you through installing the latest Omada Controller on Ubuntu 26.04 LTS, covering all required dependencies, installation steps, and verification so you can get your network up and running quickly.

Current version of Omada as of this writing is `6.2.10.17`.

> If are trying to upgrade the Controller please check the instruction at [upgrade-omada-controller](/posts/upgrade-omada-controller). Make sure to adopt the instructions based on your version.
{: .prompt-info }

First update the apt repos and upgrade current packages. I'm Assuming here that Ubuntu 26.04 box or Debian 13 is fresh install and nothing other than preinstalled with distro were installed.

```shell
sudo apt update
sudo apt upgrade -y
```

## Dependencies

For Debian systems, Omada need Java 8 or later, MongoDB 7, JSVC, curl, gnupg.

```shell
sudo apt install wget curl gnupg
```

Omada supports java 8 and above. if you just want to run Omada Controller and be done with that use java 8 otherwise you can go with java 21. Just keep in mind that you might need to troubleshoot errors, compile some packages yourself and did I mention log of troubleshooting.

### java

We are going to be using `openjdk-21 headless` with `jdk` instead of `jre`. 

```shell
sudo apt install openjdk-21-jdk-headless jsvc -y
```

### MongoDB

Omada supports MongoDB v7, let's install `gpg` key for` mongodb-org` `7.0`

```shell
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
```

Now add mongodb-org repo for focal to the source file, create a new source file for mongodb v7 with the following

```shell
sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.sources <<EOF
Types: deb
URIs: https://repo.mongodb.org/apt/ubuntu
Suites: jammy/mongodb-org/7.0
Components: multiverse
Architectures: amd64 arm64
Signed-By: /usr/share/keyrings/mongodb-server-7.0.gpg
EOF
```
{: file='/etc/apt/sources.list.d/mongodb-org-7.0.sources'}

Update your system's package index and install MongoDB 7.0:

```bash
sudo apt update
sudo apt install -y mongodb-org
```

> `MongoDB Error 132`:  On KVM based virtual machines such as proxmox, mangodb service failes to start with error 132 (Missing AES CPU instruction set). To resolve this change the CPU type to `host`
{: .prompt-warning }

Start the Mango Service

```shell
sudo systemctl daemon-reload
sudo systemctl enable --now mongod
```

## Install 

To install the Omada Controller, download the debian `deb` package from TP-Link Omada Download Center. Make sure to grab latest version [here](https://support.omadanetworks.com/us/download/software/omada-controller/)

```shell
curl -L https://static.tp-link.com/upload/software/2026/202604/20260429/Omada_Network_Application_v6.2.10.17_linux_x64_20260428102045.deb --output omada.deb
```

Install the Omada controller. 

```bash
sudo dpkg -i omada.deb
```

It might take 2 to 5 min depending upon your box configuration. Once the installation completed, visit `https://<ip>:8043`

## Post Install

To stop and run the controller

```bash
# stop command
sudo tpeap stop

# start command
sudo tpeap start

# restart command
sudo tpeap restart
```

## Uninstall

To uninstall the Omada controller, follow the prompts by running the following

```bash
sudo apt remove omadac
```

## Conclusion

With Omada SDN Controller now running on Ubuntu 24.04, you have a reliable setup to centrally manage your TP-Link devices. From here, you can secure the controller with HTTPS, configure regular backups, and even automate deployments using Ansible or Docker. Keeping both Ubuntu and Omada updated will ensure long-term stability and security for your network.  

If you run into issues or need further help, feel free to leave a comment on this post or get in touch, i’ll be happy to assist.  

[Au revoir](#conclusion).
