---
layout: post
title: MQTT over TLS on Home Assistant with traefik
description: Secure your Home Assistant MQTT broker with TLS/SSL using Traefik and Mosquitto. This guide covers setup, automated certificate management with Let’s Encrypt, and encrypted communication for IoT devices.
image: assets/img/mqtt-traefik-tls.jpeg
category:
  - trafik
  - mqtt
  - ha
  - tls
tags:
  - proxy
  - ssl
  - iot
  - mqtt-over-tls
  - mqtt-over-ssl
  - traefik
  - secure-iot-communication
---

If you’re using MQTT with Home Assistant, securing it with TLS/SSL is a must—especially if you’re exposing it outside your home network. In this guide, I’ll show you how to set up MQTT over TLS/SSL using Traefik as a reverse proxy, with the official Mosquitto add-on.

We’ll get Let’s Encrypt handling the certificates, so you don’t have to worry about manual renewals. By the end, you’ll have a fully secured MQTT broker that works seamlessly with Home Assistant and your IoT devices. Let’s dive in!

## Setup

Here are a few details about the current setup.. Home Assistant is running in a VM with ip address of `10.20.30.5` at port `1883`.
 
```
host: 10.20.30.5
port: 1883 
tls: false
```

Our goal here is to run the mqtt broker behind a Traefik reverse proxy with Fully Qualified Domain Name (FQDN) such as `mqtt.example.com`. Traefik should already be running. For setup instructions, visit [this guide](/posts/deploy-pocketbase-with-docker-behind-traefik/). Domain or subdomain should be valid and already configured with traefik. 

```
host: mqtt.example.com
port: 8883
tls: true
```

## Configuration

To securely route MQTT traffic through Traefik, we need to define the necessary configuration settings. This includes setting up an entry point for MQTT, defining a TCP service to connect to the Mosquitto broker, adding middleware for access control, and creating a router to handle incoming connections. Below are the steps to configure Traefik for MQTT over TLS.

### EntryPoint  

An **entry point** in Traefik defines how external connections reach your services. Since MQTT over TLS typically runs on port `8883`, we need to create an entry point in the `traefik.yaml` configuration file. This will ensure that Traefik listens for incoming MQTT connections on the specified port and forwards them securely to the Mosquitto broker.

Add new entry in the entrypoints of traefik config `traefik.yaml`

```yaml
entryPoints:
  mqtt:
    address: ":8883"
```
{: file='traefik.yaml' .nolineno }

#### Providers

For the file the config, i've added `watch` flag to auto update on file changes.

```yaml
providers:
  file:
    directory: /config
    watch: true
```
{: file='traefik.yaml' .nolineno }

### TCP service

create a new file at `/config/mqtt.yaml`

Add a new `service` under `tcp` services

```yaml
tcp:
  services:
    mqtt:
      loadBalancer:
        servers: 
          - address: "10.20.30.5:1883"
```
{: file='mqtt.yaml' .nolineno }

### Middleware

Now add `middleware` fow allowed list to allow clients from desired networks

```yaml
tcp:
  middlewares:
    default-whitelist-mqtt:
      ipAllowList:
        sourceRange:
          - "10.0.0.0/8"
          - "192.168.0.0/16"
          - "172.16.0.0/12"
          - "100.64.0.0/10"
```
{: file='mqtt.yaml' .nolineno }

> Make sure to change above based on your network
{: .prompt-info }

### TCP router

We can now add `router` for the service.

```yaml
tcp:
  mqtt:
    rule: "HostSNI(`mqtt.example.com`)"
    entryPoints:
      - "mqtt"
    tls: true
    service: mqtt
    middlewares:
      - default-whitelist-mqtt
```
{: file='mqtt.yaml' .nolineno }

### Full TCP traefik config file 

With the above, `mqtt.yaml` file should looks like the following

```yaml
tcp:
  routers:
    mqtt:
      rule: "HostSNI(`mqtt.local.puvvadi.net`)"
      entryPoints:
        - "mqtt"
      tls: true
      service: mqtt
      middlewares:
        - default-whitelist-mqtt

  services:
    mqtt:
      loadBalancer:
        servers: 
          - address: "10.20.30.5:1883"

  middlewares:
    default-whitelist-mqtt:
      ipAllowList:
        sourceRange:
          - "10.0.0.0/8"
          - "192.168.0.0/16"
          - "172.16.0.0/12"
          - "100.64.0.0/10"
```
{: file='mqtt.yaml' .nolineno }

Traefik should automatically provision a certificate for the domain/subdomain if one is not already available. Now MQTT should be avaiable at `mqtt.example.com` over port `8883` with `tls`.

## Example usage

To conclude, I will provide an example of how a MicroPython-based device can connect to the secured MQTT broker using the `umqtt.simple` library. This example, based on my [Pico W DHT MQTT project](https://github.com/kdpuvvadi/picow-dht-mqtt), demonstrates how to securely publish sensor data. It serves as a practical reference for integrating IoT devices with Home Assistant using MQTT over TLS/SSL.

```python
from umqtt.simple import MQTTClient

MQTT_SERVER = mqtt.example.com
MQTT_PORT = 8883
MQTT_USER = "your_username"
MQTT_PASSWORD = "your_secure_password"
MQTT_CLIENT_ID = b'livingroom climate'
MQTT_KEEPALIVE = 7200
MQTT_SSL = true
MQTT_SSL_PARAMS = {'server_hostname': MQTT_SERVER}

def connect_mqtt():
  try:
    client = MQTTClient(
        client_id=MQTT_CLIENT_ID,
        server=MQTT_SERVER,
        port=MQTT_PORT,
        user=MQTT_USER,
        password=MQTT_PASSWORD,
        keepalive=MQTT_KEEPALIVE,
        ssl=MQTT_SSL,
        ssl_params=MQTT_SSL_PARAMS,
    )
    client.connect()
    return client
  except Exception as e:
    print('Error connecting to MQTT:', e)
    raise
```
{: file='main.py' .nolineno }

## Conclusion  

Securing MQTT with TLS/SSL using Traefik ensures encrypted communication between your IoT devices and Home Assistant, enhancing both security and reliability. By integrating the Mosquitto add-on with Traefik’s reverse proxy and Let’s Encrypt, you achieve a fully automated and secure setup with minimal maintenance.  

To further illustrate its real-world application, I’ve included an example using MicroPython and the `umqtt.simple` library, demonstrating how IoT devices can securely publish data. With this setup in place, your smart home ecosystem is now better protected while maintaining seamless connectivity.

If you have any questions or thoughts, feel free to drop a comment below. [Au revoir!](#conclusion) 👋😊
