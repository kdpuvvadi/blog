+++
title = "Fix Winget Microsoft Store entries"
date = "2021-10-14T10:34:37+05:30"
author = ""
authorTwitter = "kdpuvvadi" #do not include @
cover = "/image/winget-msstore.webp"
tags = ["winget", "packagemanager", "cli" ]
keywords = ["winget", "Microsoft", "Microsoft store"]
description = "Remove Microsoft Store from Winget as a source"
showFullContent = false
readingTime = true
+++

Back when Microsoft launched [Winget](https://github.com/microsoft/winget-cli), a new package manager for windows 10, only source was it's own [winget-pkgs](https://github.com/microsoft/winget-pkgs). Recently Microsoft added support for Microsoft Store apps. It caused a lot problems and it's impossible to upgrade some apps even with exact argument.

Let's see. You have python 3.9.x installed on you pc and want to upgrade to python 3.10.x. You would try following usually to upgrade the package.

```powershell
winget upgrade python3
```

You expect the app to upgrade but you get the following.

```powershell
Multiple installed packages found matching input criteria. Please refine the input.
Name                   Id
-------------------------------------------------------------
Python 3               Python.Python.3
Python 3.10.0 (64-bit) {21b42743-c8f9-49d7-b8b6-b5855317c7ed}
```

You could use exact argument `-e` to upgrade.

```powershell
winget upgrade -e Python.Python.3
```

But you get the same result. To avoid this you could specify which source to use.

```powershell
winget upgrade python3 --source winget 
```

To avoid this, you could just remove the **msstore** store from the store list completely.

```powershell
winget source remove msstore
```

Please make sure to run it with elevated command prompt or PowerShell.
