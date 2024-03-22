---
title: "Deploy Kubernetes cluster on DigitalOcean with terraform"
date: "2022-09-15T10:48:36Z"
author: kdpuvvadi
tags: [k8s, digitalocean, terraform]
categories: [k8s, digitalocean, terraform]
---

## Installing Terraform

To install terraform, follow installation instructions [here](/posts/terraform-azure-getting-started#installing-terraform).

## Digital Ocean provider

```hcl
terraform {
  required_providers {
    digitalocean: {
      source : "digitalocean/digitalocean"
      version: "2.22.3"
    }
  }
}
```

## Authentication

Authentication can be done either with environment variables or terraform variables.

### Windows PowerShell

Open PowerShell and run the following to add new environment variable.

```shell
$ENV:DIGITALOCEAN_ACCESS_TOKEN: 'token'
```

To set the token as environment variable Persistently

```shell
[System.Environment]::SetEnvironmentVariable('DIGITALOCEAN_ACCESS_TOKEN','token')
```

### Bash

```shell
export DIGITALOCEAN_ACCESS_TOKEN='token'
```

To set the token as environment variable Persistently

```shelll
echo 'export DIGITALOCEAN_ACCESS_TOKEN='token'' >> ~/.profile
```

> Replace token with the actual `token`.
{: .prompt-tip }

Using Terraform variables
Create `var.tf` and add following

```hcl
variable "do_token" {
    type= string
    description= "Digital Ocean API Token"
    sensitive= true
}
```

And add following to `provider.tf`

```hcl
provider "digitalocean" {
  token= var.do_token
}
```

## Variables

Variables and their default values

| variable             | Remarks                      | Default          |
|----------------------|------------------------------|------------------|
| do_cluster_name      | Cluster Name                 | k8s-test         |
| do_region            | Region                       | sfo3             |
| do_pool_name         | Cluster Pool Name            | k8s-test-pool    |
| do_node_size         | Node CPu and Memory          | s-1vcpu-2gb      |
| do_nodepool_count    | No's nodes                   | 1                |
| do_pool_ad_name      | Additional Pool Name         | k8s-test-pool-ad |
| do_node_ad_size      | Node CPu and Memory          | s-1vcpu-2gb      |
| do_nodepool_ad_count | Node CPu and Memory          | 1                |
| do_nodepool_scale    | Enable Autoscaling           | true             |
| do_node_max          | Max no's nodes for autoscale | 3                |

## Cluster

Cluster module can be found in `k8s.tf`

### k8s version

Get latest `k8s` version supported by Digital Ocean with `digitalocean_kubernetes_versions` data source.

```hcl
data "digitalocean_kubernetes_versions" "get_version" {}
```

To use version prefix, add `version_prefix: "1.24"`

```hcl
data "digitalocean_kubernetes_versions" "get_version" {
    version_prefix: "1.24."
}
```

### Cluster with pool

deploy cluster with version from version above

```hcl
resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name   = var.do_cluster_name
  region : var.do_region
  version: data.digitalocean_kubernetes_versions.get_version.latest_version

  node_pool {
    name      = var.do_pool_name
    size      = var.do_node_size
    auto_scale= var.do_nodepool_scale
    min_nodes = var.do_nodepool_count
    max_nodes = var.do_node_max
  }
}
```

### Additional pool

```hcl
resource "digitalocean_kubernetes_node_pool" "k8s_cluster_pool_ad" {
  cluster_id: digitalocean_kubernetes_cluster.k8s_cluster.id

  name      = var.do_pool_ad_name
  size      = var.do_node_ad_size
  auto_scale= var.do_nodepool_scale
  min_nodes = var.do_nodepool_ad_count
  max_nodes = var.do_node_max
}
```

## Deploying

Before deploying make sure everything is as per spec by validating with

```bash
terraform validate
```

Plan the deployment with

```bash
terraform plan
```

Deploy the cluster with

```bash
terraform deploy
```

> Append `-var "do_token=token"` to use different token.
{: .prompt-tip }

## Destroy

To destroy the infrastructure, run

```bash
terraform destroy
```

> Append `-var "do_token=token"` to use different token.
{: .prompt-tip }

## Conclusion

Everything used here is in publicly available repo on GitHub [here](https://github.com/kdpuvvadi/digitalocean-k8s-terraform).Check the official documentation [here](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs). Feel free to comment here. [Au Revoir](## Conclusion).
