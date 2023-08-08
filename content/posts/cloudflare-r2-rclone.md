+++
title = "Cloudflare R2 with rclone"
date = "2023-08-08T10:04:41+05:30"
author = "KD Puvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["cloudflare", "R2", "S3", "rclone", "storage"]
keywords = ["cloudflare", "R2", "S3", "rclone", "storage"]
description = "Recently we've decided to move our archival data from S3 to Cloudflare's R2. R2 is S3 compatible object storage and comes with the benefits of `No egress fees` but with different price model."
showFullContent = false
readingTime = true
hideComments = false
+++

Recently we've decided to migrate our archival data from S3 to Cloudflare's R2. R2 is S3 compatible object storage and comes with the benefits of `No egress fees` but with different price model. You only pay for the storage you've used & Number of operation divided into `Class A` & `Class B`. For detailed pricing checkout CLoudflare's [Developer docs](https://developers.cloudflare.com/r2/pricing)

## Current setup

We've been using `rclone` to manage our data on S3. At the end of the day, data marked for archival will be copied to S3 with `rclone sync`.

Current `rclone` config looks something like the below placed at `~/.config/rclone/rclone.conf` on *nix or
`$ENV:AppData\rclone\rclone.conf` on windows.

```config
[s3archive]
type = s3
provider = AWS
env_auth = false
access_key_id = <access_key>
secret_access_key = <secret_key>
endpoint =
acl = private
region = <region>
location_constraint =
storage_class =
```

## R2 config

Cloudflare uses different authentication for R2 than their regular `TOkEN`/`KEY`. Key id, secret pair are required. To generate, navigate to R2 Dashboard and click on `Manage R2 API Tokens` and Select `Create API Token`. Add Name, Permission & Scope and Expiry then Click on Create API Token. You'll be granted `Token`, `Key ID` and `Secret Access Key`. Keep these in the safe place, you won't be able to access them again after clicking on the finish.

You also need `Account ID` of your cloudflare account. R2 config for rclone should look something like this.

Data bucket can be created from R2 Dashboard or with `rclone`.

```config
[r2]
type = s3
provider = Cloudflare
access_key_id = <access_key>
secret_access_key = <secret_key>
region = auto
endpoint = https://<cloudflare_account_id>.r2.cloudflarestorage.com/
```

> For available regions checkout [R2 Docs](https://developers.cloudflare.com/r2/buckets/data-location/)

To list the bucket, run

```shell
$ rclone lsf r2:
my-bucket/
data-bucket/
```

To check the file structure

```shell
$ rclone tree r2:data-bucket
/
├── IMG
│   ├── test1.jpg
│   ├── test2.jpg
│   └── test3.jpg
└── Docs
    ├── test1.pdf
    ├── test2.pdf
    └── test3.pdf

2 directories, 6 files
```

To copy files

```shell
$ rclone copy /path/to/files/ r2:my-bucket -v
.
.
.
Transferred:              0 B / 0 B, -, 0 B/s, ETA -
Checks:                 6 / 6, 100%
Elapsed time:         2.2s
```

## Conclusion

In place of `sync` can also be used but if the data in the current directly is not in the remote, all other remote objects will be deleted. For safety, use `--dry-run`. For more checkout rclone [documentation](https://rclone.org/commands/).

To speed up the first time writing data to R2, use `rclone copy` instead of `sync`. `bisync` is also available but it's still available for production. At the end of the pricing all the matters. Main selling point of R2 is no egress fees. If your application don't have much egress or doesn't make sense for you, it might not for you or at worst, you might be slapped with more fees. Any feedback or queries, feel free to comment here or reach out. `Au Revoir`.
