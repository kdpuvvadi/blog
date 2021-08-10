+++
title = "Nginx Proxy Manager With Ansible"
date = "2021-08-10T09:46:24Z"
author = "kd puvvadi"
authorTwitter = "" #do not include @
cover = ""
tags = ["", ""]
keywords = ["", ""]
description = ""
showFullContent = false
draft = true
+++

[Nginx Proxy Manager](https://nginxproxymanager.com/) is a life saver. It runs most of home infrastructure. So that one doesn't have to expose every port every other application needs. All you need to expose is 443 over ssh. I had to manually deploy the docker volume then docker containers or it can be easily deployed with compose but all those assuming docker is already preinstalled. Friend of mine phoned and asked me setup Proxy Manager at his house. He do know how setup and how it works but just another excuse to see another soul in these godforsaken days.

He already uses ansible and runs ESXi on dell r7515 with Epyc 7313p. Epyc was really epic. With simple playbook, he deployed an Ubuntu 20.04 LTS vm. it was up and running in no time.

To deploy simply clone the repo with the following

```sh

```
