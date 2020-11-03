+++
title = "Home Assistant Nodemcu"
date = "2020-11-03T22:12:51+05:30"
author = ""
authorTwitter = "" #do not include @
cover = ""
tags = ["", ""]
keywords = ["", ""]
description = ""
showFullContent = false
draft = true
+++

#### Setup

Open your browser of choice and enter the IP address of the Pi. If everything went well and device connected to the network, you should see the following screen. 

![](/image/hass_preparing.jpg)

The process may take some time, Take a coffe brake. Once the process is completed, you should see account creation screen.

![](/image/hass_account.png)

Name your Home Assitant setup, setup Home locatation and Select the units of choice in the following screen. 

![](/image/hass_map_units_name.png)

If everything went good so far, you should Home Assitant Dashboard *aka* ***lovelace***. 

#### ESP8266 Setup

Our goal today is connecting NodeMCU to HomeAssitant. To do that we need to install small addon ESPHome from Addon store on Home Assitant. To install ESPHome Addon, go to * Superviser > Add-on Sore * and search for ESPHome. Click on the Add-on and click install. 