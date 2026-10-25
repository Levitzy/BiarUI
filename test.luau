--!nonstrict
--[[
	BiarUI - Minimalist Modern Luau GUI Library
	Responsive across Desktop, Mobile, Tablet, and Console
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

export type ThemePalette = {
	Background: Color3,
	Sidebar: Color3,
	TitleBar: Color3,
	Surface: Color3,
	SurfaceHover: Color3,
	SurfaceActive: Color3,
	Control: Color3,
	ControlHover: Color3,
	Border: Color3,
	BorderSubtle: Color3,
	Accent: Color3,
	AccentHover: Color3,
	AccentSoft: Color3,
	Text: Color3,
	TextSecondary: Color3,
	TextMuted: Color3,
	Success: Color3,
	Danger: Color3,
}

export type GUIOptions = {
	subtitle: string?,
	theme: string | ThemePalette | nil,
	size: { number }?,
	toggleKey: Enum.KeyCode?,
	accentColor: Color3?,
}

-- Refined Neutral Zinc / Carbon Palettes (Linear / Geist / Shadcn inspired)
local Themes: { [string]: ThemePalette } = {
	Dark = {
		Background = Color3.fromRGB(10, 10, 12),
		Sidebar = Color3.fromRGB(13, 13, 16),
		TitleBar = Color3.fromRGB(10, 10, 12),
		Surface = Color3.fromRGB(17, 17, 21),
		SurfaceHover = Color3.fromRGB(22, 22, 27),
		SurfaceActive = Color3.fromRGB(26, 26, 33),
		Control = Color3.fromRGB(23, 23, 28),
		ControlHover = Color3.fromRGB(31, 31, 38),
		Border = Color3.fromRGB(42, 42, 50),
		BorderSubtle = Color3.fromRGB(28, 28, 34),
		Accent = Color3.fromRGB(99, 102, 241),
		AccentHover = Color3.fromRGB(129, 140, 248),
		AccentSoft = Color3.fromRGB(28, 29, 54),
		Text = Color3.fromRGB(244, 244, 246),
		TextSecondary = Color3.fromRGB(161, 161, 170),
		TextMuted = Color3.fromRGB(113, 113, 122),
		Success = Color3.fromRGB(16, 185, 129),
		Danger = Color3.fromRGB(239, 68, 68),
	},
	Midnight = {
		Background = Color3.fromRGB(8, 9, 12),
		Sidebar = Color3.fromRGB(11, 12, 16),
		TitleBar = Color3.fromRGB(8, 9, 12),
		Surface = Color3.fromRGB(15, 16, 22),
		SurfaceHover = Color3.fromRGB(20, 22, 30),
		SurfaceActive = Color3.fromRGB(25, 28, 38),
		Control = Color3.fromRGB(20, 22, 30),
		ControlHover = Color3.fromRGB(28, 31, 42),
		Border = Color3.fromRGB(38, 42, 56),
		BorderSubtle = Color3.fromRGB(25, 28, 38),
		Accent = Color3.fromRGB(59, 130, 246),
		AccentHover = Color3.fromRGB(96, 165, 250),
		AccentSoft = Color3.fromRGB(21, 34, 62),
		Text = Color3.fromRGB(248, 250, 252),
		TextSecondary = Color3.fromRGB(148, 163, 184),
		TextMuted = Color3.fromRGB(100, 116, 139),
		Success = Color3.fromRGB(34, 197, 94),
		Danger = Color3.fromRGB(244, 63, 94),
	},
	Light = {
		Background = Color3.fromRGB(250, 250, 250),
		Sidebar = Color3.fromRGB(244, 244, 245),
		TitleBar = Color3.fromRGB(250, 250, 250),
		Surface = Color3.fromRGB(255, 255, 255),
		SurfaceHover = Color3.fromRGB(244, 244, 245),
		SurfaceActive = Color3.fromRGB(228, 228, 231),
		Control = Color3.fromRGB(244, 244, 245),
		ControlHover = Color3.fromRGB(228, 228, 231),
		Border = Color3.fromRGB(212, 212, 216),
		BorderSubtle = Color3.fromRGB(228, 228, 231),
		Accent = Color3.fromRGB(79, 70, 229),
		AccentHover = Color3.fromRGB(99, 102, 241),
		AccentSoft = Color3.fromRGB(224, 231, 255),
		Text = Color3.fromRGB(24, 24, 27),
		TextSecondary = Color3.fromRGB(82, 82, 91),
		TextMuted = Color3.fromRGB(161, 161, 170),
		Success = Color3.fromRGB(5, 150, 105),
		Danger = Color3.fromRGB(220, 38, 38),
	},
}

local GUI = {}
GUI.__index = GUI
GUI.Themes = Themes

-- Ultra-smooth Exponential & Quint easing curves
local INSTANT_TWEEN = TweenInfo.new(0.06, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local FAST_TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SMOOTH_TWEEN = TweenInfo.new(0.28, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local SPRING_TWEEN = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Modern geometric sans typography (BuilderSans / Inter style)
local FONT_FAMILY = "rbxasset://fonts/families/BuilderSans.json"
local Fonts = {
	Regular = Font.new(FONT_FAMILY, Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Medium = Font.new(FONT_FAMILY, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
	SemiBold = Font.new(FONT_FAMILY, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
	Bold = Font.new(FONT_FAMILY, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
}

local function applyFont(label: TextLabel | TextButton | TextBox, fontFace: Font)
	local ok = pcall(function()
		label.FontFace = fontFace
	end)
	if not ok then
		label.Font = Enum.Font.GothamMedium
	end
end

local function getParentContainer(): Instance
	local success, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	local player = Players.LocalPlayer
	if player then
		local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5)
		if playerGui then
			return playerGui
		end
	end
	if success and coreGui then
		return coreGui
	end
	return workspace
end

local function createCorner(parent: Instance, radius: number): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function createStroke(parent: Instance, color: Color3, thickness: number?, transparency: number?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function createPadding(parent: Instance, top: number, bottom: number, left: number, right: number): UIPadding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, top)
	padding.PaddingBottom = UDim.new(0, bottom)
	padding.PaddingLeft = UDim.new(0, left)
	padding.PaddingRight = UDim.new(0, right)
	padding.Parent = parent
	return padding
end

local function createBar(parent: Instance, size: UDim2, pos: UDim2, color: Color3, rotation: number?, anchor: Vector2?): Frame
	local bar = Instance.new("Frame")
	bar.Size = size
	bar.Position = pos
	bar.AnchorPoint = anchor or Vector2.new(0.5, 0.5)
	bar.BackgroundColor3 = color
	bar.BorderSizePixel = 0
	bar.Rotation = rotation or 0
	bar.Parent = parent
	createCorner(bar, 4)
	return bar
end

local function inferIconName(label: string): string
	local lower = label:lower()
	if lower:find("home") or lower:find("main") or lower:find("dash") or lower:find("overview") then
		return "home"
	elseif lower:find("setting") or lower:find("config") or lower:find("option") or lower:find("pref") then
		return "sliders"
	elseif lower:find("combat") or lower:find("aim") or lower:find("weapon") or lower:find("fight") or lower:find("attack") then
		return "target"
	elseif lower:find("visual") or lower:find("esp") or lower:find("render") or lower:find("camera") or lower:find("view") then
		return "eye"
	elseif lower:find("player") or lower:find("character") or lower:find("movement") or lower:find("user") or lower:find("profile") then
		return "user"
	elseif lower:find("script") or lower:find("exec") or lower:find("console") or lower:find("log") or lower:find("cmd") then
		return "terminal"
	elseif lower:find("auto") or lower:find("farm") or lower:find("fast") or lower:find("boost") or lower:find("speed") then
		return "zap"
	elseif lower:find("teleport") or lower:find("world") or lower:find("map") or lower:find("place") then
		return "compass"
	elseif lower:find("info") or lower:find("about") or lower:find("help") or lower:find("credit") then
		return "info"
	elseif lower:find("notify") or lower:find("alert") or lower:find("bell") then
		return "bell"
	end
	return "grid"
end

function GUI:createIcon(iconName: string?, size: number?, color: Color3?, parent: Instance?): GuiObject
	local iconSize = size or 14
	local iconColor = color or self.theme.TextSecondary
	local kind = (iconName or "dot"):lower()

	if iconName and (iconName:sub(1, 13) == "rbxassetid://" or tonumber(iconName) ~= nil) then
		local image = Instance.new("ImageLabel")
		image.Name = "Icon"
		image.Size = UDim2.fromOffset(iconSize, iconSize)
		image.BackgroundTransparency = 1
		image.Image = if tonumber(iconName) then `rbxassetid://{iconName}` else iconName
		image.ImageColor3 = iconColor
		image.ScaleType = Enum.ScaleType.Fit
		if parent then
			image.Parent = parent
		end
		return image
	end

	local container = Instance.new("Frame")
	container.Name = `Icon_{kind}`
	container.Size = UDim2.fromOffset(iconSize, iconSize)
	container.BackgroundTransparency = 1
	if parent then
		container.Parent = parent
	end

	local strokeWidth = math.max(1.4, math.floor(iconSize * 0.11 * 2) / 2)

	if kind == "search" then
		local lensSize = math.floor(iconSize * 0.68)
		local lens = Instance.new("Frame")
		lens.Name = "TintStroke"
		lens.Size = UDim2.fromOffset(lensSize, lensSize)
		lens.Position = UDim2.fromOffset(1, 1)
		lens.BackgroundTransparency = 1
		lens.Parent = container
		createCorner(lens, lensSize)
		createStroke(lens, iconColor, strokeWidth)

		createBar(
			container,
			UDim2.fromOffset(math.max(4, math.floor(iconSize * 0.36)), strokeWidth),
			UDim2.new(0.76, 0, 0.76, 0),
			iconColor,
			45
		)
	elseif kind == "close" or kind == "x" then
		local barLen = math.floor(iconSize * 0.76)
		createBar(container, UDim2.fromOffset(barLen, strokeWidth), UDim2.fromScale(0.5, 0.5), iconColor, 45)
		createBar(container, UDim2.fromOffset(barLen, strokeWidth), UDim2.fromScale(0.5, 0.5), iconColor, -45)
	elseif kind == "minimize" or kind == "minus" then
		local barLen = math.floor(iconSize * 0.66)
		createBar(container, UDim2.fromOffset(barLen, strokeWidth), UDim2.fromScale(0.5, 0.5), iconColor, 0)
	elseif kind == "plus" or kind == "add" then
		local barLen = math.floor(iconSize * 0.66)
		createBar(container, UDim2.fromOffset(barLen, strokeWidth), UDim2.fromScale(0.5, 0.5), iconColor, 0)
		createBar(container, UDim2.fromOffset(strokeWidth, barLen), UDim2.fromScale(0.5, 0.5), iconColor, 0)
	elseif kind == "chevron-down" or kind == "chevron-up" then
		local arm = math.max(5, math.floor(iconSize * 0.44))
		local isUp = (kind == "chevron-up")
		createBar(
			container,
			UDim2.fromOffset(arm, strokeWidth),
			UDim2.new(0.36, 0, 0.52, 0),
			iconColor,
			if isUp then -42 else 42
		)
		createBar(
			container,
			UDim2.fromOffset(arm, strokeWidth),
			UDim2.new(0.64, 0, 0.52, 0),
			iconColor,
			if isUp then 42 else -42
		)
	elseif kind == "chevron-right" then
		local arm = math.max(5, math.floor(iconSize * 0.44))
		createBar(container, UDim2.fromOffset(arm, strokeWidth), UDim2.new(0.5, 0, 0.36, 0), iconColor, 42)
		createBar(container, UDim2.fromOffset(arm, strokeWidth), UDim2.new(0.5, 0, 0.64, 0), iconColor, -42)
	elseif kind == "check" then
		local shortArm = math.max(4, math.floor(iconSize * 0.34))
		local longArm = math.max(7, math.floor(iconSize * 0.62))
		createBar(container, UDim2.fromOffset(shortArm, strokeWidth), UDim2.new(0.33, 0, 0.60, 0), iconColor, 45)
		createBar(container, UDim2.fromOffset(longArm, strokeWidth), UDim2.new(0.62, 0, 0.48, 0), iconColor, -48)
	elseif kind == "sidebar" or kind == "menu" then
		local box = Instance.new("Frame")
		box.Name = "TintStroke"
		box.Size = UDim2.fromScale(0.86, 0.76)
		box.Position = UDim2.fromScale(0.5, 0.5)
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		box.BackgroundTransparency = 1
		box.Parent = container
		createCorner(box, 3)
		createStroke(box, iconColor, strokeWidth)

		createBar(container, UDim2.new(0, strokeWidth, 0.74, 0), UDim2.new(0.36, 0, 0.5, 0), iconColor, 0)
	elseif kind == "sliders" or kind == "settings" then
		createBar(container, UDim2.new(0.82, 0, 0, strokeWidth), UDim2.new(0.5, 0, 0.32, 0), iconColor, 0)
		createBar(container, UDim2.new(0.82, 0, 0, strokeWidth), UDim2.new(0.5, 0, 0.68, 0), iconColor, 0)
		local k1 = createBar(container, UDim2.fromOffset(4, 4), UDim2.new(0.35, 0, 0.32, 0), iconColor, 0)
		createCorner(k1, 4)
		local k2 = createBar(container, UDim2.fromOffset(4, 4), UDim2.new(0.66, 0, 0.68, 0), iconColor, 0)
		createCorner(k2, 4)
	elseif kind == "home" or kind == "grid" or kind == "dashboard" then
		local cell = math.max(4, math.floor(iconSize * 0.36))
		local positions = {
			UDim2.new(0.28, 0, 0.28, 0),
			UDim2.new(0.72, 0, 0.28, 0),
			UDim2.new(0.28, 0, 0.72, 0),
			UDim2.new(0.72, 0, 0.72, 0),
		}
		for _, pos in positions do
			local sq = Instance.new("Frame")
			sq.Name = "TintStroke"
			sq.Size = UDim2.fromOffset(cell, cell)
			sq.Position = pos
			sq.AnchorPoint = Vector2.new(0.5, 0.5)
			sq.BackgroundTransparency = 1
			sq.Parent = container
			createCorner(sq, 2)
			createStroke(sq, iconColor, 1.3)
		end
	elseif kind == "target" or kind == "combat" then
		local ring = Instance.new("Frame")
		ring.Name = "TintStroke"
		ring.Size = UDim2.fromScale(0.76, 0.76)
		ring.Position = UDim2.fromScale(0.5, 0.5)
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.BackgroundTransparency = 1
		ring.Parent = container
		createCorner(ring, iconSize)
		createStroke(ring, iconColor, strokeWidth)

		createBar(container, UDim2.fromOffset(3, 3), UDim2.fromScale(0.5, 0.5), iconColor, 0)
	elseif kind == "eye" or kind == "visual" then
		local outer = Instance.new("Frame")
		outer.Name = "TintStroke"
		outer.Size = UDim2.fromScale(0.88, 0.54)
		outer.Position = UDim2.fromScale(0.5, 0.5)
		outer.AnchorPoint = Vector2.new(0.5, 0.5)
		outer.BackgroundTransparency = 1
		outer.Parent = container
		createCorner(outer, iconSize)
		createStroke(outer, iconColor, strokeWidth)

		local pupil = createBar(container, UDim2.fromOffset(4, 4), UDim2.fromScale(0.5, 0.5), iconColor, 0)
		createCorner(pupil, 4)
	elseif kind == "user" or kind == "player" then
		local head = Instance.new("Frame")
		head.Name = "TintStroke"
		head.Size = UDim2.fromScale(0.42, 0.42)
		head.Position = UDim2.new(0.5, 0, 0.30, 0)
		head.AnchorPoint = Vector2.new(0.5, 0.5)
		head.BackgroundTransparency = 1
		head.Parent = container
		createCorner(head, iconSize)
		createStroke(head, iconColor, strokeWidth)

		local body = Instance.new("Frame")
		body.Name = "TintStroke"
		body.Size = UDim2.fromScale(0.74, 0.34)
		body.Position = UDim2.new(0.5, 0, 0.76, 0)
		body.AnchorPoint = Vector2.new(0.5, 0.5)
		body.BackgroundTransparency = 1
		body.Parent = container
		createCorner(body, 5)
		createStroke(body, iconColor, strokeWidth)
	elseif kind == "terminal" or kind == "code" then
		local arm = math.max(4, math.floor(iconSize * 0.36))
		createBar(container, UDim2.fromOffset(arm, strokeWidth), UDim2.new(0.32, 0, 0.38, 0), iconColor, 38)
		createBar(container, UDim2.fromOffset(arm, strokeWidth), UDim2.new(0.32, 0, 0.60, 0), iconColor, -38)
		createBar(container, UDim2.fromOffset(arm + 1, strokeWidth), UDim2.new(0.68, 0, 0.68, 0), iconColor, 0)
	elseif kind == "zap" or kind == "bolt" then
		local arm = math.max(6, math.floor(iconSize * 0.52))
		createBar(container, UDim2.fromOffset(arm, strokeWidth), UDim2.new(0.46, 0, 0.36, 0), iconColor, -52)
		createBar(container, UDim2.fromOffset(arm * 0.7, strokeWidth), UDim2.new(0.5, 0, 0.5, 0), iconColor, 0)
		createBar(container, UDim2.fromOffset(arm, strokeWidth), UDim2.new(0.54, 0, 0.64, 0), iconColor, -52)
	elseif kind == "compass" then
		local ring = Instance.new("Frame")
		ring.Name = "TintStroke"
		ring.Size = UDim2.fromScale(0.80, 0.80)
		ring.Position = UDim2.fromScale(0.5, 0.5)
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.BackgroundTransparency = 1
		ring.Parent = container
		createCorner(ring, iconSize)
		createStroke(ring, iconColor, strokeWidth)

		createBar(container, UDim2.fromOffset(math.floor(iconSize * 0.42), strokeWidth), UDim2.fromScale(0.5, 0.5), iconColor, -45)
	elseif kind == "info" or kind == "bell" then
		local ring = Instance.new("Frame")
		ring.Name = "TintStroke"
		ring.Size = UDim2.fromScale(0.80, 0.80)
		ring.Position = UDim2.fromScale(0.5, 0.5)
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.BackgroundTransparency = 1
		ring.Parent = container
		createCorner(ring, iconSize)
		createStroke(ring, iconColor, strokeWidth)

		createBar(container, UDim2.fromOffset(strokeWidth, math.floor(iconSize * 0.28)), UDim2.new(0.5, 0, 0.60, 0), iconColor, 0)
		createBar(container, UDim2.fromOffset(strokeWidth, strokeWidth), UDim2.new(0.5, 0, 0.34, 0), iconColor, 0)
	else
		local dot = createBar(
			container,
			UDim2.fromOffset(math.max(5, math.floor(iconSize * 0.42)), math.max(5, math.floor(iconSize * 0.42))),
			UDim2.fromScale(0.5, 0.5),
			iconColor,
			0
		)
		createCorner(dot, iconSize)
	end

	return container
end

function GUI:tintIcon(iconObject: GuiObject?, color: Color3)
	if not iconObject then
		return
	end
	if iconObject:IsA("ImageLabel") then
		TweenService:Create(iconObject, FAST_TWEEN, { ImageColor3 = color }):Play()
		return
	end
	for _, desc in iconObject:GetDescendants() do
		if desc:IsA("UIStroke") then
			TweenService:Create(desc, FAST_TWEEN, { Color = color }):Play()
		elseif desc:IsA("Frame") and desc.Name ~= "TintStroke" and desc.BackgroundTransparency < 1 then
			TweenService:Create(desc, FAST_TWEEN, { BackgroundColor3 = color }):Play()
		end
	end
end

function GUI.new(title: string?, options: GUIOptions?)
	local self = setmetatable({}, GUI)
	local opts: GUIOptions = options or {}

	if type(opts.theme) == "table" then
		self.theme = opts.theme :: ThemePalette
	elseif type(opts.theme) == "string" and Themes[opts.theme] then
		self.theme = table.clone(Themes[opts.theme])
	else
		self.theme = table.clone(Themes.Dark)
	end

	if opts.accentColor then
		self.theme.Accent = opts.accentColor
	end

	self.titleText = title or "BiarUI"
	self.subtitleText = opts.subtitle
	self.toggleKey = opts.toggleKey or Enum.KeyCode.RightShift

	self._connections = {} :: { RBXScriptConnection }
	self._contentConnections = {} :: { RBXScriptConnection }

	self.sidebarItems = {}
	self.sidebarCallbacks = {}
	self.sidebarIcons = {}
	self.selectedItem = nil
	self.currentSidebarName = "Default"
	self.dialogs = {}
	self.dropdownSelections = {}
	self.multiSelectDropdowns = {}
	self.componentStates = {}
	self.componentCallbacks = {}
	self._layoutOrder = 0
	self._sidebarCollapsed = false
	self._minimized = false

	self:_detectDevice()

	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "BiarUI"
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.Parent = getParentContainer()

	local baseWidth, baseHeight = self:_computeWindowMetrics(opts.size)
	self.baseSize = Vector2.new(baseWidth, baseHeight)

	self.mainFrame = Instance.new("Frame")
	self.mainFrame.Name = "MainFrame"
	self.mainFrame.Size = UDim2.fromOffset(baseWidth, baseHeight)
	self.mainFrame.Position = UDim2.fromScale(0.5, 0.5)
	self.mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.mainFrame.BackgroundColor3 = self.theme.Background
	self.mainFrame.BorderSizePixel = 0
	self.mainFrame.ClipsDescendants = true
	self.mainFrame.ZIndex = 2
	self.mainFrame.Parent = self.screenGui

	self.uiScale = Instance.new("UIScale")
	self.uiScale.Scale = 1
	self.uiScale.Parent = self.mainFrame

	createCorner(self.mainFrame, 10)
	self.mainStroke = createStroke(self.mainFrame, self.theme.Border, 1, 0)

	self:createTitleBar(self.titleText)
	self:createSidebar()
	self:createContentArea()
	self:createSearchBar()
	self:_createFloatingPill()
	self:_createNotificationHost()

	self:makeDraggable()
	self:_setupResponsiveListeners()

	return self
end

function GUI:_detectDevice()
	local camera = workspace.CurrentCamera
	self.screenSize = if camera then camera.ViewportSize else Vector2.new(1280, 720)
	local isTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local isSmallViewport = self.screenSize.X < 680 or self.screenSize.Y < 440
	self.isMobile = isTouch or isSmallViewport
	self.isCompact = self.screenSize.X < 520 or self.screenSize.Y < 360
end

function GUI:_computeWindowMetrics(customSize: { number }?): (number, number)
	if customSize and customSize[1] and customSize[2] then
		return customSize[1], customSize[2]
	end
	if self.isCompact then
		return 440, 290
	elseif self.isMobile then
		return 480, 320
	else
		return 550, 360
	end
end

function GUI:_updateResponsiveLayout()
	if not self.mainFrame or not self.mainFrame.Parent then
		return
	end
	self:_detectDevice()

	local vp = self.screenSize
	local targetW, targetH = self.baseSize.X, self.baseSize.Y

	local maxW = math.max(260, vp.X - 24)
	local maxH = math.max(200, vp.Y - 28)
	local scaleX = maxW / targetW
	local scaleY = maxH / targetH
	local scale = math.clamp(math.min(scaleX, scaleY, 1.08), 0.62, 1.08)

	if self.uiScale then
		self.uiScale.Scale = scale
	end

	local absW = targetW * scale
	local absH = targetH * scale
	local centerX = (vp.X * self.mainFrame.Position.X.Scale) + self.mainFrame.Position.X.Offset
	local centerY = (vp.Y * self.mainFrame.Position.Y.Scale) + self.mainFrame.Position.Y.Offset

	local halfW = absW * 0.5
	local halfH = absH * 0.5
	local clampedX = math.clamp(centerX, halfW + 8, math.max(halfW + 8, vp.X - halfW - 8))
	local clampedY = math.clamp(centerY, halfH + 8, math.max(halfH + 8, vp.Y - halfH - 8))

	self.mainFrame.Position = UDim2.fromOffset(clampedX, clampedY)
end

function GUI:_setupResponsiveListeners()
	local camera = workspace.CurrentCamera
	if camera then
		table.insert(
			self._connections,
			camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				self:_updateResponsiveLayout()
			end)
		)
	end

	table.insert(
		self._connections,
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and self.toggleKey and input.KeyCode == self.toggleKey then
				self:toggleMinimize()
			end
		end)
	)

	task.defer(function()
		self:_updateResponsiveLayout()
	end)
end

function GUI:createTitleBar(title: string)
	local titleHeight = if self.isMobile then 36 else 38
	self.titleHeight = titleHeight

	self.titleBar = Instance.new("Frame")
	self.titleBar.Name = "TitleBar"
	self.titleBar.Size = UDim2.new(1, 0, 0, titleHeight)
	self.titleBar.Position = UDim2.fromOffset(0, 0)
	self.titleBar.BackgroundColor3 = self.theme.TitleBar
	self.titleBar.BorderSizePixel = 0
	self.titleBar.ZIndex = 5
	self.titleBar.Parent = self.mainFrame

	-- Razor-thin bottom hairline divider
	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.new(0, 0, 1, -1)
	divider.BackgroundColor3 = self.theme.BorderSubtle
	divider.BorderSizePixel = 0
	divider.Parent = self.titleBar

	-- Sidebar toggle button
	self.sidebarToggleBtn = Instance.new("TextButton")
	self.sidebarToggleBtn.Name = "SidebarToggle"
	self.sidebarToggleBtn.Size = UDim2.fromOffset(24, 24)
	self.sidebarToggleBtn.Position = UDim2.new(0, 10, 0.5, -12)
	self.sidebarToggleBtn.BackgroundColor3 = self.theme.SurfaceHover
	self.sidebarToggleBtn.BackgroundTransparency = 1
	self.sidebarToggleBtn.BorderSizePixel = 0
	self.sidebarToggleBtn.Text = ""
	self.sidebarToggleBtn.AutoButtonColor = false
	self.sidebarToggleBtn.Parent = self.titleBar
	createCorner(self.sidebarToggleBtn, 6)

	local sidebarIcon = self:createIcon("sidebar", 13, self.theme.TextSecondary, self.sidebarToggleBtn)
	sidebarIcon.Position = UDim2.fromScale(0.5, 0.5)
	sidebarIcon.AnchorPoint = Vector2.new(0.5, 0.5)

	self.sidebarToggleBtn.MouseEnter:Connect(function()
		TweenService:Create(self.sidebarToggleBtn, FAST_TWEEN, { BackgroundTransparency = 0 }):Play()
		self:tintIcon(sidebarIcon, self.theme.Text)
	end)
	self.sidebarToggleBtn.MouseLeave:Connect(function()
		TweenService:Create(self.sidebarToggleBtn, FAST_TWEEN, { BackgroundTransparency = 1 }):Play()
		self:tintIcon(sidebarIcon, self.theme.TextSecondary)
	end)
	self.sidebarToggleBtn.MouseButton1Click:Connect(function()
		self:toggleSidebar()
	end)

	-- Subtle vertical separator
	local sep = Instance.new("Frame")
	sep.Name = "HeaderSep"
	sep.Size = UDim2.fromOffset(1, 12)
	sep.Position = UDim2.new(0, 41, 0.5, -6)
	sep.BackgroundColor3 = self.theme.BorderSubtle
	sep.BorderSizePixel = 0
	sep.Parent = self.titleBar

	-- Title label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -124, 1, 0)
	titleLabel.Position = UDim2.fromOffset(50, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = self.theme.Text
	titleLabel.TextSize = if self.isMobile then 13 else 14
	applyFont(titleLabel, Fonts.SemiBold)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.Parent = self.titleBar
	self.titleLabel = titleLabel

	-- Minimize button
	self.minimizeButton = Instance.new("TextButton")
	self.minimizeButton.Name = "MinimizeButton"
	self.minimizeButton.Size = UDim2.fromOffset(24, 24)
	self.minimizeButton.Position = UDim2.new(1, -60, 0.5, -12)
	self.minimizeButton.BackgroundColor3 = self.theme.SurfaceHover
	self.minimizeButton.BackgroundTransparency = 1
	self.minimizeButton.BorderSizePixel = 0
	self.minimizeButton.Text = ""
	self.minimizeButton.AutoButtonColor = false
	self.minimizeButton.Parent = self.titleBar
	createCorner(self.minimizeButton, 6)

	local minIcon = self:createIcon("minimize", 11, self.theme.TextSecondary, self.minimizeButton)
	minIcon.Position = UDim2.fromScale(0.5, 0.5)
	minIcon.AnchorPoint = Vector2.new(0.5, 0.5)

	self.minimizeButton.MouseEnter:Connect(function()
		TweenService:Create(self.minimizeButton, FAST_TWEEN, { BackgroundTransparency = 0 }):Play()
		self:tintIcon(minIcon, self.theme.Text)
	end)
	self.minimizeButton.MouseLeave:Connect(function()
		TweenService:Create(self.minimizeButton, FAST_TWEEN, { BackgroundTransparency = 1 }):Play()
		self:tintIcon(minIcon, self.theme.TextSecondary)
	end)
	self.minimizeButton.MouseButton1Click:Connect(function()
		self:toggleMinimize()
	end)

	-- Close button
	self.closeButton = Instance.new("TextButton")
	self.closeButton.Name = "CloseButton"
	self.closeButton.Size = UDim2.fromOffset(24, 24)
	self.closeButton.Position = UDim2.new(1, -32, 0.5, -12)
	self.closeButton.BackgroundColor3 = self.theme.Danger
	self.closeButton.BackgroundTransparency = 1
	self.closeButton.BorderSizePixel = 0
	self.closeButton.Text = ""
	self.closeButton.AutoButtonColor = false
	self.closeButton.Parent = self.titleBar
	createCorner(self.closeButton, 6)

	local closeIcon = self:createIcon("close", 11, self.theme.TextSecondary, self.closeButton)
	closeIcon.Position = UDim2.fromScale(0.5, 0.5)
	closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)

	self.closeButton.MouseEnter:Connect(function()
		TweenService:Create(self.closeButton, FAST_TWEEN, { BackgroundTransparency = 0.12 }):Play()
		self:tintIcon(closeIcon, Color3.fromRGB(255, 255, 255))
	end)
	self.closeButton.MouseLeave:Connect(function()
		TweenService:Create(self.closeButton, FAST_TWEEN, { BackgroundTransparency = 1 }):Play()
		self:tintIcon(closeIcon, self.theme.TextSecondary)
	end)
	self.closeButton.MouseButton1Click:Connect(function()
		self:destroy()
	end)
end

function GUI:_createFloatingPill()
	self.floatingPill = Instance.new("TextButton")
	self.floatingPill.Name = "BiarUIPill"
	self.floatingPill.Size = UDim2.fromOffset(116, 32)
	self.floatingPill.Position = UDim2.new(0.5, 0, 0, 18)
	self.floatingPill.AnchorPoint = Vector2.new(0.5, 0)
	self.floatingPill.BackgroundColor3 = self.theme.Background
	self.floatingPill.BorderSizePixel = 0
	self.floatingPill.Text = ""
	self.floatingPill.AutoButtonColor = false
	self.floatingPill.Visible = false
	self.floatingPill.ZIndex = 50
	self.floatingPill.Parent = self.screenGui
	createCorner(self.floatingPill, 16)
	createStroke(self.floatingPill, self.theme.Border, 1, 0)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(6, 6)
	dot.Position = UDim2.new(0, 13, 0.5, -3)
	dot.BackgroundColor3 = self.theme.Accent
	dot.BorderSizePixel = 0
	dot.Parent = self.floatingPill
	createCorner(dot, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -44, 1, 0)
	label.Position = UDim2.fromOffset(25, 0)
	label.BackgroundTransparency = 1
	label.Text = self.titleText
	label.TextColor3 = self.theme.Text
	label.TextSize = 12
	applyFont(label, Fonts.SemiBold)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = self.floatingPill

	local chevron = self:createIcon("chevron-down", 11, self.theme.TextSecondary, self.floatingPill)
	chevron.Position = UDim2.new(1, -16, 0.5, 0)
	chevron.AnchorPoint = Vector2.new(0.5, 0.5)

	local pillDragging = false
	local pillMoved = false
	local pillDragStart: Vector3? = nil
	local pillStartPos: UDim2? = nil

	self.floatingPill.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pillDragging = true
			pillMoved = false
			pillDragStart = input.Position
			pillStartPos = self.floatingPill.Position
		end
	end)

	table.insert(
		self._connections,
		UserInputService.InputChanged:Connect(function(input)
			if
				pillDragging
				and pillDragStart
				and pillStartPos
				and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				local delta = input.Position - pillDragStart
				if delta.Magnitude > 6 then
					pillMoved = true
					local vp = self.screenSize
					local rawX = (vp.X * pillStartPos.X.Scale) + pillStartPos.X.Offset + delta.X
					local rawY = (vp.Y * pillStartPos.Y.Scale) + pillStartPos.Y.Offset + delta.Y
					local clampedX = math.clamp(rawX, 64, math.max(64, vp.X - 64))
					local clampedY = math.clamp(rawY, 12, math.max(12, vp.Y - 46))
					TweenService:Create(self.floatingPill, INSTANT_TWEEN, {
						Position = UDim2.fromOffset(clampedX, clampedY),
					}):Play()
				end
			end
		end)
	)

	table.insert(
		self._connections,
		UserInputService.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				pillDragging = false
			end
		end)
	)

	self.floatingPill.MouseButton1Click:Connect(function()
		if not pillMoved then
			self:toggleMinimize()
		end
	end)
end

function GUI:toggleMinimize()
	self._minimized = not self._minimized
	if self._minimized then
		self.floatingPill.Visible = true
		self.floatingPill.BackgroundTransparency = 1
		TweenService:Create(self.floatingPill, FAST_TWEEN, { BackgroundTransparency = 0 }):Play()
		self.mainFrame.Visible = false
	else
		self.floatingPill.Visible = false
		self.mainFrame.Visible = true
	end
end

function GUI:toggleSidebar()
	self._sidebarCollapsed = not self._sidebarCollapsed
	local sidebarWidth = if self._sidebarCollapsed then 0 else self.sidebarWidth
	self.sidebar.ClipsDescendants = true

	TweenService:Create(self.sidebar, SMOOTH_TWEEN, {
		Size = UDim2.new(0, sidebarWidth, 1, -self.titleHeight),
	}):Play()

	TweenService:Create(self.contentArea, SMOOTH_TWEEN, {
		Size = UDim2.new(1, -sidebarWidth, 1, -self.titleHeight),
		Position = UDim2.fromOffset(sidebarWidth, self.titleHeight),
	}):Play()
end

function GUI:createSidebar()
	local sidebarWidth = if self.isMobile then 130 else 150
	self.sidebarWidth = sidebarWidth
	local titleHeight = self.titleHeight or (if self.isMobile then 36 else 38)

	self.sidebar = Instance.new("Frame")
	self.sidebar.Name = "Sidebar"
	self.sidebar.Size = UDim2.new(0, sidebarWidth, 1, -titleHeight)
	self.sidebar.Position = UDim2.fromOffset(0, titleHeight)
	self.sidebar.BackgroundColor3 = self.theme.Sidebar
	self.sidebar.BorderSizePixel = 0
	self.sidebar.ClipsDescendants = true
	self.sidebar.Parent = self.mainFrame

	-- Hairline vertical divider on right edge of sidebar
	local borderRight = Instance.new("Frame")
	borderRight.Name = "SidebarDivider"
	borderRight.Size = UDim2.new(0, 1, 1, 0)
	borderRight.Position = UDim2.new(1, -1, 0, 0)
	borderRight.BackgroundColor3 = self.theme.BorderSubtle
	borderRight.BorderSizePixel = 0
	borderRight.Parent = self.sidebar

	local topOffset = if self.isMobile then 42 else 46

	self.sidebarScrolling = Instance.new("ScrollingFrame")
	self.sidebarScrolling.Name = "SidebarScrolling"
	self.sidebarScrolling.Size = UDim2.new(1, -1, 1, -topOffset)
	self.sidebarScrolling.Position = UDim2.fromOffset(0, topOffset)
	self.sidebarScrolling.BackgroundTransparency = 1
	self.sidebarScrolling.BorderSizePixel = 0
	self.sidebarScrolling.ScrollBarThickness = 2
	self.sidebarScrolling.ScrollBarImageColor3 = self.theme.Border
	self.sidebarScrolling.CanvasSize = UDim2.fromOffset(0, 0)
	self.sidebarScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.sidebarScrolling.Parent = self.sidebar

	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sidebarLayout.Padding = UDim.new(0, 3)
	sidebarLayout.Parent = self.sidebarScrolling

	createPadding(self.sidebarScrolling, 4, 8, 8, 8)
end

function GUI:createSearchBar()
	local searchHeight = if self.isMobile then 26 else 28

	self.searchFrame = Instance.new("Frame")
	self.searchFrame.Name = "SearchFrame"
	self.searchFrame.Size = UDim2.new(1, -16, 0, searchHeight)
	self.searchFrame.Position = UDim2.fromOffset(8, 9)
	self.searchFrame.BackgroundColor3 = self.theme.Surface
	self.searchFrame.BorderSizePixel = 0
	self.searchFrame.Parent = self.sidebar

	createCorner(self.searchFrame, 6)
	local searchStroke = createStroke(self.searchFrame, self.theme.BorderSubtle, 1, 0)

	local searchIcon = self:createIcon("search", 12, self.theme.TextMuted, self.searchFrame)
	searchIcon.Position = UDim2.new(0, 8, 0.5, 0)
	searchIcon.AnchorPoint = Vector2.new(0, 0.5)

	self.searchBox = Instance.new("TextBox")
	self.searchBox.Name = "SearchBox"
	self.searchBox.Size = UDim2.new(1, -28, 1, 0)
	self.searchBox.Position = UDim2.fromOffset(25, 0)
	self.searchBox.BackgroundTransparency = 1
	self.searchBox.Text = ""
	self.searchBox.PlaceholderText = "Search..."
	self.searchBox.TextColor3 = self.theme.Text
	self.searchBox.PlaceholderColor3 = self.theme.TextMuted
	self.searchBox.TextSize = if self.isMobile then 11 else 12
	applyFont(self.searchBox, Fonts.Regular)
	self.searchBox.TextXAlignment = Enum.TextXAlignment.Left
	self.searchBox.ClearTextOnFocus = false
	self.searchBox.Parent = self.searchFrame

	self.searchBox.Focused:Connect(function()
		TweenService:Create(searchStroke, FAST_TWEEN, { Color = self.theme.Border }):Play()
		self:tintIcon(searchIcon, self.theme.Text)
	end)

	self.searchBox.FocusLost:Connect(function()
		TweenService:Create(searchStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
		self:tintIcon(searchIcon, self.theme.TextMuted)
	end)

	self.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:filterSidebarItems(self.searchBox.Text)
	end)
end

function GUI:createContentArea()
	local sidebarWidth = self.sidebarWidth or (if self.isMobile then 130 else 150)
	local titleHeight = self.titleHeight or (if self.isMobile then 36 else 38)

	self.contentArea = Instance.new("Frame")
	self.contentArea.Name = "ContentArea"
	self.contentArea.Size = UDim2.new(1, -sidebarWidth, 1, -titleHeight)
	self.contentArea.Position = UDim2.fromOffset(sidebarWidth, titleHeight)
	self.contentArea.BackgroundColor3 = self.theme.Background
	self.contentArea.BorderSizePixel = 0
	self.contentArea.Parent = self.mainFrame

	self.contentScrolling = Instance.new("ScrollingFrame")
	self.contentScrolling.Name = "ContentScrolling"
	self.contentScrolling.Size = UDim2.fromScale(1, 1)
	self.contentScrolling.Position = UDim2.fromOffset(0, 0)
	self.contentScrolling.BackgroundTransparency = 1
	self.contentScrolling.BorderSizePixel = 0
	self.contentScrolling.ScrollBarThickness = 2
	self.contentScrolling.ScrollBarImageColor3 = self.theme.Border
	self.contentScrolling.CanvasSize = UDim2.fromOffset(0, 0)
	self.contentScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.contentScrolling.Parent = self.contentArea

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, if self.isMobile then 6 else 7)
	contentLayout.Parent = self.contentScrolling

	local pad = if self.isMobile then 10 else 12
	createPadding(self.contentScrolling, pad, pad, pad, pad)
end

function GUI:_nextOrder(): number
	self._layoutOrder += 1
	return self._layoutOrder
end

function GUI:saveComponentState(sidebarName: string?, componentId: string, value: any)
	local key = sidebarName or self.currentSidebarName or "Default"
	if not self.componentStates[key] then
		self.componentStates[key] = {}
	end
	self.componentStates[key][componentId] = value
end

function GUI:getComponentState(sidebarName: string?, componentId: string, defaultValue: any): any
	local key = sidebarName or self.currentSidebarName or "Default"
	if self.componentStates[key] and self.componentStates[key][componentId] ~= nil then
		return self.componentStates[key][componentId]
	end
	return defaultValue
end

function GUI:saveComponentCallback(sidebarName: string?, componentId: string, callback: ((...any) -> ())?)
	local key = sidebarName or self.currentSidebarName or "Default"
	if not self.componentCallbacks[key] then
		self.componentCallbacks[key] = {}
	end
	self.componentCallbacks[key][componentId] = callback
end

function GUI:addSidebarItem(name: string, callback: (() -> ())?, iconName: string?)
	local itemHeight = if self.isMobile then 29 else 31
	local resolvedIcon = iconName or inferIconName(name)

	local item = Instance.new("Frame")
	item.Name = name
	item.Size = UDim2.new(1, 0, 0, itemHeight)
	item.BackgroundColor3 = self.theme.SurfaceActive
	item.BackgroundTransparency = 1
	item.BorderSizePixel = 0
	item.Parent = self.sidebarScrolling

	createCorner(item, 6)

	local iconObj = self:createIcon(resolvedIcon, 13, self.theme.TextMuted, item)
	iconObj.Position = UDim2.new(0, 10, 0.5, 0)
	iconObj.AnchorPoint = Vector2.new(0, 0.5)

	local itemButton = Instance.new("TextButton")
	itemButton.Name = "ItemButton"
	itemButton.Size = UDim2.fromScale(1, 1)
	itemButton.Position = UDim2.fromOffset(0, 0)
	itemButton.BackgroundTransparency = 1
	itemButton.Text = name
	itemButton.TextColor3 = self.theme.TextSecondary
	itemButton.TextSize = if self.isMobile then 12 else 13
	applyFont(itemButton, Fonts.Medium)
	itemButton.TextXAlignment = Enum.TextXAlignment.Left
	itemButton.TextTruncate = Enum.TextTruncate.AtEnd
	itemButton.Parent = item

	createPadding(itemButton, 0, 0, 30, 8)

	local highlight = Instance.new("Frame")
	highlight.Name = "Highlight"
	highlight.Size = UDim2.new(0, 2, 0, 12)
	highlight.Position = UDim2.new(0, 2, 0.5, -6)
	highlight.BackgroundColor3 = self.theme.Accent
	highlight.BorderSizePixel = 0
	highlight.Visible = false
	highlight.Parent = item
	createCorner(highlight, 2)

	itemButton.MouseButton1Click:Connect(function()
		self:selectSidebarItem(item, name, callback)
	end)

	itemButton.MouseEnter:Connect(function()
		if self.selectedItem ~= item then
			TweenService:Create(item, FAST_TWEEN, {
				BackgroundColor3 = self.theme.SurfaceHover,
				BackgroundTransparency = 0.25,
			}):Play()
			TweenService:Create(itemButton, FAST_TWEEN, { TextColor3 = self.theme.Text }):Play()
			self:tintIcon(iconObj, self.theme.TextSecondary)
		end
	end)

	itemButton.MouseLeave:Connect(function()
		if self.selectedItem ~= item then
			TweenService:Create(item, FAST_TWEEN, {
				BackgroundTransparency = 1,
			}):Play()
			TweenService:Create(itemButton, FAST_TWEEN, { TextColor3 = self.theme.TextSecondary }):Play()
			self:tintIcon(iconObj, self.theme.TextMuted)
		end
	end)

	self.sidebarItems[name] = item
	self.sidebarCallbacks[name] = callback
	self.sidebarIcons[name] = iconObj

	if not self.componentStates[name] then
		self.componentStates[name] = {}
	end

	if not self.selectedItem then
		self:selectSidebarItem(item, name, callback)
	end

	return item
end

function GUI:selectSidebarItem(item: Frame, name: string, callback: (() -> ())?)
	if self.selectedItem and self.selectedItem.Parent then
		local prevName = self.selectedItem.Name
		local prevHighlight = self.selectedItem:FindFirstChild("Highlight") :: Frame?
		local prevButton = self.selectedItem:FindFirstChild("ItemButton") :: TextButton?
		if prevHighlight then
			prevHighlight.Visible = false
		end
		if prevButton then
			applyFont(prevButton, Fonts.Medium)
			TweenService:Create(prevButton, FAST_TWEEN, { TextColor3 = self.theme.TextSecondary }):Play()
		end
		local prevIcon = self.sidebarIcons[prevName]
		if prevIcon then
			self:tintIcon(prevIcon, self.theme.TextMuted)
		end
		TweenService:Create(self.selectedItem, FAST_TWEEN, { BackgroundTransparency = 1 }):Play()
	end

	self.selectedItem = item
	self.currentSidebarName = name

	local highlight = item:FindFirstChild("Highlight") :: Frame?
	local itemButton = item:FindFirstChild("ItemButton") :: TextButton?
	if highlight then
		highlight.Visible = true
		highlight.Size = UDim2.new(0, 2, 0, 4)
		highlight.Position = UDim2.new(0, 2, 0.5, -2)
		TweenService:Create(highlight, SMOOTH_TWEEN, {
			Size = UDim2.new(0, 2, 0, 14),
			Position = UDim2.new(0, 2, 0.5, -7),
		}):Play()
	end
	if itemButton then
		applyFont(itemButton, Fonts.SemiBold)
		TweenService:Create(itemButton, FAST_TWEEN, { TextColor3 = self.theme.Text }):Play()
	end

	local curIcon = self.sidebarIcons[name]
	if curIcon then
		self:tintIcon(curIcon, self.theme.Accent)
	end

	TweenService:Create(item, FAST_TWEEN, {
		BackgroundColor3 = self.theme.SurfaceActive,
		BackgroundTransparency = 0,
	}):Play()

	self:clearContent()

	local resolvedCallback = callback or self.sidebarCallbacks[name]
	if resolvedCallback then
		resolvedCallback()
	end
end

function GUI:clearContent()
	for _, conn in self._contentConnections do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(self._contentConnections)
	self._layoutOrder = 0

	if self.contentScrolling then
		self.contentScrolling.ScrollingEnabled = true
	end

	for _, child in self.contentScrolling:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

function GUI:addSection(title: string)
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Name = `{title}Section`
	sectionFrame.Size = UDim2.new(1, 0, 0, 20)
	sectionFrame.BackgroundTransparency = 1
	sectionFrame.LayoutOrder = self:_nextOrder()
	sectionFrame.Parent = self.contentScrolling

	local sectionLabel = Instance.new("TextLabel")
	sectionLabel.Name = "SectionLabel"
	sectionLabel.Size = UDim2.new(1, -8, 1, 0)
	sectionLabel.Position = UDim2.fromOffset(2, 2)
	sectionLabel.BackgroundTransparency = 1
	sectionLabel.Text = title:upper()
	sectionLabel.TextColor3 = self.theme.TextMuted
	sectionLabel.TextSize = 10
	applyFont(sectionLabel, Fonts.Bold)
	sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
	sectionLabel.Parent = sectionFrame

	return sectionFrame
end

function GUI:addLabel(text: string)
	local labelFrame = Instance.new("Frame")
	labelFrame.Name = "LabelCard"
	labelFrame.Size = UDim2.new(1, 0, 0, if self.isMobile then 32 else 34)
	labelFrame.BackgroundColor3 = self.theme.Surface
	labelFrame.BorderSizePixel = 0
	labelFrame.LayoutOrder = self:_nextOrder()
	labelFrame.Parent = self.contentScrolling
	createCorner(labelFrame, 7)
	createStroke(labelFrame, self.theme.BorderSubtle, 1, 0)

	local icon = self:createIcon("info", 13, self.theme.TextSecondary, labelFrame)
	icon.Position = UDim2.new(0, 12, 0.5, 0)
	icon.AnchorPoint = Vector2.new(0, 0.5)

	local label = Instance.new("TextLabel")
	label.Name = "TextLabel"
	label.Size = UDim2.new(1, -38, 1, 0)
	label.Position = UDim2.fromOffset(30, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.theme.TextSecondary
	label.TextSize = if self.isMobile then 12 else 13
	applyFont(label, Fonts.Regular)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = labelFrame

	return labelFrame
end

function GUI:addToggle(name: string, defaultValue: boolean?, callback: ((boolean) -> ())?)
	local toggleHeight = if self.isMobile then 36 else 38
	local componentId = `{name}_toggle`
	local currentValue = self:getComponentState(self.currentSidebarName, componentId, defaultValue == true)

	self:saveComponentCallback(self.currentSidebarName, componentId, callback)

	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = `{name}Toggle`
	toggleFrame.Size = UDim2.new(1, 0, 0, toggleHeight)
	toggleFrame.BackgroundColor3 = self.theme.Surface
	toggleFrame.BorderSizePixel = 0
	toggleFrame.LayoutOrder = self:_nextOrder()
	toggleFrame.Parent = self.contentScrolling

	createCorner(toggleFrame, 7)
	local cardStroke = createStroke(toggleFrame, self.theme.BorderSubtle, 1, 0)

	local toggleLabel = Instance.new("TextLabel")
	toggleLabel.Name = "ToggleLabel"
	toggleLabel.Size = UDim2.new(1, -64, 1, 0)
	toggleLabel.Position = UDim2.fromOffset(12, 0)
	toggleLabel.BackgroundTransparency = 1
	toggleLabel.Text = name
	toggleLabel.TextColor3 = self.theme.Text
	toggleLabel.TextSize = if self.isMobile then 12 else 13
	applyFont(toggleLabel, Fonts.Medium)
	toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
	toggleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	toggleLabel.Parent = toggleFrame

	local trackW, trackH = 34, 18
	local knobSize = 12

	local toggleTrack = Instance.new("Frame")
	toggleTrack.Name = "ToggleTrack"
	toggleTrack.Size = UDim2.fromOffset(trackW, trackH)
	toggleTrack.Position = UDim2.new(1, -trackW - 12, 0.5, -trackH / 2)
	toggleTrack.BackgroundColor3 = if currentValue then self.theme.Accent else self.theme.Control
	toggleTrack.BorderSizePixel = 0
	toggleTrack.Parent = toggleFrame

	createCorner(toggleTrack, trackH / 2)
	local trackStroke = createStroke(
		toggleTrack,
		if currentValue then self.theme.Accent else self.theme.Border,
		1,
		0
	)

	local toggleKnob = Instance.new("Frame")
	toggleKnob.Name = "ToggleKnob"
	toggleKnob.Size = UDim2.fromOffset(knobSize, knobSize)
	toggleKnob.Position = if currentValue
		then UDim2.new(1, -knobSize - 3, 0.5, -knobSize / 2)
		else UDim2.new(0, 3, 0.5, -knobSize / 2)
	toggleKnob.BackgroundColor3 = if currentValue then Color3.fromRGB(255, 255, 255) else self.theme.TextSecondary
	toggleKnob.BorderSizePixel = 0
	toggleKnob.ZIndex = 2
	toggleKnob.Parent = toggleTrack
	createCorner(toggleKnob, knobSize / 2)

	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Size = UDim2.fromScale(1, 1)
	toggleButton.BackgroundTransparency = 1
	toggleButton.Text = ""
	toggleButton.ZIndex = 3
	toggleButton.Parent = toggleFrame

	local isToggled = currentValue

	local function animateToggle()
		local trackColor = if isToggled then self.theme.Accent else self.theme.Control
		local strokeColor = if isToggled then self.theme.Accent else self.theme.Border
		local knobColor = if isToggled then Color3.fromRGB(255, 255, 255) else self.theme.TextSecondary
		local knobPosition = if isToggled
			then UDim2.new(1, -knobSize - 3, 0.5, -knobSize / 2)
			else UDim2.new(0, 3, 0.5, -knobSize / 2)

		TweenService:Create(toggleTrack, SMOOTH_TWEEN, { BackgroundColor3 = trackColor }):Play()
		TweenService:Create(trackStroke, SMOOTH_TWEEN, { Color = strokeColor }):Play()
		TweenService:Create(toggleKnob, SMOOTH_TWEEN, {
			Position = knobPosition,
			BackgroundColor3 = knobColor,
		}):Play()
	end

	toggleButton.MouseEnter:Connect(function()
		TweenService:Create(toggleFrame, FAST_TWEEN, { BackgroundColor3 = self.theme.SurfaceHover }):Play()
		TweenService:Create(cardStroke, FAST_TWEEN, { Color = self.theme.Border }):Play()
	end)

	toggleButton.MouseLeave:Connect(function()
		TweenService:Create(toggleFrame, FAST_TWEEN, { BackgroundColor3 = self.theme.Surface }):Play()
		TweenService:Create(cardStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
	end)

	toggleButton.MouseButton1Click:Connect(function()
		isToggled = not isToggled
		animateToggle()
		self:saveComponentState(self.currentSidebarName, componentId, isToggled)
		if callback then
			callback(isToggled)
		end
	end)

	return toggleFrame
end

function GUI:addDropdown(
	name: string,
	options: { string },
	defaultOption: any,
	callback: ((any, number?) -> ())?,
	multiSelect: boolean?
)
	local isMulti = multiSelect == true
	local dropdownHeight = if self.isMobile then 36 else 38
	local componentId = `{name}_dropdown`

	local initialDefault: any = defaultOption
	if isMulti then
		if type(initialDefault) ~= "table" then
			initialDefault = if initialDefault ~= nil and initialDefault ~= "" then { tostring(initialDefault) } else {}
		end
	else
		initialDefault = defaultOption or options[1] or "Select"
	end

	local currentValue = self:getComponentState(self.currentSidebarName, componentId, initialDefault)
	self:saveComponentCallback(self.currentSidebarName, componentId, callback)

	local dropdownFrame = Instance.new("Frame")
	dropdownFrame.Name = `{name}Dropdown`
	dropdownFrame.Size = UDim2.new(1, 0, 0, dropdownHeight)
	dropdownFrame.BackgroundColor3 = self.theme.Surface
	dropdownFrame.BorderSizePixel = 0
	dropdownFrame.LayoutOrder = self:_nextOrder()
	dropdownFrame.Parent = self.contentScrolling

	createCorner(dropdownFrame, 7)
	local cardStroke = createStroke(dropdownFrame, self.theme.BorderSubtle, 1, 0)

	local dropdownLabel = Instance.new("TextLabel")
	dropdownLabel.Name = "DropdownLabel"
	dropdownLabel.Size = UDim2.new(0.54, -12, 1, 0)
	dropdownLabel.Position = UDim2.fromOffset(12, 0)
	dropdownLabel.BackgroundTransparency = 1
	dropdownLabel.Text = name
	dropdownLabel.TextColor3 = self.theme.Text
	dropdownLabel.TextSize = if self.isMobile then 12 else 13
	applyFont(dropdownLabel, Fonts.Medium)
	dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
	dropdownLabel.TextTruncate = Enum.TextTruncate.AtEnd
	dropdownLabel.Parent = dropdownFrame

	local buttonWidth = if self.isMobile then 114 else 136
	local buttonHeight = if self.isMobile then 24 else 26

	local dropdownButton = Instance.new("TextButton")
	dropdownButton.Name = "DropdownButton"
	dropdownButton.Size = UDim2.fromOffset(buttonWidth, buttonHeight)
	dropdownButton.Position = UDim2.new(1, -buttonWidth - 10, 0.5, -buttonHeight / 2)
	dropdownButton.BackgroundColor3 = self.theme.Control
	dropdownButton.BorderSizePixel = 0
	dropdownButton.AutoButtonColor = false
	dropdownButton.Text = ""
	dropdownButton.Parent = dropdownFrame

	createCorner(dropdownButton, 5)
	local btnStroke = createStroke(dropdownButton, self.theme.BorderSubtle, 1, 0)

	local displayText = ""
	if isMulti then
		local list = if type(currentValue) == "table" then currentValue else {}
		self.multiSelectDropdowns[name] = list
		self.dropdownSelections[name] = list
		displayText = if #list == 0 then "None" elseif #list == 1 then tostring(list[1]) else `{#list} selected`
	else
		self.dropdownSelections[name] = tostring(currentValue)
		displayText = tostring(currentValue)
	end

	local valueText = Instance.new("TextLabel")
	valueText.Name = "ValueText"
	valueText.Size = UDim2.new(1, -26, 1, 0)
	valueText.Position = UDim2.fromOffset(9, 0)
	valueText.BackgroundTransparency = 1
	valueText.Text = displayText
	valueText.TextColor3 = self.theme.TextSecondary
	valueText.TextSize = 12
	applyFont(valueText, Fonts.Regular)
	valueText.TextXAlignment = Enum.TextXAlignment.Left
	valueText.TextTruncate = Enum.TextTruncate.AtEnd
	valueText.Parent = dropdownButton

	local chevron = self:createIcon("chevron-down", 11, self.theme.TextMuted, dropdownButton)
	chevron.Name = "Arrow"
	chevron.Position = UDim2.new(1, -11, 0.5, 0)
	chevron.AnchorPoint = Vector2.new(0.5, 0.5)

	dropdownButton.MouseEnter:Connect(function()
		TweenService:Create(dropdownButton, FAST_TWEEN, { BackgroundColor3 = self.theme.ControlHover }):Play()
		TweenService:Create(btnStroke, FAST_TWEEN, { Color = self.theme.Border }):Play()
		TweenService:Create(cardStroke, FAST_TWEEN, { Color = self.theme.Border }):Play()
		self:tintIcon(chevron, self.theme.Text)
	end)

	dropdownButton.MouseLeave:Connect(function()
		TweenService:Create(dropdownButton, FAST_TWEEN, { BackgroundColor3 = self.theme.Control }):Play()
		TweenService:Create(btnStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
		TweenService:Create(cardStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
		self:tintIcon(chevron, self.theme.TextMuted)
	end)

	dropdownButton.MouseButton1Click:Connect(function()
		local latestVal = self:getComponentState(self.currentSidebarName, componentId, currentValue)
		TweenService:Create(chevron, FAST_TWEEN, { Rotation = 180 }):Play()
		local dialog = self:createDropdownDialog(name, options, latestVal, callback, dropdownButton, isMulti)
		dialog.AncestryChanged:Connect(function(_, parent)
			if not parent and chevron and chevron.Parent then
				TweenService:Create(chevron, FAST_TWEEN, { Rotation = 0 }):Play()
			end
		end)
	end)

	return dropdownFrame
end

local function updateDropdownButtonLabel(button: TextButton, text: string)
	local valueLabel = button:FindFirstChild("ValueText") :: TextLabel?
	if valueLabel then
		valueLabel.Text = text
	else
		button.Text = text
	end
end

function GUI:createDropdownDialog(
	title: string,
	options: { string },
	defaultOption: any,
	callback: ((any, number?) -> ())?,
	button: TextButton,
	multiSelect: boolean?
)
	local isMulti = multiSelect == true
	local dialogW = if self.isMobile then 260 else 290
	local dialogH = if self.isMobile then 225 else 250

	local existingOverlay = self.screenGui:FindFirstChild("DropdownOverlay")
	if existingOverlay then
		existingOverlay:Destroy()
	end

	local overlay = Instance.new("TextButton")
	overlay.Name = "DropdownOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Position = UDim2.fromOffset(0, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.ZIndex = 30
	overlay.Parent = self.screenGui

	TweenService:Create(overlay, FAST_TWEEN, { BackgroundTransparency = 0.5 }):Play()

	local dialog = Instance.new("TextButton")
	dialog.Name = "DropdownDialog"
	dialog.Size = UDim2.fromOffset(dialogW, dialogH)
	dialog.Position = UDim2.fromScale(0.5, 0.5)
	dialog.AnchorPoint = Vector2.new(0.5, 0.5)
	dialog.BackgroundColor3 = self.theme.Sidebar
	dialog.BorderSizePixel = 0
	dialog.Text = ""
	dialog.AutoButtonColor = false
	dialog.ZIndex = 31
	dialog.Parent = overlay

	local dialogScale = Instance.new("UIScale")
	dialogScale.Scale = 0.94
	dialogScale.Parent = dialog

	createCorner(dialog, 9)
	createStroke(dialog, self.theme.Border, 1, 0)

	local dialogTitle = Instance.new("TextLabel")
	dialogTitle.Name = "DialogTitle"
	dialogTitle.Size = UDim2.new(1, -48, 0, 26)
	dialogTitle.Position = UDim2.fromOffset(14, 9)
	dialogTitle.BackgroundTransparency = 1
	dialogTitle.Text = if isMulti then `{title} (Multi)` else title
	dialogTitle.TextColor3 = self.theme.Text
	dialogTitle.TextSize = 13
	applyFont(dialogTitle, Fonts.SemiBold)
	dialogTitle.TextXAlignment = Enum.TextXAlignment.Left
	dialogTitle.TextTruncate = Enum.TextTruncate.AtEnd
	dialogTitle.ZIndex = 32
	dialogTitle.Parent = dialog

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.fromOffset(22, 22)
	closeButton.Position = UDim2.new(1, -32, 0, 11)
	closeButton.BackgroundColor3 = self.theme.SurfaceHover
	closeButton.BackgroundTransparency = 1
	closeButton.BorderSizePixel = 0
	closeButton.Text = ""
	closeButton.AutoButtonColor = false
	closeButton.ZIndex = 32
	closeButton.Parent = dialog
	createCorner(closeButton, 5)

	local closeIcon = self:createIcon("close", 10, self.theme.TextSecondary, closeButton)
	closeIcon.Position = UDim2.fromScale(0.5, 0.5)
	closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)

	closeButton.MouseEnter:Connect(function()
		TweenService:Create(closeButton, FAST_TWEEN, { BackgroundTransparency = 0 }):Play()
		self:tintIcon(closeIcon, self.theme.Text)
	end)
	closeButton.MouseLeave:Connect(function()
		TweenService:Create(closeButton, FAST_TWEEN, { BackgroundTransparency = 1 }):Play()
		self:tintIcon(closeIcon, self.theme.TextSecondary)
	end)

	local searchFrame = Instance.new("Frame")
	searchFrame.Name = "SearchFrame"
	searchFrame.Size = UDim2.new(1, -24, 0, 26)
	searchFrame.Position = UDim2.fromOffset(12, 40)
	searchFrame.BackgroundColor3 = self.theme.Surface
	searchFrame.BorderSizePixel = 0
	searchFrame.ZIndex = 32
	searchFrame.Parent = dialog
	createCorner(searchFrame, 6)
	local searchStroke = createStroke(searchFrame, self.theme.BorderSubtle, 1, 0)

	local searchIcon = self:createIcon("search", 11, self.theme.TextMuted, searchFrame)
	searchIcon.Position = UDim2.new(0, 9, 0.5, 0)
	searchIcon.AnchorPoint = Vector2.new(0, 0.5)

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Size = UDim2.new(1, -30, 1, 0)
	searchBox.Position = UDim2.fromOffset(25, 0)
	searchBox.BackgroundTransparency = 1
	searchBox.Text = ""
	searchBox.PlaceholderText = "Filter options..."
	searchBox.TextColor3 = self.theme.Text
	searchBox.PlaceholderColor3 = self.theme.TextMuted
	searchBox.TextSize = 12
	applyFont(searchBox, Fonts.Regular)
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus = false
	searchBox.ZIndex = 33
	searchBox.Parent = searchFrame

	searchBox.Focused:Connect(function()
		TweenService:Create(searchStroke, FAST_TWEEN, { Color = self.theme.Border }):Play()
	end)
	searchBox.FocusLost:Connect(function()
		TweenService:Create(searchStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
	end)

	local bottomReserved = if isMulti then 112 else 76
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "OptionsScroll"
	scrollFrame.Size = UDim2.new(1, -24, 1, -bottomReserved)
	scrollFrame.Position = UDim2.fromOffset(12, 72)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 2
	scrollFrame.ScrollBarImageColor3 = self.theme.Border
	scrollFrame.CanvasSize = UDim2.fromOffset(0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.ZIndex = 32
	scrollFrame.Parent = dialog

	local optionLayout = Instance.new("UIListLayout")
	optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	optionLayout.Padding = UDim.new(0, 4)
	optionLayout.Parent = scrollFrame

	createPadding(scrollFrame, 2, 4, 1, 3)

	local optionFrames = {}
	local currentSelections = if isMulti
		then (if type(defaultOption) == "table" then defaultOption else (self.multiSelectDropdowns[title] or {}))
		else { tostring(defaultOption or self.dropdownSelections[title] or "") }

	for i, option in options do
		local isSelected = table.find(currentSelections, option) ~= nil

		local optionFrame = Instance.new("Frame")
		optionFrame.Name = `Option{i}`
		optionFrame.Size = UDim2.new(1, 0, 0, 28)
		optionFrame.BackgroundColor3 = if isSelected then self.theme.SurfaceActive else self.theme.Surface
		optionFrame.BorderSizePixel = 0
		optionFrame.LayoutOrder = i
		optionFrame.ZIndex = 32
		optionFrame.Parent = scrollFrame
		createCorner(optionFrame, 6)

		local optStroke = createStroke(
			optionFrame,
			if isSelected then self.theme.Border else self.theme.BorderSubtle,
			1,
			0
		)

		local checkIcon = self:createIcon("check", 11, self.theme.Accent, optionFrame)
		checkIcon.Name = "CheckIcon"
		checkIcon.Position = UDim2.new(1, -13, 0.5, 0)
		checkIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		checkIcon.Visible = isSelected

		local optionButton = Instance.new("TextButton")
		optionButton.Name = "OptionButton"
		optionButton.Size = UDim2.fromScale(1, 1)
		optionButton.BackgroundTransparency = 1
		optionButton.Text = option
		optionButton.TextColor3 = if isSelected then self.theme.Text else self.theme.TextSecondary
		optionButton.TextSize = 12
		applyFont(optionButton, if isSelected then Fonts.Medium else Fonts.Regular)
		optionButton.TextXAlignment = Enum.TextXAlignment.Left
		optionButton.TextTruncate = Enum.TextTruncate.AtEnd
		optionButton.ZIndex = 33
		optionButton.Parent = optionFrame
		createPadding(optionButton, 0, 0, 10, 26)

		optionFrames[option] = {
			frame = optionFrame,
			stroke = optStroke,
			check = checkIcon,
			button = optionButton,
			selected = isSelected,
		}

		optionButton.MouseEnter:Connect(function()
			if not optionFrames[option].selected then
				TweenService:Create(optionFrame, FAST_TWEEN, { BackgroundColor3 = self.theme.SurfaceHover }):Play()
				TweenService:Create(optionButton, FAST_TWEEN, { TextColor3 = self.theme.Text }):Play()
			end
		end)

		optionButton.MouseLeave:Connect(function()
			if not optionFrames[option].selected then
				TweenService:Create(optionFrame, FAST_TWEEN, { BackgroundColor3 = self.theme.Surface }):Play()
				TweenService:Create(optionButton, FAST_TWEEN, { TextColor3 = self.theme.TextSecondary }):Play()
			end
		end)

		optionButton.MouseButton1Click:Connect(function()
			if isMulti then
				local entry = optionFrames[option]
				entry.selected = not entry.selected
				entry.check.Visible = entry.selected
				applyFont(entry.button, if entry.selected then Fonts.Medium else Fonts.Regular)
				TweenService:Create(entry.frame, FAST_TWEEN, {
					BackgroundColor3 = if entry.selected then self.theme.SurfaceActive else self.theme.Surface,
				}):Play()
				TweenService:Create(entry.stroke, FAST_TWEEN, {
					Color = if entry.selected then self.theme.Border else self.theme.BorderSubtle,
				}):Play()
				TweenService:Create(entry.button, FAST_TWEEN, {
					TextColor3 = if entry.selected then self.theme.Text else self.theme.TextSecondary,
				}):Play()
			else
				for _, data in optionFrames do
					data.selected = false
					data.check.Visible = false
					applyFont(data.button, Fonts.Regular)
					TweenService:Create(data.frame, FAST_TWEEN, { BackgroundColor3 = self.theme.Surface }):Play()
					TweenService:Create(data.stroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
				end

				local entry = optionFrames[option]
				entry.selected = true
				entry.check.Visible = true
				applyFont(entry.button, Fonts.Medium)
				TweenService:Create(entry.frame, FAST_TWEEN, { BackgroundColor3 = self.theme.SurfaceActive }):Play()
				TweenService:Create(entry.stroke, FAST_TWEEN, { Color = self.theme.Border }):Play()

				local componentId = `{title}_dropdown`
				self:saveComponentState(self.currentSidebarName, componentId, option)
				self.dropdownSelections[title] = option
				updateDropdownButtonLabel(button, option)

				task.wait(0.06)
				if overlay and overlay.Parent then
					overlay:Destroy()
				end

				if callback then
					callback(option, i)
				end
			end
		end)
	end

	if isMulti then
		local confirmButton = Instance.new("TextButton")
		confirmButton.Name = "ConfirmButton"
		confirmButton.Size = UDim2.new(1, -24, 0, 28)
		confirmButton.Position = UDim2.new(0, 12, 1, -36)
		confirmButton.BackgroundColor3 = self.theme.Control
		confirmButton.BorderSizePixel = 0
		confirmButton.Text = "Done"
		confirmButton.TextColor3 = self.theme.Text
		confirmButton.TextSize = 12
		applyFont(confirmButton, Fonts.SemiBold)
		confirmButton.AutoButtonColor = false
		confirmButton.ZIndex = 33
		confirmButton.Parent = dialog
		createCorner(confirmButton, 6)
		createStroke(confirmButton, self.theme.Border, 1, 0)

		confirmButton.MouseEnter:Connect(function()
			TweenService:Create(confirmButton, FAST_TWEEN, { BackgroundColor3 = self.theme.ControlHover }):Play()
		end)
		confirmButton.MouseLeave:Connect(function()
			TweenService:Create(confirmButton, FAST_TWEEN, { BackgroundColor3 = self.theme.Control }):Play()
		end)

		confirmButton.MouseButton1Click:Connect(function()
			local selectedOptions = {}
			for _, opt in options do
				if optionFrames[opt] and optionFrames[opt].selected then
					table.insert(selectedOptions, opt)
				end
			end

			local componentId = `{title}_dropdown`
			self:saveComponentState(self.currentSidebarName, componentId, selectedOptions)
			self.multiSelectDropdowns[title] = selectedOptions

			local summary = if #selectedOptions == 0
				then "None"
				elseif #selectedOptions == 1 then selectedOptions[1]
				else `{#selectedOptions} selected`
			updateDropdownButtonLabel(button, summary)

			overlay:Destroy()
			if callback then
				callback(selectedOptions)
			end
		end)
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = searchBox.Text:lower()
		for option, data in optionFrames do
			data.frame.Visible = (query == "" or option:lower():find(query, 1, true) ~= nil)
		end
	end)

	closeButton.MouseButton1Click:Connect(function()
		overlay:Destroy()
	end)

	overlay.MouseButton1Click:Connect(function()
		overlay:Destroy()
	end)

	TweenService:Create(dialogScale, SMOOTH_TWEEN, { Scale = 1 }):Play()
	table.insert(self.dialogs, overlay)

	return dialog
end

function GUI:addButton(name: string, callback: (() -> ())?, iconName: string?)
	local buttonHeight = if self.isMobile then 34 else 36

	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = `{name}ButtonFrame`
	buttonFrame.Size = UDim2.new(1, 0, 0, buttonHeight)
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.LayoutOrder = self:_nextOrder()
	buttonFrame.Parent = self.contentScrolling

	-- Minimalist low-profile surface button (instead of a loud full-width purple block)
	local button = Instance.new("TextButton")
	button.Name = `{name}Button`
	button.Size = UDim2.fromScale(1, 1)
	button.Position = UDim2.fromScale(0.5, 0.5)
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.BackgroundColor3 = self.theme.Control
	button.BorderSizePixel = 0
	button.Text = name
	button.TextColor3 = self.theme.Text
	button.TextSize = if self.isMobile then 12 else 13
	applyFont(button, Fonts.Medium)
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	button.Parent = buttonFrame

	createCorner(button, 7)
	local btnStroke = createStroke(button, self.theme.BorderSubtle, 1, 0)

	if iconName then
		local icon = self:createIcon(iconName, 13, self.theme.TextSecondary, button)
		icon.Position = UDim2.new(0, 12, 0.5, 0)
		icon.AnchorPoint = Vector2.new(0, 0.5)
	end

	local chevronRight = self:createIcon("chevron-right", 11, self.theme.TextMuted, button)
	chevronRight.Position = UDim2.new(1, -13, 0.5, 0)
	chevronRight.AnchorPoint = Vector2.new(0.5, 0.5)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, FAST_TWEEN, { BackgroundColor3 = self.theme.ControlHover }):Play()
		TweenService:Create(btnStroke, FAST_TWEEN, { Color = self.theme.Border }):Play()
		TweenService:Create(chevronRight, FAST_TWEEN, { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
		self:tintIcon(chevronRight, self.theme.Text)
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, FAST_TWEEN, {
			BackgroundColor3 = self.theme.Control,
			Size = UDim2.fromScale(1, 1),
		}):Play()
		TweenService:Create(btnStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
		TweenService:Create(chevronRight, FAST_TWEEN, { Position = UDim2.new(1, -13, 0.5, 0) }):Play()
		self:tintIcon(chevronRight, self.theme.TextMuted)
	end)

	button.MouseButton1Click:Connect(function()
		for _, dialog in self.dialogs do
			if dialog and dialog.Parent then
				dialog:Destroy()
			end
		end
		table.clear(self.dialogs)

		TweenService:Create(btnStroke, INSTANT_TWEEN, { Color = self.theme.Accent }):Play()
		local pressTween = TweenService:Create(button, INSTANT_TWEEN, {
			BackgroundColor3 = self.theme.SurfaceActive,
		})
		pressTween:Play()
		task.delay(0.12, function()
			if button and button.Parent then
				TweenService:Create(button, FAST_TWEEN, { BackgroundColor3 = self.theme.ControlHover }):Play()
				TweenService:Create(btnStroke, FAST_TWEEN, { Color = self.theme.Border }):Play()
			end
		end)

		if callback then
			callback()
		end
	end)

	return buttonFrame
end

function GUI:addSlider(
	name: string,
	minValue: number,
	maxValue: number,
	defaultValue: number?,
	callback: ((number) -> ())?,
	step: number?,
	suffix: string?
)
	local sliderHeight = if self.isMobile then 46 else 48
	local componentId = `{name}_slider`

	local range = math.max(0.0001, maxValue - minValue)
	local resolvedStep = step or (if range <= 2 or (defaultValue and defaultValue % 1 ~= 0) then 0.1 else 1)
	local unitSuffix = suffix or ""

	local function snapValue(raw: number): number
		local clamped = math.clamp(raw, minValue, maxValue)
		local snapped = minValue + math.floor(((clamped - minValue) / resolvedStep) + 0.5) * resolvedStep
		return tonumber(string.format("%.4f", math.clamp(snapped, minValue, maxValue))) or minValue
	end

	local function formatValue(val: number): string
		if resolvedStep >= 1 and val % 1 == 0 then
			return `{math.floor(val + 0.5)}{unitSuffix}`
		end
		local decimals = math.max(1, math.ceil(-math.log10(resolvedStep)))
		return `{string.format(`%.{decimals}f`, val)}{unitSuffix}`
	end

	local initialVal = snapValue(defaultValue or minValue)
	local currentValue = snapValue(self:getComponentState(self.currentSidebarName, componentId, initialVal))

	self:saveComponentCallback(self.currentSidebarName, componentId, callback)

	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = `{name}Slider`
	sliderFrame.Size = UDim2.new(1, 0, 0, sliderHeight)
	sliderFrame.BackgroundColor3 = self.theme.Surface
	sliderFrame.BorderSizePixel = 0
	sliderFrame.LayoutOrder = self:_nextOrder()
	sliderFrame.Parent = self.contentScrolling

	createCorner(sliderFrame, 7)
	local cardStroke = createStroke(sliderFrame, self.theme.BorderSubtle, 1, 0)

	-- Top Row: Label on Left, Compact Stepper (- [Value] +) on Right
	local sliderLabel = Instance.new("TextLabel")
	sliderLabel.Name = "SliderLabel"
	sliderLabel.Size = UDim2.new(1, -120, 0, 18)
	sliderLabel.Position = UDim2.fromOffset(12, 6)
	sliderLabel.BackgroundTransparency = 1
	sliderLabel.Text = name
	sliderLabel.TextColor3 = self.theme.Text
	sliderLabel.TextSize = if self.isMobile then 12 else 13
	applyFont(sliderLabel, Fonts.Medium)
	sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
	sliderLabel.TextTruncate = Enum.TextTruncate.AtEnd
	sliderLabel.Parent = sliderFrame

	local controlsGroup = Instance.new("Frame")
	controlsGroup.Name = "ControlsGroup"
	controlsGroup.Size = UDim2.fromOffset(92, 18)
	controlsGroup.Position = UDim2.new(1, -104, 0, 6)
	controlsGroup.BackgroundTransparency = 1
	controlsGroup.Parent = sliderFrame

	local minusBtn = Instance.new("TextButton")
	minusBtn.Name = "MinusButton"
	minusBtn.Size = UDim2.fromOffset(18, 18)
	minusBtn.Position = UDim2.fromOffset(0, 0)
	minusBtn.BackgroundColor3 = self.theme.Control
	minusBtn.BorderSizePixel = 0
	minusBtn.Text = ""
	minusBtn.AutoButtonColor = false
	minusBtn.Parent = controlsGroup
	createCorner(minusBtn, 4)

	local minusIcon = self:createIcon("minus", 9, self.theme.TextMuted, minusBtn)
	minusIcon.Position = UDim2.fromScale(0.5, 0.5)
	minusIcon.AnchorPoint = Vector2.new(0.5, 0.5)

	local valueBadge = Instance.new("Frame")
	valueBadge.Name = "ValueBadge"
	valueBadge.Size = UDim2.fromOffset(48, 18)
	valueBadge.Position = UDim2.fromOffset(22, 0)
	valueBadge.BackgroundColor3 = self.theme.Control
	valueBadge.BorderSizePixel = 0
	valueBadge.Parent = controlsGroup
	createCorner(valueBadge, 4)
	local badgeStroke = createStroke(valueBadge, self.theme.BorderSubtle, 1, 0)

	local valueLabel = Instance.new("TextBox")
	valueLabel.Name = "ValueLabel"
	valueLabel.Size = UDim2.new(1, -4, 1, 0)
	valueLabel.Position = UDim2.fromOffset(2, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = formatValue(currentValue)
	valueLabel.TextColor3 = self.theme.Text
	valueLabel.PlaceholderColor3 = self.theme.TextMuted
	valueLabel.TextSize = 11
	applyFont(valueLabel, Fonts.SemiBold)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Center
	valueLabel.ClearTextOnFocus = false
	valueLabel.Parent = valueBadge

	local plusBtn = Instance.new("TextButton")
	plusBtn.Name = "PlusButton"
	plusBtn.Size = UDim2.fromOffset(18, 18)
	plusBtn.Position = UDim2.fromOffset(74, 0)
	plusBtn.BackgroundColor3 = self.theme.Control
	plusBtn.BorderSizePixel = 0
	plusBtn.Text = ""
	plusBtn.AutoButtonColor = false
	plusBtn.Parent = controlsGroup
	createCorner(plusBtn, 4)

	local plusIcon = self:createIcon("plus", 9, self.theme.TextMuted, plusBtn)
	plusIcon.Position = UDim2.fromScale(0.5, 0.5)
	plusIcon.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Bottom Row: Sleek 4px Minimalist Track & Flush Solid White Thumb
	local trackHeight = 4
	local knobSize = 12

	local sliderTrack = Instance.new("Frame")
	sliderTrack.Name = "SliderTrack"
	sliderTrack.Size = UDim2.new(1, -24, 0, trackHeight)
	sliderTrack.Position = UDim2.new(0, 12, 1, -13)
	sliderTrack.BackgroundColor3 = self.theme.Control
	sliderTrack.BorderSizePixel = 0
	sliderTrack.Parent = sliderFrame
	createCorner(sliderTrack, trackHeight / 2)

	local initialAlpha = math.clamp((currentValue - minValue) / range, 0, 1)

	-- Offset keeps the 12px thumb flush inside the left/right edges of the track at 0% and 100%
	local function getTrackPos(alpha: number): UDim2
		return UDim2.new(alpha, (0.5 - alpha) * knobSize, 0.5, 0)
	end

	local function getFillSize(alpha: number): UDim2
		return UDim2.new(alpha, (0.5 - alpha) * knobSize, 1, 0)
	end

	local sliderFill = Instance.new("Frame")
	sliderFill.Name = "SliderFill"
	sliderFill.Size = getFillSize(initialAlpha)
	sliderFill.BackgroundColor3 = self.theme.Accent
	sliderFill.BorderSizePixel = 0
	sliderFill.ZIndex = 2
	sliderFill.Parent = sliderTrack
	createCorner(sliderFill, trackHeight / 2)

	local sliderKnob = Instance.new("Frame")
	sliderKnob.Name = "SliderKnob"
	sliderKnob.Size = UDim2.fromOffset(knobSize, knobSize)
	sliderKnob.Position = getTrackPos(initialAlpha)
	sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
	sliderKnob.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
	sliderKnob.BorderSizePixel = 0
	sliderKnob.ZIndex = 4
	sliderKnob.Parent = sliderTrack
	createCorner(sliderKnob, knobSize)
	createStroke(sliderKnob, self.theme.Background, 1.5, 0)

	-- Subtle halo ring on drag/hover
	local knobHalo = Instance.new("Frame")
	knobHalo.Name = "KnobHalo"
	knobHalo.Size = UDim2.fromOffset(0, 0)
	knobHalo.Position = UDim2.fromScale(0.5, 0.5)
	knobHalo.AnchorPoint = Vector2.new(0.5, 0.5)
	knobHalo.BackgroundColor3 = self.theme.Accent
	knobHalo.BackgroundTransparency = 1
	knobHalo.BorderSizePixel = 0
	knobHalo.ZIndex = 3
	knobHalo.Parent = sliderKnob
	createCorner(knobHalo, 24)

	local hitArea = Instance.new("TextButton")
	hitArea.Name = "HitArea"
	hitArea.Size = UDim2.new(1, 12, 0, 22)
	hitArea.Position = UDim2.fromScale(0.5, 0.5)
	hitArea.AnchorPoint = Vector2.new(0.5, 0.5)
	hitArea.BackgroundTransparency = 1
	hitArea.Text = ""
	hitArea.AutoButtonColor = false
	hitArea.ZIndex = 6
	hitArea.Parent = sliderTrack

	local dragging = false
	local hoveringTrack = false

	local function applyValue(newVal: number, fireCallback: boolean)
		local snapped = snapValue(newVal)
		currentValue = snapped
		local alpha = math.clamp((snapped - minValue) / range, 0, 1)

		if not valueLabel:IsFocused() then
			valueLabel.Text = formatValue(snapped)
		end

		local tInfo = if dragging then INSTANT_TWEEN else FAST_TWEEN
		TweenService:Create(sliderFill, tInfo, {
			Size = getFillSize(alpha),
		}):Play()
		TweenService:Create(sliderKnob, tInfo, {
			Position = getTrackPos(alpha),
		}):Play()

		self:saveComponentState(self.currentSidebarName, componentId, snapped)
		if fireCallback and callback then
			callback(snapped)
		end
	end

	local function updateFromInput(input: InputObject)
		local trackWidth = math.max(1, sliderTrack.AbsoluteSize.X - knobSize)
		local startX = sliderTrack.AbsolutePosition.X + (knobSize * 0.5)
		local relativePos = math.clamp((input.Position.X - startX) / trackWidth, 0, 1)
		local rawVal = minValue + (maxValue - minValue) * relativePos
		applyValue(rawVal, true)
	end

	local function setVisualActive(active: boolean)
		if active then
			TweenService:Create(cardStroke, FAST_TWEEN, { Color = self.theme.Border }):Play()
			TweenService:Create(badgeStroke, FAST_TWEEN, { Color = self.theme.Accent }):Play()
			TweenService:Create(sliderKnob, FAST_TWEEN, { Size = UDim2.fromOffset(knobSize + 2, knobSize + 2) }):Play()
			TweenService:Create(knobHalo, FAST_TWEEN, {
				Size = UDim2.fromOffset(22, 22),
				BackgroundTransparency = 0.8,
			}):Play()
		else
			TweenService:Create(cardStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
			TweenService:Create(badgeStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
			TweenService:Create(sliderKnob, FAST_TWEEN, { Size = UDim2.fromOffset(knobSize, knobSize) }):Play()
			TweenService:Create(knobHalo, FAST_TWEEN, {
				Size = if hoveringTrack then UDim2.fromOffset(18, 18) else UDim2.fromOffset(0, 0),
				BackgroundTransparency = if hoveringTrack then 0.88 else 1,
			}):Play()
		end
	end

	hitArea.MouseEnter:Connect(function()
		hoveringTrack = true
		if not dragging then
			TweenService:Create(knobHalo, FAST_TWEEN, {
				Size = UDim2.fromOffset(18, 18),
				BackgroundTransparency = 0.88,
			}):Play()
		end
	end)

	hitArea.MouseLeave:Connect(function()
		hoveringTrack = false
		if not dragging then
			TweenService:Create(knobHalo, FAST_TWEEN, {
				Size = UDim2.fromOffset(0, 0),
				BackgroundTransparency = 1,
			}):Play()
		end
	end)

	hitArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			if self.contentScrolling then
				self.contentScrolling.ScrollingEnabled = false
			end
			setVisualActive(true)
			updateFromInput(input)
		end
	end)

	table.insert(
		self._contentConnections,
		UserInputService.InputChanged:Connect(function(input)
			if
				dragging
				and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				updateFromInput(input)
			end
		end)
	)

	table.insert(
		self._contentConnections,
		UserInputService.InputEnded:Connect(function(input)
			if
				dragging
				and (
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				dragging = false
				if self.contentScrolling then
					self.contentScrolling.ScrollingEnabled = true
				end
				setVisualActive(false)
			end
		end)
	)

	local function bindStepBtn(btn: TextButton, icon: GuiObject, delta: number)
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, FAST_TWEEN, { BackgroundColor3 = self.theme.ControlHover }):Play()
			self:tintIcon(icon, self.theme.Text)
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, FAST_TWEEN, { BackgroundColor3 = self.theme.Control }):Play()
			self:tintIcon(icon, self.theme.TextMuted)
		end)
		btn.MouseButton1Click:Connect(function()
			applyValue(currentValue + delta, true)
		end)
	end

	bindStepBtn(minusBtn, minusIcon, -resolvedStep)
	bindStepBtn(plusBtn, plusIcon, resolvedStep)

	valueLabel.Focused:Connect(function()
		valueLabel.Text = tostring(currentValue)
		TweenService:Create(badgeStroke, FAST_TWEEN, { Color = self.theme.Accent }):Play()
	end)

	valueLabel.FocusLost:Connect(function()
		TweenService:Create(badgeStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
		local cleaned = valueLabel.Text:gsub("[^%d%.%-]", "")
		local parsed = tonumber(cleaned)
		if parsed then
			applyValue(parsed, true)
		else
			valueLabel.Text = formatValue(currentValue)
		end
	end)

	return sliderFrame
end

function GUI:addTextInput(name: string, placeholder: string?, callback: ((string) -> ())?)
	local inputHeight = if self.isMobile then 54 else 58
	local componentId = `{name}_textinput`
	local currentValue = self:getComponentState(self.currentSidebarName, componentId, "")

	self:saveComponentCallback(self.currentSidebarName, componentId, callback)

	local inputFrame = Instance.new("Frame")
	inputFrame.Name = `{name}Input`
	inputFrame.Size = UDim2.new(1, 0, 0, inputHeight)
	inputFrame.BackgroundColor3 = self.theme.Surface
	inputFrame.BorderSizePixel = 0
	inputFrame.LayoutOrder = self:_nextOrder()
	inputFrame.Parent = self.contentScrolling

	createCorner(inputFrame, 7)
	local cardStroke = createStroke(inputFrame, self.theme.BorderSubtle, 1, 0)

	local labelName = Instance.new("TextLabel")
	labelName.Name = "LabelName"
	labelName.Size = UDim2.new(1, -24, 0, 16)
	labelName.Position = UDim2.fromOffset(12, 6)
	labelName.BackgroundTransparency = 1
	labelName.Text = name
	labelName.TextColor3 = self.theme.TextSecondary
	labelName.TextSize = 11
	applyFont(labelName, Fonts.Medium)
	labelName.TextXAlignment = Enum.TextXAlignment.Left
	labelName.TextTruncate = Enum.TextTruncate.AtEnd
	labelName.Parent = inputFrame

	local boxH = if self.isMobile then 24 else 26
	local inputContainer = Instance.new("Frame")
	inputContainer.Name = "InputContainer"
	inputContainer.Size = UDim2.new(1, -24, 0, boxH)
	inputContainer.Position = UDim2.new(0, 12, 1, -boxH - 6)
	inputContainer.BackgroundColor3 = self.theme.Control
	inputContainer.BorderSizePixel = 0
	inputContainer.Parent = inputFrame

	createCorner(inputContainer, 5)
	local containerStroke = createStroke(inputContainer, self.theme.BorderSubtle, 1, 0)

	local textBox = Instance.new("TextBox")
	textBox.Name = "TextBox"
	textBox.Size = UDim2.new(1, -18, 1, 0)
	textBox.Position = UDim2.fromOffset(9, 0)
	textBox.BackgroundTransparency = 1
	textBox.Text = currentValue
	textBox.PlaceholderText = placeholder or `Enter {name:lower()}...`
	textBox.TextColor3 = self.theme.Text
	textBox.PlaceholderColor3 = self.theme.TextMuted
	textBox.TextSize = 12
	applyFont(textBox, Fonts.Regular)
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.ClearTextOnFocus = false
	textBox.Parent = inputContainer

	textBox.Focused:Connect(function()
		TweenService:Create(containerStroke, FAST_TWEEN, { Color = self.theme.Accent }):Play()
		TweenService:Create(labelName, FAST_TWEEN, { TextColor3 = self.theme.Text }):Play()
		TweenService:Create(cardStroke, FAST_TWEEN, { Color = self.theme.Border }):Play()
	end)

	textBox.FocusLost:Connect(function()
		TweenService:Create(containerStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
		TweenService:Create(labelName, FAST_TWEEN, { TextColor3 = self.theme.TextSecondary }):Play()
		TweenService:Create(cardStroke, FAST_TWEEN, { Color = self.theme.BorderSubtle }):Play()
		self:saveComponentState(self.currentSidebarName, componentId, textBox.Text)
		if callback then
			callback(textBox.Text)
		end
	end)

	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:saveComponentState(self.currentSidebarName, componentId, textBox.Text)
	end)

	return inputFrame
end

function GUI:createDialog(title: string, content: string, buttons: { { any } }?)
	local dialogW = if self.isMobile then 260 else 290
	local dialogH = if self.isMobile then 160 else 172

	local overlay = Instance.new("TextButton")
	overlay.Name = "DialogOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Position = UDim2.fromOffset(0, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.ZIndex = 40
	overlay.Parent = self.screenGui

	TweenService:Create(overlay, FAST_TWEEN, { BackgroundTransparency = 0.5 }):Play()

	local dialog = Instance.new("TextButton")
	dialog.Name = "Dialog"
	dialog.Size = UDim2.fromOffset(dialogW, dialogH)
	dialog.Position = UDim2.fromScale(0.5, 0.5)
	dialog.AnchorPoint = Vector2.new(0.5, 0.5)
	dialog.BackgroundColor3 = self.theme.Sidebar
	dialog.BorderSizePixel = 0
	dialog.Text = ""
	dialog.AutoButtonColor = false
	dialog.ZIndex = 41
	dialog.Parent = overlay

	local dialogScale = Instance.new("UIScale")
	dialogScale.Scale = 0.94
	dialogScale.Parent = dialog

	createCorner(dialog, 9)
	createStroke(dialog, self.theme.Border, 1, 0)

	local dialogTitle = Instance.new("TextLabel")
	dialogTitle.Name = "DialogTitle"
	dialogTitle.Size = UDim2.new(1, -28, 0, 20)
	dialogTitle.Position = UDim2.fromOffset(14, 12)
	dialogTitle.BackgroundTransparency = 1
	dialogTitle.Text = title
	dialogTitle.TextColor3 = self.theme.Text
	dialogTitle.TextSize = 13
	applyFont(dialogTitle, Fonts.SemiBold)
	dialogTitle.TextXAlignment = Enum.TextXAlignment.Left
	dialogTitle.ZIndex = 42
	dialogTitle.Parent = dialog

	local dialogContent = Instance.new("TextLabel")
	dialogContent.Name = "DialogContent"
	dialogContent.Size = UDim2.new(1, -28, 1, -82)
	dialogContent.Position = UDim2.fromOffset(14, 36)
	dialogContent.BackgroundTransparency = 1
	dialogContent.Text = content
	dialogContent.TextColor3 = self.theme.TextSecondary
	dialogContent.TextSize = 12
	applyFont(dialogContent, Fonts.Regular)
	dialogContent.TextXAlignment = Enum.TextXAlignment.Left
	dialogContent.TextYAlignment = Enum.TextYAlignment.Top
	dialogContent.TextWrapped = true
	dialogContent.ZIndex = 42
	dialogContent.Parent = dialog

	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "ButtonFrame"
	buttonFrame.Size = UDim2.new(1, -28, 0, 26)
	buttonFrame.Position = UDim2.new(0, 14, 1, -36)
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.ZIndex = 42
	buttonFrame.Parent = dialog

	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	buttonLayout.Padding = UDim.new(0, 8)
	buttonLayout.Parent = buttonFrame

	local resolvedButtons = buttons or { { "OK", function() end } }

	for i, buttonData in resolvedButtons do
		local buttonName = tostring(buttonData[1] or "OK")
		local buttonCallback = buttonData[2]
		local isPrimary = (i == 1)

		local dialogButton = Instance.new("TextButton")
		dialogButton.Name = `DialogButton{i}`
		dialogButton.Size = UDim2.fromOffset(68, 26)
		dialogButton.BackgroundColor3 = if isPrimary then self.theme.Accent else self.theme.Control
		dialogButton.BorderSizePixel = 0
		dialogButton.Text = buttonName
		dialogButton.TextColor3 = if isPrimary then Color3.fromRGB(255, 255, 255) else self.theme.Text
		dialogButton.TextSize = 12
		applyFont(dialogButton, Fonts.Medium)
		dialogButton.AutoButtonColor = false
		dialogButton.LayoutOrder = i
		dialogButton.ZIndex = 43
		dialogButton.Parent = buttonFrame
		createCorner(dialogButton, 6)

		if not isPrimary then
			createStroke(dialogButton, self.theme.BorderSubtle, 1, 0)
		end

		dialogButton.MouseEnter:Connect(function()
			local hoverColor = if isPrimary then self.theme.AccentHover else self.theme.ControlHover
			TweenService:Create(dialogButton, FAST_TWEEN, { BackgroundColor3 = hoverColor }):Play()
		end)

		dialogButton.MouseLeave:Connect(function()
			local normalColor = if isPrimary then self.theme.Accent else self.theme.Control
			TweenService:Create(dialogButton, FAST_TWEEN, { BackgroundColor3 = normalColor }):Play()
		end)

		dialogButton.MouseButton1Click:Connect(function()
			if buttonCallback then
				buttonCallback()
			end
			if overlay and overlay.Parent then
				overlay:Destroy()
			end
		end)
	end

	overlay.MouseButton1Click:Connect(function()
		overlay:Destroy()
	end)

	TweenService:Create(dialogScale, SMOOTH_TWEEN, { Scale = 1 }):Play()
	table.insert(self.dialogs, overlay)

	return overlay
end

function GUI:_createNotificationHost()
	self.notificationHost = Instance.new("Frame")
	self.notificationHost.Name = "Notifications"
	self.notificationHost.Size = UDim2.new(0, 250, 1, -24)
	self.notificationHost.Position = UDim2.new(1, -12, 0, 12)
	self.notificationHost.AnchorPoint = Vector2.new(1, 0)
	self.notificationHost.BackgroundTransparency = 1
	self.notificationHost.ZIndex = 60
	self.notificationHost.Parent = self.screenGui

	local layout = Instance.new("UIListLayout")
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.Parent = self.notificationHost
end

function GUI:notify(title: string, message: string, duration: number?)
	if not self.notificationHost then
		return
	end
	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.Size = UDim2.fromOffset(240, 52)
	toast.BackgroundColor3 = self.theme.Sidebar
	toast.BorderSizePixel = 0
	toast.ZIndex = 61
	toast.Parent = self.notificationHost
	createCorner(toast, 8)
	createStroke(toast, self.theme.Border, 1, 0)

	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(0, 2, 1, -16)
	accentBar.Position = UDim2.fromOffset(8, 8)
	accentBar.BackgroundColor3 = self.theme.Accent
	accentBar.BorderSizePixel = 0
	accentBar.ZIndex = 62
	accentBar.Parent = toast
	createCorner(accentBar, 2)

	local tLabel = Instance.new("TextLabel")
	tLabel.Size = UDim2.new(1, -26, 0, 16)
	tLabel.Position = UDim2.fromOffset(16, 8)
	tLabel.BackgroundTransparency = 1
	tLabel.Text = title
	tLabel.TextColor3 = self.theme.Text
	tLabel.TextSize = 12
	applyFont(tLabel, Fonts.SemiBold)
	tLabel.TextXAlignment = Enum.TextXAlignment.Left
	tLabel.TextTruncate = Enum.TextTruncate.AtEnd
	tLabel.ZIndex = 62
	tLabel.Parent = toast

	local mLabel = Instance.new("TextLabel")
	mLabel.Size = UDim2.new(1, -26, 0, 20)
	mLabel.Position = UDim2.fromOffset(16, 24)
	mLabel.BackgroundTransparency = 1
	mLabel.Text = message
	mLabel.TextColor3 = self.theme.TextSecondary
	mLabel.TextSize = 11
	applyFont(mLabel, Fonts.Regular)
	mLabel.TextXAlignment = Enum.TextXAlignment.Left
	mLabel.TextTruncate = Enum.TextTruncate.AtEnd
	mLabel.ZIndex = 62
	mLabel.Parent = toast

	local toastScale = Instance.new("UIScale")
	toastScale.Scale = 0.92
	toastScale.Parent = toast
	TweenService:Create(toastScale, SMOOTH_TWEEN, { Scale = 1 }):Play()

	task.delay(duration or 3, function()
		if toast and toast.Parent then
			local out = TweenService:Create(toastScale, FAST_TWEEN, { Scale = 0.88 })
			TweenService:Create(toast, FAST_TWEEN, { BackgroundTransparency = 1 }):Play()
			out:Play()
			out.Completed:Connect(function()
				if toast and toast.Parent then
					toast:Destroy()
				end
			end)
		end
	end)
end

function GUI:filterSidebarItems(searchText: string)
	local query = searchText:lower()
	for name, item in self.sidebarItems do
		item.Visible = (query == "" or name:lower():find(query, 1, true) ~= nil)
	end
end

function GUI:makeDraggable()
	local dragging = false
	local dragStart: Vector3? = nil
	local startPos: UDim2? = nil

	self.titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.mainFrame.Position
		end
	end)

	table.insert(
		self._connections,
		UserInputService.InputChanged:Connect(function(input)
			if
				dragging
				and dragStart
				and startPos
				and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				local delta = input.Position - dragStart
				local vp = self.screenSize
				local scale = if self.uiScale then self.uiScale.Scale else 1
				local halfW = (self.baseSize.X * scale) * 0.5
				local halfH = (self.baseSize.Y * scale) * 0.5

				local rawX = (vp.X * startPos.X.Scale) + startPos.X.Offset + delta.X
				local rawY = (vp.Y * startPos.Y.Scale) + startPos.Y.Offset + delta.Y

				local clampedX = math.clamp(rawX, halfW + 6, math.max(halfW + 6, vp.X - halfW - 6))
				local clampedY = math.clamp(rawY, halfH + 6, math.max(halfH + 6, vp.Y - halfH - 6))

				TweenService:Create(self.mainFrame, INSTANT_TWEEN, {
					Position = UDim2.fromOffset(clampedX, clampedY),
				}):Play()
			end
		end)
	)

	table.insert(
		self._connections,
		UserInputService.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				dragging = false
			end
		end)
	)
end

function GUI:destroy()
	self:clearContent()
	for _, conn in self._connections do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(self._connections)

	if self.screenGui then
		self.screenGui:Destroy()
	end
end

function GUI:show()
	self.screenGui.Enabled = true
end

function GUI:hide()
	self.screenGui.Enabled = false
end

return GUI
