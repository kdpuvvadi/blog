# Blog

[Hugo](https://gohugo.io/) Blog running on [Cloudflare](https://cloudflare.com) with theme [Terminal](https://github.com/panr/hugo-theme-terminal)

Live [URL](https://blog.puvvadi.me)

## Testing

```shell
hugo server
```

check the output at `http://localhost:1313`

## Deployment

### Build configurations

```ini
Build command: hugo --gc --minify
Build output directory: /public
Root directory: /
Build comments on pull requests: Enabled
```

### Environment variables

 `HUGO_VERSION` : `0.88.1`

> Running this is `0.88.1`, you can change it to latest Hugo Build.
