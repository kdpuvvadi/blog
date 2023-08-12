---
title: "Setup No Password Login for WordPress"
layout: post
tags: [wordpress, trusona, 2fa]
categories: [wordpress, 2fa]
image: /assets/img/trusona-login-wordpress.webp
---

Passwords can be tricky. They are hard to remember and easy to guess and easy to be stolen. And there is Human element and our stupid brains always wants use same or similar passwords for login on every other website, including social networks, Personal email and Works emails etc.

When it comes to WordPress, this can be more damaging. If your business website is compromised because of some weak password or any other human elements. Chance of password compromise increases with the number of people administrating the site.

If you remove the “PASSWORD” from the equation and setup password less login to your WordPress business website or your blog using WordPress it reduces the chance of password compromise. Keep in mind, though, it won’t protect from week firewall or Zero-day from poorly coded plugin or theme. You should always use security plugin. I personally recommend `secure`, it has great features and User friendly.

To start, your WordPress site should be already set up and you only need to install one plugin and no configuration or complicated API setups are not required.

`Trusona`, Security/authentication service used by American Federal Services like FBI, CIA, etc. to make sure said person is accessing the service. It is available to consumers free of charge.

Go to `Dashboard` > `Plugins` > `Add New` and Search for `Trusona`

![Trusona](/assets/img/trusona.webp)

Click on Install and after installation, Activate. I’ve already installed the plugin and activated. WordPress side of things are done for now.

To actually use it, install the app on your mobile device **Android** or **iOS**. After installing the app, Open the application and touch on hamburger menu and click on Email. Add an email used for WordPress user and Click enter and Confirm the Prompt.

![email trusona](/assets/img/trusona-email.webp)

You will receive a confirmation email. Confirm the email and you’ll be asked to use Fingerprint on Android or FaceID/TouchID on iOS to make sure you are authenticating.

Pretty much setup is completed. To test the login, logout of WordPress and you will see change in the login screen.

![wordpress trusona login](/assets/img/trusona-login-wordpress.webp)

Click on Login with Trusona, You’ll be navigated to Trusona website and will prompted with QR Code. Open the Trusona Application, Scan the code and Confirm with Fingerprint.FaceID/TouchID. You’ll be logged into your WordPress.

To Actually disable the Password login, Go to *Dashboard > Settings > Trusona* and Make sure you’ve checked Trusona ONLY Mode.

![trusona options](/assets/img/trusona-options.webp)

**Trusona Only Mode**: Disable the password and Only use Trusona for Added security

If are running membership website or users usually signup to use the services enable **Self-Service Account Creation** to let the users signup using Trusona.
