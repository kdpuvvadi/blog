---
title: "Use GitHub as commenting system for Hugo"
date: "2022-11-01T12:13:32+05:30"
author: kdpuvvadi
---

I was using [Disqus](https://disqus.com/) comments on this blog but i was not satisfied with it. Reasons being, it was increasing load times and sometimes inserting ads, even after opting out and expensive. And there is privacy issue with it. To enable Disqus, all you have to do was signup and add site tag in `config.toml`/`config.yaml`. But i decided to let go and go with `giscus`.

## What is giscus

`giscus` premise is simple. Use GitHub Discussions as a commenting system and integration is plan & simple. Uses github native APIs. All you need is Github account and repo, as you may already have to host the hugo content and others.

## Prerequisites

As mentioned in the documentation repo has to be public and Discussion feature has to be enabled. If your hugo repo is private, you can create a public repo for just comments and use that. To enable discussion feature, goto repo settings and Enable Discussion under `General >> Features`

You need to install giscus app on the repo to be able to add create discussion threads when an user lefts a comment. To install the app goto [giscus app](https://github.com/apps/giscus) in the [Github Marketplace](https://github.com/marketplace), Click on install and follow the suit.

## Install

First you need to add giscus script block to `comments.html` under `layouts >> partials`.

```html
<script src="https://giscus.app/client.js"
    data-repo="[ENTER REPO HERE]"
    data-repo-id="[ENTER REPO ID HERE]"
    data-category="[ENTER CATEGORY NAME HERE]"
    data-category-id="[ENTER CATEGORY ID HERE]"
    data-mapping="pathname"
    data-strict="0"
    data-reactions-enabled="1"
    data-emit-metadata="0"
    data-input-position="bottom"
    data-theme="preferred_color_scheme"
    data-lang="en"
    crossorigin="anonymous"
    async>
</script>
```

Replace the placeholders with actual details of your repo to continue. You can fill repo details and discussion details manually or you can goto [giscus app](https://giscus.app/) and select the repo and auto fills the data.

- `repository`: username/repo-name
- `Page ↔️ Discussions Mapping`: Select based on your preference. It'll be title of Discussions topic of you blog post. I've selected `Discussion title contains page og:title` and added meta tag to `layouts >> head.html`

```html
{% raw %}
<meta property="og:title" content="{{ if .IsHome }}{{ $.Site.Title }}{{ else }}{{ .Title }}{{ end }}">
{% endraw %}
```

- `Discussion Category`: General or create a custom category and select preferred one.
- Select Theme and features.

Copy the `Enable giscus` script block and replace content on `comments.html` under `layouts >> partials`. Your comments.html should look something similor to this.

```html
<script src="https://giscus.app/client.js"
    data-repo="kdpuvvadi/blog"
    data-repo-id="MDEwOlJlcG9zaXRvcnkzMDkyOTI1NzI="
    data-category-id="DIC_kwDOEm9uHM4CSN_-"
    data-mapping="og:title"
    data-strict="0"
    data-reactions-enabled="1"
    data-emit-metadata="0"
    data-input-position="top"
    data-theme="dark"
    data-lang="en"
    data-loading="lazy"
    crossorigin="anonymous"
    async>
</script>
```

## Conculsion

I wanted to run entire hugo blog inside github. Now repo is on GitHub, Hosted under github pages and comments are hosted inside same. At the end of the it's a bad thing to keep all your eggs under one basket but it's a non critical infrastructure. So, i think it's worth it. [Au revoir](#conclusion).
