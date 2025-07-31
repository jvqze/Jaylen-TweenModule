---
sidebar_position: 3
---

# Basic Tweening

You can tween any `BasePart` or `Model` like so:

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
`<>` means required & `[]` means optional.
:::

#### Example

```lua
TweenModule.Color(workspace.Model, "QuadInOut:1.5:0:true:0", Color3.fromRGB(255, 100, 100))
```

This uses `Enum.EasingStyle.Quad` and using `Enum.EasingDiection.InOut` for 1.5 seconds, does **not** repeat, reverses **once**, and has **no delay**.
