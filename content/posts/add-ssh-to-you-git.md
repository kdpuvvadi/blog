---
title: "Add SSH to You Git"
date: 2021-11-06T10:50:52+05:30
draft: true
---

First Remove remote to avoid conflicts

```bash
git remote origin remove
```

### Generate SSH keys

```bash
ssh-keygen -C "your_email@example.com"
```

Select default location and when prompted for passcode enter key phrase to secure the key if need, otherwise leave it empty. Default location for SSH key `/home/username/.ssh`

Output should look something like this

```bash
Generating public/private rsa key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa): 
Created directory '/home/user/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/user/.ssh/id_rsa.
Your public key has been saved in /home/user/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:jbnE9oEj6VFpG7EYZ6872PWEEBxkLytkqW6D8hbDxos your_email@example.com
The key's randomart image is:
+---[RSA 2048]----+
|      .oO.       |
|       B.B       |
|      = O o      |
|     + = % .     |
| o  . = S = .    |
|  *o . O * +     |
|.o.++ o = . .    |
|Eoo. .   .       |
| ..              |
+----[SHA256]-----+
```

### Display the public key with 

```bash
cat ~/.ssh/id_rsa.pub
```

Copy all the contents


### Add SSH key to your GitHub account

To add the key to GitHub, go to `github.com > Settings > SSH and GPG keys`

Select `New SSH key`, Paste the copied public key contents  in the `key` section. 
Provide a title and click on `Add SSH key`

To add repository, go to `GitHub repo > Click on Code > select SSH`. Copy the link.
Usually link would looks like this `git@github.com:username/repo_name.git`

### Add repo to your project 

```bash
git remote add origin git@github.com:username/repo_name.git
```
