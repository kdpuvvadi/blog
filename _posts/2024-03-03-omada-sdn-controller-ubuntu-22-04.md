---
title: "Install Omada Controller on Ubuntu 22.04 & Debian 12"
date: "2024-03-03T14:07:30+05:30"
updated: "2024-04-05T13:55:00+05:30"
author: kdpuvvadi
tags: [ubuntu, ubuntu-2204, mongodb, tp-link, sdn, omada, network, firewall, gateway, vpn, proxmox, debian-12, debian]
categories: [networking, omada, firewall]
image: assets/img/install-omaad-ubuntu-2204.jpeg
---

Update: Omada released new version `5.14.20` with support for `MongoDB v7`.

Previously posted a guide for installing Omada Controller on Ubuntu 20.04. Received log of requests for guide on 22.04. It's not simply straightforward as Omada still uses old dependencies, which could break some packages if incorrectly installed. ~~The reason I'm writing this here is because the official guides and documentation are outdated and are refusing to fix them.~~

First update the apt repos and upgrade current packages. I'm Assuming here that Ubuntu 22.04 box is fresh install and nothing other than preinstalled with distro were installed.

```shell
sudo apt update
sudo apt upgrade -y
```

## Install Dependencies

For Debian systems, Omada need Java 8 or later, MongoDB 7, JSVC, curl, gpg.

```shell
sudo apt install wget curl gnupg
```

Omada supports java 8 and above. if you just want to run Omada Controller and be done with that use java 8 otherwise you can go with java 21. Just keep in mind that you might need to troubleshoot errors, compile some packages yourself and did I mention log of troubleshooting.

### java 8 

Install Java 8 package `openjdk-8-jre-headless` and `jsvc` along with that.

```shell
sudo apt install openjdk-8-jre-headless jsvc -y
```

### java 21

We need to install `jdk` and compile `jsvc` package. We are using opensource Java 21 binary `openjdk-21-jdk-headless`

```shell
sudo apt install openjdk-21-jre-headless -y
```

Latest `jsvc` in the apt repo does not support version 21. Let's compile it ourselves.

```shell
wget https://archive.apache.org/dist/commons/daemon/source/commons-daemon-1.4.0-src.tar.gz
tar xvzf commons-daemon-1.4.0-src.tar.gz
cd commons-daemon-1.4.0-src
cd src/native/unix/
./configure --with-java=/usr/lib/jvm/java-21-openjdk-amd64
make
sudo cp jsvc /usr/bin/
```

Using latest version `1.4.0`, `1.2.4` or `1.3.1` can be used in place.

> If you receive error while configuration step 
>`checking for JDK os include directory... Cannot find jni_md.h in /usr/lib/jvm/java-21-openjdk-amd64/`, try following
{: .prompt-info }

```shell
cd /usr/lib/jvm/java-21-openjdk-amd64
sudo ln -s include/linux/jni_md.h jni_md.h
```

## Install MongoDB

Omada now supports MongoDB v7, let's install `gpg` key for` mongodb-org` `7.0`

```shell
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
```

Now add mongodb-org repo for focal to the source list

create a new source file first

```shell
touch /etc/apt/sources.list.d/mongodb-org-7.0.list
```

Add following to the source list file

```
deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse
```
{: file='/etc/apt/sources.list.d/mongodb-org-7.0.list'}

Update repo and install mongodb

```shell
sudo apt update
sudo apt install -y mongodb-org
```

## Install Omada Controller

TP link provides 2 type of installers. Debian package and tar.gz archive. Both are pretty much straight forward. Go to TP-Link website [Omada Controller Download Page](https://www.tp-link.com/en/support/download/omada-software-controller/).

### Install from tar.gz

Download the tar.gz. `5.14.26.1` is latest version as of writing this. Replace the URL with latest one.

```shell
wget https://static.tp-link.com/upload/software/2024/202407/20240710/Omada_SDN_Controller_v5.14.26.1_linux_x64.tar.gz
```

Extract the archive & Navigate to the directory

```shell
tar -xvzf Omada_SDN_Controller_v5.14.26.1_linux_x64.tar.gz -C omada
cd Omada_SDN_Controller_v5.14.26.1_linux_x64
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

### Install from .deb

Download the deb package from TP Link

```shell
wget https://static.tp-link.com/upload/software/2024/202407/20240710/Omada_SDN_Controller_v5.14.26.1_linux_x64.deb
```

Install with the following

```shell
sudo dpkg -i Omada_SDN_Controller_v5.14.26.1_linux_x64.deb
```

To uninstall

```bash
sudo apt remove omadac
```

It might take 2 to 5 min depending upon your system configuration. Once the installation completed, visit <https://ip:8088>

## Conclusion

Installation is simple and straight forward. lets setup the controller and add router, APs and configure the network next weeks. Any help need hit me on twitter or comment below. [Au revoir](#conclusion).
