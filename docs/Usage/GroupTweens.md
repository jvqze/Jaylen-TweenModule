---
sidebar_position: 4
---

# Group Tweens

Group multiple models or parts into one controller:

```lua
local Groups = TweenModule.Groups
local MyFavoriteUnbiasedGroup = Groups.new(workspace.Model1, workspace.Model2)

MyFavoriteUnbiasedGroup:Move("SineInOut:2", CFrame.new(0, 5, 0), true)
MyFavoriteUnbiasedGroup:Color("OutBounce:1", Color3.fromRGB(0, 255, 0))
MyFavoriteUnbiasedGroup:Add(workspace.Model3)
MyFavoriteUnbiasedGroup:Remove(workspace.Model1)
```

:::info
All the functions you use for `Models`, `Folders`, & `BaseParts`, they work with groups. The only change is that instead of using `.Move`, it would be `:Move`,
and you don't have to identify the `target` or `instance`, they're already defined by the group, this is the same for the other functions.
:::
