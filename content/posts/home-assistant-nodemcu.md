+++
title = "Connecting Nodemcu to Home Assistant"
date = "2020-11-03T22:12:51+05:30"
author = "KD"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["NodeMCU","ESP8266", "ESPHome", "Home Assitant", "Home Automation"]
keywords = ["Home Assitant", "HASS", "Automation"]
description = "Step by Step guide for connecting NodeMCU to the Home Assistant and Monitoring Humidity & Temparature with DHT11 on Raspberry Pi"
showFullContent = false
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

After completion of Flashing, disconnet the NodeMCU from the PC and Connect it to the Power source. Before connecting the Power source, connect DHT11 sensor to NodeMCU using following config

#### Wiring Sensor

| DHT11 | NodeMCU |
|-------|---------|
| VCC   | 3V3     |
| GND   | GND     |
| DATA  | D6      |

LED indicator of Sensor should be illuminated after connecting the power source. 

#### Sensor Config

To Display the Temparature and Humidity, first sensor should be configured in ESPHome. Copy the following Config and add it to the ***living room.yaml*** file. (only sensor config should be added. Previous config shoudle be changed.)

{{< code language="yaml" title="living_room.yaml" id="3" expand="Show" collapse="Hide" >}}

esphome:
  name: living_room
  platform: ESP8266
  board: nodemcuv2

# WiFi name and password for connecting to the network
wifi:
  ssid: "Wife Name"
  password: "WiFi Password"

  # Enable fallback hotspot (captive portal) in case wifi connection fails
  ap:
    ssid: "Hotspot name"
    password: "Password"

captive_portal:

# Enable logging
logger:

# Enable Home Assistant API
api:
  password: "API Password"
# OTA Updates with password protection
ota:
  password: "OTA Password"

sensor:
  - platform: dht
    pin: D6
    temperature:
      name: "Temperature"
    humidity:
      name: "Humidity"
    # Update intervel in Seconds
    update_interval: 30s
    model: DHT11

{{< /code >}}

Click on Save. Upload to upload the binary via OTA Update. After validation, compilation and Uploading, ESP8266 will reboot itself and trasmitting data to Home Assitant securely over APIs.
Click on Log to see the data beeing sent from ESP8266 to the Home Assitant. 

![](/image/esp8266_temp_humid_log.png)

#### Adding Data to Lovelace

Go to * Configuration > Integration *, *ESPHome:living_room* should present there. Click on **CONFIGURE** and *Do you want to add the ESPHome node living_room to Home Assistant?* prompts, click on *submit*. it prompts for passowrd, set in the config. Enter the password and Select the Room *e.g Living Room* 

Now, go to *Configuration > Entities > select  Temparature (sensor.temparature ESPHome) and Select Humidity (sensor.humidity ESPHome) > ENABLE SELECTED* and *yes* on the prompt *This will make them available in Home Assistant again if they are now disabled.*

If everything went well, Temparature and Humidity should be available in Lovelace. 

![](/image/esphome_temp_humid_out.png)

#### Conclusion

ESP8266 can be configured to work with Home Assitant is few steps and in 5 min. possibilities are limit less. Multiple Nodes can be configired. Multiple sensors can be intigrated. Automation with NodeMCU can be done with simple steps. In my setup Home Assitant is controlling Air Conditioner with NodeMCU, DHT11 sensor and [Broadlink](https://www.ibroadlink.com/) [RM mini 3](https://www.amazon.in/BroadLink-Universal-Control-RM-MINI3/dp/B01G1PZUK2). If the temparature in the room reaches bellow 20, cooling will turn off and if the temparature reaches 30 Cooling will be back on. if the Humidity is too high or too low, Humidy control will be selected as the AC fuction. Possibilities are limit less. [Au revoir](#conclusion)