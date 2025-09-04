---
title: "Install Omada Controller on Ubuntu 24.04"
date: "2025-09-04T21:08:30+05:30"
updated: "2025-09-04T21:08:30+05:30"
author: kdpuvvadi
tags: [ubuntu, ubuntu-2404, mongodb, tp-link, sdn, omada, network, firewall, gateway, vpn, proxmox]
categories: [networking, omada, firewall, sdn]
image: assets/img/install-omada-ubuntu-2404.png
---

Current version of Omada as of this writing is `5.15.24.19`. Let's Install Omada controller on latest LTS on Ubuntu. 

> If are trying to upgrade the Controller please check the instruction at [upgrade-omada-controller](/posts/upgrade-omada-controller). Make sure to adopt the instructions based on your version.
{: .prompt-info }

First update the apt repos and upgrade current packages. I'm Assuming here that Ubuntu 24.04 box is fresh install and nothing other than preinstalled with distro were installed.

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

Now add mongodb-org repo for focal to the source list, create a new source file for mongodb v7 with the following

```shell
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```
{: file='/etc/apt/sources.list.d/mongodb-org-7.0.list'}

Update repo and install mongodb

```shell
sudo apt update
sudo apt install -y mongodb-org
```

## Install 

To install the Omada Controller, download the deb package from TP-Link support. Make sure to grab latest version [here](https://support.omadanetworks.com/us/product/omada-software-controller/?resourceType=download)

```shell
wget https://static.tp-link.com/upload/software/2025/202508/20250802/omada_v5.15.24.19_linux_x64_20250724152622.deb
```

Install the Omada controller. 

```bash
sudo dpkg -i omada_v5.15.24.19_linux_x64_20250724152622.deb
```

It might take 2 to 5 min depending upon your box configuration. Once the installation completed, visit `https://<ip>:8043`

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

Installation is simple and straight forward. Any help needed, feel free to comment below. [Au revoir](#conclusion).
