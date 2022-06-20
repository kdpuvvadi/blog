+++
title = "Fix Git SSH Permissions"
date = "2020-11-02T16:59:49+05:30"
author = "KD"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["git", "SSH"]
keywords = ["Dev","Tech"]
description = "Fix permission errors while using git with SSH"
showFullContent = false
draft= true
+++

![access denied ssh](https://cdn.puvvadi.me/img/gitlab-access-denied-publickey.webp)

When you try to *git push* it throws Permission Denied(public key) error.

```bash
<pre class="wp-block-code">
Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

When this keeps happening and you think you’ve already added the public key in the GitLab or BitBucket or any other. You might’ve added key in `Pageant` which comes with putty but git doesn’t use the key from there. To solve this, open `git bash` as Administrator. Don’t use [windows terminal](/posts/launch-windows-terminal-cmd/) or default CMD, better use \*nix cli.

- Type `cd ~/.ssh` It will take you to `%userprofile%/.ssh` or `C:/users/%username%/.ssh`
- Run `ls`, there should be two file `id_rsa` and `id_rsa.pub`
- If those files are already there, then copy the content of `id_rsa.pub` file and paste it in the key section of git service provider.
- if not continue bellow steps.
- To create SSH key type the following `ssh-keygen -t rsa -C “your_email@example.com”`
- replace `your_email@example.com` with your email address. If you wish set a key phrase for the key add it when it prompts.
- Now do the `ls`, both files should be created by now. Open the directory and copy the contents of id_rsa.pub file to the key section of your git provides.
- Now try pushing the git repo with `git push`, it should work by now.
