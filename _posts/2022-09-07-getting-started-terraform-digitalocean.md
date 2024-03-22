---
title: "Getting Started with Terraform & Digitalocean"
date: "2022-09-07T14:08:49+05:30"
author: kdpuvvadi
tags: [terraform, iac, digitalocean, cloud]
keywords: [terraform, digitalocean]
---

## Installing Terraform

> Follow Installation Instructions [here](/posts/terraform-azure-getting-started#installing-terraform").
{: .prompt-tip }

## Terraform

Create a directory where you want to store the terraform configuration files. Create a file named main.tf. This is where we store all the configurations.

Adding providers block

```hcl
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.36.0"
    }
  }
}
```

As of this writing, digitalocean's terraform provider is of version `2.36.0`.

## Initialize

To Initialize the terraform and install the azure plugin, you should run

```bash
terraform init
```

Output should be similar to this

```shell
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding digitalocean/digitalocean versions matching "2.36.0"...
- Installing digitalocean/digitalocean v2.36.0...
- Installed digitalocean/digitalocean v2.36.0 (signed by a HashiCorp partner, key ID F82037E524B9C0E8)
```

## Generating DigitalOcean API Token

Terraform needs API Token to communicate with DigitalOcean and to deploy the infrastructure. Generate the API token by going to `DigitalOcean` >> `API` >> `Tokens/Keys`.

> Please copy new personal access token now. It won't be shown again for security.
{: .prompt-info }

## Authentication

Authentication can be done either with environment variables or terraform variables.

### Windows PowerShell

Open `Powershell` and run the following to add new environment variable.

```shell
$ENV:DIGITALOCEAN_ACCESS_TOKEN: 'token'
```

To set the token as environment variable Persistently

```shell
[System.Environment]::SetEnvironmentVariable('DIGITALOCEAN_ACCESS_TOKEN','token')
```

### Bash

```bash
export DIGITALOCEAN_ACCESS_TOKEN='token'
```

To set the token as environment variable Persistently

```bash
echo 'export DIGITALOCEAN_ACCESS_TOKEN='token'' >> ~/.profile
```

> Replace `token` with the actual token.
{: .prompt-tip }

### Using Terraform variables

Create `var.tf` and add following

```hcl
variable "do_token" {
  type         =  string
  description  =  "Digital Ocean API Token"
  sensitive    =  true
}
```

And add following to `main.tf`

```hcl
provider "digitalocean" {
  token =  var.do_token
}
```

## Create a Droplet

To create a droplet, create a new file `droplet.tf` and add following

```hcl
resource "digitalocean_droplet" "terraform_droplet" {
  image  = "ubuntu-22-04-x64"
  name   = "web-1"
  region = "nyc2"
  size   = "s-1vcpu-1gb"
}
```

Here I'm using `Ubuntu 22.04 LTS` image and using basic `size` with 1vCPU and 1GB of RAM on deploying it in the `nyc2`. You can choose whatever you like.

To add ssh key to the account add following to either separate `ssh.tf` or `droplet.tf`

```hcl
resource "digitalocean_ssh_key" "ssh_default" {
  name      = "terraform ssh"
  public_key= file("~/.ssh/id_rsa.pub")
}
```

and attach newly added ssh key to the droplet. updated `droplet.tf` should look like this

```hcl
resource "digitalocean_droplet" "terraform_droplet" {
  image   = "ubuntu-22-04-x64"
  name    = "terraform"
  region  = "blr1"
  size    = "s-1vcpu-1gb"
  ssh_keys= [digitalocean_ssh_key.ssh_default.fingerprint]
}
```

> if the given key is already added to you account, terraform throws the error. in that case, remove ssh block and just add MD5 fingerprint of the public key to the droplet block.
{: .prompt-tip }

To get the `MD5 fingerprint of the key run

```bash
ssh-keygen -lf  ~/.ssh/id_rsa.pub -E MD5
```

Updated `droplet.tf` should look like this

```hcl
resource "digitalocean_droplet" "terraform_droplet" {
  image   = "ubuntu-22-04-x64"
  name    = "terraform"
  region  = "blr1"
  size    = "s-1vcpu-1gb"
  ssh_keys= ["a0:b1:c2:3d:4e:5f:g6:h7:i8:9j:0k:1l:2m:n3:o4:p5"]
}
```

### cloud init

To pass user data run commands such as adding users, adding groups or install any tools on droplet on first launch, specify user data file `init.yml`

```yaml
#cloud-config

users:
  - default
  - name: terraform
    gecos: terraform
    shell: /bin/bash
    primary_group: terraform
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: users, admin, sudo
    lock_passwd: false
    ssh_authorized_keys:
        - pubkey
runcmd:
  - apt update
  - apt upgrade -y
  - apt install curl -y
```

Updated `droplet.tf` should look something like this

```hcl
resource "digitalocean_droplet" "terraform_droplet" {
  image = "ubuntu-22-04-x64"
  name  = "terraform"
  region= "blr1"
  size  = "s-1vcpu-1gb"
  user_data= file("init.yml")
  ssh_keys=` [digitalocean_ssh_key.ssh_default.fingerprint]
}
```

## Outputs

After deploying the droplet, we might need it's ip address to proceed. To capture that, we need to create a variable and pass deployed droplet ip to that variable.

Create `outputs.tf` and add following

```hcl
output "ip_address" {
  value= digitalocean_droplet.terraform_droplet.ipv4_address
  description= "The public IP address of your droplet."
}
```

## Deploy

To validate code run `terraform validate`. If everything is valid and no syntactical errors are there, output should be like

```bash
$ terraform validate
Success! The configuration is valid.
```

To dry run the everything and to see what are the changes, run

```bash
terraform plan
```

If terraform variable were used to define authentication token

```bash
terraform plan -var="do_token=token"
```

```hcl
terraform plan

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the

following symbols:
  + create

Terraform will perform the following actions:

  # digitalocean_droplet.terraform_droplet will be created
  + resource "digitalocean_droplet" "terraform_droplet" {
      + backups             : false
      + created_at          : (known after apply)
      + disk                : (known after apply)
      + graceful_shutdown   : false
      + id                  : (known after apply)
      + image               : "ubuntu-22-04-x64"
      + ipv4_address        : (known after apply)
      + ipv4_address_private: (known after apply)
      + ipv6                : false
      + ipv6_address        : (known after apply)
      + locked              : (known after apply)
      + memory              : (known after apply)
      + monitoring          : false
      + name                : "terraform"
      + price_hourly        : (known after apply)
      + price_monthly       : (known after apply)
      + private_networking  : (known after apply)
      + region              : "blr1"
      + resize_disk         : true
      + size                : "s-1vcpu-1gb"
      + status              : (known after apply)
      + urn                 : (known after apply)
      + user_data           : "0743846df7e7237339701a0bd8d31d35945590cb"
      + vcpus               : (known after apply)
      + volume_ids          : (known after apply)
      + vpc_uuid            : (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ip_address: (known after apply)

you run "terraform apply" now.
```

To deploy the droplet run

```hcl
terraform deploy
```

If terraform variable were used to define authentication token

```bash
terraform deploy -var="do_token=token"
```

Answer `yes` to the prompt to deploy

```hcl
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

Once completed, outputs the ip and status

```hcl
terraform deploy
.
.
.
.
digitalocean_droplet.terraform_droplet: Creation complete after 1m29s [id=123456789]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

ip_address: "123.456.798.10"
```

## Destroy

To destroy the infrastructure, run

```hcl
terraform destroy
```

Answer the prompt with `yes` to destroy

```hcl
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

## Conclusion

Everything used here is in publicly available repo on GitHub [here](https://github.com/kdpuvvadi/terraform-digitalocean-starter)

Check the official documentation [here](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs). Feel free to comment here or drop an [email](/contact). Au Revoir.
