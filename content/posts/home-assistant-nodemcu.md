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

In the Previous [post](home-assistant-setup.md "Home Assistant setup on Raspberry Pi"), we had setup Home Assitant on Raspberry pi. For the first intigration, we are going to use ESP8266 *aka* NodeMCU. Required items as follows

#### Requirments

    - ESP8266
    - Powersupply
    - DHT11 Sensor

#### ESP8266 Setup

Our goal today is connecting NodeMCU to HomeAssitant and reading temparature and humidity data from the DHT11 sensor. To do that we need to install small addon ESPHome from Addon store on Home Assitant. To install ESPHome Addon, go to * Superviser > Add-on Sore * and search for ESPHome. Click on the Add-on and click install. Once the instalation is completed, i recommend turning on *Show in sidebar* and *watchdog* for quick access and recover the add-on incase of carsh.

Now, goto ***ESPHome*** on the Leftside menu. Click on the + to add a Node. 

If eveything went very well, you should see Living Room Node on ESPHome. Click on Edit to check the config. It should look something like bellow. 

![](/image/esphome_node_setup.gif)

{{< code language="yaml" title="living_room.yaml" id="3" expand="Show" collapse="Hide" >}}

    esphome:
    name: living_room
    platform: ESP8266
    board: nodemcuv2

    wifi:
    ssid: "Wirelessname"
    password: "password"

    # Enable fallback hotspot (captive portal) in case wifi connection fails
    ap:
        ssid: "Living Room Fallback Hotspot"
        password: "password"

    captive_portal:

    # Enable logging
    logger:

    # Enable Home Assistant API
    api:
    password: "password"

    ota:
    password: "password"
{{< /code >}}

#### Falshing

Now, Click on Menu and compile. After the compilation completed click on Download to save the binary. To flash the binary to the NodeMCU, Download [NodeMCU Flasher](https://github.com/nodemcu/nodemcu-flasher). Open NodeMCU Flasher. Select COM port and binary file to flash in Config tab. 

![](/image/nodemcu_flasher_flash.png)

Click on *Flash*

![](/image/nodemcu_flash_done.png)

After completion of Flashing, disconnet the NodeMCU from the PC and Connect it to the Power source.