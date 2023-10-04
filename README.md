# Blog

[Jekyll](https://jekyllrb.com/) Blog running on [Cloudflare](https://cloudflare.com) with theme [Chirpy](https://chirpy.cotes.page/)

Live [URL](https://blog.puvvadi.me)

## Testing

```shell
yarn install # install dependencies
yarn start # live test
yarn build # build
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
      version = "4.16.0"
    }
    vercel = {
      source  = "vercel/vercel"
      version = "0.15.1"
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
