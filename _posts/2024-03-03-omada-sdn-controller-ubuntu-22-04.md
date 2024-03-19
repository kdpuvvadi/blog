---
title: "Install Omada Controller on Ubuntu 22.04"
date: "2024-03-03T14:07:30+05:30"
author: kdpuvvadi
tags: [ubuntu, mongodb, tp-link, sdn, omada, network, firewall, gateway, vpn, proxmox]
categories: [networking, omada, firewall]
---

Previously posted a guide for installing Omada Controller on Ubuntu 20.04. Received log of requests for guide on 22.04. It's not simply straight forward as Omada Still using old dependencies and might break some package if incorrectly installed. Reason i'm writing this here is official guides and documentation are outdated and refusing to fix them.

First update the apt repos and upgrade current packages. I'm Assuming here that Ubuntu 22.04 box is fresh install and nothing other than preinstalled with distro were installed.

```shell
sudo apt update
sudo apt upgrade -y
```

## Install Dependencies

For Debian systems, Omada need Java 8 or later, MongoDB 4, JSVC, curl.


Omada Controller is return in Java & we are using opensource Java 17 binary `Openjdk-17-jre-headless`

```shell
sudo apt install Openjdk-17-jre-headless jsvc curl -y
```

## Install MongoDB

Mongo dB version 4 or earlier are not available on Ubuntu 22.04 or Debian 12. Reason being `libssl 1.1` is deprecated in later versions of Debian and ubuntu. 

First install `libssl 1.1`

```shell
curl -sSL http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1-1ubuntu2.1~18.04.23_amd64.deb -o libssl1.1.deb
sudo dpkg -i libssl1.1.deb
```

As of this writing, v4.4 is supported in Omada. Let's install `gpg` key for` mongodb-org` `4.4`

```shell
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo gpg --dearmour -o /usr/share/keyrings/mongo-org-4.4.gpg
```

Now add mongodb-org repo for focal to the source list

create a new source file first

```shell
touch /etc/apt/sources.list.d/mongodb-org-4.4.list
```

Add following to the source list file
```
deb [ arch=amd64 signed-by=/usr/share/keyrings/mongodb-org-4.4.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse
```
{: file='/etc/apt/sources.list.d/mongodb-org-4.4.list'}

Update repo and install mongodb

```shell
sudo apt install mongodb-org -y
```

## Install Omada Controller

TP link provides 2 type of installers. Debian package and tar.gz archive. Both are pretty much straight forward. Go to TP-Link website [Omada Controller Download Page](https://www.tp-link.com/en/support/download/omada-software-controller/).

## Install from tar.gz

Download the tar.gz. 5.6.3 is latest version as of writing this. Replace the URL with latest one.

```shell
wget https://static.tp-link.com/upload/software/2024/202402/20240227/Omada_SDN_Controller_v5.13.30.8_linux_x64.tar.gz
```

Extract the archive & Navigate to the directory

```shell
mkdir omada
tar -xvzf Omada_SDN_Controller_v5.13.30.8_linux_x64.tar.gz -C omada
cd omada
```

Make install script `install.sh` executable.

```shell
sudo chmod +x install.sh
```

Install the controller with the following

```shell
sudo ./install.sh
```

To uninstall Omada Controller

```bash
sudo ./uninstall.sh
```

## Install from .deb

Download the deb package from TP Link

```shell
wget https://static.tp-link.com/upload/software/2024/202402/20240227/Omada_SDN_Controller_v5.13.30.8_linux_x64.deb
```

Install with the following

```shell
sudo dpkg -i Omada_SDN_Controller_v5.13.30.8_linux_x64.deb
```

To uninstall

```bash
sudo apt remove omadac
```

It might take 2 to 5 min depending upon your system configuration. Once the installation completed, visit <https://ip:8088>

### Conclusion

Installation is simple and straight forward. lets setup the controller and add router, APs and configure the network next weeks. Any help need hit me on twitter or comment below. [Au revoir](#conclusion).
