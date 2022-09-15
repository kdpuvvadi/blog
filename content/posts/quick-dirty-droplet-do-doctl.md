+++
title = "Quick and Dirty way to deploy droplets with doctl"
date = "2021-12-02T11:10:24+05:30"
author = "KD Puvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["doctl", "digitalocean"]
keywords = ["", ""]
description = ""
showFullContent = false
readingTime = true
+++


We use DigitalOcean as our main infrastructure and in our development cycle as disposable machines. We deploy the vm, install the stack with ansible and do the things and dispose that. I suggested to our upper management that we need to build simple automation tool that can do all of this with digitalocean `API` but they though building that might divert the resources current project but allowed to work on that few hours a week.

So, decided to write a small and simple shell script to deploy droplets with interactive prompts while we work on the platform. It has to be simple, quick and dirty.

## Requirements

- It has to be simple
- I've to work on my free time.
- So, it has to quick. Hence doctl & cli
- All the regions,sizes and distros that we use should be available.

## Selection

We decided to use public key at `~/.ssh/id_rsa.pub` for key based authentication. As most of the devs already added their key to DO's teams account.

We use Ubuntu 20.04, 21.04 and CentOS 7, 8. We've production env at SFO 2 & 3, BLR1, SGP1 and NYC 1 & 2.

## Building

Instead using root user then setup user account with ansible We decided to go with cloud-init for user setup on the vm as it's simple to implement and DigitalOcean already supports that in their cli platform.

```yaml
#cloud-config
users:
  - name: username
    ssh-authorized-keys:
      - pubkey
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/shell
runcmd:
  - sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
  - sed -i -e '$aAllowUsers ansible' /etc/ssh/sshd_config
  - restart ssh
```

`username` and `pubkey` fields will be populated with the main script using `sed`. Also, root login being disabled with `cloud-init`

When we first wrote the script, we would check `doctl` is installed or not then throw error with `please install doctl` and exit.

```shell
doctl >/dev/null 2>/dev/null

if [ "$?" != 0 ]; then
    echo "Error!" 1>&2
    echo "please install doctl"
    exit 127
fi
```

But later devs just wanted to install doctl with same script. As soon as the installation completed, prompting for AUTH token for authentication.

```shell
doctl >/dev/null 2>/dev/null

if [ "$?" != 0 ]; 
then 
    echo "Error!" 1>&2
    echo "doctl is not installed."
    echo -n "Install doctl?[Y/N]" && read -r reply 
    if [[ $reply =~ ^(Y|y)$ ]];
    then
        echo "Installing doctl"
        # Get doctl latest version
        latestver=$(curl --silent "https://api.github.com/repos/digitalocean/doctl/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//g')
        
        #get system arch
        sysarch=$(dpkg --print-architecture)

        #latest version uri
        downURL="https://github.com/digitalocean/doctl/releases/download/v$latestver/doctl-$latestver-linux-$sysarch.tar.gz"

        # Download the latest release
        wget $downURL 

        # Extract archive
        echo Extracting the archive
        tar -xvf doctl-$latestver-linux-$sysarch.tar.gz

        # Move
        echo Installing
        sudo mv doctl /usr/local/bin
        if test -f "/usr/local/bin/doctl"; then
            echo done
        fi

        #cleanup
        echo cleaning up
        rm -rf doctl-$latestver-*
        echo done

        echo "Setup doctl auth. Please keep the auth token ready"
        echo "Start Authentication?[Y/N]"
        doctl auth init --context default
        
    else
        echo "Error!" 1>&2
        echo please install doctl
        exit 127
    fi
fi
```

If the user wants to install it manually, all they have to do is select anything other than y for the prompt.

To check and import user pub key to their account

First get the MD5 of the key from `~/.ssh/id_rsa.pub` then extract on the signature with `cut`

```shell
ssh_key=$(ssh-keygen -E md5 -lf ~/.ssh/id_rsa.pub | cut -b 10-56)
```

Get ssh keys from users account

```shell
doctlkeys=$(doctl compute ssh-key list | awk '{print $3}' | sed '/FingerPrint/d')
```

Check key is present in the user account, if not import it.

```shell
if [[ "$doctlkeys" != *"$ssh_key"* ]]; then
    echo "SSH key not added"
    sleep 1
    echo "Adding pub key to DigitalOcean"
    sysHost=$(cat /etc/hostname | sed 's/\.//g')
    doctl compute ssh-key import $sysHost --public-key-file ~/.ssh/id_rsa.pub
fi
```

With all that, key logic should look something like this.

```shell
ssh_key=$(ssh-keygen -E md5 -lf ~/.ssh/id_rsa.pub | cut -b 10-56)

# get keys from doctl
doctlkeys=$(doctl compute ssh-key list | awk '{print $3}' | sed '/FingerPrint/d')

#check key is present
if [[ "$doctlkeys" != *"$ssh_key"* ]]; then
    echo "SSH key not added"
    sleep 1
    echo "Adding pub key to DigitalOcean"
    sysHost=$(cat /etc/hostname | sed 's/\.//g')
    doctl compute ssh-key import $sysHost --public-key-file ~/.ssh/id_rsa.pub
fi
```

changing the username and pubkey with user prompt and ssh key.

```shell
echo -n 'Enter username of droplet:' && read -r User_Name

# Copy init file
cp copy.init.yml init.yml

# replace username
sed -i -e "s/username/$User_Name/" init.yml

# add pub key
key_pub=$(cat ~/.ssh/id_rsa.pub)
sed -i -e "s|pubkey|$key_pub|" init.yml
```

Selection is as simple as follows

```shell
PS3='Select the Size of VPS: '
Size=("s-1vcpu-1gb" "s-1vcpu-2gb" "s-2vcpu-2gb" )
select opt3 in "${Size[@]}"

do
    case $opt3 in
        "s-1vcpu-1gb")
            Server_size="s-1vcpu-1gb"
            break
            ;;
        "s-1vcpu-2gb")
            Server_size="s-1vcpu-2gb"
            break
            ;;
        "s-2vcpu-2gb")
            Server_size="s-2vcpu-2gb"
            break
            ;;
        *) echo "invalid option $REPLY";; 
    esac
done
```

Once the user selection completed, simply deploying droplet with `doctl compute droplet create` and to make sure it's provisioned using `--wait` flag to return only if the provisioning completed. After that simply listing the droplets with `doctl compute droplet list`

## GitHub

## Clone

```shell
git clone https://github.com/kdpuvvadi/doctl-deploy.git && cd doctl-deploy
```

## deploy

```shell
chmod u+x deploy.sh
./deploy.sh
```

## Roadmap & Conclusion

Our platform using DigitalOcean's API is still under development as there aren't any dedicated resources allocated to it. In the meantime planning on porting this to `powershell` for the devs who's on windows platform. They can use this on windows with `WSL2` though.

See you soon *Au revoir*
