+++
title = "Getting Started with Terraform for Microsoft Azure "
date = "2022-03-18T14:15:58+05:30"
author = "KD Puvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["terraform", "iac", "azure", "cloud"]
keywords = ["Terraform", "Azure"]
description = "Getting Started with Terraform for Microsoft Azure to deploy infrastructure with code."
showFullContent = false
readingTime = true
+++

Infrastructure as Code is a god send for system admins and devops teams around the world. With [Terraform](https://www.terraform.io/) it's a walk in the park.

## Installing Terraform

Follow the instructions based on the your operating system.

### Windows

Visit [Terraform](https://www.terraform.io/downloads)'s downloads page & Windows. Select the architecture and download zip file to your windows pc.

Once downloaded, extract the archive file and copy the **terraform.exe** to safe location, something like **C:/tools/** and set the path to environment variables.

### debian

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

### RHEL

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```

### MacOS

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

open terminal and test it with

```bash
terraform version
```

you should see something like this.

```bash
Terraform v1.1.7
on windows_amd64
```

## Azure Shell install

To run on azure, terraform use default Azure login stored in `.azure` direcotry on user home. To login, Azure CLI needs to be installed. Download the CLI from [Microsoft](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli). Once download completed, installed the Azure CLI and Open the Powershell or Windows Terminal.

To login, run

```bash
az login
```

It should show something similor to this

```bash
 az login
A web browser has been opened at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize. Please continue the login in the web browser. If no web browser is available or if the web browser fails to open, use device code flow with `az login --use-device-code`.
```

It'll open the default browser of you system and prompts for microsoft account login. Continue login in the browser.

Once the login completed, it'll output the subscription details

```bash
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "",
    "id": "",
    "isDefault": true,
    "managedByTenants": [],
    "name": "",
    "state": "Enabled",
    "tenantId": "",
    "user": {
      "name": "user@gmail.com",
      "type": "user"
    }
  }
]
```

You can check the this details in the future with

```bash
az account show
```

To view the output as a table

```bash
az account show -o table
```

## Terraform

Create a direcotry where you want to store the terraform configaration files. Create a file named `main.tf`. Thi i where we store all the configs.

First add azure plugin details in the `main.tf`

```json
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.99.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}
```

To create a resource group to add any resources on azure,

```json
resource "azurerm_resource_group" "south1" {
  name     = "region-southindia"
  location = "southindia"
  tags = {
    "environment" = "dev"
    "source"      = "terraform"
  }
}
```

Here, resource type i `azurerm_resource_group` and resource name is `south1` which we can define as want.

Tags can be used to with `"key" = "Value"` as many as you want.

You should see some thing like this in `main.tf`

```json
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.99.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_resource_group" "south1" {
  name     = "region-southindia"
  location = "southindia"
  tags = {
    "environment" = "dev"
    "source"      = "terraform"
  }
}
```

### Initialize

To Initialize the terraform and install the azure plugin, you should run

```bash
terraform init
```

output should be something similor

```bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "2.99.0"...
- Installing hashicorp/azurerm v2.99.0...
- Installed hashicorp/azurerm v2.99.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### format

To format all the config properly run

```bash
terraform fmt
```

### Validation

Before running the config, you should validate it to check everything is sound.

```bash
terraform validate
```

Output should looks like this

```bash
$ terraform validate
Success! The configuration is valid.
```

### Plan and Apply

To check modification and what's actully change on live infrastructure, run

```bash
terraform plan
```

```bash
$ terraform.exe plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.south1 will be created
  + resource "azurerm_resource_group" "south1" {
      + id       = (known after apply)
      + location = "southindia"
      + name     = "region-southindia"
      + tags     = {
          + "environment" = "dev"
          + "source"      = "terraform"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

> Here `+` means create.

To make changes run

```bash
terraform apply
```

And terraform will prompt from confirmation and only accepts `yes` to apply changes.

```bash
Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.

Enter a value: yes
```

Enter `yes` to continue.

```bash
azurerm_resource_group.south1: Creating...
azurerm_resource_group.south1: Creation complete after 2s [id=/subscriptions/id/resourceGroups/region-southindia]
```

To check wether the changes made here are working or not, login to azure dashboard and check resource groups.

### Delete the resources

To delete the resource created, run

```bash
terraform destroy
```

Enter `yes` to approve the changes.

## Conslusion

With Terraform, sky is the limit for managing infrastructure. Check the azure documentation [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs). Feel free to comment here or drop an [email](/contact). Au Revoir.
