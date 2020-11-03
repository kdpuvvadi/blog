+++
title = "Portainer on Wsl2"
date = "2020-11-02T19:37:15+05:30"
author = "KD Puvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["docker", "portainer","wsl", "wsl2"]
keywords = ["Tech", "Dev"]
description = "Use WSL2 with portainer to speedup your Dev time"
showFullContent = false
+++

![](/image/wsl2-portainer.jpg)

I’ve been using WSL2 for developping for both personal and Professional use cases. To manage and quick deploy the containers, i’ve been using *[Portainer](https://www.portainer.io/)*. As much as i love to use Terminal, i’m mostly lazy.

I’m assuming you’ve already WSL2 installed and docker is up and running.

First create a volume with following.

````
$ docker volume create portainer_data
````

![](/image/portainer-volume.jpg)

Now, install portainer

````
$ docker run -d 
    -p 8000:8000 
    -p 9000:9000 
    --name=portainer 
    --restart=always 
    -v /var/run/docker.sock:/var/run/docker.sock 
    -v portainer_data:/data 
    portainer/portainer-ce
````

![](/image/portainer-running.png)

Here, Port *9000* is used for serving UI and API. Port 8000 is for running SSH tunnel between portainer instance and the agent.

Now, set a admin password

![](/image/portainer-user.png)

Now, Select Docker as Environment and click Connect

![](/image/portainer-env.png)

Here it is,

![](/image/portainer-dashboard.png)

To pull images from *Dockerhub* go to images on left menu, type in the name of the container and tag *e.g node:current-alpine3.10*. click on Pull the Image.

![](/image/docker-images-hub.png)

you can import of your own container and spin off the containers.