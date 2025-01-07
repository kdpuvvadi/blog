# Blog

[Jekyll](https://jekyllrb.com/) Blog running on [Cloudflare](https://cloudflare.com) with theme [Chirpy](https://chirpy.cotes.page/)

Live [URL](https://blog.puvvadi.me)

## Testing

```shell
bundle install
jekyll serve --config _config_preview.yml # live test
jekyll serve --config _config_preview.yml --drafts # live test with drafts
bundle exec jekyll build --config _config_preview.yml # preview build
bundle exec jekyll build --config _config.yml # production build
```

check the output at `http://localhost:4000`

## Deployment

Deploying with [terraform](https://terraform.io/) using [terraform cloud](app.terraform.io) on Cloudflare Pages. `Github actions` runs the `terraform apply` when changes to the terraform directory pushed. Config can be found under `terraform` directory.

providers in terraform

```hcl
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.48.0"
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

## License

Licensed under [MIT](/LICENSE)
