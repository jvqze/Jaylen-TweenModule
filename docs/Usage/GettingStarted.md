---
sidebar_position: 2
---

# Getting Started

Before doing anything with your code, you need to identify TweenModule.

```lua
local TweenModule = require(Path.To.TweenModule)
```

:::danger Are you using this TweenModule for TRIA.os and receiving an error about a Script not implementing Runtime?
If you're using this specifically for **[TRIA.os](https://www.roblox.com/games/6311279644/TRIA-os-Escape)**, go to the `TweenModule` and put this on line 1

```lua
require(game:GetService("ServerScriptService").Runtime):Init()
```

If it still doesn't work, please check for any of your scripts that doesn't have Runtime on line 1.

:::
