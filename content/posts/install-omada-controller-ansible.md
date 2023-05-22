+++
title = "Install Omada Controller with Ansible playbook"
date = "2021-09-07T10:09:18+05:30"
author = "kdpuvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = "/image/ansible-omada-controller.webp"
tags = ["omada", "ansible", "network" ]
keywords = ["omada controller", "ansible", "playbook", "tp-link" ]
description = "Install Omada controller on Debian and CentOS linux distribution with ansible playbook."
showFullContent = false
readingTime = true
+++

## Introduction

In the previous post on "How to [Install Omada controller on ubuntu](/posts/omada-sdn-controller-ubuntu/)", we deployed the controller with all the manual method. To deploy on multiple machines and multiple locations, it's cumbersome and time consuming.

So, it is efficient to use automation to deploy the controller.

## Ansible Playbook

Playbook can be found at [repo](https://github.com/kdpuvvadi/omada-ansible), clone the repo with the following

```shell
git clone https://github.com/kdpuvvadi/omada-ansible.git omada-ansible
```

and `cd` into the directory

```shell
cd omada-ansible
```

## Supported Repos

Tested the playbook on the following repos

* Debian 10, 11
* CentOS 8, Rocky Linux 8
* Ubuntu 18.04, 20.04

## Ansible Setup

* install pip `sudo apt install python3-pip -y`
* install ansible with pip `python3 -m pip install ansible`

## Variables & Inventory

* Copy inventory sample file `cp inventory.ini.j2 inventory.ini`
* Change the ip address with actual IP address of the host server.
* Copy variable file with `cp vars.ini.j2 vars.ini`
* install requirements `ansible-galaxy collection install -r requirements.yml`

## Run

### Test Connection

To test the connection with host run the following and it should return success message.

```shell
ansible all -m ping
```

### run the playbook

```shell
ansible-playbook main.yml
```

> If you need password for the sudo append `-K` and enter the password when prompted

```shell
ansible-playbook main.yml -K
```

## Post Installation

* Omada controller will be available on <https://HOST-IP:8088/> or <https://HOST-IP:8043/>.
* Following ports should be open on host for the controller to work properly.
  * 8088
  * 8043
  * 27001
  * 27002
  * 29810
  * 29811
  * 29812
  * 29813

## Manage Omada Service

* `sudo tpeap status` -- show the status of Controller;
* `sudo tpeap start` -- start the Omada Controller;
* `sudo tpeap stop` --stop running the Omada Controller.

**Au revoir*
