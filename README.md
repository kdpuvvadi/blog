# Blog

[Hugo](https://gohugo.io/) Blog running on [Cloudflare](https://cloudflare.com) with theme [Terminal](https://github.com/panr/hugo-theme-terminal)

Live [URL](https://blog.puvvadi.me)

## Testing

```shell
hugo server
```

check the output at `http://localhost:1313`

## Deployment

Deploying with [terraform](https://terraform.io/) using [terraform cloud](app.terraform.io) on Cloudflare Pages. `Github actions` runs the `terraform apply` when changes to the terraform directory pushed. Config can be found under `terraform` directory.

providers in terraform

```hcl
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.8.0"
    }
  }
  cloud {
    organization = "KDPuvvadi"

    workspaces {
      name = "blog"
    }
  }
}
```

Build configurations to manually deploy

```ini
Build command: hugo --gc --minify
Build output directory: /public
Root directory: /
Build comments on pull requests: Enabled
```

Environment variables

```env
HUGO_VERSION = "0.113.0"
NODE_VERSION = "18.16.0"
```

> Running this is `0.113.0`, you can change it to latest Hugo Build (Make sure to test it locally before deploying).

## Posts

- [Getting Started With Azure Iot Hub](https://blog.puvvadi.me/posts/getting-started-with-azure-iot-hub/)
- [Getting Started with Terraform Cloud](https://blog.puvvadi.me/posts/getting-started-terraform-cloud/)
- [Deploy and Manage your site on cloudflare with Terraform](https://blog.puvvadi.me/posts/cloudflare-pages-terraform/)
- [Deploy and Manage your site on Vercel with Terraform](https://blog.puvvadi.me/posts/manage-static-site-vercel-terraform/)
- [Use GitHub as commenting system for Hugo](https://blog.puvvadi.me/posts/github-comments-hugo-giscus/)
- [Deploy Kubernetes cluster on DigitalOcean with terraform](https://blog.puvvadi.me/posts/digitalocean-kubernetes-terraform/)
- [Getting Started with Terraform & Digitalocean](https://blog.puvvadi.me/posts/getting-started-terraform-digitalocean/)
- [Getting Started with Terraform for Microsoft Azure](https://blog.puvvadi.me/posts/terraform-azure-getting-started/)
- [Upgrade the Omada Controller](https://blog.puvvadi.me/posts/upgrade-omada-controller/)
- [Quick and Dirty way to deploy droplets with doctl](https://blog.puvvadi.me/posts/quick-dirty-droplet-do-doctl/)
- [Fix Winget Microsoft Store entries](https://blog.puvvadi.me/posts/winget-fix-msstore/)
- [Install Omada Controller with Ansible playbook](https://blog.puvvadi.me/posts/install-omada-controller-ansible/)
- [Install Omada Controller on Ubuntu 20.04](https://blog.puvvadi.me/posts/omada-sdn-controller-ubuntu/)
- [Getting Started With Hugo in Windows and Free Hosting with Netlify](https://blog.puvvadi.me/posts/getting-started-with-hugo-windows/)
- [Access Home Assistant from anywhere securely with DuckDNS, Let’s Encrypt and NGINX](https://blog.puvvadi.me/posts/set-up-duckdns-home-assistant-letsencrypt-nginx-duckdns/)
- [Connecting Nodemcu to Home Assistant](https://blog.puvvadi.me/posts/home-assistant-nodemcu/)
- [Home Assistant Setup on Raspberry Pi](https://blog.puvvadi.me/posts/home-assistant-setup/)
- [Add Contact form to Hugo with Google forms](https://blog.puvvadi.me/posts/add-contact-form-hugo-google-forms/)
- [Portainer on Wsl2](https://blog.puvvadi.me/posts/portainer-on-wsl2/)
- [Setup No Password Login for WordPress](https://blog.puvvadi.me/posts/setup-no-password-login-for-wordpress/)

## License

Licensed under [MIT](/LICENSE)

Uses [terminal](https://github.com/panr/hugo-theme-terminal) by [panr](https://github.com/panr)
