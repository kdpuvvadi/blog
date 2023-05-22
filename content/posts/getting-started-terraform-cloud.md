+++
title = "Getting Started with Terraform Cloud"
date = "2023-05-17T23:04:51+05:30"
author = "kdpuvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["terraform", "hashicorp", "terraform cloud"]
keywords = ["terraform", "hashicorp", "terraform cloud"]
description = "Getting started with Terraform Cloud and sync your organization's Infrastructure state upto date and readily available to your teams "
showFullContent = false
readingTime = true
hideComments = false
+++

Terraformis very good at keep the state of the Infrastructure up to date. By default state is stored in `terraform.tfstate` and stored on local machine. But big downside is keeping the state up to date between the all the members of the teams of Engineers & who has the latest state. It can lead to data loss and revenue loss. If the state can be stored in a central location and synced across the engineers with
latest current state.

There are multiple ways to do that. such as

- Terraform Cloud
- Terraform backend

[Terraform Cloud](https://app.terraform.io/) is free start and has flexible pricing. Signup [here](https://app.terraform.io/public/signup/account) for free.

[Terraformn backend](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) is similor to Terraform Cloud but state can saved on multiple cloud providers such as `aws`, `gcp`, `azre` and etc.

Opensource selfhosted alternative to Terraform Cloud are [otf](https://github.com/leg100/otf), [digger](https://github.com/diggerhq/digger), [terrakube](https://github.com/AzBuilder/terrakube).

## Terraform Cloud Login

To login to the terraform cloud, run `terraform login`, it will open a browser window and navigate the `Tokens` section in `User Settings`. Provide Name and Expiry of the token and copy the token and enter it in the terminal.

## Create Workspace

Create a workspace in Terraform Cloud and you can select Default project or create separate project. Select `CLI-driven workflow`

## Terraform Cloud config

To initialize the terraform cloud, Add a cloud block to the directory's Terraform configuration, to specify which organization and workspace(s) to use.

```hcl
terraform {
  cloud {
    organization = "my-org"

    workspaces {
      name = "demo-workspace"
    }
  }
}
```

You can also use environment variables to configure cloud block attributes such as `organization` and `workspace` with `TF_CLOUD_ORGANIZATION` and `TF_WORKSPACE` respectively. These will come in handy when running in CI/CD pipelines.

## Terraform initialization

Initialize terraform with `init` argument.

```shell
$terraform init

Initializing Terraform Cloud...
.
.
.
.
Terraform Cloud has been successfully initialized!

You may now begin working with Terraform Cloud. Try running "terraform plan" to
see any changes that are required for your infrastructure.

If you ever set or change modules or Terraform Settings, run "terraform init"
again to reinitialize your working directory.
```

## Run the config

On the first run, if the state is stored locally, terraform will prompt to migrate the state to the cloud. Upon on selecting `yes`, state will be moved to the cloud and can be access by anyone in the team by simply providing the access the project and workspace.

## Conclusion

Terraform Cloud is easy to manage and will be on the lighter side on the chanrges too. Makes sence for smaller teams. But your organisation wants to selfhost the terraform cloud, Terraform Enterprise is a selfthosted Terraform Cloud with SSO and other features. But needs hefty check and on role engineers to managing and administration.

As menstioned above, there are plenty of opensource alternatives. My personal favorite is [otf](https://github.com/leg100/otf). But does not come with any support, you manager might not like that. Any how, keep building `Au Revoir`.
