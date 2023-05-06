+++
title = "Deploy and Manage your site on Vercel with Terraform"
date = "2023-02-26T14:05:30+05:30"
author = "kdpuvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = "/image/vercel-cloudflare-terraform.webp"
tags = ["terraform", "Cloudflare", "Vercel"]
keywords = ["terraform", "Cloudflare", "Vercel"]
description = "Deploy and manage your Vercel website with infrastructure as a code using terraform"
showFullContent = false
readingTime = true
hideComments = false
+++

I'm running this blog on [vercel](https://vercel.com/) with [Hugo](https://gohugo.io/) static site generator and manage my DNS with [Cloudflare](https://www.cloudflare.com/). Managing it on two separate dashboards may not be that challenging but it's annoying and what the state of the site is always unknown. So, like any other DevOps engineer do, I'm managing my blog with terraform. With the [terraform](https://www.terraform.io/) state will always be same across all the devices and it'll be easy to manage. I'm also using terraform cloud for this but let's talk about that on another day.

## Installing Terraform

Follow the instructions based on the your operating system.

### Windows

{{< code language="pwsh" title="Install terraform in windows">}}
winget install --id Hashicorp.Terraform
{{< /code >}}

### Debian

{{< code language="bash" title="Install terraform in debian">}}
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
{{< /code >}}

### RHEL

{{< code language="bash" title="Install terraform in RHEL">}}
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
{{< /code >}}

### MacOS

{{< code language="bash" title="Install terraform in MacOS">}}
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
{{< /code >}}

open terminal and test it with `terraform version`

you should see something like this.

{{< code language="bash">}}
Terraform v1.3.9
on linux_amd64
{{< /code >}}

## Providers

Providers are interfaces that interact with their API and maintain the architecture.

Here we are using Vercel and Cloudflare providers. We can keep all our terraform configuration in single file or keep them separate.

{{< code language="hcl" title="Terraform Providers" >}}
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 0.11.4"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.0.0"
    }
  }
}
{{< /code >}}

To communicate with the Vercel and Cloudflare, you can either create a variable and pass on the Auth tokens or You can use environment variable.

### Vercel

With variable

{{< code language="hcl" >}}
provider "vercel" {
  api_token = var.vercel_api_token
}

variable "vercel_api_token" {
  type      = string
  sensitive = true
}
{{< /code >}}

To use Environment variable

{{< code language="shell" >}}
export VERCEL_API_TOKEN='token'
{{< /code >}}

### Cloudflare

with variable

{{< code language="hcl" >}}
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}
{{< /code >}}

## Vercel Project

First create a project on vercel with `vercel_project`,

{{< code language="hcl" >}}
resource "vercel_project" "test_project" {
  name      = "test_blog"
  framework = "hugo"

  git_repository = {
    type = "github"
    repo = "kdpuvvadi/vercel_hugo_blog"
  }
}
{{< /code >}}

Here I'm using [Hugo](https://gohugo.io/) for testing. Any framework can be used from `NextJs` to just a html page. Also, git repo should be provided. GitHub, Gitlab or Bitbucket can be used.

## Environment Variables

Environment variables can also be set here such as which version of NodeJS to be used, which version of Hugo to be used and etc.

{{< code language="hcl" >}}
resource "vercel_project_environment_variable" "test_env" {
  project_id = vercel_project.test_project.id
  key        = "HUGO_VERSION"
  value      = "0.110.0"
  target     = ["production"]
}
{{< /code >}}

## Deploy the site

Deploy the project with `vercel_deployment`

{{< code language="hcl" >}}
resource "vercel_deployment" "test_deploy" {
  project_id = vercel_project.test_project.id
  ref        = "main"
  production = "true"

  project_settings = {
    build_command    = "hugo --gc --minify"
    output_directory = "/public"
    root_directory   = "/"
  }
}
{{< /code >}}

## Add Domain to the project

Add custom domain to the project with `vercel_project_domain`

{{< code language="hcl" >}}
resource "vercel_project_domain" "test_domain" {
  project_id = vercel_project.test_project.id
  domain     = "example.com"
}
{{< /code >}}

## Cloudflare zone

To add a CNAME record or A record to the Cloudflare, we need zone ID. To get the zone ID, get the record data with `cloudflare_zones` and filter the data

{{< code language="hcl">}}
data "cloudflare_zones" "get_zone_data" {
  filter {
    name = "example.com"
  }
}
{{< /code >}}

Zone is available at `data.cloudflare_zones.get_zone_data.zones[0].id`

## Add record on Cloudflare

Add DNS record on Cloudflare to point to the vercel site with `cloudflare_record`. Vercel deployment URL is available from deployment config at `vercel_deployment.test_deploy.domains[0]`.

{{< code language="hcl">}}
resource "cloudflare_record" "zone_blog_record" {
  zone_id = data.cloudflare_zones.get_zone_data.zones[0].id
  name    = "@"
  value   = vercel_deployment.test_deploy.domains[0]
  type    = "CNAME"
  proxied = true
  ttl     = 1
}
{{< /code >}}

## Deployment

### Initialize

To Initialize the terraform and install the providers, run

{{< code language="shell">}}
terraform init
{{< /code >}}

Terraform will install the providers and required module.

### Validation

Before running the configuration, you should validate it to check everything is sound and good.

{{< code language="shell">}}
terraform validate
{{< /code >}}

Output should looks like this

{{< code language="shell">}}
$ terraform validate
Success! The configuration is valid.
Plan and Apply
{{< /code >}}

### Planning

Before deploying plan can be created with plan argument and can be saved.

{{< code language="shell">}}
terraform plan
{{< /code >}}

Output should be something like

{{< code language="shell">}}
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
.
.
.
{{< /code >}}

### Apply

To make changes run

{{< code language="shell">}}
terraform apply
{{< /code >}}

And terraform will prompt for confirmation and only accepts `yes` to apply changes.

{{< code language="shell">}}
Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.

Enter a value:
{{< /code >}}

Enter yes to continue.

After making any changes make sure validate and apply again. To refresh the state of the site run `terraform refresh`

Project will be deployed and DNS record will be added to the Cloudflare.

## Conclusion

With the terraform, making changes are very easy and state can be maintained. Au Revoir.
