+++
title = "Deploy and Manage your site on cloudflare with Terraform"
date = "2023-05-17T14:20:30+05:30"
author = "kdpuvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["terraform", "Cloudflare", "pages", "hugo"]
keywords = ["terraform", "Cloudflare", "pages"]
description = "Deploy and manage your website with infrastructure as a code using terraform on CLoudflare pages"
showFullContent = false
readingTime = true
hideComments = false
+++

previously i've published guide on deploying your site on [vercel](https://vercel.com/) with terraform. Now let's deploy it on [cloudflare](https://cloudflare.com/) with terraform. I'm running this blog with [Hugo](https://gohugo.io/) static site generator and manage my DNS with [Cloudflare](https://www.cloudflare.com/). Managing it on GUI may not be that challenging but it's annoying and what the state of the site is always unknown. So, like any other DevOps engineer do, I'm managing my blog with terraform. With the [terraform](https://www.terraform.io/) state will always be same across all the devices and it'll be easy to manage. I'm also using terraform cloud for this but let's talk about that on another day.

## Installing Terraform

Follow the instructions based on the your operating system.

### Windows

```pwsh
winget install --id Hashicorp.Terraform
```

### Debian

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
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

open terminal and test it with `terraform version`

you should see something like this.

```bash
Terraform v1.4.6
on linux_amd64
```

## Providers

Providers are interfaces that interact with their API and maintain the architecture.

Here we are using Vercel and Cloudflare providers. We can keep all our terraform configuration in single file or keep them separate.

```hcl
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.6.0"
    }
  }
}
```

To communicate with the Cloudflare, you can either create a variable and pass on the Auth tokens or You can use environment variable.

Authenticate with variables

```hcl
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}
```

## Account ID

Cloudflare provider requires account id to be added to every config. We can use `cloudflare_accounts` data sources.

```hcl
data "cloudflare_accounts" "cloudflare_account_data" {
  name = "KD Puvvadi"
}
```

## Cloudflare Pages Project

First create a project on vercel with `cloudflare_pages_project`,

```hcl
esource "cloudflare_pages_project" "blog_pages_project" {
  account_id        = data.cloudflare_accounts.cloudflare_account_data.accounts[0].id
  name              = "blog"
  production_branch = "main"

  source {
    type = "github"
    config {
      owner                         = "kdpuvvadi"
      repo_name                     = "blog"
      production_branch             = "main"
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "all"
      preview_branch_includes       = ["*"]
      preview_branch_excludes       = ["main", "prod"]
    }
  }

  build_config {
    build_command       = "hugo --gc --minify"
    destination_dir     = "public"
    root_dir            = ""
  }

  deployment_configs {
    preview {
      environment_variables = {
        HUGO_VERSION = "0.111.0"
        NODE_VERSION = "16.20.0"
      }
      fail_open = true
    }
    production {
      environment_variables = {
        HUGO_VERSION = "0.111.0"
        NODE_VERSION = "16.20.0"
      }
      fail_open = true
    }
  }
}
```

Here I'm using [Hugo](https://gohugo.io/) for testing. Any framework can be used from `NextJs` to just a single page `html` page. Also, git repo should be provided. GitHub, Gitlab or Bitbucket can be used.

## Add Domain to the project

Add custom domain to the project with `cloudflare_pages_domain`

```hcl
resource "cloudflare_pages_domain" "cloudflare_blog_domain" {
  account_id   = data.cloudflare_accounts.cloudflare_account_data.accounts[0].id
  project_name = cloudflare_pages_project.blog_pages_project.name
  domain       = "blog.puvvadi.me"
}
```

## Add record on Cloudflare

Limitation of the `cloudflare_pages_domain` is it does not add `CNAME` record to your zone.

To add a record to the Cloudflare, Zone ID is required. Zone ID can be obtained `cloudflare_zones` data source.

```hcl
data "cloudflare_zones" "zone_puvvadi_me" {
  filter {
    name = "puvvadi.me"
  }
}
```

Zone ID is available at `data.cloudflare_zones.get_zone_data.zones[0].id`.

Add DNS record on Cloudflare to point to the site with `cloudflare_record`. Deployment URL is available from deployment config at `cloudflare_pages_project.blog_pages_project.subdomain`.

```hcl
resource "cloudflare_record" "cloudflare_blog_record" {
  zone_id         = data.cloudflare_zones.zone_puvvadi_me.zones[0].id
  name            = "blog"
  value           = cloudflare_pages_project.blog_pages_project.subdomain
  type            = "CNAME"
  proxied         = true
  ttl             = 1
  allow_overwrite = true
}
```

### Initialize

To Initialize the terraform and install the providers, run

```hcl
terraform init
```

Terraform will install the providers and required module.

### Validation

Before running the configuration, you should validate it to check everything is sound and good.

```hcl
terraform validate
```

Output should looks like this

```hcl
$ terraform validate
Success! The configuration is valid.
Plan and Apply
```

### Planning

Before deploying plan can be created with plan argument and can be saved.

```hcl
terraform plan
```

Output should be something like

```hcl
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
.
.
.
```

### Apply

To make changes run

```hcl
terraform apply
```

And terraform will prompt for confirmation and only accepts `yes` to apply changes.

```hcl
Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.

Enter a value:
```

Enter `yes` to continue.

After making any changes make sure validate and apply again. To refresh the state of the site run `terraform refresh`

Project will be deployed and DNS record will be added to the Cloudflare.

## Conclusion

With the terraform, making changes are very easy and state can be maintained. Au Revoir.
