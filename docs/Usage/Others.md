---
sidebar_position: 5
---

# Features & Functions

Here to show more features and functions that the TweenModule has!

## [Tween by Tag](https://jvqze.github.io/Jaylen-TweenModule/api/TweenModule#TweenTag)

Tween anything tagged with `CollectionService`:

```lua
TweenModule.TweenTag("Tweenable", "ElasticOut:2", { Transparency = 0.5 })
```

## [Chain Tweens](https://jvqze.github.io/Jaylen-TweenModule/api/TweenModule#ChainTween)

Play multiple tweens one after the other:

```lua
TweenModule.ChainTween({
    { instance = workspace.Part1, tweenInfo = "SineOut:1", props = { Transparency = 0.2 } },
    { instance = workspace.Part1, tweenInfo = "SineIn:1", props = { Transparency = 1 } },
}, function()
    print("Finished chain!")
end)
```

## [Color Support](https://jvqze.github.io/Jaylen-TweenModule/api/TweenModule#Color)

Supports:

- `Color3`
- `BrickColor`
- Hex strings like `"#ff0000"`

```lua
TweenModule.Color(workspace.Part, "QuadOut:1", BrickColor.new("Bright blue"))
TweenModule.Color(workspace.Part, "OutElastic:1", "#FFB6C1")
```

## [Beam / Curve Tweening](https://jvqze.github.io/Jaylen-TweenModule/api/TweenModule#SequenceTween)

```lua
TweenModule.SequenceTween(workspace.MyBeam, "SineInOut:2", {
    Color = ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 0, 1)),
    CurveSize0 = 2,
}, true)
```

## [Shake](https://jvqze.github.io/Jaylen-TweenModule/api/TweenModule#Shake)

```lua
TweenModule.Shake(workspace.Part, 2, 5, false)
```

Shakes a part for 2 seconds at intensity 5. Use `-1` for infinite shake (stop manually).

## [Scale](https://jvqze.github.io/Jaylen-TweenModule/api/TweenModule#Scale)

```lua
TweenModule.Scale(workspace.Model, "SineOut:1", Vector3.new(2, 2, 2), true, false)
```

- `adjustPosition = true`: Moves part as it scales.
- `scaledByModel = true`: Preserves relative offsets inside the model.
