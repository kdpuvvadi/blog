---
layout: post
title: mqtt over TLS on Home Assistant with traefik
description: Secure MQTT brocker with TLS/SSL with Let's Certificates using traefik
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
---

For the traefik setup checkout this at previous post [here](/posts/deploy-pocketbase-with-docker-behind-traefik/). I'm using Official Add-on Eclipse [Mosquitto](https://github.com/home-assistant/addons/tree/master/mosquitto). 

Current config 

```
host: 10.20.30.5
port: 1883 
tls: false
```

New config at the end

```
host: mqtt.example.com
port: 8883
tls: true
```

Add new entry in the entrypoints of traefik config `traefik.yaml`

```yaml
entryPoints:
  mqtt:
    address: ":8883"
```

For the file the config, i've added `watch` flag to auto update on file changes.

```yaml
providers:
  file:
    directory: /config
    watch: true
```

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

Make sure to change above based on your network

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

With the above `mqtt.yaml` file should looks like the following

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

traefik should provision a new cert for the given domain/subdomain if not already avaiable. Now mqtt should be avaiable at `mqtt.example.com` over port `8883` with `tls`.

## usage

using `micropython` and `umqtt` library

```python
from umqtt.simple import MQTTClient

MQTT_SERVER = mqtt.example.com
MQTT_PORT = 8883
MQTT_USER = mqtt_user
MQTT_PASSWORD = SecurePassword
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
