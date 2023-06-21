+++
title = "Getting Started With Azure Iot Hub"
date = "2023-06-21T09:52:34+05:30"
author = "kdpuvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["Azure Iot Hub", "MQTT", "Azure", "IoT", "Cloud"]
keywords = ["Azure Iot Hub", "MQTT", "Azure", "IoT", "Cloud"]
description = ""
showFullContent = false
readingTime = true
hideComments = false
+++

Sending telemetry data from remote IoT device to the outside or to the cloud is pretty hard. Most of the machines are behind locked down networks or behind CGNAT. No way for direct communication to the open internet. As they should beWhich is good for security but it makes life hard for the Home labers, Engineers trying to connect edge device to the network and working to collect telemetry data such as recent alarms, Sensors logs, authentication history and etc.

That's where [Azure IoT Hub](https://azure.microsoft.com/en-in/products/iot-hub) comes to picture. Works anywhere. Even behind the firewall with secure socket communications with TLC. End user can brings their own certificates.

## Getting started

On [Microsoft Azure](https://azure.microsoft.com/en-in/) everything is under a resource group. It helps the end user to organise their resources. User might have different devices in the given location or number of locations, resources belongs to each location can organised into different resource groups.

## Create Resource group

On Azure's [portal](https://portal.azure.com/), select [Resource Group](https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups). Click on `+ Create` to create a new resource group for our IoT Hub. Enter the name for resource group and select the nearest data centre to your desired location. It might take up to 2 minutes to complete the task. Once completed, user will receive a notification.

## Create IoT Hub

To create IoT Hub, Go to portal home page or go to all services and select `IoT Hub`.  Click on `+ Create` to create the IoT hub. Select the resource group which was created earlier and select the remaining details based on the requirement and click on `Review + Create`.

> `Tier` and `Daily Message Limit` can be upgraded in the future. Start with low when testing. `IoT hub name` should be unique, Not only to your account but to the entire Azure Network.

### Create IoT Device

Navigate to created IoT Hub and Select `Devices` Under `Device Management`. Select `Add Device`. Click save to create device.

### Create Module Identity

Device might have multiple sensors or IO Modules. With modules, data can organised. To add module, Select `Add Module Identity`. Add relevant name and click save to add the module. Multiple modules can be add to the device and can send the data in between the modules.

## Connection

To connect to the `Azure IoT Hub`,  Device needs `Client id`, `Module id`, `Username` and `shared access signatures`(`SAS token`) as a `Password`. By providing `SAS` token, access can be limited that particular device.

### Client Id

syntax of client ID to `{device-id}/{module-id}`. Here it would `edge-device-001/edge-device-001-temp-sensor-001`.

### Username

syntax of the `Username` is

`<hubname>.azure-devices.net/{device_id}/{module_id}/?api-version=2021-04-12`.

Here it would be as following

`Si-Iot-Hub--001.azure-devices.net/edge-device-001/edge-device-001-temp-sensor-001/?api-version=2021-04-12`

> Select the latest `api-version` available. Selecting wrong version might cause unintentional behaviour.

### SAS Token

To generate `SAS Token`, Open `Azure CLI` and run following

```pwsh
az iot hub generate-sas-token -n {iothub_name}
```

Copy the generated token and add it as a `password`.

### WILL Topic

To publish messages, `WILL` topic is required, syntax as follows.

`devices/{device-id}/modules/{module-id}/messages/events/`

It would be

`devices/edge-device-001/modules/edge-device-001-temp-sensor-001/messages/events/`

### Receiving Messages

To listen to the messages

`devices/{device-id}/modules/{module-id}/#`

It would be

`devices/edge-device-001/modules/edge-device-001-temp-sensor-001/#`

Testing connection in development environment is better before directly trying to connect and send data from the edge device. To test connection few tools has to be installed in the development environment system.

## Requirements

- [Visual Studio Code](https://code.visualstudio.com/)
- Extensions for VS Code
  - [Azure Account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account)
  - [Azure IoT Hub](https://marketplace.visualstudio.com/items?itemName=vsciot-vscode.azure-iot-toolkit)
- MQTT Client

## Install VS Code

Install Visual Studio Code by visiting official [website](https://code.visualstudio.com/).

VS Code can also be installed with Winget, Windows Package Manager

```pwsh
winget install -e --id Microsoft.VisualStudioCode
```

## Install extensions

To install required extension, click on Extension icon on `Activity` Bar. Search for `Azure IoT Hub` and Install the `Azure IoT Hub` extension. This extensions depends on `Azure Account` extension. So, it'll be installed along with this extension.

## Login to Azure account

To login to azure account, Click on `Azure` icon on the `Activity` Tab and click on `Sign in to Azure`. A browser window will open and prompts to login the `azure account`. After the authentication completed, browser windows can be closed and login process will be completed. Close the VS Code and reopen it.

Previously created IoT Hub, Devices and Module Identities should be present here. Please keep [username](#username), [SAS token](#sas-token) generated previously and [others](#connection) in the hand.

## Testing Connection

To test device login, connection test and publish data, `MQTT` client is required. One such client is [MQTTX](https://github.com/emqx/MQTTX). Download it from their GitHub Release page [here](https://github.com/emqx/MQTTX/releases/latest).

Create a new connection in `MQTTX`

Fill the details from IoT Hub, and Enable `SSL/TLS`. Scroll down to `Last WILL and Testment` section and add sample `json` body to send.

```yaml
Name: Testing # Any name
Client ID: edge-device-001/edge-device-001-temp-sensor-001`. # in format {device-id}/{module-id}
Host: <hubname>.azure-devices.net # `mqtts`
Port: 8883 # 8883 for mqtts
Username: <hubname>.azure-devices.net/{device_id}/{module_id}/?api-version=2021-04-12
Password: # SAS token
SSL/TLS: Enable
SSL Secure: Enable
Certificate: CS Signed Server
MQTT Version: 3.1.1 # Current stable version on azure is 3.1.1 & v5 is in preview
```

Connection session timing can be adjusted based on the user preferences. Click on connect on right side top. Once connection established, `Connected`, message will be shown. If the connection the device module established, color of the modules changes from blue to green.

## Monitor Messages

To monitor the messages published by devices, Right click on the device and select `Start Monitoring Built-in Event Endpoint`. Output windows with `Azure IoT Hub` will open and displays the data from the `IoT Hub` and any and all published data.

To push data, Edit the payload and click on send icon. Published data will be displayed in output window of the VS Code Messages published by different modules will also be displayed in the Output windows.
