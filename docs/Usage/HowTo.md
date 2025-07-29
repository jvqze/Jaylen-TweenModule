# How do I use this?

Welcome to **Jaylen's TweenModule** — a powerful and flexible tweening utility for Roblox that supports:

- Custom easing profile strings like `"SineOut:1.5:0:true:0"`
- Group tweening for multiple models or parts
- Folder support (folders are treated like models)
- Built-in utility functions like `:Move`, `:Color`, `:Scale`, `:Rotate`, `:Shake`, and more

## Getting Started

Before doing anything with your code, you need to identify TweenModule.

```lua
local TweenModule = require(Path.To.TweenModule)
```

:::danger Are you using this TweenModule and receiving an error about a Script not implementing Runtime?
If you're using this specifically for **[TRIA.os](https://www.roblox.com/games/6311279644/TRIA-os-Escape)**, go to the `TweenModule` and put this on line 1
:::

```lua
require(game:GetService("ServerScriptService").Runtime):Init()
```

If it still doesn't work, please check for any of your scripts that doesn't have Runtime on line 1.

## Basic Tween

You can tween any BasePart or Model like so:

```lua
TweenModule.Move(workspace.MyPart, "SineOut:1", Vector3.new(0, 10, 0), false)
```

This moves `MyPart` 10 studs up over 1 second using Sine easing outward.

## TweenInfo: String or Instance

:::info
All functions in TweenModule accept either a `TweenInfo` object or a `TweenInfo` string.
:::

### Option 1: TweenInfo.new

You can use the default TweenInfo like this:

```lua
TweenModule.Move(workspace.Part, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), Vector3.new(0, 5, 0), true)
```

### Option 2: TweenInfo String Profile Format

You can also pass a string with this format:

```lua
<EasingStyle><EasingDirection>:[Duration]:[RepeatCount]:[Reverses]:[DelayTime]
```

:::caution Please note
Only the **EasingStyle**+**EasingDirection** are required.
:::

#### Example

```lua
TweenModule.Color(workspace.Model, "QuadInOut:1.5:0:true:0", Color3.fromRGB(255, 100, 100))
```

This uses `Quad` easing in & out for 1.5 seconds, does not repeat, reverses once, and has no delay.

## Group Tweens

Group multiple models or parts into one controller:

```lua
local Groups = TweenModule.Groups
local MyFavoriteUnbiasedGroup = Groups.new(workspace.Model1, workspace.Model2)

MyFavoriteUnbiasedGroup:Move("SineInOut:2", CFrame.new(0, 5, 0), true)
MyFavoriteUnbiasedGroup:Color("OutBounce:1", Color3.fromRGB(0, 255, 0))
MyFavoriteUnbiasedGroup:Add(workspace.Model3)
MyFavoriteUnbiasedGroup:Remove(workspace.Model1)
```

## Tween by Tag

Tween anything tagged with CollectionService:

```lua
TweenModule.TweenTag("Tweenable", "ElasticOut:2", { Transparency = 0.5 })
```

## Chain Tweens

Play multiple tweens one after the other:

```lua
TweenModule.ChainTween({
    { instance = workspace.Part1, tweenInfo = "SineOut:1", props = { Transparency = 0.2 } },
    { instance = workspace.Part1, tweenInfo = "SineIn:1", props = { Transparency = 1 } },
}, function()
    print("Finished chain!")
end)
```

## Color Support

Supports:

- `Color3`
- `BrickColor`
- Hex strings like `"#ff0000"`

```lua
TweenModule.Color(workspace.Part, "QuadOut:1", BrickColor.new("Bright blue"))
TweenModule.Color(workspace.Part, "OutElastic:1", "#FFB6C1")
```

## Beam / Curve Tweening

```lua
TweenModule.SequenceTween(workspace.MyBeam, "SineInOut:2", {
    Color = ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 0, 1)),
    CurveSize0 = 2,
}, true)
```

## Shake

```lua
TweenModule.Shake(workspace.Part, 2, 5, false)
```

Shakes a part for 2 seconds at intensity 5. Use `-1` for infinite shake (stop manually).

## Scale

```lua
TweenModule.Scale(workspace.Model, "SineOut:1", Vector3.new(2, 2, 2), true, false)
```

- `adjustPosition = true`: Moves part as it scales.
- `scaledByModel = true`: Preserves relative offsets inside the model.
