local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local GUI = {}
GUI.__index = GUI

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

function GUI.new(title)
    local self = setmetatable({}, GUI)
    
    self.isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    self.screenSize = workspace.CurrentCamera.ViewportSize
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "ModernGUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = PlayerGui
    
    local guiSize = self.isMobile and {420, 300} or {480, 320}
    if self.screenSize.X < 550 then
        guiSize = {self.screenSize.X * 0.9, self.screenSize.Y * 0.7}
    end
    
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, guiSize[1], 0, guiSize[2])
    self.mainFrame.Position = UDim2.new(0.5, -guiSize[1]/2, 0.5, -guiSize[2]/2)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
    self.mainFrame.BackgroundTransparency = 0.05
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.isMobile and 8 or 12)
    corner.Parent = self.mainFrame
    
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = -1
    shadow.Parent = self.mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, self.isMobile and 12 or 16)
    shadowCorner.Parent = shadow
    
    self:createTitleBar(title or "Modern GUI")
    self:createSidebar()
    self:createContentArea()
    self:createSearchBar()
    
    self.sidebarItems = {}
    self.sidebarCallbacks = {}
    self.selectedItem = nil
    self.dialogs = {}
    self.dropdownSelections = {}
    self.multiSelectDropdowns = {}
    
    self.componentStates = {}
    self.componentCallbacks = {}
    
    self:makeDraggable()
    
    return self
end

function GUI:createTitleBar(title)
    local titleHeight = self.isMobile and 28 or 35
    
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Size = UDim2.new(1, 0, 0, titleHeight)
    self.titleBar.Position = UDim2.new(0, 0, 0, 0)
    self.titleBar.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
    self.titleBar.BackgroundTransparency = 0.1
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, self.isMobile and 8 or 12)
    titleCorner.Parent = self.titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = self.isMobile and 14 or 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = self.titleBar
    
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, self.isMobile and 24 or 28, 0, self.isMobile and 20 or 24)
    self.closeButton.Position = UDim2.new(1, self.isMobile and -30 or -34, 0, self.isMobile and 4 or 6)
    self.closeButton.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
    self.closeButton.BorderSizePixel = 0
    self.closeButton.Text = "×"
    self.closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.closeButton.TextSize = self.isMobile and 12 or 14
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.Parent = self.titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = self.closeButton
    
    self.closeButton.MouseButton1Click:Connect(function()
        self:destroy()
    end)
end

function GUI:createSidebar()
    local sidebarWidth = self.isMobile and 100 or 125
    local titleHeight = self.isMobile and 28 or 35
    
    self.sidebar = Instance.new("Frame")
    self.sidebar.Name = "Sidebar"
    self.sidebar.Size = UDim2.new(0, sidebarWidth, 1, -titleHeight)
    self.sidebar.Position = UDim2.new(0, 0, 0, titleHeight)
    self.sidebar.BackgroundColor3 = Color3.fromRGB(22, 25, 32)
    self.sidebar.BackgroundTransparency = 0.1
    self.sidebar.BorderSizePixel = 0
    self.sidebar.Parent = self.mainFrame
    
    self.sidebarScrolling = Instance.new("ScrollingFrame")
    self.sidebarScrolling.Name = "SidebarScrolling"
    self.sidebarScrolling.Size = UDim2.new(1, 0, 1, self.isMobile and -35 or -42)
    self.sidebarScrolling.Position = UDim2.new(0, 0, 0, self.isMobile and 35 or 42)
    self.sidebarScrolling.BackgroundTransparency = 1
    self.sidebarScrolling.BorderSizePixel = 0
    self.sidebarScrolling.ScrollBarThickness = 3
    self.sidebarScrolling.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
    self.sidebarScrolling.Parent = self.sidebar
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 4)
    sidebarLayout.Parent = self.sidebarScrolling
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 8)
    sidebarPadding.PaddingBottom = UDim.new(0, 8)
    sidebarPadding.PaddingLeft = UDim.new(0, 8)
    sidebarPadding.PaddingRight = UDim.new(0, 8)
    sidebarPadding.Parent = self.sidebarScrolling
end

function GUI:createSearchBar()
    local searchHeight = self.isMobile and 24 or 28
    
    self.searchFrame = Instance.new("Frame")
    self.searchFrame.Name = "SearchFrame"
    self.searchFrame.Size = UDim2.new(1, -16, 0, searchHeight)
    self.searchFrame.Position = UDim2.new(0, 8, 0, 8)
    self.searchFrame.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
    self.searchFrame.BorderSizePixel = 0
    self.searchFrame.Parent = self.sidebar
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = self.searchFrame
    
    self.searchBox = Instance.new("TextBox")
    self.searchBox.Name = "SearchBox"
    self.searchBox.Size = UDim2.new(1, -24, 1, 0)
    self.searchBox.Position = UDim2.new(0, 8, 0, 0)
    self.searchBox.BackgroundTransparency = 1
    self.searchBox.Text = ""
    self.searchBox.PlaceholderText = "Search..."
    self.searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.searchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
    self.searchBox.TextSize = self.isMobile and 11 or 14
    self.searchBox.Font = Enum.Font.Gotham
    self.searchBox.TextXAlignment = Enum.TextXAlignment.Left
    self.searchBox.Parent = self.searchFrame
    
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Name = "SearchIcon"
    searchIcon.Size = UDim2.new(0, 12, 0, 12)
    searchIcon.Position = UDim2.new(1, -18, 0.5, -6)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextColor3 = Color3.fromRGB(140, 140, 160)
    searchIcon.TextSize = self.isMobile and 8 or 10
    searchIcon.Parent = self.searchFrame
    
    self.searchBox.Changed:Connect(function()
        self:filterSidebarItems(self.searchBox.Text)
    end)
end

function GUI:createContentArea()
    local sidebarWidth = self.isMobile and 100 or 125
    local titleHeight = self.isMobile and 28 or 35
    
    self.contentArea = Instance.new("Frame")
    self.contentArea.Name = "ContentArea"
    self.contentArea.Size = UDim2.new(1, -sidebarWidth, 1, -titleHeight)
    self.contentArea.Position = UDim2.new(0, sidebarWidth, 0, titleHeight)
    self.contentArea.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    self.contentArea.BackgroundTransparency = 0.1
    self.contentArea.BorderSizePixel = 0
    self.contentArea.Parent = self.mainFrame
    
    self.contentScrolling = Instance.new("ScrollingFrame")
    self.contentScrolling.Name = "ContentScrolling"
    self.contentScrolling.Size = UDim2.new(1, 0, 1, 0)
    self.contentScrolling.Position = UDim2.new(0, 0, 0, 0)
    self.contentScrolling.BackgroundTransparency = 1
    self.contentScrolling.BorderSizePixel = 0
    self.contentScrolling.ScrollBarThickness = self.isMobile and 3 or 4
    self.contentScrolling.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
    self.contentScrolling.Parent = self.contentArea
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, self.isMobile and 6 or 8)
    contentLayout.Parent = self.contentScrolling
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, self.isMobile and 12 or 16)
    contentPadding.PaddingBottom = UDim.new(0, self.isMobile and 12 or 16)
    contentPadding.PaddingLeft = UDim.new(0, self.isMobile and 12 or 16)
    contentPadding.PaddingRight = UDim.new(0, self.isMobile and 12 or 16)
    contentPadding.Parent = self.contentScrolling
end

function GUI:saveComponentState(sidebarName, componentId, value)
    if not self.componentStates[sidebarName] then
        self.componentStates[sidebarName] = {}
    end
    self.componentStates[sidebarName][componentId] = value
end

function GUI:getComponentState(sidebarName, componentId, defaultValue)
    if self.componentStates[sidebarName] and self.componentStates[sidebarName][componentId] ~= nil then
        return self.componentStates[sidebarName][componentId]
    end
    return defaultValue
end

function GUI:saveComponentCallback(sidebarName, componentId, callback)
    if not self.componentCallbacks[sidebarName] then
        self.componentCallbacks[sidebarName] = {}
    end
    self.componentCallbacks[sidebarName][componentId] = callback
end

function GUI:addSidebarItem(name, callback)
    local itemHeight = self.isMobile and 28 or 32
    
    local item = Instance.new("Frame")
    item.Name = name
    item.Size = UDim2.new(1, 0, 0, itemHeight)
    item.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
    item.BorderSizePixel = 0
    item.Parent = self.sidebarScrolling
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 10)
    itemCorner.Parent = item
    
    local itemButton = Instance.new("TextButton")
    itemButton.Name = "ItemButton"
    itemButton.Size = UDim2.new(1, 0, 1, 0)
    itemButton.Position = UDim2.new(0, 0, 0, 0)
    itemButton.BackgroundTransparency = 1
    itemButton.Text = name
    itemButton.TextColor3 = Color3.fromRGB(220, 220, 230)
    itemButton.TextSize = self.isMobile and 11 or 13
    itemButton.Font = Enum.Font.Gotham
    itemButton.TextXAlignment = Enum.TextXAlignment.Center
    itemButton.Parent = item
    
    local itemPadding = Instance.new("UIPadding")
    itemPadding.PaddingLeft = UDim.new(0, 8)
    itemPadding.PaddingRight = UDim.new(0, 8)
    itemPadding.Parent = itemButton
    
    local highlight = Instance.new("Frame")
    highlight.Name = "Highlight"
    highlight.Size = UDim2.new(0, 3, 0.7, 0)
    highlight.Position = UDim2.new(0, 0, 0.15, 0)
    highlight.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    highlight.BorderSizePixel = 0
    highlight.Visible = false
    highlight.Parent = item
    
    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0, 2)
    highlightCorner.Parent = highlight
    
    itemButton.MouseButton1Click:Connect(function()
        self:selectSidebarItem(item, name, callback)
    end)
    
    itemButton.MouseEnter:Connect(function()
        if self.selectedItem ~= item then
            local tween = TweenService:Create(item, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 46, 54)})
            tween:Play()
        end
    end)
    
    itemButton.MouseLeave:Connect(function()
        if self.selectedItem ~= item then
            local tween = TweenService:Create(item, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 36, 44)})
            tween:Play()
        end
    end)
    
    self.sidebarItems[name] = item
    self.sidebarCallbacks[name] = callback
    
    if not self.componentStates[name] then
        self.componentStates[name] = {}
    end
    
    return item
end

function GUI:selectSidebarItem(item, name, callback)
    if self.selectedItem then
        local prevHighlight = self.selectedItem:FindFirstChild("Highlight")
        if prevHighlight then
            prevHighlight.Visible = false
        end
        local tween = TweenService:Create(self.selectedItem, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 36, 44)})
        tween:Play()
    end
    
    self.selectedItem = item
    self.currentSidebarName = name
    local highlight = item:FindFirstChild("Highlight")
    if highlight then
        highlight.Visible = true
    end
    
    local tween = TweenService:Create(item, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(52, 56, 64)})
    tween:Play()
    
    self:clearContent()
    
    if callback then
        callback()
    end
end

function GUI:clearContent()
    for _, child in ipairs(self.contentScrolling:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
            child:Destroy()
        end
    end
end

function GUI:addToggle(name, defaultValue, callback)
    local toggleHeight = self.isMobile and 32 or 36
    local componentId = name .. "_toggle"
    local currentValue = self:getComponentState(self.currentSidebarName, componentId, defaultValue)
    
    self:saveComponentCallback(self.currentSidebarName, componentId, callback)
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name .. "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, toggleHeight)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(26, 29, 36)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = self.contentScrolling
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "ToggleLabel"
    toggleLabel.Size = UDim2.new(1, -60, 1, 0)
    toggleLabel.Position = UDim2.new(0, self.isMobile and 12 or 16, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = name
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = self.isMobile and 12 or 15
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local switchSize = self.isMobile and {32, 18} or {38, 20}
    local knobSize = self.isMobile and 14 or 16
    
    local toggleTrack = Instance.new("Frame")
    toggleTrack.Name = "ToggleTrack"
    toggleTrack.Size = UDim2.new(0, switchSize[1], 0, switchSize[2])
    toggleTrack.Position = UDim2.new(1, -switchSize[1] - (self.isMobile and 12 or 16), 0.5, -switchSize[2]/2)
    toggleTrack.BackgroundColor3 = currentValue and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(72, 72, 74)
    toggleTrack.BorderSizePixel = 0
    toggleTrack.Parent = toggleFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, switchSize[2]/2)
    trackCorner.Parent = toggleTrack
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "ToggleKnob"
    toggleKnob.Size = UDim2.new(0, knobSize, 0, knobSize)
    toggleKnob.Position = currentValue and UDim2.new(1, -knobSize - 2, 0.5, -knobSize/2) or UDim2.new(0, 2, 0.5, -knobSize/2)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.ZIndex = 2
    toggleKnob.Parent = toggleTrack
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, knobSize/2)
    knobCorner.Parent = toggleKnob
    
    local knobShadow = Instance.new("Frame")
    knobShadow.Name = "KnobShadow"
    knobShadow.Size = UDim2.new(1, 4, 1, 4)
    knobShadow.Position = UDim2.new(0, -2, 0, -2)
    knobShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.BackgroundTransparency = 0.3
    knobShadow.ZIndex = 1
    knobShadow.Parent = toggleKnob
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, knobSize/2 + 2)
    shadowCorner.Parent = knobShadow
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(1, 20, 1, 20)
    toggleButton.Position = UDim2.new(0, -10, 0, -10)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.ZIndex = 3
    toggleButton.Parent = toggleTrack
    
    local isToggled = currentValue
    
    local function animateToggle()
        local trackColor = isToggled and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(72, 72, 74)
        local knobPosition = isToggled and UDim2.new(1, -knobSize - 2, 0.5, -knobSize/2) or UDim2.new(0, 2, 0.5, -knobSize/2)
        
        local trackTween = TweenService:Create(toggleTrack, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = trackColor})
        local knobTween = TweenService:Create(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = knobPosition})
        
        trackTween:Play()
        knobTween:Play()
    end
    
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

function GUI:addDropdown(name, options, defaultOption, callback, multiSelect)
    multiSelect = multiSelect or false
    local dropdownHeight = self.isMobile and 32 or 36
    local componentId = name .. "_dropdown"
    local currentValue = self:getComponentState(self.currentSidebarName, componentId, defaultOption or options[1] or "")
    
    self:saveComponentCallback(self.currentSidebarName, componentId, callback)
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = name .. "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, dropdownHeight)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(26, 29, 36)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = self.contentScrolling
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 8)
    dropdownCorner.Parent = dropdownFrame
    
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Name = "DropdownLabel"
    dropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
    dropdownLabel.Position = UDim2.new(0, self.isMobile and 12 or 16, 0, 0)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = name
    dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownLabel.TextSize = self.isMobile and 12 or 15
    dropdownLabel.Font = Enum.Font.Gotham
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Parent = dropdownFrame
    
    local buttonWidth = self.isMobile and 90 or 110
    local buttonHeight = self.isMobile and 20 or 24
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
    dropdownButton.Position = UDim2.new(1, -buttonWidth - (self.isMobile and 12 or 16), 0.5, -buttonHeight/2)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(44, 47, 58)
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = currentValue
    dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownButton.TextSize = self.isMobile and 10 or 13
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.Parent = dropdownFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = dropdownButton
    
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 12, 0, 12)
    arrow.Position = UDim2.new(1, -16, 0.5, -6)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(180, 180, 200)
    arrow.TextSize = self.isMobile and 8 or 10
    arrow.Font = Enum.Font.Gotham
    arrow.Parent = dropdownButton
    
    if multiSelect then
        self.multiSelectDropdowns[name] = self:getComponentState(self.currentSidebarName, componentId, {})
        self.dropdownSelections[name] = {}
    else
        self.dropdownSelections[name] = currentValue
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        self:createDropdownDialog(name, options, currentValue, callback, dropdownButton, multiSelect)
    end)
    
    return dropdownFrame
end

function GUI:createDropdownDialog(title, options, defaultOption, callback, button, multiSelect)
    multiSelect = multiSelect or false
    local dialogSize = self.isMobile and {260, 220} or {300, 260}
    
    local overlay = Instance.new("Frame")
    overlay.Name = "DropdownOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 25
    overlay.Parent = self.screenGui
    
    local dialog = Instance.new("Frame")
    dialog.Name = "DropdownDialog"
    dialog.Size = UDim2.new(0, dialogSize[1], 0, dialogSize[2])
    dialog.Position = UDim2.new(0.5, -dialogSize[1]/2, 0.5, -dialogSize[2]/2)
    dialog.BackgroundColor3 = Color3.fromRGB(22, 25, 32)
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 30
    dialog.Parent = overlay
    
    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 12)
    dialogCorner.Parent = dialog
    
    local dialogTitle = Instance.new("TextLabel")
    dialogTitle.Name = "DialogTitle"
    dialogTitle.Size = UDim2.new(1, -40, 0, 30)
    dialogTitle.Position = UDim2.new(0, 12, 0, 8)
    dialogTitle.BackgroundTransparency = 1
    dialogTitle.Text = "Select " .. title .. (multiSelect and " (Multiple)" or "")
    dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    dialogTitle.TextSize = self.isMobile and 14 or 18
    dialogTitle.Font = Enum.Font.GothamBold
    dialogTitle.TextXAlignment = Enum.TextXAlignment.Left
    dialogTitle.Parent = dialog
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -28, 0, 8)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = self.isMobile and 10 or 12
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = dialog
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = closeButton
    
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchFrame"
    searchFrame.Size = UDim2.new(1, -24, 0, self.isMobile and 24 or 28)
    searchFrame.Position = UDim2.new(0, 12, 0, 40)
    searchFrame.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = dialog
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchFrame
    
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -24, 1, 0)
    searchBox.Position = UDim2.new(0, 8, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search options..."
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
    searchBox.TextSize = self.isMobile and 10 or 12
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = searchFrame
    
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Name = "SearchIcon"
    searchIcon.Size = UDim2.new(0, 12, 0, 12)
    searchIcon.Position = UDim2.new(1, -18, 0.5, -6)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextColor3 = Color3.fromRGB(140, 140, 160)
    searchIcon.TextSize = self.isMobile and 8 or 10
    searchIcon.Parent = searchFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "OptionsScroll"
    scrollFrame.Size = UDim2.new(1, -24, 1, multiSelect and -110 or -80)
    scrollFrame.Position = UDim2.new(0, 12, 0, 72)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
    scrollFrame.Parent = dialog
    
    local optionLayout = Instance.new("UIListLayout")
    optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionLayout.Padding = UDim.new(0, 3)
    optionLayout.Parent = scrollFrame
    
    local optionPadding = Instance.new("UIPadding")
    optionPadding.PaddingTop = UDim.new(0, 4)
    optionPadding.PaddingBottom = UDim.new(0, 4)
    optionPadding.Parent = scrollFrame
    
    local optionFrames = {}
    local currentSelections = multiSelect and (self.multiSelectDropdowns[title] or {}) or {self.dropdownSelections[title]}
    
    for i, option in ipairs(options) do
        local optionFrame = Instance.new("Frame")
        optionFrame.Name = "Option" .. i
        optionFrame.Size = UDim2.new(1, 0, 0, self.isMobile and 26 or 30)
        optionFrame.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
        optionFrame.BorderSizePixel = 0
        optionFrame.Parent = scrollFrame
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 6)
        optionCorner.Parent = optionFrame
        
        local isSelected = false
        for _, selection in ipairs(currentSelections) do
            if selection == option then
                isSelected = true
                break
            end
        end
        
        local bottomBorder = Instance.new("Frame")
        bottomBorder.Name = "BottomBorder"
        bottomBorder.Size = UDim2.new(1, 0, 0, 2)
        bottomBorder.Position = UDim2.new(0, 0, 1, -2)
        bottomBorder.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
        bottomBorder.BorderSizePixel = 0
        bottomBorder.Visible = isSelected
        bottomBorder.Parent = optionFrame
        
        local highlightGlow = Instance.new("Frame")
        highlightGlow.Name = "HighlightGlow"
        highlightGlow.Size = UDim2.new(1, 0, 1, 0)
        highlightGlow.Position = UDim2.new(0, 0, 0, 0)
        highlightGlow.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
        highlightGlow.BackgroundTransparency = isSelected and 0.85 or 1
        highlightGlow.BorderSizePixel = 0
        highlightGlow.ZIndex = 0
        highlightGlow.Parent = optionFrame
        
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(0, 6)
        glowCorner.Parent = highlightGlow
        
        local checkIcon = Instance.new("TextLabel")
        checkIcon.Name = "CheckIcon"
        checkIcon.Size = UDim2.new(0, 18, 0, 18)
        checkIcon.Position = UDim2.new(1, -24, 0.5, -9)
        checkIcon.BackgroundTransparency = 1
        checkIcon.Text = "✓"
        checkIcon.TextColor3 = Color3.fromRGB(52, 199, 89)
        checkIcon.TextSize = self.isMobile and 12 or 14
        checkIcon.Font = Enum.Font.GothamBold
        checkIcon.Visible = isSelected
        checkIcon.ZIndex = 2
        checkIcon.Parent = optionFrame
        
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "OptionButton"
        optionButton.Size = UDim2.new(1, 0, 1, 0)
        optionButton.BackgroundTransparency = 1
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.TextSize = self.isMobile and 10 or 12
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextXAlignment = Enum.TextXAlignment.Center
        optionButton.Parent = optionFrame
        
        local optionPadding = Instance.new("UIPadding")
        optionPadding.PaddingLeft = UDim.new(0, 8)
        optionPadding.PaddingRight = UDim.new(0, 8)
        optionPadding.Parent = optionButton
        
        optionFrames[option] = {frame = optionFrame, border = bottomBorder, glow = highlightGlow, check = checkIcon, selected = isSelected}
        
        optionButton.MouseEnter:Connect(function()
            if not optionFrames[option].selected then
                local hoverTween = TweenService:Create(optionFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(42, 46, 54)})
                local glowTween = TweenService:Create(highlightGlow, TweenInfo.new(0.15), {BackgroundTransparency = 0.92})
                hoverTween:Play()
                glowTween:Play()
            end
        end)
        
        optionButton.MouseLeave:Connect(function()
            if not optionFrames[option].selected then
                local hoverTween = TweenService:Create(optionFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 36, 44)})
                local glowTween = TweenService:Create(highlightGlow, TweenInfo.new(0.15), {BackgroundTransparency = 1})
                hoverTween:Play()
                glowTween:Play()
            end
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            if multiSelect then
                optionFrames[option].selected = not optionFrames[option].selected
                bottomBorder.Visible = optionFrames[option].selected
                checkIcon.Visible = optionFrames[option].selected
                
                local glowTween = TweenService:Create(highlightGlow, TweenInfo.new(0.2), {
                    BackgroundTransparency = optionFrames[option].selected and 0.85 or 1
                })
                glowTween:Play()
                
                if optionFrames[option].selected then
                    local borderTween = TweenService:Create(bottomBorder, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                        Size = UDim2.new(1, 0, 0, 3)
                    })
                    borderTween:Play()
                end
            else
                for _, data in pairs(optionFrames) do
                    data.border.Visible = false
                    data.check.Visible = false
                    data.selected = false
                    local glowTween = TweenService:Create(data.glow, TweenInfo.new(0.2), {BackgroundTransparency = 1})
                    glowTween:Play()
                end
                
                optionFrames[option].selected = true
                bottomBorder.Visible = true
                checkIcon.Visible = true
                local selectGlowTween = TweenService:Create(highlightGlow, TweenInfo.new(0.2), {BackgroundTransparency = 0.85})
                local borderTween = TweenService:Create(bottomBorder, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                    Size = UDim2.new(1, 0, 0, 3)
                })
                selectGlowTween:Play()
                borderTween:Play()
                
                local componentId = title .. "_dropdown"
                self:saveComponentState(self.currentSidebarName, componentId, option)
                self.dropdownSelections[title] = option
                button.Text = option
                
                wait(0.1)
                overlay:Destroy()
                
                if callback then
                    callback(option, i)
                end
            end
        end)
    end
    
    if multiSelect then
        local confirmButton = Instance.new("TextButton")
        confirmButton.Name = "ConfirmButton"
        confirmButton.Size = UDim2.new(0, 80, 0, 24)
        confirmButton.Position = UDim2.new(1, -92, 1, -32)
        confirmButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
        confirmButton.BorderSizePixel = 0
        confirmButton.Text = "Done"
        confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmButton.TextSize = self.isMobile and 10 or 12
        confirmButton.Font = Enum.Font.GothamBold
        confirmButton.Parent = dialog
        
        local confirmCorner = Instance.new("UICorner")
        confirmCorner.CornerRadius = UDim.new(0, 6)
        confirmCorner.Parent = confirmButton
        
        confirmButton.MouseButton1Click:Connect(function()
            local selectedOptions = {}
            for option, data in pairs(optionFrames) do
                if data.selected then
                    table.insert(selectedOptions, option)
                end
            end
            
            local componentId = title .. "_dropdown"
            self:saveComponentState(self.currentSidebarName, componentId, selectedOptions)
            self.multiSelectDropdowns[title] = selectedOptions
            button.Text = #selectedOptions > 0 and (#selectedOptions == 1 and selectedOptions[1] or #selectedOptions .. " selected") or "None selected"
            
            overlay:Destroy()
            
            if callback then
                callback(selectedOptions)
            end
        end)
    end
    
    local function filterOptions(searchText)
        searchText = searchText:lower()
        for option, data in pairs(optionFrames) do
            if searchText == "" or option:lower():find(searchText) then
                data.frame.Visible = true
            else
                data.frame.Visible = false
            end
        end
    end
    
    searchBox.Changed:Connect(function()
        filterOptions(searchBox.Text)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    overlay.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    dialog.MouseButton1Click:Connect(function(input)
        input.Handled = true
    end)
    
    dialog.Position = UDim2.new(0.5, -dialogSize[1]/2, 0.5, -dialogSize[2] - 40)
    local tween = TweenService:Create(dialog, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -dialogSize[1]/2, 0.5, -dialogSize[2]/2)})
    tween:Play()
    
    return dialog
end

function GUI:addSlider(name, minValue, maxValue, defaultValue, callback)
    local sliderHeight = self.isMobile and 45 or 52
    local componentId = name .. "_slider"
    local currentValue = self:getComponentState(self.currentSidebarName, componentId, defaultValue)
    
    self:saveComponentCallback(self.currentSidebarName, componentId, callback)
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name .. "Slider"
    sliderFrame.Size = UDim2.new(1, 0, 0, sliderHeight)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(26, 29, 36)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = self.contentScrolling
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 10)
    sliderCorner.Parent = sliderFrame
    
    local sliderGlow = Instance.new("Frame")
    sliderGlow.Name = "SliderGlow"
    sliderGlow.Size = UDim2.new(1, 4, 1, 4)
    sliderGlow.Position = UDim2.new(0, -2, 0, -2)
    sliderGlow.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    sliderGlow.BackgroundTransparency = 1
    sliderGlow.BorderSizePixel = 0
    sliderGlow.ZIndex = 0
    sliderGlow.Parent = sliderFrame
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 12)
    glowCorner.Parent = sliderGlow
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "SliderLabel"
    sliderLabel.Size = UDim2.new(1, -60, 0, 18)
    sliderLabel.Position = UDim2.new(0, self.isMobile and 14 or 18, 0, 4)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.TextSize = self.isMobile and 13 or 16
    sliderLabel.Font = Enum.Font.GothamBold
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0, 50, 0, 18)
    valueLabel.Position = UDim2.new(1, -64, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(currentValue)
    valueLabel.TextColor3 = Color3.fromRGB(0, 122, 255)
    valueLabel.TextSize = self.isMobile and 13 or 16
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "SliderTrack"
    sliderTrack.Size = UDim2.new(1, -36, 0, 6)
    sliderTrack.Position = UDim2.new(0, 18, 1, -20)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(38, 42, 52)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack
    
    local trackGradient = Instance.new("UIGradient")
    trackGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 42, 52)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(28, 32, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(38, 42, 52))
    }
    trackGradient.Rotation = 90
    trackGradient.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new((currentValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 132, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 122, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 102, 235))
    }
    fillGradient.Rotation = 90
    fillGradient.Parent = sliderFill
    
    local knobSize = self.isMobile and 16 or 18
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "SliderKnob"
    sliderKnob.Size = UDim2.new(0, knobSize, 0, knobSize)
    sliderKnob.Position = UDim2.new((currentValue - minValue) / (maxValue - minValue), -knobSize/2, 0.5, -knobSize/2)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.ZIndex = 4
    sliderKnob.Parent = sliderTrack
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob
    
    local knobGradient = Instance.new("UIGradient")
    knobGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(245, 245, 245)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 235, 235))
    }
    knobGradient.Rotation = 45
    knobGradient.Parent = sliderKnob
    
    local knobShadow = Instance.new("Frame")
    knobShadow.Name = "KnobShadow"
    knobShadow.Size = UDim2.new(1, 6, 1, 6)
    knobShadow.Position = UDim2.new(0, -3, 0, -3)
    knobShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.BackgroundTransparency = 0.15
    knobShadow.ZIndex = 3
    knobShadow.Parent = sliderKnob
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(1, 0)
    shadowCorner.Parent = knobShadow
    
    local knobHighlight = Instance.new("Frame")
    knobHighlight.Name = "KnobHighlight"
    knobHighlight.Size = UDim2.new(0, 0, 0, 0)
    knobHighlight.Position = UDim2.new(0.5, 0, 0.5, 0)
    knobHighlight.AnchorPoint = Vector2.new(0.5, 0.5)
    knobHighlight.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    knobHighlight.BackgroundTransparency = 0.6
    knobHighlight.BorderSizePixel = 0
    knobHighlight.ZIndex = 2
    knobHighlight.Parent = sliderKnob
    
    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(1, 0)
    highlightCorner.Parent = knobHighlight
    
    local knobInner = Instance.new("Frame")
    knobInner.Name = "KnobInner"
    knobInner.Size = UDim2.new(0, 5, 0, 5)
    knobInner.Position = UDim2.new(0.5, -2.5, 0.5, -2.5)
    knobInner.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    knobInner.BorderSizePixel = 0
    knobInner.ZIndex = 5
    knobInner.Parent = sliderKnob
    
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(1, 0)
    innerCorner.Parent = knobInner
    
    local actualValue = currentValue
    local dragging = false
    
    local function updateSlider(input)
        local relativePos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        actualValue = math.floor(minValue + (maxValue - minValue) * relativePos + 0.5)
        
        valueLabel.Text = tostring(actualValue)
        
        local fillTween = TweenService:Create(sliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {Size = UDim2.new(relativePos, 0, 1, 0)})
        local knobTween = TweenService:Create(sliderKnob, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {Position = UDim2.new(relativePos, -knobSize/2, 0.5, -knobSize/2)})
        
        fillTween:Play()
        knobTween:Play()
        
        self:saveComponentState(self.currentSidebarName, componentId, actualValue)
        
        if callback then
            callback(actualValue)
        end
    end
    
    local function startDragging()
        dragging = true
        local expandTween = TweenService:Create(knobHighlight, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 30, 0, 30)
        })
        local scaleTween = TweenService:Create(sliderKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, knobSize + 4, 0, knobSize + 4)
        })
        local glowTween = TweenService:Create(sliderGlow, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 0.7
        })
        local innerTween = TweenService:Create(knobInner, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 6, 0, 6),
            Position = UDim2.new(0.5, -3, 0.5, -3)
        })
        expandTween:Play()
        scaleTween:Play()
        glowTween:Play()
        innerTween:Play()
    end
    
    local function stopDragging()
        dragging = false
        local contractTween = TweenService:Create(knobHighlight, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        local scaleTween = TweenService:Create(sliderKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, knobSize, 0, knobSize)
        })
        local glowTween = TweenService:Create(sliderGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 1
        })
        local innerTween = TweenService:Create(knobInner, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 5, 0, 5),
            Position = UDim2.new(0.5, -2.5, 0.5, -2.5)
        })
        contractTween:Play()
        scaleTween:Play()
        glowTween:Play()
        innerTween:Play()
    end
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDragging()
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                stopDragging()
            end
        end
    end)
    
    return sliderFrame
end

function GUI:addButton(name, callback)
    local buttonHeight = self.isMobile and 32 or 36
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = name .. "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, 0, 0, buttonHeight + 10)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = self.contentScrolling
    
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(1, -20, 0, buttonHeight)
    button.Position = UDim2.new(0, 10, 0, 5)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = self.isMobile and 13 or 16
    button.Font = Enum.Font.GothamBold
    button.Parent = buttonFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button
    
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 86, 214)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(58, 134, 255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0, 123, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 101, 235))
    }
    buttonGradient.Rotation = 135
    buttonGradient.Parent = button
    
    local buttonGlow = Instance.new("Frame")
    buttonGlow.Name = "ButtonGlow"
    buttonGlow.Size = UDim2.new(1, 8, 1, 8)
    buttonGlow.Position = UDim2.new(0, -4, 0, -4)
    buttonGlow.BackgroundColor3 = Color3.fromRGB(58, 134, 255)
    buttonGlow.BackgroundTransparency = 1
    buttonGlow.BorderSizePixel = 0
    buttonGlow.ZIndex = 0
    buttonGlow.Parent = button
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 14)
    glowCorner.Parent = buttonGlow
    
    local buttonShadow = Instance.new("Frame")
    buttonShadow.Name = "ButtonShadow"
    buttonShadow.Size = UDim2.new(1, 8, 1, 8)
    buttonShadow.Position = UDim2.new(0, -4, 0, 2)
    buttonShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    buttonShadow.BackgroundTransparency = 0.25
    buttonShadow.ZIndex = -1
    buttonShadow.Parent = button
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 14)
    shadowCorner.Parent = buttonShadow
    
    local shadowGradient = Instance.new("UIGradient")
    shadowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 40))
    }
    shadowGradient.Rotation = 90
    shadowGradient.Parent = buttonShadow
    
    local highlightLayer = Instance.new("Frame")
    highlightLayer.Name = "HighlightLayer"
    highlightLayer.Size = UDim2.new(1, 0, 0.6, 0)
    highlightLayer.Position = UDim2.new(0, 0, 0, 0)
    highlightLayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    highlightLayer.BackgroundTransparency = 0.7
    highlightLayer.BorderSizePixel = 0
    highlightLayer.ZIndex = 1
    highlightLayer.Parent = button
    
    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0, 10)
    highlightCorner.Parent = highlightLayer
    
    local highlightGradient = Instance.new("UIGradient")
    highlightGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    highlightGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.7, 0.8),
        NumberSequenceKeypoint.new(1, 1)
    }
    highlightGradient.Rotation = 90
    highlightGradient.Parent = highlightLayer
    
    button.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(buttonGradient, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(108, 106, 234)),
                ColorSequenceKeypoint.new(0.3, Color3.fromRGB(78, 154, 255)),
                ColorSequenceKeypoint.new(0.7, Color3.fromRGB(20, 143, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 121, 245))
            }
        })
        local glowTween = TweenService:Create(buttonGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 0.5
        })
        local shadowTween = TweenService:Create(buttonShadow, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 0.1,
            Position = UDim2.new(0, -4, 0, 4)
        })
        local scaleTween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(1, -16, 0, buttonHeight + 3)
        })
        hoverTween:Play()
        glowTween:Play()
        shadowTween:Play()
        scaleTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local hoverTween = TweenService:Create(buttonGradient, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 86, 214)),
                ColorSequenceKeypoint.new(0.3, Color3.fromRGB(58, 134, 255)),
                ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0, 123, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 101, 235))
            }
        })
        local glowTween = TweenService:Create(buttonGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 1
        })
        local shadowTween = TweenService:Create(buttonShadow, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 0.25,
            Position = UDim2.new(0, -4, 0, 2)
        })
        local scaleTween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(1, -20, 0, buttonHeight)
        })
        hoverTween:Play()
        glowTween:Play()
        shadowTween:Play()
        scaleTween:Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        for _, dialog in ipairs(self.dialogs) do
            if dialog and dialog.Parent then
                dialog:Destroy()
            end
        end
        self.dialogs = {}
        
        local clickTween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(1, -24, 0, buttonHeight - 3)
        })
        clickTween:Play()
        
        clickTween.Completed:Connect(function()
            local releaseTween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, -16, 0, buttonHeight + 3)
            })
            releaseTween:Play()
        end)
        
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.3
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 3
        ripple.Parent = button
        
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        local rippleExpand = TweenService:Create(ripple, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 140, 0, 140),
            BackgroundTransparency = 1
        })
        
        rippleExpand:Play()
        rippleExpand.Completed:Connect(function()
            ripple:Destroy()
        end)
        
        if callback then
            callback()
        end
    end)
    
    return buttonFrame
end

function GUI:addTextInput(name, placeholder, callback)
    local inputHeight = self.isMobile and 50 or 60
    local componentId = name .. "_textinput"
    local currentValue = self:getComponentState(self.currentSidebarName, componentId, "")
    
    self:saveComponentCallback(self.currentSidebarName, componentId, callback)
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = name .. "Input"
    inputFrame.Size = UDim2.new(1, 0, 0, inputHeight)
    inputFrame.BackgroundColor3 = Color3.fromRGB(26, 29, 36)
    inputFrame.BackgroundTransparency = 0.1
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = self.contentScrolling
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    
    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputContainer"
    inputContainer.Size = UDim2.new(1, -24, 0, self.isMobile and 32 or 38)
    inputContainer.Position = UDim2.new(0, 12, 1, self.isMobile and -38 or -44)
    inputContainer.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
    inputContainer.BackgroundTransparency = 0.2
    inputContainer.BorderSizePixel = 0
    inputContainer.Parent = inputFrame
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 6)
    containerCorner.Parent = inputContainer
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Name = "ContainerStroke"
    containerStroke.Color = Color3.fromRGB(68, 72, 82)
    containerStroke.Thickness = 2
    containerStroke.Transparency = 0.3
    containerStroke.Parent = inputContainer
    
    local underline = Instance.new("Frame")
    underline.Name = "Underline"
    underline.Size = UDim2.new(0, 0, 0, 3)
    underline.Position = UDim2.new(0.5, 0, 1, -3)
    underline.AnchorPoint = Vector2.new(0.5, 0)
    underline.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    underline.BorderSizePixel = 0
    underline.Parent = inputContainer
    
    local underlineCorner = Instance.new("UICorner")
    underlineCorner.CornerRadius = UDim.new(0, 2)
    underlineCorner.Parent = underline
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, -20, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = currentValue
    textBox.PlaceholderText = ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
    textBox.TextSize = self.isMobile and 13 or 16
    textBox.Font = Enum.Font.Gotham
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputContainer
    
    local floatingLabel = Instance.new("TextLabel")
    floatingLabel.Name = "FloatingLabel"
    floatingLabel.Size = UDim2.new(0, 200, 0, 20)
    floatingLabel.Position = UDim2.new(0, 10, 0, self.isMobile and 11 or 14)
    floatingLabel.BackgroundTransparency = 1
    floatingLabel.Text = placeholder or name
    floatingLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
    floatingLabel.TextSize = self.isMobile and 13 or 16
    floatingLabel.Font = Enum.Font.Gotham
    floatingLabel.TextXAlignment = Enum.TextXAlignment.Left
    floatingLabel.ZIndex = 3
    floatingLabel.Parent = inputContainer
    
    local labelBackground = Instance.new("Frame")
    labelBackground.Name = "LabelBackground"
    labelBackground.Size = UDim2.new(0, 0, 0, 6)
    labelBackground.Position = UDim2.new(0, 10, 0, -3)
    labelBackground.BackgroundColor3 = Color3.fromRGB(26, 29, 36)
    labelBackground.BackgroundTransparency = 0.95
    labelBackground.BorderSizePixel = 0
    labelBackground.Visible = false
    labelBackground.ZIndex = 2
    labelBackground.Parent = inputContainer
    
    local labelName = Instance.new("TextLabel")
    labelName.Name = "LabelName"
    labelName.Size = UDim2.new(1, -24, 0, 16)
    labelName.Position = UDim2.new(0, 12, 0, 4)
    labelName.BackgroundTransparency = 1
    labelName.Text = name
    labelName.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelName.TextSize = self.isMobile and 13 or 16
    labelName.Font = Enum.Font.GothamMedium
    labelName.TextXAlignment = Enum.TextXAlignment.Left
    labelName.Parent = inputFrame
    
    local function animateLabel(focused, clickPosition)
        local isActive = focused or textBox.Text ~= ""
        
        if isActive then
            local labelSize = floatingLabel.TextBounds.X + 16
            
            local labelTween = TweenService:Create(floatingLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 10, 0, -12),
                TextSize = self.isMobile and 10 or 13,
                TextColor3 = focused and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(180, 180, 200)
            })
            
            local backgroundTween = TweenService:Create(labelBackground, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, labelSize, 0, 6)
            })
            
            labelBackground.Visible = true
            labelTween:Play()
            backgroundTween:Play()
        else
            local labelTween = TweenService:Create(floatingLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 10, 0, self.isMobile and 11 or 14),
                TextSize = self.isMobile and 13 or 16,
                TextColor3 = Color3.fromRGB(140, 140, 160)
            })
            
            local backgroundTween = TweenService:Create(labelBackground, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 0, 0, 6)
            })
            
            labelTween:Play()
            backgroundTween:Play()
            
            backgroundTween.Completed:Connect(function()
                if not (focused or textBox.Text ~= "") then
                    labelBackground.Visible = false
                end
            end)
        end
        
        local strokeTween = TweenService:Create(containerStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Color = focused and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(68, 72, 82),
            Thickness = focused and 3 or 2,
            Transparency = focused and 0 or 0.3
        })
        
        local underlineTween = TweenService:Create(underline, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = focused and UDim2.new(1, 0, 0, 3) or UDim2.new(0, 0, 0, 3)
        })
        
        local containerTween = TweenService:Create(inputContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundColor3 = focused and Color3.fromRGB(36, 40, 48) or Color3.fromRGB(32, 36, 44),
            BackgroundTransparency = focused and 0.1 or 0.2
        })
        
        strokeTween:Play()
        underlineTween:Play()
        containerTween:Play()
    end
    
    if currentValue ~= "" then
        animateLabel(false)
    end
    
    textBox.Focused:Connect(function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        animateLabel(true, Vector2.new(mouse.X, mouse.Y))
    end)
    
    textBox.FocusLost:Connect(function()
        animateLabel(false)
        self:saveComponentState(self.currentSidebarName, componentId, textBox.Text)
        if callback then
            callback(textBox.Text)
        end
    end)
    
    textBox.Changed:Connect(function()
        if textBox.Text ~= "" and floatingLabel.Position.Y.Offset > 0 then
            animateLabel(false)
        end
        self:saveComponentState(self.currentSidebarName, componentId, textBox.Text)
    end)
    
    inputContainer.MouseEnter:Connect(function()
        if not textBox:IsFocused() then
            local hoverTween = TweenService:Create(inputContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(34, 38, 46),
                BackgroundTransparency = 0.15
            })
            
            local strokeHoverTween = TweenService:Create(containerStroke, TweenInfo.new(0.15), {
                Transparency = 0.1
            })
            
            hoverTween:Play()
            strokeHoverTween:Play()
        end
    end)
    
    inputContainer.MouseLeave:Connect(function()
        if not textBox:IsFocused() then
            local hoverTween = TweenService:Create(inputContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(32, 36, 44),
                BackgroundTransparency = 0.2
            })
            
            local strokeHoverTween = TweenService:Create(containerStroke, TweenInfo.new(0.15), {
                Transparency = 0.3
            })
            
            hoverTween:Play()
            strokeHoverTween:Play()
        end
    end)
    
    return inputFrame
end

function GUI:createDialog(title, content, buttons)
    local dialogSize = self.isMobile and {240, 170} or {280, 190}
    
    local overlay = Instance.new("Frame")
    overlay.Name = "DialogOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 25
    overlay.Parent = self.screenGui
    
    local dialog = Instance.new("Frame")
    dialog.Name = "Dialog"
    dialog.Size = UDim2.new(0, dialogSize[1], 0, dialogSize[2])
    dialog.Position = UDim2.new(0.5, -dialogSize[1]/2, 0.5, -dialogSize[2]/2)
    dialog.BackgroundColor3 = Color3.fromRGB(22, 25, 32)
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 30
    dialog.Parent = overlay
    
    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 8)
    dialogCorner.Parent = dialog
    
    local dialogTitle = Instance.new("TextLabel")
    dialogTitle.Name = "DialogTitle"
    dialogTitle.Size = UDim2.new(1, -24, 0, 24)
    dialogTitle.Position = UDim2.new(0, 12, 0, 8)
    dialogTitle.BackgroundTransparency = 1
    dialogTitle.Text = title
    dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    dialogTitle.TextSize = self.isMobile and 12 or 14
    dialogTitle.Font = Enum.Font.GothamBold
    dialogTitle.TextXAlignment = Enum.TextXAlignment.Left
    dialogTitle.Parent = dialog
    
    local contentHeight = self.isMobile and 90 or 100
    
    local dialogContent = Instance.new("TextLabel")
    dialogContent.Name = "DialogContent"
    dialogContent.Size = UDim2.new(1, -24, 0, contentHeight)
    dialogContent.Position = UDim2.new(0, 12, 0, 34)
    dialogContent.BackgroundTransparency = 1
    dialogContent.Text = content
    dialogContent.TextColor3 = Color3.fromRGB(200, 200, 200)
    dialogContent.TextSize = self.isMobile and 11 or 14
    dialogContent.Font = Enum.Font.Gotham
    dialogContent.TextXAlignment = Enum.TextXAlignment.Left
    dialogContent.TextYAlignment = Enum.TextYAlignment.Top
    dialogContent.TextWrapped = true
    dialogContent.Parent = dialog
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, -24, 0, self.isMobile and 24 or 28)
    buttonFrame.Position = UDim2.new(0, 12, 1, self.isMobile and -32 or -36)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = dialog
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Padding = UDim.new(0, 6)
    buttonLayout.Parent = buttonFrame
    
    buttons = buttons or {{"OK", function() overlay:Destroy() end}}
    
    for i, buttonData in ipairs(buttons) do
        local buttonName, buttonCallback = buttonData[1], buttonData[2]
        
        local dialogButton = Instance.new("TextButton")
        dialogButton.Name = "DialogButton" .. i
        dialogButton.Size = UDim2.new(0, self.isMobile and 50 or 60, 1, 0)
        dialogButton.BackgroundColor3 = i == 1 and Color3.fromRGB(58, 134, 255) or Color3.fromRGB(48, 52, 62)
        dialogButton.BorderSizePixel = 0
        dialogButton.Text = buttonName
        dialogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dialogButton.TextSize = self.isMobile and 10 or 13
        dialogButton.Font = Enum.Font.Gotham
        dialogButton.Parent = buttonFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = dialogButton
        
        dialogButton.MouseButton1Click:Connect(function()
            if buttonCallback then
                buttonCallback()
            end
            overlay:Destroy()
        end)
        
        dialogButton.MouseEnter:Connect(function()
            local hoverColor = i == 1 and Color3.fromRGB(78, 154, 255) or Color3.fromRGB(68, 72, 82)
            local tween = TweenService:Create(dialogButton, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor})
            tween:Play()
        end)
        
        dialogButton.MouseLeave:Connect(function()
            local normalColor = i == 1 and Color3.fromRGB(58, 134, 255) or Color3.fromRGB(48, 52, 62)
            local tween = TweenService:Create(dialogButton, TweenInfo.new(0.15), {BackgroundColor3 = normalColor})
            tween:Play()
        end)
    end
    
    dialog.Position = UDim2.new(0.5, -dialogSize[1]/2, 0.5, -dialogSize[2] - 40)
    local tween = TweenService:Create(dialog, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -dialogSize[1]/2, 0.5, -dialogSize[2]/2)})
    tween:Play()
    
    table.insert(self.dialogs, overlay)
    
    return overlay
end

function GUI:filterSidebarItems(searchText)
    searchText = searchText:lower()
    
    for name, item in pairs(self.sidebarItems) do
        if searchText == "" or name:lower():find(searchText) then
            item.Visible = true
        else
            item.Visible = false
        end
    end
end

function GUI:makeDraggable()
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function GUI:destroy()
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
