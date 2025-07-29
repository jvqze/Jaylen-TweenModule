require(game:GetService("ServerScriptService").Runtime):Init()

--[[  
-- Jaylen's (jayziac) TweenModule! \ Inspired by link_cable --  
--

--------------------------------------------------------------------------------
-- QUICK SETUP:
--------------------------------------------------------------------------------

Move the TweenModule ModuleScript to the Special Folder of your map (or put it anywhere you would like)

-- local TweenModule = require(map.Special.TweenModule)

-- Example Usage:
-- TweenModule.Move(workspace.Part, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), CFrame.new(0, 10, 0), true)

--------------------------------------------------------------------------------
-- FUNCTIONS:
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- CustomTween (Tweens any property of an instance with an optional callback)
-------------------------------------------------------------------------------
-- TweenModule.CustomTween(target, tweenInfo, properties, callback)
--
-- Parameters:
-- target      -> (Instance) The instance to tween (e.g., workspace.Part)
-- tweenInfo   -> (TweenInfo) Defines duration, easing, etc.
-- properties  -> (Dictionary) { PropertyName = Value } (e.g., {Transparency = 0.5})
-- callback    -> (Function, optional) Function to execute after the tween completes.
--
-- Example:
-- TweenModule.CustomTween(workspace.Part, TweenInfo.new(1), {Transparency = 0.5}, function()
--     print("Tween Completed!")
-- end)

-------------------------------------------------------------------------------
-- Move (Moves an object with optional pivot-based movement)
-------------------------------------------------------------------------------
-- TweenModule.Move(target, tweenInfo, movement, byPivot)
--
-- Parameters:
-- target      -> (PVInstance) Part or Model to move.
-- tweenInfo   -> (TweenInfo) Duration, easing style, etc.
-- movement    -> (CFrame) The movement offset or absolute position.
-- byPivot     -> (Boolean) Moves relative to its pivot if true, otherwise moves to an absolute position.
--
-- Example:
-- TweenModule.Move(workspace.Part, TweenInfo.new(2), CFrame.new(5, 10, 0), true)

-------------------------------------------------------------------------------
-- Rotate (Rotates an object in world space or around its pivot)
-------------------------------------------------------------------------------
-- TweenModule.Rotate(target, tweenInfo, rotation, byPivot)
--
-- Parameters:
-- rotation    -> (Vector3) Rotation in degrees {X, Y, Z}
-- byPivot     -> (Boolean) Rotates relative to pivot if true, otherwise rotates in world space.
--
-- Example:
-- TweenModule.Rotate(workspace.Part, TweenInfo.new(2), Vector3.new(0, 90, 0), true)

-------------------------------------------------------------------------------
-- Scale (Scales an object with optional position adjustment)
-------------------------------------------------------------------------------
-- TweenModule.Scale(target, tweenInfo, scaleTo, adjustPosition)
--
-- Parameters:
-- scaleTo         -> (Vector3) Scaling amounts {X, Y, Z}
-- adjustPosition  -> (Boolean) Moves object while scaling.
--
-- Example:
-- TweenModule.Scale(workspace.Part, TweenInfo.new(2), Vector3.new(2, 2, 2), true)

-------------------------------------------------------------------------------
-- Transparency (Sets an object to a specified transparency)
-------------------------------------------------------------------------------
-- TweenModule.Transparency(target, tweenInfo, transparency)
--
-- Parameters:
-- transparency -> (Number) 0 (opaque) → 1 (invisible).
--
-- Example:
-- TweenModule.Transparency(workspace.Part, TweenInfo.new(1), 0.5)

-------------------------------------------------------------------------------
-- Color (Changes the color of an object)
-------------------------------------------------------------------------------
-- TweenModule.Color(target, tweenInfo, ColorTo)
--
-- Parameters:
-- ColorTo -> (Color3) Target color (e.g., Color3.fromRGB(255, 100, 100))
--
-- Example:
-- TweenModule.Color(workspace.Part, TweenInfo.new(2), Color3.fromRGB(255, 100, 100))

-------------------------------------------------------------------------------
-- Shake (Applies a shaking effect to an object)
-------------------------------------------------------------------------------
-- TweenModule.Shake(target, duration, intensity, individually)
--
-- Parameters:
-- duration     -> (Number) Shake time, -1 for infinite.
-- intensity    -> (Number) Strength of the shake.
-- individually -> (Boolean) If true, shakes parts in a model separately.
--
-- Example:
-- local stopShake = TweenModule.Shake(workspace.Part, -1, 2, true)
-- task.wait(5)
-- stopShake() -- Stops the shake after 5 seconds
-------------------------------------------------------------------------------
-- Jiggle (Creates a jiggling motion effect, useful for softbody physics)
-------------------------------------------------------------------------------
-- TweenModule.Jiggle(target, tweenInfo, intensity, repeatCount)
--
-- Parameters:
-- intensity   -> (Number) Strength of jiggle.
-- repeatCount -> (Number) How many times to jiggle.
--
-- Example:
-- TweenModule.Jiggle(workspace.Part, TweenInfo.new(0.5), 5, 3)
-------------------------------------------------------------------------------
-- SequenceTween (Interpolates ColorSequence, NumberSequence, or numerical properties)
-------------------------------------------------------------------------------
-- TweenModule.SequenceTween(target, tweenInfo, properties, universal)
--
-- Parameters:
-- target     -> (Instance) The object to tween. Can be a Beam, UIGradient, or 
--               any instance with interpolatable properties.
-- tweenInfo  -> (TweenInfo) Configuration for the tween (time, easing style, etc.).
-- properties -> (Table) A dictionary of properties to tween (e.g., Color, 
--               Transparency, CurveSize0).
-- universal  -> (Boolean) If true, applies to all child instances that 
--               support tweening.
--
-- Example:
-- TweenModule.SequenceTween(workspace.ModelWithBeam, TweenInfo.new(3, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut), {
--     Color = Color3.new(1, 0, 1), -- Tween to Purple
--     Transparency = NumberSequence.new({
--         NumberSequenceKeypoint.new(0, 0),
--         NumberSequenceKeypoint.new(1, 1)
--     }),
--     CurveSize0 = 45
-- }, true)
-------------------------------------------------------------------------------
-- VARIABLES EXPLAINED:
-------------------------------------------------------------------------------
-- Standard Parameters:
-- target      -> (Instance) The object to tween.
-- tweenInfo   -> (TweenInfo) Duration, easing style, etc.
-- properties  -> (Dictionary) {Property = Value}
-- callback    -> (Function) Runs when tween completes.

-- Special Parameters:
-- CFrame      -> (CFrame) Position or rotation transformation.
-- Vector3     -> (Vector3) Scaling or positional change.
-- Color3      -> (Color3) RGB color values.

-------------------------------------------------------------------------------
-- Q/A:
-------------------------------------------------------------------------------

-- Q: How do I stop an infinite Shake?
-- local stopShake = TweenModule.Shake(workspace.Part, -1, 2, true)
-- task.wait(5)
-- stopShake() -- Stops the shake after 5 seconds.

-- Q: Why is my model moving unexpectedly?
-- Make sure you're using byPivot = true if you want relative movement.

-- Q: Can I use this for UI elements?
-- Yes! The module can tween UI properties like Size, Position, or Transparency.

-------------------------------------------------------------------------------
-- CONTACT:
-------------------------------------------------------------------------------
-- Roblox: @jayziac / 5558646286
-- Discord: jvqze
--]]