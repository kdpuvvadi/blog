---
title: "Proxmox 8 Post Installation"
date: "2023-08-25T13:05:53+05:30"
image: /assets/img/proxmox-postinstall.png
tags: [proxmox, guide]
categories: [proxmox, homelab]
authors: [kdpuvvadi]
---

For Homelabers, Proxmox subscription doesn't make sense. These are the following post install step I use.

## Disable 'pve-enterprise' repo

Without any active subscription, updating the proxmox with `enterprise` is not possible. To avoid errors and notices every time update is run, disable the repo.

To disable the `pve-enterprise` repo, edit `/etc/apt/sources.list.d/pve-enterprise.list` and comment out the repo URL

```
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
```
{: file="/etc/apt/sources.list.d/pve-enterprise.list" }

> To enable the repo in the future, remove the comment.
{: .prompt-info }

## Enable 'pve-no-subscription' repo

In the absence of enterprise repo, to update the proxmox, `pve-no-subscription` repo can be used.

To add `pve-no-subscription` repo, create a `pve-no-subscription.list` under `/etc/apt/sources.list.d`. Add following to the file to add and enable the repo.

```
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
```
{: file="/etc/apt/sources.list.d/pve-no-subscription.list" }

## Disable 'No valid subscription' Notice

`No valid subscription` notices can be annoying sometimes. It's bit complicated than the previous once. Proxmox webUI sends the notice. So, we'll disable that particular code block located in `proxmoxlib.js` placed at `/usr/share/javascript/proxmox-widget-toolkit`. 

> Before proceeding, make sure to backup the original file in the safe place. To copy the file, run `cp /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js ~/proxmoxlib.js`. If anything goes wrong, just replace the file.
{: .prompt-warning }

Open `/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js` file with your favourite file editor and find `.data.status.toLowerCase()` block

```js
 .data.status.toLowerCase()! == 'active') {
    Ext.Msg.show({
        title: gettext('No valid subscription'),
        icon: Ext.Msg.WARNING,
```
{: file="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js" }

Replace `active` your choice of word and also remove `!`. It should look something similar as below


```js
 .data.status.toLowerCase() == 'NoWarning') {
    Ext.Msg.show({
        title: gettext('No valid subscription'),
        icon: Ext.Msg.WARNING,
```
{: file="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js" }

> Do not edit any more than you need to. If anything goes wrong, replace the file with backup.
{: .prompt-info }

## Disable High Availability

If you plan on running single node proxmox instance, disabling High Availability(HA) disables unnecessary services. 

To disable ha, 

```shell
systemctl disable -q --now pve-ha-lrm
systemctl disable -q --now pve-ha-crm
systemctl disable -q --now corosync
```

In the future if ha is required, simply run following to enable it.

```shell
systemctl enable -q --now pve-ha-lrm
systemctl enable -q --now pve-ha-crm
systemctl enable -q --now corosync
```

## Updates

Make sure upgrade all the packages. 

```shell
apt update
apt upgrade -y
```

## Conclusion

Any thoughts or feedback, feel free to comment. `Au Revoir`.
