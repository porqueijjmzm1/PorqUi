-- check my rscripts: porqueijjmzm
-- go to read.md for documentation

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Util = (function()
	local Util = {}

	Util.Fonts = {
		Regular = Enum.Font.Gotham,
		Medium = Enum.Font.GothamMedium,
		Bold = Enum.Font.GothamBold,
	}

	function Util.Create(className, props, children)
		local inst = Instance.new(className)
		local parent = nil
		for key, value in pairs(props or {}) do
			if key == "Parent" then
				parent = value
			else
				inst[key] = value
			end
		end
		for _, child in ipairs(children or {}) do
			child.Parent = inst
		end
		if parent then
			inst.Parent = parent
		end
		return inst
	end

	function Util.Tween(inst, duration, goal, style, direction)
		local info = TweenInfo.new(
			duration or 0.2,
			style or Enum.EasingStyle.Quad,
			direction or Enum.EasingDirection.Out
		)
		local tween = TweenService:Create(inst, info, goal)
		tween:Play()
		return tween
	end

	function Util.Corner(parent, radius)
		local r = typeof(radius) == "UDim" and radius or UDim.new(0, radius or 8)
		return Util.Create("UICorner", { CornerRadius = r, Parent = parent })
	end

	function Util.Stroke(parent, thickness, color)
		return Util.Create("UIStroke", {
			Thickness = thickness or 1,
			Color = color or Color3.new(1, 1, 1),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = parent,
		})
	end

	function Util.Padding(parent, left, top, right, bottom)
		return Util.Create("UIPadding", {
			PaddingLeft = UDim.new(0, left or 0),
			PaddingTop = UDim.new(0, top or 0),
			PaddingRight = UDim.new(0, right or 0),
			PaddingBottom = UDim.new(0, bottom or 0),
			Parent = parent,
		})
	end

	function Util.GetGuiParent()
		if typeof(gethui) == "function" then
			local ok, ui = pcall(gethui)
			if ok and typeof(ui) == "Instance" then
				return ui
			end
		end
		local ok, core = pcall(function()
			return game:GetService("CoreGui")
		end)
		if ok and core then
			local writable = pcall(function()
				local probe = Instance.new("Folder")
				probe.Parent = core
				probe:Destroy()
			end)
			if writable then
				return core
			end
		end
		return Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	function Util.MountGui(gui)
		local parent = Util.GetGuiParent()
		local old = parent:FindFirstChild(gui.Name)
		if old then
			old:Destroy()
		end
		if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
			pcall(syn.protect_gui, gui)
		elseif typeof(protect_gui) == "function" then
			pcall(protect_gui, gui)
		end
		gui.Parent = parent
	end

	function Util.Round(value, increment)
		return math.floor(value / increment + 0.5) * increment
	end

	function Util.Decimals(increment)
		local str = string.format("%.6f", increment):gsub("0+$", "")
		local fraction = str:match("%.(%d*)$")
		return fraction and #fraction or 0
	end

	function Util.Draggable(handle, target)
		local dragging = false
		local dragStart = Vector2.zero
		local startPos = target.Position

		local began = handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = Vector2.new(input.Position.X, input.Position.Y)
				startPos = target.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		local changed = UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
				Util.Tween(target, 0.08, {
					Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					),
				}, Enum.EasingStyle.Sine)
			end
		end)

		return { began, changed }
	end

	return Util
end)()

local Theme = (function()
	local Theme = {}

	Theme.Themes = {
		Dark = {
			Background = Color3.fromRGB(20, 20, 26),
			Topbar = Color3.fromRGB(26, 26, 34),
			Element = Color3.fromRGB(32, 32, 42),
			ElementHover = Color3.fromRGB(42, 42, 54),
			Stroke = Color3.fromRGB(55, 55, 70),
			Text = Color3.fromRGB(240, 240, 245),
			SubText = Color3.fromRGB(160, 160, 175),
			Accent = Color3.fromRGB(110, 90, 255),
			AccentAlt = Color3.fromRGB(70, 160, 255),
			Transparency = 0.05,
		},
		Light = {
			Background = Color3.fromRGB(244, 245, 249),
			Topbar = Color3.fromRGB(255, 255, 255),
			Element = Color3.fromRGB(232, 234, 242),
			ElementHover = Color3.fromRGB(220, 223, 235),
			Stroke = Color3.fromRGB(205, 208, 220),
			Text = Color3.fromRGB(30, 32, 40),
			SubText = Color3.fromRGB(100, 104, 120),
			Accent = Color3.fromRGB(90, 90, 240),
			AccentAlt = Color3.fromRGB(60, 150, 240),
			Transparency = 0,
		},
		Ocean = {
			Background = Color3.fromRGB(12, 24, 38),
			Topbar = Color3.fromRGB(16, 32, 50),
			Element = Color3.fromRGB(20, 40, 62),
			ElementHover = Color3.fromRGB(28, 54, 82),
			Stroke = Color3.fromRGB(40, 78, 112),
			Text = Color3.fromRGB(230, 244, 255),
			SubText = Color3.fromRGB(140, 175, 205),
			Accent = Color3.fromRGB(0, 200, 190),
			AccentAlt = Color3.fromRGB(40, 140, 255),
			Transparency = 0.08,
		},
	}

	Theme.CurrentName = "Dark"
	Theme.Current = Theme.Themes.Dark

	local bound = setmetatable({}, { __mode = "k" })
	local gradients = setmetatable({}, { __mode = "k" })
	local listeners = {}
	local nextId = 0

	function Theme:Register(name, colors)
		local full = table.clone(self.Themes.Dark)
		for key, value in pairs(colors) do
			full[key] = value
		end
		self.Themes[name] = full
	end

	function Theme:AccentSequence()
		return ColorSequence.new(self.Current.Accent, self.Current.AccentAlt)
	end

	function Theme:Bind(inst, map)
		bound[inst] = map
		for prop, key in pairs(map) do
			inst[prop] = self.Current[key]
		end
	end

	function Theme:BindGradient(gradient)
		gradients[gradient] = true
		gradient.Color = self:AccentSequence()
	end

	function Theme:OnChanged(callback)
		nextId += 1
		local id = nextId
		listeners[id] = callback
		return {
			Disconnect = function()
				listeners[id] = nil
			end,
		}
	end

	function Theme:Set(name)
		local theme = self.Themes[name]
		if not theme then
			warn("[UILib] Tema inexistente: " .. tostring(name))
			return false
		end
		self.CurrentName = name
		self.Current = theme

		for inst, map in pairs(bound) do
			local goal = {}
			for prop, key in pairs(map) do
				goal[prop] = theme[key]
			end
			Util.Tween(inst, 0.3, goal)
		end
		for gradient in pairs(gradients) do
			gradient.Color = self:AccentSequence()
		end
		for _, callback in pairs(listeners) do
			task.spawn(callback, name, theme)
		end
		return true
	end

	return Theme
end)()

local Loader = (function()
	local Loader = {}

	function Loader.new(parent, props)
		props = props or {}
		local size = props.Size or 24

		local ring = Util.Create("Frame", {
			Name = "Spinner",
			BackgroundTransparency = 1,
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			Position = props.Position or UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(size, size),
			Parent = parent,
		})
		Util.Corner(ring, UDim.new(0.5, 0))

		local stroke = Util.Stroke(ring, math.max(2, math.floor(size / 8)), Color3.new(1, 1, 1))
		local gradient = Util.Create("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.7, 1),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = stroke,
		})
		Theme:BindGradient(gradient)

		local spin = TweenService:Create(
			gradient,
			TweenInfo.new(props.Speed or 0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
			{ Rotation = 360 }
		)
		spin:Play()

		local object = { Instance = ring }

		function object:SetVisible(visible)
			ring.Visible = visible
			if visible then
				spin:Play()
			else
				spin:Pause()
			end
		end

		function object:Destroy()
			spin:Cancel()
			ring:Destroy()
		end

		return object
	end

	return Loader
end)()

local Notifications = (function()
	local Notifications = {}
	Notifications.__index = Notifications

	local TYPES = {
		Success = { Color = Color3.fromRGB(46, 204, 113), Icon = "✓" },
		Error = { Color = Color3.fromRGB(231, 76, 60), Icon = "✕" },
		Warning = { Color = Color3.fromRGB(241, 196, 15), Icon = "!" },
		Info = { Color = Color3.fromRGB(52, 152, 219), Icon = "i" },
	}

	local OFFSCREEN = UDim2.new(1, 60, 0, 0)

	function Notifications.new()
		local self = setmetatable({}, Notifications)
		self._order = 0

		self.Gui = Util.Create("ScreenGui", {
			Name = "UILib_Toasts",
			ResetOnSpawn = false,
			DisplayOrder = 101,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		Util.MountGui(self.Gui)

		self.Holder = Util.Create("Frame", {
			Name = "Holder",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -16, 1, -16),
			Size = UDim2.new(0, 320, 1, -32),
			Parent = self.Gui,
		})
		Util.Create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Parent = self.Holder,
		})

		return self
	end

	function Notifications:_create(opts)
		self._order += 1

		local wrapper = Util.Create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = self._order,
			Parent = self.Holder,
		})

		local toast = Util.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = OFFSCREEN,
			BorderSizePixel = 0,
			Parent = wrapper,
		})
		Theme:Bind(toast, { BackgroundColor3 = "Element" })
		Util.Corner(toast, 10)
		local stroke = Util.Stroke(toast, 1)
		Theme:Bind(stroke, { Color = "Stroke" })
		Util.Padding(toast, 12, 10, 12, 20)

		local iconFrame = Util.Create("Frame", {
			Size = UDim2.fromOffset(26, 26),
			BorderSizePixel = 0,
			Parent = toast,
		})
		Util.Corner(iconFrame, UDim.new(0.5, 0))

		local iconLabel = Util.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Font = Util.Fonts.Bold,
			TextSize = 15,
			TextColor3 = Color3.new(1, 1, 1),
			Parent = iconFrame,
		})

		local textHolder = Util.Create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(38, 0),
			Size = UDim2.new(1, -38, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = toast,
		})
		Util.Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = textHolder })

		local title = Util.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Font = Util.Fonts.Bold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
			Parent = textHolder,
		})
		Theme:Bind(title, { TextColor3 = "Text" })

		local content = Util.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Util.Fonts.Regular,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = 2,
			Parent = textHolder,
		})
		Theme:Bind(content, { TextColor3 = "SubText" })

		local track = Util.Create("Frame", {
			Position = UDim2.new(0, 0, 1, 10),
			Size = UDim2.new(1, 0, 0, 3),
			BorderSizePixel = 0,
			Visible = false,
			Parent = toast,
		})
		Theme:Bind(track, { BackgroundColor3 = "Stroke" })
		Util.Corner(track, UDim.new(1, 0))

		local fill = Util.Create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			Parent = track,
		})
		Util.Corner(fill, UDim.new(1, 0))

		local closed = false
		local progressTween = nil
		local spinner = nil
		local handle = {}

		local function dismiss()
			if closed then
				return
			end
			closed = true
			if progressTween then
				progressTween:Cancel()
			end
			if spinner then
				spinner:Destroy()
			end
			local height = toast.AbsoluteSize.Y
			Util.Tween(toast, 0.25, { Position = OFFSCREEN }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			task.delay(0.25, function()
				wrapper.AutomaticSize = Enum.AutomaticSize.None
				wrapper.Size = UDim2.new(1, 0, 0, height)
				local shrink = Util.Tween(wrapper, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
				shrink.Completed:Wait()
				wrapper:Destroy()
			end)
		end

		local function startProgress(duration)
			track.Visible = true
			fill.Size = UDim2.fromScale(1, 1)
			progressTween = Util.Tween(fill, duration, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Linear)
			progressTween.Completed:Connect(function(state)
				if state == Enum.PlaybackState.Completed then
					dismiss()
				end
			end)
		end

		local function apply(newOpts)
			local kind = TYPES[newOpts.Type or "Info"] or TYPES.Info
			if newOpts.Title then
				title.Text = newOpts.Title
			end
			if newOpts.Content ~= nil then
				content.Text = newOpts.Content
				content.Visible = newOpts.Content ~= ""
			end
			fill.BackgroundColor3 = kind.Color

			if newOpts.Loading then
				iconFrame.BackgroundTransparency = 1
				iconLabel.Text = ""
				if not spinner then
					spinner = Loader.new(iconFrame, { Size = 24 })
				end
			else
				if spinner then
					spinner:Destroy()
					spinner = nil
				end
				iconFrame.BackgroundTransparency = 0
				iconFrame.BackgroundColor3 = kind.Color
				iconLabel.Text = newOpts.Icon or kind.Icon
			end

			if newOpts.Duration and newOpts.Duration > 0 and not newOpts.Loading then
				startProgress(newOpts.Duration)
			end
		end

		toast.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dismiss()
			end
		end)

		apply(opts)
		Util.Tween(toast, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		handle.Dismiss = dismiss
		function handle:Update(newOpts)
			if closed then
				return
			end
			if progressTween then
				progressTween:Cancel()
				progressTween = nil
			end
			apply(newOpts)
		end

		return handle
	end

	function Notifications:Notify(opts)
		opts = opts or {}
		opts.Duration = opts.Duration or 4
		return self:_create(opts)
	end

	function Notifications:Loading(opts)
		opts = opts or {}
		opts.Loading = true
		opts.Type = opts.Type or "Info"
		return self:_create(opts)
	end

	function Notifications:Destroy()
		self.Gui:Destroy()
	end

	return Notifications
end)()

local Library = (function()
	local Library = { Theme = Theme, Util = Util, Loader = Loader }
	Library.__index = Library

	local Window = {}
	Window.__index = Window

	local Tab = {}
	Tab.__index = Tab

	local WHITE = Color3.new(1, 1, 1)

	local Icons = {
		eye = "rbxassetid://13321848342",
		eyeclosed = "rbxassetid://133178224707634",
		aim = "rbxassetid://11738671951",
		settings = "rbxassetid://13300915335",
		click = "rbxassetid://12804017070",
		dots = "rbxassetid://108202729577310",
	}
	Library.Icons = Icons

	Library.Logo = "rbxassetid://76951800690268"
	Library.MobileIcon = "rbxassetid://12519968991"

	local resolved = {}
	local function resolveAsset(raw)
		if resolved[raw] then
			return resolved[raw]
		end
		local id = raw:match("%d+")
		local ok, result = pcall(function()
			local objects = game:GetObjects("rbxassetid://" .. id)
			local obj = objects and objects[1]
			if obj then
				if obj:IsA("Decal") or obj:IsA("Texture") then
					return obj.Texture
				elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
					return obj.Image
				end
			end
			return nil
		end)
		if ok and typeof(result) == "string" and result ~= "" then
			resolved[raw] = result
		else
			resolved[raw] = raw
		end
		return resolved[raw]
	end

	local function resolveIcon(icon)
		if typeof(icon) ~= "string" or icon == "" then
			return nil
		end
		local raw
		if Icons[string.lower(icon)] then
			raw = Icons[string.lower(icon)]
		elseif icon:match("^rbxassetid://") then
			raw = icon
		elseif tonumber(icon) then
			raw = "rbxassetid://" .. icon
		else
			return nil
		end
		return resolveAsset(raw)
	end

	local function applyImageAsync(label, icon)
		local id = tostring(icon):match("%d+")
		if not id then
			return
		end
		local raw = "rbxassetid://" .. id
		label.Image = resolved[raw] or raw
		if not resolved[raw] then
			task.spawn(function()
				local image = resolveAsset(raw)
				if label.Parent then
					label.Image = image
				end
			end)
		end
	end

	local function makeIcon(parent, image, size, position, colorKey)
		local img = Util.Create("ImageLabel", {
			BackgroundTransparency = 1,
			Image = image,
			Size = UDim2.fromOffset(size, size),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = position,
			ScaleType = Enum.ScaleType.Fit,
			Parent = parent,
		})
		if colorKey then
			Theme:Bind(img, { ImageColor3 = colorKey })
		end
		return img
	end

	local function cardIcon(card, icon)
		local image = resolveIcon(icon)
		if not image then
			return 12, nil
		end
		return 40, makeIcon(card, image, 18, UDim2.new(0, 12, 0.5, 0), "SubText")
	end

	function Library:AddIcon(name, assetId)
		Icons[string.lower(name)] = typeof(assetId) == "number" and ("rbxassetid://" .. assetId) or assetId
	end

	local function safeCall(callback, ...)
		if typeof(callback) ~= "function" then
			return
		end
		local ok, err = pcall(callback, ...)
		if not ok then
			warn("[UILib] Erro no callback: " .. tostring(err))
		end
	end

	local function makeLabel(parent, props)
		local lbl = Util.Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = props.Bold and Util.Fonts.Bold or Util.Fonts.Medium,
			Text = props.Text or "",
			TextSize = props.TextSize or 14,
			TextXAlignment = props.Align or Enum.TextXAlignment.Left,
			TextWrapped = props.Wrap or false,
			AnchorPoint = props.AnchorPoint or Vector2.zero,
			Position = props.Position or UDim2.new(),
			Size = props.Size or UDim2.fromScale(1, 1),
			Parent = parent,
		})
		if props.AutoY then
			lbl.AutomaticSize = Enum.AutomaticSize.Y
			lbl.TextYAlignment = Enum.TextYAlignment.Top
		end
		if not props.NoBind then
			Theme:Bind(lbl, { TextColor3 = props.Color or "Text" })
		end
		return lbl
	end

	local function makeCard(page, height, interactive)
		local props = {
			Size = UDim2.new(1, 0, 0, height or 40),
			BorderSizePixel = 0,
			Parent = page,
		}
		if interactive then
			props.AutoButtonColor = false
			props.Text = ""
		end
		local card = Util.Create(interactive and "TextButton" or "Frame", props)
		Theme:Bind(card, { BackgroundColor3 = "Element" })
		Util.Corner(card, 8)
		local stroke = Util.Stroke(card, 1)
		Theme:Bind(stroke, { Color = "Stroke" })

		if interactive then
			card.MouseEnter:Connect(function()
				Util.Tween(card, 0.15, { BackgroundColor3 = Theme.Current.ElementHover })
			end)
			card.MouseLeave:Connect(function()
				Util.Tween(card, 0.15, { BackgroundColor3 = Theme.Current.Element })
			end)
		end
		return card
	end

	local function registerFlag(tab, flag, object)
		if flag then
			tab.Window.Flags[flag] = object
		end
	end

	function Library:SetFont(regular, medium, bold)
		Util.Fonts.Regular = regular or Util.Fonts.Regular
		Util.Fonts.Medium = medium or regular or Util.Fonts.Medium
		Util.Fonts.Bold = bold or Util.Fonts.Bold
	end

	function Library:SetTheme(name)
		return Theme:Set(name)
	end

	function Library:RegisterTheme(name, colors)
		Theme:Register(name, colors)
	end

	function Library:CreateWindow(cfg)
		cfg = cfg or {}
		if cfg.Theme then
			Theme:Set(cfg.Theme)
		end

		local self = setmetatable({}, Window)
		self.Tabs = {}
		self.Flags = {}
		self.Visible = true
		self.Minimized = false
		self._conns = {}
		self._themeConns = {}

		local camera = workspace.CurrentCamera
		local screen = camera and camera.ViewportSize or Vector2.new(1280, 720)
		local size = cfg.Size or UDim2.fromOffset(580, 390)
		if size.X.Scale == 0 and size.Y.Scale == 0 then
			size = UDim2.fromOffset(
				math.min(size.X.Offset, screen.X - 24),
				math.min(size.Y.Offset, screen.Y - 24)
			)
		end
		self.Size = size

		local compact = size.X.Offset < 520
		local sidebarW = compact and 108 or 140
		self.Compact = compact

		self.Gui = Util.Create("ScreenGui", {
			Name = cfg.Name or "UILib",
			ResetOnSpawn = false,
			DisplayOrder = 100,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		Util.MountGui(self.Gui)

		self.Notifications = Notifications.new()

		local main = Util.Create("Frame", {
			Name = "Main",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(size.X.Offset * 0.85, size.Y.Offset * 0.85),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = self.Gui,
		})
		Theme:Bind(main, { BackgroundColor3 = "Background", BackgroundTransparency = "Transparency" })
		Util.Corner(main, 12)
		local mainStroke = Util.Stroke(main, 1)
		Theme:Bind(mainStroke, { Color = "Stroke" })
		self.Main = main
		self._scale = Util.Create("UIScale", { Scale = 1, Parent = main })
		Util.Tween(main, 0.35, { Size = size }, Enum.EasingStyle.Back)

		local topbar = Util.Create("Frame", {
			Name = "Topbar",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 42),
			Parent = main,
		})
		local divider = Util.Create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
			BorderSizePixel = 0,
			Parent = topbar,
		})
		Theme:Bind(divider, { BackgroundColor3 = "Stroke" })

		local logo = Util.Create("ImageLabel", {
			Name = "Logo",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			Size = UDim2.fromOffset(26, 26),
			ScaleType = Enum.ScaleType.Fit,
			Parent = topbar,
		})
		applyImageAsync(logo, cfg.Logo or Library.Logo)

		local titleLabel = makeLabel(topbar, {
			Text = cfg.Name or "UI Library",
			Bold = true,
			TextSize = 15,
			Position = UDim2.fromOffset(44, 0),
			Size = UDim2.new(0.5, 0, 1, 0),
		})
		if cfg.Subtitle then
			local textWidth = TextService:GetTextSize(
				titleLabel.Text, 15, Util.Fonts.Bold, Vector2.new(400, 42)
			).X
			makeLabel(topbar, {
				Text = cfg.Subtitle,
				Color = "SubText",
				TextSize = 12,
				Position = UDim2.fromOffset(44 + textWidth + 10, 0),
				Size = UDim2.new(0.4, 0, 1, 0),
			})
		end

		local function topButton(text, offsetFromRight)
			local btn = Util.Create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, offsetFromRight, 0.5, 0),
				Size = UDim2.fromOffset(28, 28),
				BackgroundTransparency = 1,
				BackgroundColor3 = WHITE,
				AutoButtonColor = false,
				Text = text,
				Font = Util.Fonts.Bold,
				TextSize = 18,
				Parent = topbar,
			})
			Theme:Bind(btn, { TextColor3 = "SubText" })
			Util.Corner(btn, 6)
			btn.MouseEnter:Connect(function()
				Util.Tween(btn, 0.15, { BackgroundTransparency = 0.88 })
			end)
			btn.MouseLeave:Connect(function()
				Util.Tween(btn, 0.15, { BackgroundTransparency = 1 })
			end)
			return btn
		end

		local closeBtn = topButton("×", -10)
		local minBtn = topButton("–", -42)
		closeBtn.MouseButton1Click:Connect(function()
			self:Destroy()
		end)
		minBtn.MouseButton1Click:Connect(function()
			self:Minimize(not self.Minimized)
		end)

		for _, c in ipairs(Util.Draggable(topbar, main)) do
			table.insert(self._conns, c)
		end

		local sidebar = Util.Create("Frame", {
			Name = "Sidebar",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, 52),
			Size = UDim2.new(0, sidebarW, 1, -62),
			Parent = main,
		})
		self.TabList = Util.Create("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
			Parent = sidebar,
		})
		Util.Create("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = self.TabList,
		})

		self.Pages = Util.Create("Frame", {
			Name = "Pages",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(sidebarW + 20, 52),
			Size = UDim2.new(1, -(sidebarW + 30), 1, -62),
			ClipsDescendants = true,
			Parent = main,
		})

		local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
		table.insert(self._conns, UserInputService.InputBegan:Connect(function(input, processed)
			if not processed and input.KeyCode == toggleKey then
				self:SetVisible(not self.Visible)
			end
		end))

		table.insert(self._themeConns, Theme:OnChanged(function()
			for _, tab in ipairs(self.Tabs) do
				tab:_refresh()
			end
		end))

		local wantBall = cfg.MobileButton
		if wantBall == nil then
			wantBall = UserInputService.TouchEnabled
		end
		if wantBall then
			self:_createMobileButton(cfg)
		end

		return self
	end

	function Window:_track(conn)
		table.insert(self._conns, conn)
	end

	function Window:_onTheme(fn)
		table.insert(self._themeConns, Theme:OnChanged(fn))
	end

	function Window:_createMobileButton(cfg)
		local SIZE = cfg.MobileButtonSize or 46

		local gui = Util.Create("ScreenGui", {
			Name = (cfg.Name or "UILib") .. "_Mobile",
			ResetOnSpawn = false,
			DisplayOrder = 102,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		Util.MountGui(gui)
		self.MobileGui = gui

		local ball = Util.Create("ImageButton", {
			Name = "Ball",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(SIZE, 140),
			Size = UDim2.fromOffset(SIZE, SIZE),
			AutoButtonColor = false,
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Crop,
			Parent = gui,
		})
		Theme:Bind(ball, { BackgroundColor3 = "Element" })
		Util.Corner(ball, UDim.new(0.5, 0))
		local stroke = Util.Stroke(ball, 2)
		Theme:Bind(stroke, { Color = "Accent" })
		applyImageAsync(ball, cfg.MobileIcon or Library.MobileIcon)
		local scale = Util.Create("UIScale", { Scale = 1, Parent = ball })

		local activeInput = nil
		local moved = false
		local dragStart = Vector2.zero
		local startPos = Vector2.zero

		ball.InputBegan:Connect(function(input)
			if activeInput then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				activeInput = input
				moved = false
				dragStart = Vector2.new(input.Position.X, input.Position.Y)
				startPos = Vector2.new(ball.Position.X.Offset, ball.Position.Y.Offset)
				Util.Tween(scale, 0.08, { Scale = 0.9 })
			end
		end)

		self:_track(UserInputService.InputChanged:Connect(function(input)
			if not activeInput then
				return
			end
			local isMouse = activeInput.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseMovement
			local isTouch = input == activeInput
			if not (isMouse or isTouch) then
				return
			end
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
			if delta.Magnitude > 8 then
				moved = true
			end
			if moved then
				local bounds = gui.AbsoluteSize
				local target = startPos + delta
				ball.Position = UDim2.fromOffset(
					math.clamp(target.X, SIZE / 2, math.max(SIZE / 2, bounds.X - SIZE / 2)),
					math.clamp(target.Y, SIZE / 2, math.max(SIZE / 2, bounds.Y - SIZE / 2))
				)
			end
		end))

		self:_track(UserInputService.InputEnded:Connect(function(input)
			if not activeInput then
				return
			end
			local sameMouse = input.UserInputType == Enum.UserInputType.MouseButton1
				and activeInput.UserInputType == Enum.UserInputType.MouseButton1
			if input == activeInput or sameMouse then
				activeInput = nil
				Util.Tween(scale, 0.12, { Scale = 1 }, Enum.EasingStyle.Back)
				if not moved then
					self:SetVisible(not self.Visible)
				end
			end
		end))

		self.MobileBall = ball
	end

	function Window:SetMobileButtonVisible(visible)
		if self.MobileGui then
			self.MobileGui.Enabled = visible
		end
	end

	function Window:SetVisible(visible)
		self.Visible = visible
		if visible then
			self._scale.Scale = 0.92
			self.Main.Visible = true
			Util.Tween(self._scale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
		else
			self.Main.Visible = false
		end
	end

	function Window:Minimize(state)
		self.Minimized = state
		local target = state and UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 42) or self.Size
		Util.Tween(self.Main, 0.3, { Size = target }, Enum.EasingStyle.Quint)
	end

	function Window:SetTheme(name)
		return Theme:Set(name)
	end

	function Window:Notify(opts)
		return self.Notifications:Notify(opts)
	end

	function Window:Task(title, fn)
		local handle = self.Notifications:Loading({ Title = title, Content = "Aguarde..." })
		task.spawn(function()
			local ok, err = pcall(fn)
			if ok then
				handle:Update({ Type = "Success", Title = title, Content = "Concluído com sucesso.", Duration = 3 })
			else
				handle:Update({ Type = "Error", Title = title, Content = tostring(err), Duration = 5 })
			end
		end)
		return handle
	end

	function Window:Destroy()
		for _, conn in ipairs(self._conns) do
			conn:Disconnect()
		end
		for _, conn in ipairs(self._themeConns) do
			conn.Disconnect()
		end
		if self.MobileGui then
			self.MobileGui:Destroy()
		end
		Util.Tween(self.Main, 0.25, { Size = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.delay(0.3, function()
			self.Gui:Destroy()
			self.Notifications:Destroy()
		end)
	end

	function Window:CreateTab(name, icon)
		local tab = setmetatable({ Name = name, Window = self, Active = false }, Tab)

		local button = Util.Create("TextButton", {
			Name = name,
			AutoButtonColor = false,
			Text = "",
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = #self.Tabs + 1,
			Parent = self.TabList,
		})
		Util.Corner(button, 8)
		Theme:BindGradient(Util.Create("UIGradient", { Rotation = 0, Parent = button }))

		local image = resolveIcon(icon)
		local iconImage = nil
		local textOffset = 12
		local prefix = ""
		if image then
			iconImage = makeIcon(button, image, 18, UDim2.new(0, 10, 0.5, 0))
			iconImage.ImageColor3 = Theme.Current.SubText
			textOffset = 36
		elseif icon then
			prefix = icon .. "  "
		end

		local text = makeLabel(button, {
			Text = prefix .. name,
			Position = UDim2.fromOffset(textOffset, 0),
			Size = UDim2.new(1, -textOffset, 1, 0),
			NoBind = true,
		})
		text.TextColor3 = Theme.Current.SubText

		local page = Util.Create("ScrollingFrame", {
			Name = name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Current.Accent,
			Visible = false,
			Parent = self.Pages,
		})
		Util.Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = page,
		})
		Util.Padding(page, 0, 0, 8, 6)

		tab.Button = button
		tab.Text = text
		tab.Icon = iconImage
		tab.Page = page

		button.MouseButton1Click:Connect(function()
			tab:Select()
		end)
		button.MouseEnter:Connect(function()
			if not tab.Active then
				Util.Tween(button, 0.15, { BackgroundTransparency = 0.9 })
			end
		end)
		button.MouseLeave:Connect(function()
			if not tab.Active then
				Util.Tween(button, 0.15, { BackgroundTransparency = 1 })
			end
		end)

		table.insert(self.Tabs, tab)
		if #self.Tabs == 1 then
			tab:Select()
		end
		return tab
	end

	function Tab:_refresh()
		self.Text.TextColor3 = self.Active and WHITE or Theme.Current.SubText
		if self.Icon then
			self.Icon.ImageColor3 = self.Active and WHITE or Theme.Current.SubText
		end
		self.Page.ScrollBarImageColor3 = Theme.Current.Accent
	end

	function Tab:_setActive(active)
		self.Active = active
		Util.Tween(self.Button, 0.25, { BackgroundTransparency = active and 0 or 1 })
		Util.Tween(self.Text, 0.25, { TextColor3 = active and WHITE or Theme.Current.SubText })
		if self.Icon then
			Util.Tween(self.Icon, 0.25, { ImageColor3 = active and WHITE or Theme.Current.SubText })
		end
		if active then
			self.Page.Position = UDim2.fromOffset(0, 14)
			self.Page.Visible = true
			Util.Tween(self.Page, 0.3, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint)
		else
			self.Page.Visible = false
		end
	end

	function Tab:Select()
		for _, other in ipairs(self.Window.Tabs) do
			if other ~= self and other.Active then
				other:_setActive(false)
			end
		end
		if not self.Active then
			self:_setActive(true)
		end
	end

	function Tab:CreateSection(name)
		local holder = Util.Create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
			Parent = self.Page,
		})
		local lbl = makeLabel(holder, {
			Text = string.upper(name or "Seção"),
			Bold = true,
			TextSize = 11,
			Color = "SubText",
			Position = UDim2.fromOffset(4, 6),
			Size = UDim2.new(1, -4, 1, -6),
		})
		return {
			Set = function(_, text)
				lbl.Text = string.upper(text)
			end,
		}
	end

	function Tab:CreateLabel(text)
		local c = makeCard(self.Page, 34)
		local lbl = makeLabel(c, {
			Text = text or "Label",
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -24, 1, 0),
		})
		return {
			Set = function(_, newText)
				lbl.Text = newText
			end,
		}
	end

	function Tab:CreateParagraph(opts)
		opts = opts or {}
		local c = makeCard(self.Page, 0)
		c.AutomaticSize = Enum.AutomaticSize.Y
		Util.Padding(c, 12, 10, 12, 10)
		Util.Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = c })

		local title = makeLabel(c, { Text = opts.Title or "Título", Bold = true, Size = UDim2.new(1, 0, 0, 18) })
		title.LayoutOrder = 1
		local body = makeLabel(c, {
			Text = opts.Content or "",
			Color = "SubText",
			TextSize = 13,
			Wrap = true,
			AutoY = true,
			Size = UDim2.new(1, 0, 0, 0),
		})
		body.Font = Util.Fonts.Regular
		body.LayoutOrder = 2

		return {
			Set = function(_, newTitle, newContent)
				title.Text = newTitle or title.Text
				body.Text = newContent or body.Text
			end,
		}
	end

	function Tab:CreateButton(opts)
		opts = opts or {}
		local c = makeCard(self.Page, 40, true)

		local textX = cardIcon(c, opts.Icon == nil and "click" or opts.Icon)
		makeLabel(c, {
			Text = opts.Name or "Botão",
			Position = UDim2.fromOffset(textX, 0),
			Size = UDim2.new(1, -(textX + 28), 1, 0),
		})
		makeLabel(c, {
			Text = "›",
			Bold = true,
			TextSize = 20,
			Color = "SubText",
			Align = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 0),
			Size = UDim2.fromOffset(20, 40),
		})

		local scale = Util.Create("UIScale", { Parent = c })
		c.MouseButton1Down:Connect(function()
			Util.Tween(scale, 0.08, { Scale = 0.97 })
		end)
		c.MouseButton1Up:Connect(function()
			Util.Tween(scale, 0.12, { Scale = 1 }, Enum.EasingStyle.Back)
		end)
		c.MouseLeave:Connect(function()
			Util.Tween(scale, 0.12, { Scale = 1 })
		end)
		c.MouseButton1Click:Connect(function()
			c.BackgroundColor3 = Theme.Current.Accent
			Util.Tween(c, 0.35, { BackgroundColor3 = Theme.Current.ElementHover })
			safeCall(opts.Callback)
		end)

		return { Instance = c }
	end

	function Tab:CreateToggle(opts)
		opts = opts or {}
		local c = makeCard(self.Page, 40, true)
		local iconOn = resolveIcon(opts.IconOn or opts.Icon)
		local iconOff = resolveIcon(opts.IconOff or opts.Icon)
		local textX, iconLabel = cardIcon(c, opts.IconOn or opts.Icon or opts.IconOff)
		makeLabel(c, {
			Text = opts.Name or "Toggle",
			Position = UDim2.fromOffset(textX, 0),
			Size = UDim2.new(1, -(textX + 58), 1, 0),
		})

		local track = Util.Create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(42, 22),
			BorderSizePixel = 0,
			Parent = c,
		})
		Theme:Bind(track, { BackgroundColor3 = "Stroke" })
		Util.Corner(track, UDim.new(0.5, 0))

		local fill = Util.Create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = track,
		})
		Util.Corner(fill, UDim.new(0.5, 0))
		Theme:BindGradient(Util.Create("UIGradient", { Rotation = 0, Parent = fill }))

		local knob = Util.Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
			Parent = track,
		})
		Util.Corner(knob, UDim.new(0.5, 0))

		local object = { Value = false }

		local function set(value, fire)
			object.Value = value
			if iconLabel then
				iconLabel.Image = value and (iconOn or iconOff) or (iconOff or iconOn)
			end
			Util.Tween(fill, 0.2, { BackgroundTransparency = value and 0 or 1 })
			Util.Tween(knob, 0.2, {
				Position = value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			}, Enum.EasingStyle.Back)
			if fire then
				safeCall(opts.Callback, value)
			end
		end

		function object:Set(value)
			set(value and true or false, true)
		end

		c.MouseButton1Click:Connect(function()
			set(not object.Value, true)
		end)

		set(opts.CurrentValue == true, false)
		registerFlag(self, opts.Flag, object)
		return object
	end

	function Tab:CreateSlider(opts)
		opts = opts or {}
		local range = opts.Range or { 0, 100 }
		local min, max = range[1], range[2]
		local increment = opts.Increment or 1
		local suffix = opts.Suffix or ""
		local decimals = Util.Decimals(increment)

		local c = makeCard(self.Page, 56)
		makeLabel(c, {
			Text = opts.Name or "Slider",
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.new(1, -100, 0, 18),
		})
		local valueLabel = makeLabel(c, {
			Color = "SubText",
			Align = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 8),
			Size = UDim2.fromOffset(90, 18),
		})

		local track = Util.Create("Frame", {
			Position = UDim2.new(0, 12, 1, -18),
			Size = UDim2.new(1, -24, 0, 6),
			BorderSizePixel = 0,
			Parent = c,
		})
		Theme:Bind(track, { BackgroundColor3 = "Stroke" })
		Util.Corner(track, UDim.new(0.5, 0))

		local fill = Util.Create("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
			Parent = track,
		})
		Util.Corner(fill, UDim.new(0.5, 0))
		Theme:BindGradient(Util.Create("UIGradient", { Rotation = 0, Parent = fill }))

		local knob = Util.Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
			Parent = fill,
		})
		Util.Corner(knob, UDim.new(0.5, 0))

		local object = { Value = min }

		local function set(value, fire)
			value = min + Util.Round(value - min, increment)
			value = tonumber(string.format("%." .. decimals .. "f", math.clamp(value, min, max)))
			local changed = value ~= object.Value
			object.Value = value
			valueLabel.Text = string.format("%." .. decimals .. "f", value) .. suffix
			local alpha = (max > min) and (value - min) / (max - min) or 0
			Util.Tween(fill, 0.08, { Size = UDim2.new(alpha, 0, 1, 0) })
			if fire and changed then
				safeCall(opts.Callback, value)
			end
		end

		function object:Set(value)
			set(value, true)
		end

		local hit = Util.Create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 28),
			Size = UDim2.new(1, 0, 1, -28),
			Parent = c,
		})

		local dragging = false
		local function fromInput(input)
			local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			set(min + alpha * (max - min), true)
		end

		hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				fromInput(input)
			end
		end)
		self.Window:_track(UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				fromInput(input)
			end
		end))
		self.Window:_track(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end))

		set(opts.CurrentValue or min, false)
		registerFlag(self, opts.Flag, object)
		return object
	end

	function Tab:CreateDropdown(opts)
		opts = opts or {}
		local options = opts.Options or {}
		local HEADER = 40
		local ROW = 28

		local c = makeCard(self.Page, HEADER)
		c.ClipsDescendants = true

		local header = Util.Create("TextButton", {
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			Size = UDim2.new(1, 0, 0, HEADER),
			Parent = c,
		})

		local textX = cardIcon(header, opts.Icon == nil and "dots" or opts.Icon)
		makeLabel(header, {
			Text = opts.Name or "Dropdown",
			Position = UDim2.fromOffset(textX, 0),
			Size = UDim2.new(0.5, -textX, 1, 0),
		})
		local selectedLabel = makeLabel(header, {
			Color = "SubText",
			Align = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -34, 0, 0),
			Size = UDim2.new(0.5, -34, 1, 0),
		})
		local arrow = makeLabel(header, {
			Text = "▼",
			TextSize = 10,
			Color = "SubText",
			Align = Enum.TextXAlignment.Center,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
		})

		local list = Util.Create("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, HEADER + 2),
			Size = UDim2.new(1, -16, 1, -(HEADER + 8)),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 2,
			Parent = c,
		})
		Util.Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

		local object = { Value = opts.CurrentOption, Open = false }
		local rows = {}

		local function openHeight()
			return HEADER + math.min(#options * (ROW + 4), 160) + 10
		end

		local function paint()
			for option, row in pairs(rows) do
				local selected = option == object.Value
				row.TextColor3 = selected and Theme.Current.Accent or Theme.Current.Text
				row.Font = selected and Util.Fonts.Bold or Util.Fonts.Medium
			end
			selectedLabel.Text = tostring(object.Value or "Selecionar")
		end

		local function toggle(open)
			object.Open = open
			Util.Tween(arrow, 0.2, { Rotation = open and 180 or 0 })
			Util.Tween(c, 0.25, {
				Size = UDim2.new(1, 0, 0, open and openHeight() or HEADER),
			}, Enum.EasingStyle.Quint)
		end

		local function select(option, fire)
			object.Value = option
			paint()
			if fire then
				safeCall(opts.Callback, option)
			end
		end

		local function build()
			for _, row in pairs(rows) do
				row:Destroy()
			end
			rows = {}
			for index, option in ipairs(options) do
				local row = Util.Create("TextButton", {
					AutoButtonColor = false,
					Text = tostring(option),
					TextSize = 13,
					Font = Util.Fonts.Medium,
					Size = UDim2.new(1, 0, 0, ROW),
					BorderSizePixel = 0,
					LayoutOrder = index,
					Parent = list,
				})
				Theme:Bind(row, { BackgroundColor3 = "ElementHover" })
				Util.Corner(row, 6)
				rows[option] = row
				row.MouseButton1Click:Connect(function()
					select(option, true)
					toggle(false)
				end)
			end
			paint()
		end

		header.MouseButton1Click:Connect(function()
			toggle(not object.Open)
		end)
		self.Window:_onTheme(paint)

		function object:Set(option)
			select(option, true)
		end

		function object:Refresh(newOptions, keepCurrent)
			options = newOptions
			if not keepCurrent or not table.find(options, object.Value) then
				object.Value = options[1]
			end
			build()
			if object.Open then
				toggle(true)
			end
		end

		build()
		if object.Value == nil then
			object.Value = options[1]
		end
		paint()
		registerFlag(self, opts.Flag, object)
		return object
	end

	function Tab:CreateLoader(opts)
		opts = opts or {}
		local c = makeCard(self.Page, 40)
		local spinner = Loader.new(c, {
			Size = 20,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
		})
		local text = makeLabel(c, {
			Text = opts.Name or "Carregando...",
			Position = UDim2.fromOffset(44, 0),
			Size = UDim2.new(1, -56, 1, 0),
		})

		local object = {}
		function object:SetText(newText)
			text.Text = newText
		end
		function object:Finish(newText)
			spinner:Destroy()
			text.Position = UDim2.fromOffset(12, 0)
			text.Text = newText or "Concluído"
		end
		function object:Destroy()
			spinner:Destroy()
			c:Destroy()
		end
		return object
	end

	function Library.CreateDummy(colors)
		colors = colors or {}
		local skin = colors.Skin or Color3.fromRGB(240, 190, 150)
		local shirt = colors.Shirt or Color3.fromRGB(70, 110, 200)
		local pants = colors.Pants or Color3.fromRGB(55, 58, 70)

		local model = Instance.new("Model")
		model.Name = "Dummy"

		local function part(name, partSize, position, color)
			local p = Instance.new("Part")
			p.Name = name
			p.Size = partSize
			p.CFrame = CFrame.new(position)
			p.Color = color
			p.Material = Enum.Material.SmoothPlastic
			p.Anchored = true
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
			p.TopSurface = Enum.SurfaceType.Smooth
			p.BottomSurface = Enum.SurfaceType.Smooth
			p.Parent = model
			return p
		end

		local torso = part("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0), shirt)
		local head = part("Head", Vector3.new(2, 1, 1), Vector3.new(0, 1.5, 0), skin)
		part("Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0), skin)
		part("Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0), skin)
		part("Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, -2, 0), pants)
		part("Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, -2, 0), pants)

		pcall(function()
			local face = Instance.new("Decal")
			face.Name = "face"
			face.Texture = "rbxasset://textures/face.png"
			face.Face = Enum.NormalId.Front
			face.Parent = head
		end)

		model.PrimaryPart = torso
		return model
	end

	function Tab:CreateViewport(opts)
		opts = opts or {}
		local height = opts.Height or 200
		local window = self.Window

		local card = makeCard(self.Page, height)
		card.ClipsDescendants = true
		card.Active = true

		local vp = Util.Create("ViewportFrame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Ambient = Color3.fromRGB(160, 160, 170),
			LightColor = Color3.fromRGB(255, 255, 255),
			LightDirection = Vector3.new(-0.4, -0.8, -0.6),
			ZIndex = 1,
			Parent = card,
		})
		local camera = Util.Create("Camera", {
			FieldOfView = opts.FieldOfView or 40,
			Parent = vp,
		})
		vp.CurrentCamera = camera

		if opts.Name then
			local title = makeLabel(card, {
				Text = opts.Name,
				TextSize = 12,
				Color = "SubText",
				Position = UDim2.fromOffset(10, 6),
				Size = UDim2.new(1, -20, 0, 16),
			})
			title.ZIndex = 6
		end

		local object = {
			Card = card,
			Viewport = vp,
			Camera = camera,
			Model = nil,
			Size = Vector3.new(4, 5, 1),
			Center = Vector3.zero,
			Angle = 0,
			AutoRotate = opts.Rotate ~= false,
			RotateSpeed = opts.RotateSpeed or 0.8,
		}

		local base = CFrame.new()
		local callbacks = {}
		local dragging = false

		local function apply()
			local model = object.Model
			if model then
				model:PivotTo(
					CFrame.new(object.Center)
						* CFrame.Angles(0, object.Angle, 0)
						* CFrame.new(-object.Center)
						* base
				)
			end
		end

		function object:SetModel(model)
			if self.Model then
				self.Model:Destroy()
			end
			self.Model = model
			if not model then
				return
			end
			model.Parent = vp
			local cf, boundsSize = model:GetBoundingBox()
			self.Center = cf.Position
			self.Size = boundsSize
			base = model:GetPivot()

			local dist = (boundsSize.Y * 0.5) / math.tan(math.rad(camera.FieldOfView * 0.5)) * 1.25
				+ boundsSize.Z * 0.5
			camera.CFrame = CFrame.new(self.Center - Vector3.new(0, 0, dist), self.Center)
			apply()
		end

		function object:Add(inst)
			inst.Parent = vp
			return inst
		end

		function object:OnRender(fn)
			table.insert(callbacks, fn)
		end

		function object:Project(worldPos)
			local rel = camera.CFrame:PointToObjectSpace(worldPos)
			local depth = -rel.Z
			local abs = vp.AbsoluteSize
			if depth <= 0.01 or abs.X <= 0 or abs.Y <= 0 then
				return nil
			end
			local h = 2 * depth * math.tan(math.rad(camera.FieldOfView * 0.5))
			local w = h * (abs.X / abs.Y)
			return Vector2.new((rel.X / w + 0.5) * abs.X, (0.5 - rel.Y / h) * abs.Y)
		end

		card.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		window:_track(UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				object.Angle += input.Delta.X * 0.012
				apply()
			end
		end))

		local page = self.Page
		window:_track(RunService.RenderStepped:Connect(function(dt)
			if not (page.Visible and window.Visible and not window.Minimized) then
				return
			end
			if object.Model and object.AutoRotate and not dragging then
				object.Angle += dt * object.RotateSpeed
				apply()
			end
			for _, fn in ipairs(callbacks) do
				local ok, err = pcall(fn, dt, object)
				if not ok then
					warn("[UILib] Erro no OnRender: " .. tostring(err))
				end
			end
		end))

		if opts.Model then
			object:SetModel(opts.Model)
		end

		return object
	end

	function Tab:CreateEspPreview(opts)
		opts = opts or {}
		local window = self.Window

		local viewport = self:CreateViewport({
			Name = opts.Name or "ESP Preview",
			Height = opts.Height or 250,
			FieldOfView = 35,
			Rotate = true,
			RotateSpeed = 0.6,
		})
		viewport:SetModel(opts.Model or Library.CreateDummy())

		local overlay = Util.Create("Frame", {
			Name = "EspOverlay",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 3,
			Parent = viewport.Card,
		})

		local hint = makeLabel(overlay, {
			Text = "Ative o ESP para ver o preview",
			Color = "SubText",
			TextSize = 12,
			Align = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
		})
		hint.ZIndex = 4
		hint.Visible = false

		local colorMap = {
			["Vermelho"] = Color3.fromRGB(255, 70, 70),
			["Verde"] = Color3.fromRGB(70, 255, 110),
			["Azul"] = Color3.fromRGB(70, 150, 255),
			["Branco"] = Color3.fromRGB(255, 255, 255),
		}

		local function flag(name, default)
			local f = window.Flags[name]
			if f == nil then
				return default
			end
			return f.Value
		end

		local function newFrame()
			return Util.Create("Frame", {
				BorderSizePixel = 0,
				ZIndex = 4,
				Visible = false,
				Parent = overlay,
			})
		end

		local function newText(textSize)
			return Util.Create("TextLabel", {
				BackgroundTransparency = 1,
				Font = Util.Fonts.Bold,
				TextSize = textSize,
				TextStrokeTransparency = 0.5,
				ZIndex = 5,
				Visible = false,
				Parent = overlay,
			})
		end

		local function setLine(line, a, b, color, thickness, transparency)
			local d = b - a
			line.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
			line.Size = UDim2.fromOffset(d.Magnitude, thickness)
			line.Rotation = math.deg(math.atan2(d.Y, d.X))
			line.BackgroundColor3 = color
			line.BackgroundTransparency = transparency
			line.Visible = true
		end

		local box = Util.Create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 4,
			Visible = false,
			Parent = overlay,
		})
		local boxStroke = Util.Stroke(box, 1.5, WHITE)

		local cornerPieces = {}
		for i = 1, 8 do
			cornerPieces[i] = newFrame()
		end

		local edges = {}
		for i = 1, 12 do
			local line = newFrame()
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			edges[i] = line
		end

		local skeletonLines = {}
		for i = 1, 10 do
			local line = newFrame()
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			skeletonLines[i] = line
		end

		local tracer = newFrame()
		tracer.AnchorPoint = Vector2.new(0.5, 0.5)

		local nameLabel = newText(13)
		nameLabel.AnchorPoint = Vector2.new(0.5, 1)
		nameLabel.Size = UDim2.fromOffset(200, 14)
		nameLabel.Text = Players.LocalPlayer and Players.LocalPlayer.DisplayName or "Jogador"

		local distLabel = newText(12)
		distLabel.AnchorPoint = Vector2.new(0.5, 0)
		distLabel.Size = UDim2.fromOffset(120, 14)

		local healthBg = newFrame()
		healthBg.BackgroundColor3 = Color3.new(0, 0, 0)
		local healthFill = newFrame()
		healthFill.ZIndex = 5

		local function hideAll()
			box.Visible = false
			nameLabel.Visible = false
			distLabel.Visible = false
			healthBg.Visible = false
			healthFill.Visible = false
			tracer.Visible = false
			for _, f in ipairs(cornerPieces) do
				f.Visible = false
			end
			for _, f in ipairs(edges) do
				f.Visible = false
			end
			for _, f in ipairs(skeletonLines) do
				f.Visible = false
			end
		end

		local CORNER_SIGNS = {}
		for i = 0, 7 do
			CORNER_SIGNS[i] = {
				(i % 2 == 0) and -1 or 1,
				(math.floor(i / 2) % 2 == 0) and -1 or 1,
				(math.floor(i / 4) % 2 == 0) and -1 or 1,
			}
		end
		local EDGE_PAIRS = {}
		for i = 0, 7 do
			for _, bit in ipairs({ 1, 2, 4 }) do
				if math.floor(i / bit) % 2 == 0 then
					table.insert(EDGE_PAIRS, { i, i + bit })
				end
			end
		end

		viewport:OnRender(function()
			if not flag("EspEnabled", true) then
				hideAll()
				hint.Visible = true
				return
			end
			hint.Visible = false

			local t = os.clock()
			local colorName = flag("EspColor", "Vermelho")
			local color
			if colorName == "Arco-íris" then
				color = Color3.fromHSV((t * 0.25) % 1, 1, 1)
			else
				color = colorMap[colorName] or colorMap["Vermelho"]
			end
			local alpha = math.clamp(flag("EspAlpha", 0), 0, 0.95)

			local center, bounds = viewport.Center, viewport.Size
			local half = Vector3.new(bounds.X, bounds.Y, bounds.X * 0.5) / 2
			local projected = {}
			local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
			for i = 0, 7 do
				local s = CORNER_SIGNS[i]
				local p = viewport:Project(center + Vector3.new(s[1] * half.X, s[2] * half.Y, s[3] * half.Z))
				if not p then
					hideAll()
					return
				end
				projected[i] = p
				minX, minY = math.min(minX, p.X), math.min(minY, p.Y)
				maxX, maxY = math.max(maxX, p.X), math.max(maxY, p.Y)
			end
			local x, y, w, h = minX, minY, maxX - minX, maxY - minY
			local overlaySize = overlay.AbsoluteSize

			local boxStyle = flag("EspBoxStyle", "Cantos")
			local showBoxes = flag("EspBoxes", false)
			box.Visible = showBoxes and boxStyle == "Completa"
			if box.Visible then
				box.Position = UDim2.fromOffset(x, y)
				box.Size = UDim2.fromOffset(w, h)
				boxStroke.Color = color
				boxStroke.Transparency = alpha
			end

			local showCorners = showBoxes and boxStyle == "Cantos"
			if showCorners then
				local len = math.max(6, math.min(w, h) * 0.22)
				local th = 2
				local pieces = {
					{ x, y, len, th }, { x, y, th, len },
					{ x + w - len, y, len, th }, { x + w - th, y, th, len },
					{ x, y + h - th, len, th }, { x, y + h - len, th, len },
					{ x + w - len, y + h - th, len, th }, { x + w - th, y + h - len, th, len },
				}
				for i, f in ipairs(cornerPieces) do
					local d = pieces[i]
					f.Position = UDim2.fromOffset(d[1], d[2])
					f.Size = UDim2.fromOffset(d[3], d[4])
					f.BackgroundColor3 = color
					f.BackgroundTransparency = alpha
					f.Visible = true
				end
			else
				for _, f in ipairs(cornerPieces) do
					f.Visible = false
				end
			end

			local show3d = showBoxes and boxStyle == "3D"
			for i, f in ipairs(edges) do
				if show3d then
					local pair = EDGE_PAIRS[i]
					setLine(f, projected[pair[1]], projected[pair[2]], color, 1.5, alpha)
				else
					f.Visible = false
				end
			end

			nameLabel.Visible = flag("EspNames", false)
			if nameLabel.Visible then
				nameLabel.Position = UDim2.fromOffset(x + w / 2, y - 3)
				nameLabel.TextColor3 = color
				nameLabel.TextTransparency = alpha
			end

			distLabel.Visible = flag("EspDistance", false)
			if distLabel.Visible then
				distLabel.Position = UDim2.fromOffset(x + w / 2, y + h + 3)
				distLabel.Text = string.format("%d studs", 60 + math.floor(25 * math.sin(t * 0.5)))
				distLabel.TextColor3 = color
				distLabel.TextTransparency = alpha
			end

			local showHealth = flag("EspHealth", false)
			healthBg.Visible = showHealth
			healthFill.Visible = showHealth
			if showHealth then
				local hp = 0.65 + 0.35 * math.sin(t * 0.9)
				healthBg.Position = UDim2.fromOffset(x - 7, y)
				healthBg.Size = UDim2.fromOffset(4, h)
				healthBg.BackgroundTransparency = 0.45
				healthFill.Position = UDim2.fromOffset(x - 6, y + 1 + (h - 2) * (1 - hp))
				healthFill.Size = UDim2.fromOffset(2, (h - 2) * hp)
				healthFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60):Lerp(Color3.fromRGB(60, 255, 100), hp)
				healthFill.BackgroundTransparency = alpha
			end

			if flag("EspTracers", false) then
				local origin = flag("EspTracerOrigin", "Embaixo")
				local from
				if origin == "Meio" then
					from = Vector2.new(overlaySize.X / 2, overlaySize.Y / 2)
				elseif origin == "Mouse" then
					from = UserInputService:GetMouseLocation() - overlay.AbsolutePosition
				else
					from = Vector2.new(overlaySize.X / 2, overlaySize.Y)
				end
				setLine(tracer, from, Vector2.new(x + w / 2, y + h), color, 1.5, alpha)
			else
				tracer.Visible = false
			end

			local model = viewport.Model
			local showSkeleton = flag("EspSkeleton", false)
			local torsoPart = model and model:FindFirstChild("Torso")
			local headPart = model and model:FindFirstChild("Head")
			local lArm = model and model:FindFirstChild("Left Arm")
			local rArm = model and model:FindFirstChild("Right Arm")
			local lLeg = model and model:FindFirstChild("Left Leg")
			local rLeg = model and model:FindFirstChild("Right Leg")
			if showSkeleton and torsoPart and headPart and lArm and rArm and lLeg and rLeg then
				local tcf = torsoPart.CFrame
				local pts = {
					head = headPart.Position,
					neck = tcf * Vector3.new(0, 1, 0),
					pelvis = tcf * Vector3.new(0, -1, 0),
					lSh = tcf * Vector3.new(-1, 1, 0),
					rSh = tcf * Vector3.new(1, 1, 0),
					lHand = lArm.CFrame * Vector3.new(0, -0.9, 0),
					rHand = rArm.CFrame * Vector3.new(0, -0.9, 0),
					lHip = tcf * Vector3.new(-0.5, -1, 0),
					rHip = tcf * Vector3.new(0.5, -1, 0),
					lFoot = lLeg.CFrame * Vector3.new(0, -1, 0),
					rFoot = rLeg.CFrame * Vector3.new(0, -1, 0),
				}
				local links = {
					{ "head", "neck" }, { "neck", "pelvis" },
					{ "neck", "lSh" }, { "lSh", "lHand" },
					{ "neck", "rSh" }, { "rSh", "rHand" },
					{ "pelvis", "lHip" }, { "lHip", "lFoot" },
					{ "pelvis", "rHip" }, { "rHip", "rFoot" },
				}
				for i, line in ipairs(skeletonLines) do
					local a = viewport:Project(pts[links[i][1]])
					local b = viewport:Project(pts[links[i][2]])
					if a and b then
						setLine(line, a, b, color, 1.5, alpha)
					else
						line.Visible = false
					end
				end
			else
				for _, line in ipairs(skeletonLines) do
					line.Visible = false
				end
			end
		end)

		return viewport
	end

	return Library
end)()

Library.Version = "1.1.0"

return Library

