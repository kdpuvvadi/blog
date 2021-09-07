+++
title = "Install Omada Controller with Ansible playbook"
date = "2021-09-07T10:09:18+05:30"
author = "kdpuvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = "/image/ansible-omada-controller.jpg"
tags = ["omada", "ansible", "network" ]
keywords = ["omada controller", "ansible", "playboo", "tp-link" ]
description = "Install Omada controller on Debian and CentOS linux distribution with ansible playbook."
showFullContent = false
+++


# Introduction

In previous post on How to [Install Omada controller on ubuntu](/posts/omada-sdn-controller-ubuntu/), we deployed the controller with all the manual method. To deploy on multiple machines and multiple locations, it's cumbersome and time consuming.

So, it is efficient to use automation to deploy the controller.

## Ansible Playbook

Playbook can be found on [repo](https://github.com/kdpuvvadi/Omada-Ansible), clone the repo with the following

````shell
git clone https://github.com/kdpuvvadi/Omada-Ansible.git omada-ansible
````
and `cd` into the directory

````shell
cd omada-ansible
````

## Supported Repos

Tested the playbook on the follwoing repos

* Debian 8, 9 & 10
* CentOS 6, 7
* Ubuntu 18.04, 20.04

*CentOS 8 is not supported yet*

## Ansible Setup

* install pip `sudo apt install python3-pip -y`
* install ansible with pip `python3 -m pip install ansible`
* install requirements `ansible-galaxy collection install -r requirements.yml`

## Varibles & Inventory

* Copy inventory sample file `cp example.inventory.ini inventory.ini`
* Change the ip address with actual IP address of the host server.
* Copy varible file with `cp example.vars.ini vars.ini`

## Run the Playbook

* To test the connection with host run the following and it should return success message.

````shell
ansible all -k ping
````

* To run the playbook

````shell
ansible-playbook main.yml
````

* If you need password for the sudo append `-K` and enter the password when prompted

````shell
ansible-playbook main.yml -K
````

## Post Installation

* Omada controller will be avaiable on https://HOST-IP:8088/ or https://HOST-IP:8043/.
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

**Au revoir**