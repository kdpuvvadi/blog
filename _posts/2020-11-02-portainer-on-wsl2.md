---
title: "Portainer on Wsl2"
date: "2020-11-02T19:37:15+05:30"
author: kdpuvvadi
image: /assets/img/wsl2-portainer.webp
tags: [docker, portainer, wsl, wsl2]
categories: [docker, portainer, wsl]
---

I’ve been using WSL2 for developing for both personal and Professional use cases. To manage and quick deploy the containers, I’ve been using *[Portainer](https://www.portainer.io/)*. As much as I love to use Terminal, i’m mostly lazy.

I’m assuming you’ve already WSL2 installed and docker is up and running.

First create a volume with following.

```shell
docker volume create portainer_data
```

![Portainer Volume](/assets/img/portainer-volume.webp)

Now, install Portainer

```shell
docker run -d
    -p 8000:8000
    -p 9000:9000
    --name=portainer
    --restart=always
    -v /var/run/docker.sock:/var/run/docker.sock
    -v portainer_data:/data
    portainer/portainer-ce
```

![Portainer Running](/assets/img/portainer-running.webp)

Here, Port *9000* is used for serving UI and API. Port 8000 is for running SSH tunnel between portainer instance and the agent.

Now, set a admin password

![Portainer User](/assets/img/portainer-user.webp)

Now, Select Docker as Environment and click Connect

![Portainer Env](/assets/img/portainer-env.webp)

Here it is,

![Portainer Dashboard](/assets/img/portainer-dashboard.webp)

To pull images from *Docker hub* go to images on left menu, type in the name of the container and tag *e.g node:current-alpine3.10*. click on Pull the Image.

![Docker Images](/assets/img/docker-images-hub.webp)

you can import of your own container and spin off the containers.
