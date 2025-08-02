-- If you need to add RunTime, copy the line via Documentation and replace this line with that

local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--[=[
	@class TweenModule
	@tag TweenModule
	A module for creating and managing tweens in Roblox.
	Provides group tweening, custom profiles, tag-based tweens, and more.
]=]

local TweenModule = {}
TweenModule.Active = {}
TweenModule.Groups = {}
TweenModule.ShowTips = script:GetAttribute("ShowErrorTips")

TweenModule.Enums = {
	Styles = {
		Linear = Enum.EasingStyle.Linear,
		Sine = Enum.EasingStyle.Sine,
		Back = Enum.EasingStyle.Back,
		Bounce = Enum.EasingStyle.Bounce,
		Circular = Enum.EasingStyle.Circular,
		Cubic = Enum.EasingStyle.Cubic,
		Elastic = Enum.EasingStyle.Elastic,
		Exponential = Enum.EasingStyle.Exponential,
		Quad = Enum.EasingStyle.Quad,
		Quart = Enum.EasingStyle.Quart,
		Quint = Enum.EasingStyle.Quint,
	},
	Directions = {
		In = Enum.EasingDirection.In,
		Out = Enum.EasingDirection.Out,
		InOut = Enum.EasingDirection.InOut,
	},
}

local BasePartPool = table.create(10)

local CommonPropertyTypos = {
	["Transperency"] = "Transparency",
	["Colur"] = "Color",
	["Szie"] = "Size",
	["Postion"] = "Position",
}

local ErrorTips = {
	["attempt to index nil"] = {
		tip = "You might be tweening an object that doesn't exist or couldn't be found. Make sure the instance you're trying to tween is valid.",
	},
	["invalid argument #%d+"] = {
		tip = "A value passed into TweenService or TweenInfo may be the wrong type. Use `number`, `UDim2`, `Vector3`, etc. — not strings like `'0.5'`.",
	},
	["expected .* got .*"] = {
		tip = "One of your arguments is the wrong type. Double-check the value types you're passing.",
	},
	["not a valid member"] = {
		tip = "This error usually means you mistyped a property name. Check for typos like `Transperency` instead of `Transparency`.",
		suggest = function(err)
			for typo, correct in pairs(CommonPropertyTypos) do
				if err:find(typo) then
					return ("Did you mean `%s` instead of `%s`?"):format(correct, typo)
				end
			end
		end,
	},
	["TweenService:Create.*failed"] = {
		tip = "You're probably trying to tween a non-tweenable property. Only use `Transparency`, `Size`, `Position`, `Color`, etc.",
	},
}

local function LogError(context: string, err: string)
	error(("[%s] : %s"):format(context, err))
end

local function HandleError(context: string, err: string)
	LogError(context, err)

	if not TweenModule.ShowTips then
		return
	end

	for Pattern, Data in pairs(ErrorTips) do
		if err:match(Pattern) then
			warn("[Jaylen's TweenModule TIP] " .. Data.tip)
			if Data.suggest then
				local suggestion = Data.suggest(err)
				if suggestion then
					warn("[Jaylen's TweenModule Suggestion] " .. suggestion)
				end
			end
		end
	end
end

local function ParseTweenProfile(ProfileName: string): TweenInfo?
	if not ProfileName then
		LogError("ParseTweenProfile", "No profile name provided (got nil)")
		return nil
	end

	local EasingStyleMatch, EasingDirectionMatch
	local duration, repeatCount, reverses, delayTime = 1, 0, false, 0

	local segments = string.split(ProfileName, ":")
	local ProfileSegment = segments[1]:lower()

	local SortedDirections = {}

	for DirectionName, DirectionEnum in pairs(TweenModule.Enums.Directions) do
		table.insert(SortedDirections, { Name = DirectionName, Enum = DirectionEnum })
	end

	table.sort(SortedDirections, function(a, b)
		return #a.Name > #b.Name
	end)

	for _, Entry in ipairs(SortedDirections) do
		if ProfileSegment:find(Entry.Name:lower()) then
			EasingDirectionMatch = Entry.Enum
			break
		end
	end

	for StyleName, StyleEnum in pairs(TweenModule.Enums.Styles) do
		if ProfileSegment:find(StyleName:lower()) then
			EasingStyleMatch = StyleEnum
			break
		end
	end

	if segments[2] then
		duration = tonumber(segments[2]) or 1
	end
	if segments[3] then
		repeatCount = tonumber(segments[3]) or 0
	end
	if segments[4] then
		reverses = segments[4]:lower() == "true"
	end
	if segments[5] then
		delayTime = tonumber(segments[5]) or 0
	end

	if EasingStyleMatch and EasingDirectionMatch then
		return TweenInfo.new(duration, EasingStyleMatch, EasingDirectionMatch, repeatCount, reverses, delayTime)
	end

	LogError(
		"ParseTweenProfile",
		`The TweenInfo "{ProfileName}" is not a Tween, please check the tutorial for any help`
	)
	return nil
end

local function createTween(instance: Instance, tweenInfo: TweenInfo | string, properties: { [string]: any })
	if typeof(tweenInfo) == "string" then
		tweenInfo = ParseTweenProfile(tweenInfo)
		if not tweenInfo then
			HandleError("createTween", "Failed to parse TweenInfo string: " .. tweenInfo)
			return nil
		end
	end

	local success, Tween = pcall(function()
		return TweenService:Create(instance, tweenInfo, properties)
	end)

	if not success then
		HandleError("createTween", Tween)
		return nil
	end

	local Handle = {
		Tween = Tween,
		Play = function()
			Tween:Play()
		end,
		Pause = function()
			Tween:Pause()
		end,
		Resume = function()
			Tween:Play()
		end,
		Cancel = function()
			if Tween.PlaybackState ~= Enum.PlaybackState.Completed then
				Tween:Cancel()
			end
			Tween:Destroy()
			if TweenModule.Active then
				TweenModule.Active[instance] = nil
			end
		end,
	}

	TweenModule.Active = TweenModule.Active or {}
	TweenModule.Active[instance] = Handle

	Tween.Completed:Once(function()
		Handle.Cancel()
	end)

	Tween:Play()
	return Handle
end

local function lerpProperty(start, target, alpha)
	if typeof(start) == "ColorSequence" and typeof(target) == "ColorSequence" then
		local newKeypoints = {}
		for i, keypoint in ipairs(start.Keypoints) do
			local targetKeypoint = target.Keypoints[i] or target.Keypoints[#target.Keypoints]
			local startColor = keypoint.Value
			local targetColor = targetKeypoint.Value

			local lerpedColor = Color3.new(
				startColor.R + (targetColor.R - startColor.R) * alpha,
				startColor.G + (targetColor.G - startColor.G) * alpha,
				startColor.B + (targetColor.B - startColor.B) * alpha
			)

			table.insert(newKeypoints, ColorSequenceKeypoint.new(keypoint.Time, lerpedColor))
		end
		return ColorSequence.new(newKeypoints)
	elseif typeof(start) == "ColorSequence" and typeof(target) == "Color3" then
		local startColor = start.Keypoints[1].Value
		local targetColor = target

		local lerpedColor = Color3.new(
			startColor.R + (targetColor.R - startColor.R) * alpha,
			startColor.G + (targetColor.G - startColor.G) * alpha,
			startColor.B + (targetColor.B - startColor.B) * alpha
		)

		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, lerpedColor),
			ColorSequenceKeypoint.new(1, lerpedColor),
		})
	elseif typeof(start) == "NumberSequence" and typeof(target) == "NumberSequence" then
		local newKeypoints = {}
		for i, keypoint in ipairs(start.Keypoints) do
			local targetKeypoint = target.Keypoints[i] or target.Keypoints[#target.Keypoints]
			local startValue = keypoint.Value
			local targetValue = targetKeypoint.Value

			local interpolatedValue = startValue + (targetValue - startValue) * alpha

			table.insert(newKeypoints, NumberSequenceKeypoint.new(keypoint.Time, math.clamp(interpolatedValue, 0, 1)))
		end
		return NumberSequence.new(newKeypoints)
	elseif typeof(start) == "Vector2" and typeof(target) == "Vector2" then
		return Vector2.new(start.X + (target.X - start.X) * alpha, start.Y + (target.Y - start.Y) * alpha)
	elseif typeof(start) == "number" and typeof(target) == "number" then
		return start + (target - start) * alpha
	else
		return start
	end
end

local function getBaseParts(target: PVInstance): { BasePart }
	table.clear(BasePartPool)

	if target:IsA("BasePart") then
		table.insert(BasePartPool, target)
	elseif target:IsA("Model") or target:IsA("Folder") then
		for _, descendant in ipairs(target:GetDescendants()) do
			if descendant:IsA("BasePart") then
				table.insert(BasePartPool, descendant)
			end
		end
	end

	return BasePartPool
end

local function interpolateProperty(
	instance: Instance,
	property: string,
	duration: number,
	targetValue: any,
	easingStyle: Enum.EasingStyle,
	easingDirection: Enum.EasingDirection,
	repeatCount: number?,
	reverses: boolean?,
	delayTime: number?,
	lerpFunction: (start: any, goal: any, alpha: number) -> any
)
	if delayTime and delayTime > 0 then
		task.delay(delayTime, function()
			interpolateProperty(
				instance,
				property,
				duration,
				targetValue,
				easingStyle,
				easingDirection,
				repeatCount,
				reverses,
				nil,
				lerpFunction
			)
		end)
		return
	end

	local startTime: number = tick()
	local startValue = instance[property]
	local connection: RBXScriptConnection
	local count, isReversing = 0, false

	local totalCycles = repeatCount and (reverses and repeatCount * 2 or repeatCount) or 1

	connection = RunService.Heartbeat:Connect(function()
		local elapsedTime: number = math.clamp(tick() - startTime, 0, duration)
		local alpha: number = TweenService:GetValue(elapsedTime / duration, easingStyle, easingDirection)

		local currentStart = isReversing and targetValue or startValue
		local currentTarget = isReversing and startValue or targetValue

		if typeof(currentStart) == "ColorSequence" and typeof(currentTarget) == "Color3" then
			local startColor = currentStart.Keypoints[1].Value
			local targetColor = currentTarget

			local lerpedColor = Color3.new(
				math.clamp(startColor.R * (1 - alpha) + targetColor.R * alpha, 0, 1),
				math.clamp(startColor.G * (1 - alpha) + targetColor.G * alpha, 0, 1),
				math.clamp(startColor.B * (1 - alpha) + targetColor.B * alpha, 0, 1)
			)

			instance[property] = ColorSequence.new({
				ColorSequenceKeypoint.new(0, lerpedColor),
				ColorSequenceKeypoint.new(1, lerpedColor),
			})
		elseif typeof(currentStart) == "NumberSequence" and typeof(currentTarget) == "NumberSequence" then
			local newKeypoints = {}
			for i, keypoint in ipairs(currentStart.Keypoints) do
				local targetKeypoint = currentTarget.Keypoints[i] or currentTarget.Keypoints[#currentTarget.Keypoints]
				local lerpedValue = keypoint.Value + (targetKeypoint.Value - keypoint.Value) * alpha

				table.insert(
					newKeypoints,
					NumberSequenceKeypoint.new(math.clamp(keypoint.Time, 0, 1), math.clamp(lerpedValue, 0, 1))
				)
			end
			instance[property] = NumberSequence.new(newKeypoints)
		else
			instance[property] = lerpFunction(currentStart, currentTarget, alpha)
		end

		if elapsedTime >= duration then
			count += 1

			if reverses and count < totalCycles then
				isReversing = not isReversing
			end

			if count >= totalCycles then
				connection:Disconnect()
			else
				startTime = tick()
			end
		end
	end)
end

--[=[
	@within TweenModule
	@function Move
	@since 1.0.0
	Moves a PVInstance (Model, Folder, or BasePart) to a new position using tweens.

	@param target PVInstance
	@param tweenInfo TweenInfo | string
	@param movement CFrame | Vector3
	@param byPivot boolean

	@return TweenHandle

	**Example:**
	```lua
	local Part = workspace.MyPart
	local Model = workspace.MyModel

	-- Move a part upward by 10 studs over 1 second
	TweenModule.Move(Part, "QuadOut:1", Vector3.new(0, 10, 0), false)

	-- Move a model forward relative to its pivot
	TweenModule.Move(Model, "SineInOut:2", CFrame.new(0, 0, -20), true)
	```
]=]

function TweenModule.Move(
	target: PVInstance,
	tweenInfo: TweenInfo | string,
	movement: CFrame | Vector3,
	byPivot: boolean
)
	local isFolder = target:IsA("Folder")
	local model = target

	if isFolder then
		model = Instance.new("Model")
		model.Name = "[TempMoveModel]"
		model.Parent = workspace

		for _, child in ipairs(target:GetChildren()) do
			if child:IsA("BasePart") then
				child.Parent = model
			end
		end

		model:PivotTo(target:GetPivot())
	end

	local originalPivot = model:GetPivot()
	local newPivot: CFrame

	if typeof(movement) == "CFrame" then
		newPivot = byPivot and (originalPivot * movement) or (originalPivot + movement.Position)
	elseif typeof(movement) == "Vector3" then
		newPivot = originalPivot + movement
	else
		error("[TweenModule.Move] 'movement' must be a CFrame or Vector3")
	end

	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = originalPivot

	CFrameValue.Changed:Connect(function(value)
		model:PivotTo(value)
	end)

	local TweenHandler = createTween(CFrameValue, tweenInfo, { Value = newPivot })

	TweenHandler.Tween.Completed:Connect(function()
		CFrameValue:Destroy()
		if isFolder then
			for _, part in ipairs(model:GetChildren()) do
				if part:IsA("BasePart") then
					part.Parent = target
				end
			end
			model:Destroy()
		end
	end)

	TweenHandler.Play()
	return TweenHandler
end

--[=[
	@within TweenModule
	@function CustomTween
	@since 1.0.0
	Tweens a given instance with specified properties and optional completion callback.

	@param target Instance
	@param tweenInfo TweenInfo | string
	@param properties { [string]: any }
	@param callback? (() -> nil)

	@return TweenHandle

	**Example:**
	```lua
	local Handle = TweenModule.CustomTween(workspace.Part, "QuadInOut:2", {
		Transparency = 1,
		Color = Color3.new(1, 0, 0),
	}, function()
		print("Tween finished!")
	end)

	Handle.Pause() -- Pauses the tween
	task.wait(1)
	Handle.Resume() -- Resumes the tween
	```
]=]

function TweenModule.CustomTween(
	target: Instance,
	tweenInfo: TweenInfo | string,
	properties: { [string]: any },
	callback: (() -> nil)?
)
	if typeof(tweenInfo) == "string" then
		tweenInfo = ParseTweenProfile(tweenInfo)
		if not tweenInfo then
			HandleError("createTween", "Failed to parse TweenInfo string: " .. tweenInfo)
			return nil
		end
	end

	local success, Tween = pcall(function()
		return TweenService:Create(target, tweenInfo, properties)
	end)

	if not success then
		HandleError("createTween", Tween)
		return nil
	end

	local Handle = {
		Tween = Tween,
		Play = function()
			Tween:Play()
		end,
		Pause = function()
			Tween:Pause()
		end,
		Resume = function()
			Tween:Play()
		end,
		Cancel = function()
			if Tween.PlaybackState ~= Enum.PlaybackState.Completed then
				Tween:Cancel()
			end
			Tween:Destroy()
			if TweenModule.Active then
				TweenModule.Active[target] = nil
			end
		end,
	}

	TweenModule.Active = TweenModule.Active or {}
	TweenModule.Active[target] = Handle

	Tween.Completed:Once(function()
		Handle.Cancel()
		if callback then
			callback()
		end
	end)

	return Handle
end

--[=[
	@within TweenModule
	@function ChainTween
	@since 2.0.0
	Chains multiple tweens to play one after another in sequence.

	@param tweens { { instance: Instance, tweenInfo: TweenInfo | string, props: { [string]: any } } } -- A list of tween configs to apply in sequence.
	@param onComplete (() -> nil)? -- Optional callback function called after all tweens complete.

	**Example:**
	```lua
	TweenModule.ChainTween({
		{
			instance = workspace.Part1,
			tweenInfo = "SineOut:1",
			props = { Position = Vector3.new(0, 10, 0) },
		},
		{
			instance = workspace.Part2,
			tweenInfo = "SineIn:1",
			props = { Position = Vector3.new(0, 0, 0) },
		},
	}, function()
		print("Chain finished!")
	end)
	```
]=]

function TweenModule.ChainTween(
	tweens: { { instance: Instance, tweenInfo: TweenInfo | string, props: { [string]: any } } },
	onComplete: (() -> nil)?
)
	task.spawn(function()
		for _, TweenData in ipairs(tweens) do
			local TweenHandler = createTween(TweenData.instance, TweenData.tweenInfo, TweenData.props)
			local CompletedTween = false

			TweenHandler.Tween.Completed:Once(function()
				CompletedTween = true
			end)

			TweenHandler.Tween:Play()

			repeat
				task.wait()
			until CompletedTween
			TweenHandler.Tween:Destroy()
		end

		if onComplete then
			onComplete()
		end
	end)
end

--[=[
	@within TweenModule
	@function Transparency
	@since 1.0.0
	Tweens the transparency of all BaseParts in a target.

	@param target PVInstance -- The instance (Model, BasePart, or Folder) whose BaseParts' transparency will be affected.
	@param tweenInfo TweenInfo | string -- The TweenInfo.new() settings or a string profile (e.g. "SineOut:1.5").
	@param Transparency number -- The target transparency value between 0 and 1.

	**Example:**
	```lua
	TweenModule.Transparency(workspace.Model, "QuadInOut:0.5", 1)
	```
]=]

function TweenModule.Transparency(target: PVInstance, tweenInfo: TweenInfo | string, Transparency: number)
	for _, part in ipairs(getBaseParts(target)) do
		createTween(part, tweenInfo, { Transparency = Transparency })
	end
end

--[=[
	@within TweenModule
	@function TweenTag
	@since 2.0.0
	Tweens all instances with a specific CollectionService tag using the provided tween settings and property goals.

	@param tag string 
	@param tweenInfo TweenInfo | string 
	@param properties { [string]: any } 
	@param callback? (() -> nil) 

	**Example:**
	```lua
	TweenModule.TweenTag("HighlightParts", "BackInOut:1.2", { Transparency = 0.25 }, function()
		print("All tagged parts have finished tweening.")
	end)
	```
]=]

function TweenModule.TweenTag(
	tag: string,
	tweenInfo: TweenInfo | string,
	properties: { [string]: any },
	callback: (() -> nil)?
)
	local CollectionTag = CollectionService:GetTagged(tag)
	local TweensRemain = #CollectionTag

	if TweensRemain == 0 then
		if callback then
			callback()
		end
		return
	end

	for _, instance in ipairs(CollectionTag) do
		TweenModule.CustomTween(instance, tweenInfo, properties, function()
			TweensRemain -= 1
			if TweensRemain == 0 and callback then
				callback()
			end
		end).Play()
	end
end

--[=[
	@within TweenModule
	@function Shake
	@since 1.0.0
	Applies a shaking effect to a PVInstance for a set duration and intensity.

	@param target PVInstance
	@param duration number -- The total time in seconds the shake lasts (`-1` for infinite shake)
	@param intensity number -- How strong the shake is (higher = more jitter).
	@param individually boolean -- If true, shakes each BasePart individually; otherwise, shakes the entire model via pivot

	@return () -> () -- A function that can be called to manually stop the shake.

	**Example:**
	```lua
	local StopShake = TweenModule.Shake(workspace.Model, 2, 6, true) -- Will shake the model for 2 seconds with intensity 6 and each part individually.

	-- Stop early after 1 second
	task.delay(1, function()
		StopShake()
	end)
	```
]=]

function TweenModule.Shake(target: PVInstance, duration: number, intensity: number, individually: boolean)
	local originalPivot = target:GetPivot()
	local baseParts = getBaseParts(target)
	local active = true
	local startTime = os.clock()

	local originalOffsets = {}

	for _, part in ipairs(baseParts) do
		originalOffsets[part] = part.CFrame
	end

	task.spawn(function()
		while active do
			task.wait(0.05)

			if individually then
				for _, part in ipairs(baseParts) do
					local randomOffset = CFrame.new(
						math.random(-intensity, intensity) / 10,
						math.random(-intensity, intensity) / 10,
						math.random(-intensity, intensity) / 10
					)
					part.CFrame = originalOffsets[part] * randomOffset
				end
			else
				local randomOffset = CFrame.new(
					math.random(-intensity, intensity) / 10,
					math.random(-intensity, intensity) / 10,
					math.random(-intensity, intensity) / 10
				)
				target:PivotTo(originalPivot * randomOffset)
			end

			if duration ~= -1 and (os.clock() - startTime) >= duration then
				active = false
			end
		end

		if individually then
			for _, part in ipairs(baseParts) do
				part.CFrame = originalOffsets[part]
			end
		else
			target:PivotTo(originalPivot)
		end
	end)

	return function()
		active = false
	end
end

--[=[
	@within TweenModule
	@function Scale
	@since 1.0.0
	Scales a PVInstance's BaseParts by a Vector3 value, optionally adjusting position.

	@param target PVInstance 
	@param tweenInfo TweenInfo | string -- The tween settings or a string profile (e.g., "SineOut:1.5").
	@param scaleTo Vector3 
	@param adjustPosition boolean -- If true, adjusts each part’s position to compensate for scaling.
	@param scaledByModel boolean -- If true, scales the whole model using pivot math. Requires `target:IsA("Model")`.

	**Example:**
	```lua
	-- Scale up each part in a folder by (2, 2, 2) and shift positions
	TweenModule.Scale(workspace.BuildingParts, "InOutQuad:1.25", Vector3.new(2, 2, 2), true, false)

	-- Uniformly scale a model from its pivot point
	TweenModule.Scale(workspace.CarModel, "SineOut:1.5", Vector3.new(1.2, 1.2, 1.2), false, true)
	```
]=]

function TweenModule.Scale(
	target: PVInstance,
	tweenInfo: TweenInfo | string,
	scaleTo: Vector3,
	adjustPosition: boolean,
	scaledByModel: boolean
)
	if not scaledByModel then
		for _, part in ipairs(getBaseParts(target)) do
			local properties = { Size = part.Size + scaleTo }
			if adjustPosition then
				properties.Position = part.Position + (scaleTo / 2)
			end
			createTween(part, tweenInfo, properties)
		end
	else
		if target:IsA("Model") then
			local originalPosition = target:GetPivot().Position

			for _, BasePart in pairs(getBaseParts(target)) do
				local offset = BasePart.Position - originalPosition
				local scaledOffset = offset * scaleTo
				local newPosition = originalPosition + scaledOffset
				local newSize = BasePart.Size * scaleTo

				createTween(BasePart, tweenInfo, { Size = newSize, Position = newPosition })
			end
		else
			error("scaledByModel was set to true, but target is not a model")
		end
	end
end

--[=[
	@within TweenModule
	@function Color
	@since 1.1.1
	Animates the color of all BaseParts within a PVInstance to a target color.

	@param target PVInstance 
	@param tweenInfo TweenInfo | string 
	@param ColorTo Color3 | BrickColor | string -- The target color (can be Color3, BrickColor, or hex string like `"#ff0040"`)

	**Example:**
	```lua
	-- Tween to bright red using a string profile
	TweenModule.Color(workspace.Model, "QuadOut:1", "#ff0040")

	-- Tween to BrickColor
	TweenModule.Color(workspace.Model, "QuadOut:1", BrickColor.new("Bright red"))

	-- Tween to Color3 directly
	TweenModule.Color(workspace.Model, "QuadOut:1", Color3.fromRGB(0, 255, 150))
	```
]=]

function TweenModule.Color(
	target: Model | BasePart,
	tweenInfo: TweenInfo | string,
	ColorTo: Color3 | BrickColor | string
)
	local ResolvedColor: Color3

	if typeof(ColorTo) == "BrickColor" then
		ResolvedColor = ColorTo.Color
	elseif typeof(ColorTo) == "string" then
		if ColorTo:match("^#%x%x%x%x%x%x$") then
			local r, g, b = ColorTo:match("^#(%x%x)(%x%x)(%x%x)$")
			ResolvedColor = Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
		else
			local ok, Brick = pcall(BrickColor.new, ColorTo)
			if ok then
				ResolvedColor = Brick.Color
			else
				LogError("Invalid Color", `Invalid color string: "{ColorTo}"`)
			end
		end
	elseif typeof(ColorTo) == "Color3" then
		ResolvedColor = ColorTo
	else
		LogError("Invalid Color", `Unsupported color type: {typeof(ColorTo)}`)
	end

	for _, part in ipairs(getBaseParts(target)) do
		createTween(part, tweenInfo, { Color = ResolvedColor })
	end
end

--[=[
	@within TweenModule
	@function Rotate
	@since 1.0.0
	Rotates a PVInstance (Model, Folder, or BasePart) using tweens.

	@param target PVInstance 
	@param tweenInfo TweenInfo | string 
	@param rotation Vector3 -- The rotation in degrees (X, Y, Z).
	@param byPivot boolean -- If true, rotates around the current pivot point.

	**Example:**
	```lua
	TweenModule.Rotate(workspace.MyModelIWantRotatedNOW, "SineOut:1", Vector3.new(0, 90, 0), true)
	```
]=]

function TweenModule.Rotate(target: PVInstance, tweenInfo: TweenInfo | string, rotation: Vector3, byPivot: boolean)
	local isFolder = target:IsA("Folder")
	local model = target

	if isFolder then
		model = Instance.new("Model")
		model.Name = "[TempRotateModel]"
		model.Parent = workspace

		for _, child in ipairs(target:GetChildren()) do
			if child:IsA("BasePart") then
				child.Parent = model
			end
		end

		model:PivotTo(target:GetPivot())
	end

	local originalPivot = model:GetPivot()
	local rotationCFrame = CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))

	local newPivot = byPivot and (originalPivot * rotationCFrame)
		or (rotationCFrame * (originalPivot - originalPivot.Position) + originalPivot.Position)

	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = originalPivot

	CFrameValue.Changed:Connect(function(value)
		model:PivotTo(value)
	end)

	local TweenHandler = createTween(CFrameValue, tweenInfo, { Value = newPivot })

	TweenHandler.Tween.Completed:Connect(function()
		CFrameValue:Destroy()

		if isFolder then
			for _, part in ipairs(model:GetChildren()) do
				if part:IsA("BasePart") then
					part.Parent = target
				end
			end
			model:Destroy()
		end
	end)

	TweenHandler.Play()
end

--[=[
	@within TweenModule
	@function SequenceTween
	@since 1.1.0
	Animates properties of Beams or their descendants using NumberSequence or ColorSequence with easing.

	@param target Instance 
	@param tweenInfo TweenInfo | string 
	@param properties { [string]: any } -- Table of properties to tween. Supports `Color`, `Transparency`, `CurveSize0`, `CurveSize1`.
	@param universal boolean -- If true, recursively applies to all Beams inside the target.

	:::caution Use this function with caution!
	This function has only been tested with Beams and their properties. Other instances may not work as expected but will be continuously worked on if any issues arise.
	:::

	**Example:**
	```lua
	-- Animate all beams in a model to fade transparency over 2 seconds
	TweenModule.SequenceTween(workspace.MyBeamGroup, "SineOut:2", {
		Transparency = NumberSequence.new(1)
	}, true)

	-- Animate a single beam's color
	TweenModule.SequenceTween(myBeam, "QuadIn:1.5", {
		Color = ColorSequence.new(Color3.new(1, 0, 0))
	}, false)
	```
]=]

function TweenModule.SequenceTween(
	target: Instance,
	tweenInfo: TweenInfo | string,
	properties: { [string]: any },
	universal: boolean
)
	if typeof(tweenInfo) == "string" then
		tweenInfo = ParseTweenProfile(tweenInfo)
		if not tweenInfo then
			HandleError("SequenceTween", "Invalid tweenInfo profile string")
			return
		end
	end

	local Sequences = {}

	if universal then
		if not target:IsA("Instance") then
			error("Universal Mode: true | Requires an Instance.")
		end
		for _, descendant in ipairs(target:GetDescendants()) do
			for property, _ in pairs(properties) do
				local success, value = pcall(function()
					return descendant[property]
				end)
				if success and value then
					local propertyType = typeof(value)
					if
						propertyType == "ColorSequence"
						or propertyType == "NumberSequence"
						or propertyType == "Vector2"
						or propertyType == "number"
					then
						table.insert(Sequences, descendant)
						break
					end
				end
			end
		end
	else
		table.insert(Sequences, target)
	end

	for _, instance in ipairs(Sequences) do
		for property, targetValue in pairs(properties) do
			local success, startValue = pcall(function()
				return instance[property]
			end)
			if success and startValue then
				task.spawn(function()
					interpolateProperty(
						instance,
						property,
						tweenInfo.Time,
						targetValue,
						tweenInfo.EasingStyle,
						tweenInfo.EasingDirection,
						tweenInfo.RepeatCount,
						tweenInfo.Reverses,
						tweenInfo.DelayTime,
						lerpProperty
					)
				end)
			end
		end
	end
end

export type GroupHandler = {
	Add: (self: GroupHandler, ...Instance) -> (),
	Remove: (self: GroupHandler, ...Instance) -> (),

	Move: (self: GroupHandler, tweenInfo: TweenInfo | string, movement: CFrame | Vector3, byPivot: boolean) -> any,
	Color: (self: GroupHandler, tweenInfo: TweenInfo | string, colorTo: Color3) -> any,
	Rotate: (self: GroupHandler, tweenInfo: TweenInfo | string, rotation: Vector3, byPivot: boolean) -> any,
	Scale: (
		self: GroupHandler,
		tweenInfo: TweenInfo | string,
		scaleTo: Vector3,
		adjustPosition: boolean,
		scaledByModel: boolean
	) -> any,
	Transparency: (self: GroupHandler, tweenInfo: TweenInfo | string, transparency: number) -> any,
	Shake: (self: GroupHandler, duration: number, intensity: number, individually: boolean) -> () -> (),
	CustomTween: (
		self: GroupHandler,
		tweenInfo: TweenInfo,
		properties: { [string]: any },
		callback: (() -> ())?
	) -> any,
}

--[=[
	@class GroupHandler
	@tag GroupHandler
	A handle returned by `TweenModule.Groups.new(...)` that lets you tween multiple instances at once using the same methods as TweenModule.
	Also provides utility methods like `Add` and `Remove`.

	**Example:**
	```lua
	local TweenModule = require(Path.To.TweenModule)
	local Groups = TweenModule.Groups

	local MyFirstEverGroup = Groups.new(workspace.Part1, workspace.Part2)

	for i = 1, 10 do
		task.wait(0.15)
		MyFirstEverGroup:Move("SineOut:0.15", CFrame.new(0, 5, 0), false)

		if i == 5 then
			MyFirstEverGroup:Add(workspace.Part3)
		end
	end
	```
]=]

--[=[
	@within GroupHandler
	@function new
	@since 2.0.0
	Creates a new group tween handle that allows tweening multiple instances together.

	@param ... Instance
	@return GroupHandler
]=]

function TweenModule.Groups.new(...): GroupHandler
	local Instances = { ... }
	local GroupHandler = {}

	--[=[
	@within GroupHandler
	@method Add
	Adds instances to the group.

	@param ... Instance
	]=]

	function GroupHandler:Add(...)
		local AddInstances = { ... }
		for _, inst in ipairs(AddInstances) do
			if typeof(inst) == "Instance" and inst.Parent then
				table.insert(Instances, inst)
			end
		end
	end

	--[=[
	@within GroupHandler
	@method Remove
	Removes instances from the group.

	@param ... Instance
	]=]

	function GroupHandler:Remove(...)
		local RemoveInstances = { ... }
		for _, target in ipairs(RemoveInstances) do
			for i = #Instances, 1, -1 do
				if Instances[i] == target then
					table.remove(Instances, i)
					break
				end
			end
		end
	end

	setmetatable(GroupHandler, {
		__index = function(_, Method)
			local TweenFunction = TweenModule[Method]

			if typeof(TweenFunction) == "function" then
				return function(_, ...)
					local args = { ... }
					for _, inst in ipairs(Instances) do
						pcall(function()
							TweenFunction(inst, table.unpack(args))
						end)
					end
				end
			end

			return nil
		end,
	})

	return GroupHandler
end

--[=[
	@within TweenModule
	@function PauseAll
	Pauses all currently running tweens tracked by TweenModule.
]=]

--[=[
	@within TweenModule
	@function ResumeAll
	Resumes all paused tweens tracked by TweenModule.
]=]

--[=[
	@within TweenModule
	@function CancelAll
	Cancels and cleans up all active tweens managed by TweenModule.
]=]

for _, Action in ipairs({ "Pause", "Resume", "Cancel" }) do
	TweenModule[Action .. "All"] = function()
		for _, Handler in pairs(TweenModule.Active) do
			if Handler and Handler[Action] then
				Handler[Action]()
			end
		end
	end
end

return TweenModule
