+++
title = "Upgrade the Omada Controller"
date = "2022-03-15T00:09:38+05:30"
author = "KD Puvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["", ""]
keywords = ["omada", "omada sdn upgrade"]
description = "Recently few people contacted for instructions on upgrading omada controller from v4.x to v5.x. This can be straight forward but there is a slight chance that you might loose all the data/config of the controller."
showFullContent = false
readingTime = true
+++

Recently few people contacted for instructions on upgrading omada controller from v4.x to v5.x. This can be straight forward but there is a slight chance that you might loose all the data/config of the controller.

Upgrade on hardware controller is stright, you go to the ` settings >> Controller Settings >> Maintenance >> Firmware ` and check for upgrade and controllers takes care of everything.

But for selfhsoted controller, upgrade can be different based on the method you've installed the controller like either with ` .deb ` package on debian or ` tarball `.

## Back from Controller

Please download the backup from controller setting if anything goes wrong

To download the backup, go to ` settings >> Controller Settings >> Maintenance >> Backup & Restore >> backup ` and select the duration data you want to backup and click ` Download Backup Files `.

## Upgrade path for `.deb` package

Stop the controller with ` sudo tpeap stop `

You should see about like below.

```bash
sudo tpeap stop
Stopping Omada Controller
Stop successfully.
```

Uninstall the controller with `sudo apt remove omadac`

```bash
sudo apt remove omadac
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following packages will be REMOVED:
  omadac
0 upgraded, 0 newly installed, 1 to remove and 0 not upgraded.
After this operation, 110 MB disk space will be freed.
Do you want to continue? [Y/n]
```

Select `Y` and hit `Enter` to continue

```bash
(Reading database ... 95806 files and directories currently installed.)
Removing omadac (4.4.4) ...
Omada Controller will be uninstalled from [/opt/tplink/EAPController] (y/n):
```

Select `y` and hit `Enter` to continue and prompts the following

```bash
Do you want to backup controller settings (y/n):
```

Select `Y` and hit `Enter` to start the backup.

You should see similor output as below

``` bash
Backup controller settings to /opt/tplink/EAPController/../omada_db_backup success.
Processing triggers for systemd (245.4-4ubuntu3.15) ...
```

Backup will be stored at `/opt/tplink/omada_db_backup` in `omada.db.tar.gz`.

Make a copy of the backup for safe keeping with following to the users home directory.

```bash
cp /opt/tplink/omada_db_backup/omada.db.tar.gz  ~/omada.db.tar.gz
```

Now Download the latest version from TP-Link website. As of this writing `v5.0.30` is the latest version.

`wget https://static.tp-link.com/upload/software/2022/202201/20220120/Omada_SDN_Controller_v5.0.30_linux_x64.deb`

Install the Controller with `sudo dpkg -i Omada_SDN_Controller_v5.0.30_linux_x64.deb`

``` bash
sudo dpkg -i Omada_SDN_Controller_v5.0.30_linux_x64.deb
Selecting previously unselected package omadac.
(Reading database ... 95541 files and directories currently installed.)
Preparing to unpack Omada_SDN_Controller_v5.0.30_linux_x64.deb ...
Unpacking omadac (5.0.30) ...
Setting up omadac (5.0.30) ...
Install Omada Controller succeeded!
==========================
Omada Controller detects that you have backup previous setting before, will you import it (y/n):
```

Select `Y` and hit `Enter` to import the backup. You should see output similor to here below

``` bash
Import previous setting seccess.
Omada Controller will start up with system boot. You can also control it by [/usr/bin/tpeap].
check omada
Starting Omada Controller. Please wait..................
Started successfully.
You can visit http://localhost:8088 on this host to manage the wireless network.
========================
Processing triggers for systemd (245.4-4ubuntu3.15) ...
```

Visit `http://controller_ip:8088` to check the controller is running or not.

## Upgrade the Install from `tarball`

First, Stop the controller with `sudo tpeap stop`

You should see about like below.

``` bash
sudo tpeap stop
Stopping Omada Controller
Stop successfully.
```

you need `tarball` of the current version you've installed. To download visit [Omada Controller Download](https://www.tp-link.com/en/support/download/omada-software-controller/v4/)

untar with archive with following. Change the version based on your install.

`tar -xvzf Omada_SDN_Controller_v4.4.4_linux_x64.tar.gz`

Open the directory and ruin following to uninstall the controller.

``` bash
sudo ./uninstall.sh
Omada Controller will be uninstalled from [/opt/tplink/EAPController] (y/n): 
```

Select `Y` and hit `Enter` uninstall the controller.

```bash
Do you want to backup database [/opt/tplink/EAPController/data/db] (y/n): 
```

Select `Y` and hit `Enter` to backup the controller.

```bash
Uninstall Omada Controller successfully.
```

Download the latest version tarball

`wget https://static.tp-link.com/upload/software/2022/202201/20220120/Omada_SDN_Controller_v5.0.30_linux_x64.tar.gz`

untar with archive with following. Change the version based on your install.

`tar -xvzf Omada_SDN_Controller_v5.0.30_linux_x64.tar.gz`

change directory to the untar and Install the latest version with the following.

```bash
sudo ./install.sh
Omada Controller will be installed in [/opt/tplink/EAPController] (y/n):
```

Select `Y` and hit `Enter` install the controller.

```bash
======================
Installation start ...
Install Omada Controller succeeded!
==========================
Omada Controller detects that you have backup previous setting before, will you import it (y/n):
```

Select `Y` and hit `Enter` import the backup.

you should see something similor to the following

```bash
Import previous setting seccess.
Omada Controller will start up with system boot. You can also control it by [/usr/bin/tpeap].
Starting Omada Controller. Please wait.......................
Started successfully.
You can visit http://localhost:8088 on this host to manage the wireless network.
```

Visit `http://controller_ip:8088` to check the controller is running or not.

## Conclusion

Upgrading can be nerve wracking as you loose all the data and config of the controller and you need start from scratch. This may cause internet outage to your network based the network setup you've.

If something went wrong and you lost the backup, you still've backup from controller setup. Install the controller again and just import the back from controller settings.

I Hope this was helpfull. If you need more help hit me on [twitter](https://twitter.com/kdpuvvadi) or shoot an [Email](https://blog.puvvadi.me/contact).

Au revoir.
