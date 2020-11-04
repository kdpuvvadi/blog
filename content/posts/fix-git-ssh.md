+++
title = "Fix Git SSH Permissions"
date = "2020-11-02T16:59:49+05:30"
author = "KD"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["git", "ssh"]
keywords = ["Dev","Tech"]
description = "Fix permission errors while using git with SSH"
showFullContent = false
+++

![](/image/gitlab-access-denied-publickey.jpg)

When you try to *git push* it throws Permission Denied(publickey) error.

```
<pre class="wp-block-code">
Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

When this keeps happening and you think you’ve already added the public key in the GitLab or BitBucket or any other. You might’ve added key in ***Pageant*** which comes with putty but git doen’t use the key from there. To solve this, open ***git bash*** as Administator. *(Don’t use [windows terminal](https://kd.puvvadi.me/launch-windows-terminal-from-cmd/) or default CMD, better use \*nix cli)*

- Type **<span style="text-decoration: underline;">*cd ~/.ssh*</span>** It will take you to *%userprofile%/.ssh* or C:/users/*username*/.ssh
- Run *<span style="text-decoration: underline;">**ls**</span>*, there should be two file ***id\_rsa*** and ***id\_rsa.pub***
- If those files are alredy there, then copy the content of ***id\_rsa.pub*** file and paste it in the key section of git service provider.
- if not continue bellow steps.
- To create SSH key type the following ***<span style="text-decoration: underline;">ssh-keygen -t rsa -C “your\_email@example.com”</span>***
- replace ***your\_email@example.com*** with your email address. If you wish set a keyphrase for the key add it when it prompts.
- Now do the<span style="text-decoration: underline;"> ***ls***</span>, both files should be created by now. Open the directory and copy the contents of id\_rsa.pub file to the key section of your git provides.
- Now try pushing the git repo with ***git push***, it should work by now.