local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local CONFIG_FILE = "evade_hub_config.json"
local config = {}

local HiddenStorage = game:GetService("ReplicatedStorage"):FindFirstChild("HiddenPlayersStorage")
if not HiddenStorage then
    HiddenStorage = Instance.new("Folder")
    HiddenStorage.Name = "HiddenPlayersStorage"
    HiddenStorage.Parent = game:GetService("ReplicatedStorage")
end

local menuCollapsed = false
local playersHidden = false
local exceptionsEnabled = false
local botsEspEnabled = false
local excludedPlayers = {}
local activeBotHighlights = {}

local function hideCharacter(character)
    if character and character:IsDescendantOf(workspace) then
        character.Parent = HiddenStorage
    end
end

local function restoreCharacter(character)
    if character and character:IsDescendantOf(HiddenStorage) then
        character.Parent = workspace
    end
end

local function updateVisibility()
    if not playersHidden then
        for _, char in ipairs(HiddenStorage:GetChildren()) do
            restoreCharacter(char)
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if exceptionsEnabled and excludedPlayers[player.Name] then
                restoreCharacter(player.Character)
            else
                hideCharacter(player.Character)
            end
        end
    end
end
if PlayerGui:FindFirstChild("EvadeHubGui") then
    PlayerGui.EvadeHubGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EvadeHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 180) 
MainFrame.Position = UDim2.new(0, 20, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.65 
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 0, 40)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EVADE HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Active = true
Title.Parent = MainFrame

local SidebarFrame = Instance.new("Frame")
SidebarFrame.Name = "SidebarFrame"
SidebarFrame.Size = UDim2.new(0, 120, 1, -40)
SidebarFrame.Position = UDim2.new(0, 0, 0, 40)
SidebarFrame.BackgroundTransparency = 1
SidebarFrame.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 6)
SidebarList.Parent = SidebarFrame

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingLeft = UDim.new(0, 10)
SidebarPadding.PaddingTop = UDim.new(0, 8)
SidebarPadding.Parent = SidebarFrame

local tabsList = {}
local pagesList = {}

local function createTabButton(name, layoutOrder)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -6, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.LayoutOrder = layoutOrder
    TabBtn.Parent = SidebarFrame

    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 15
    Label.Font = Enum.Font.SourceSansBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TabBtn

    table.insert(tabsList, TabBtn)

    return TabBtn
end

local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 28, 0, 28)
ToggleMenuBtn.AnchorPoint = Vector2.new(1, 0)
ToggleMenuBtn.Position = UDim2.new(1, -45, 0, 6)
ToggleMenuBtn.BackgroundTransparency = 1
ToggleMenuBtn.Text = "-"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.TextSize = 20
ToggleMenuBtn.Font = Enum.Font.SourceSansBold
ToggleMenuBtn.ZIndex = 100
ToggleMenuBtn.Active = true
ToggleMenuBtn.Parent = MainFrame

local CloseMenuBtn = Instance.new("TextButton")
CloseMenuBtn.Size = UDim2.new(0, 28, 0, 28)
CloseMenuBtn.AnchorPoint = Vector2.new(1, 0)
CloseMenuBtn.Position = UDim2.new(1, -10, 0, 6)
CloseMenuBtn.BackgroundTransparency = 1
CloseMenuBtn.Text = "X"
CloseMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseMenuBtn.TextSize = 15
CloseMenuBtn.Font = Enum.Font.SourceSansBold
CloseMenuBtn.ZIndex = 100
CloseMenuBtn.Active = true
CloseMenuBtn.Parent = MainFrame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -130, 1, -40)
ContentFrame.Position = UDim2.new(0, 130, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local PagePlayers = Instance.new("Frame")
PagePlayers.Name = "PagePlayers"
PagePlayers.Size = UDim2.new(1, 0, 1, 0)
PagePlayers.BackgroundTransparency = 1
PagePlayers.Visible = true
PagePlayers.Parent = ContentFrame

local PagePlayersList = Instance.new("UIListLayout")
PagePlayersList.SortOrder = Enum.SortOrder.LayoutOrder
PagePlayersList.Padding = UDim.new(0, 12)
PagePlayersList.Parent = PagePlayers

local PagePlayersPadding = Instance.new("UIPadding")
PagePlayersPadding.PaddingLeft, PagePlayersPadding.PaddingRight, PagePlayersPadding.PaddingTop = UDim.new(0, 5), UDim.new(0, 18), UDim.new(0, 8)
PagePlayersPadding.Parent = PagePlayers

local PageGuiTab = Instance.new("Frame")
PageGuiTab.Name = "PageGuiTab"
PageGuiTab.Size = UDim2.new(1, 0, 1, 0)
PageGuiTab.BackgroundTransparency = 1
PageGuiTab.Visible = false
PageGuiTab.Parent = ContentFrame

local PageGuiTabList = Instance.new("UIListLayout")
PageGuiTabList.SortOrder = Enum.SortOrder.LayoutOrder
PageGuiTabList.Padding = UDim.new(0, 12)
PageGuiTabList.Parent = PageGuiTab

local PageGuiTabPadding = Instance.new("UIPadding")
PageGuiTabPadding.PaddingLeft, PageGuiTabPadding.PaddingRight, PageGuiTabPadding.PaddingTop = UDim.new(0, 5), UDim.new(0, 18), UDim.new(0, 8)
PageGuiTabPadding.Parent = PageGuiTab

local PageColorSettings = Instance.new("Frame")
PageColorSettings.Name = "PageColorSettings"
PageColorSettings.Size = UDim2.new(1, 0, 1, 0)
PageColorSettings.BackgroundTransparency = 1
PageColorSettings.Visible = false
PageColorSettings.Parent = ContentFrame

local ColorWheelBtn = Instance.new("ImageButton")
ColorWheelBtn.Name = "ColorWheel"
ColorWheelBtn.Size = UDim2.new(0, 110, 0, 110)
ColorWheelBtn.Position = UDim2.new(0, 10, 0, 12)
ColorWheelBtn.BackgroundTransparency = 1
ColorWheelBtn.Image = "rbxassetid://6980520070"
ColorWheelBtn.Parent = PageColorSettings

local WheelCorner = Instance.new("UICorner")
WheelCorner.CornerRadius = UDim.new(1, 0)
WheelCorner.Parent = ColorWheelBtn

local isPickingColor = false
local function updateColorFromWheel(inputPosition)
    local wheelCenter = ColorWheelBtn.AbsolutePosition + (ColorWheelBtn.AbsoluteSize / 2)
    local delta = inputPosition - wheelCenter
    local radius = ColorWheelBtn.AbsoluteSize.X / 2
    local distance = delta.Magnitude

    if distance <= radius or isPickingColor then
        local angle = math.atan2(delta.Y, delta.X)
        local hue = (angle + math.pi) / (math.pi * 2)
        local saturation = math.clamp(distance / radius, 0, 1)
        local selectedColor = Color3.fromHSV(hue, saturation, 1)
        
        MainStroke.Color = selectedColor
        MainFrame.BackgroundColor3 = selectedColor
    end
end

ColorWheelBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isPickingColor = true
        updateColorFromWheel(Vector2.new(input.Position.X, input.Position.Y))
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isPickingColor and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateColorFromWheel(Vector2.new(input.Position.X, input.Position.Y))
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isPickingColor = false
    end
end)

local PageBots = Instance.new("Frame")
PageBots.Name = "PageBots"
PageBots.Size = UDim2.new(1, 0, 1, 0)
PageBots.BackgroundTransparency = 1
PageBots.Visible = false
PageBots.Parent = ContentFrame

local PageBotsList = Instance.new("UIListLayout")
PageBotsList.SortOrder = Enum.SortOrder.LayoutOrder
PageBotsList.Padding = UDim.new(0, 12)
PageBotsList.Parent = PageBots

local PageBotsPadding = Instance.new("UIPadding")
PageBotsPadding.PaddingLeft, PageBotsPadding.PaddingRight, PageBotsPadding.PaddingTop = UDim.new(0, 5), UDim.new(0, 18), UDim.new(0, 8)
PageBotsPadding.Parent = PageBots

pagesList["Tab1"] = PagePlayers
pagesList["Tab2"] = PageGuiTab
pagesList["Tab3"] = PageBots

local function createToggle(parent, text, layoutOrder)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 34)
    Frame.BackgroundTransparency = 1
    Frame.LayoutOrder = layoutOrder
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 16
    Label.Font = Enum.Font.SourceSansBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SwitchBG = Instance.new("TextButton")
    SwitchBG.Size = UDim2.new(0, 50, 0, 24)
    SwitchBG.Position = UDim2.new(1, -50, 0.5, -12)
    SwitchBG.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SwitchBG.BackgroundTransparency = 0.3
    SwitchBG.Text = ""
    SwitchBG.Parent = Frame

    Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = UDim2.new(0, 3, 0.5, -9)
    Circle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Circle.BorderSizePixel = 0
    Circle.Parent = SwitchBG

    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local function setStatus(state)
        local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(80, 80, 80)
        local targetTransparency = state and 0 or 0.3
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(SwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = targetColor, BackgroundTransparency = targetTransparency}):Play()
    end

    return SwitchBG, setStatus
end

local ToggleHideBtn, setHideStatus = createToggle(PagePlayers, "Скрыть игроков", 1)
local ToggleExceptBtn, setExceptStatus = createToggle(PagePlayers, "Исключения", 2)
local ToggleTimerBtn, setTimerStatus = createToggle(PageGuiTab, "Таймер раунда", 1)
local ToggleBotsEspBtn, setBotsEspStatus = createToggle(PageBots, "ESP на Ботов", 1)

local DropdownFrame = Instance.new("Frame")
DropdownFrame.Name = "DropdownFrame"
DropdownFrame.Size = UDim2.new(1, -145, 0, 0)
DropdownFrame.Position = UDim2.new(0, 135, 0, 165) 
DropdownFrame.BackgroundTransparency = 1
DropdownFrame.ClipsDescendants = true
DropdownFrame.Parent = MainFrame

local DropdownBG = Instance.new("ScrollingFrame")
DropdownBG.Size = UDim2.new(1, 0, 0, 120)
DropdownBG.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
DropdownBG.BackgroundTransparency = 0.4
DropdownBG.BorderSizePixel = 0
DropdownBG.ScrollBarThickness = 5
DropdownBG.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownBG.Parent = DropdownFrame

Instance.new("UICorner", DropdownBG).CornerRadius = UDim.new(0, 6)

local DropdownList = Instance.new("UIListLayout")
DropdownList.SortOrder = Enum.SortOrder.Name
DropdownList.Parent = DropdownBG
local function clearBotHighlights()
    for model, hl in pairs(activeBotHighlights) do
        if hl then hl:Destroy() end
    end
    table.clear(activeBotHighlights)
end

local function applyHighlightToBot(bot)
    if not activeBotHighlights[bot] then
        local hl = Instance.new("Highlight")
        hl.Name = "BotMenuESP"
        hl.FillColor = Color3.fromRGB(100, 100, 100)
        hl.FillTransparency = 0.6
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.Adornee = bot
        hl.Parent = ScreenGui
        activeBotHighlights[bot] = hl
    end
end

local function scanBotsFast()
    if not botsEspEnabled then 
        clearBotHighlights()
        return 
    end

    local gameFolder = workspace:FindFirstChild("Game")
    local foldersToSearch = {}
    
    if gameFolder then
        local b1 = gameFolder:FindFirstChild("Bots")
        if b1 then table.insert(foldersToSearch, b1) end
    end
    local b2 = workspace:FindFirstChild("Bots")
    if b2 then table.insert(foldersToSearch, b2) end
    
    for _, folder in ipairs(foldersToSearch) do
        for _, bot in ipairs(folder:GetChildren()) do
            if bot:IsA("Model") then
                applyHighlightToBot(bot)
            end
        end
    end

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
            if string.find(obj.Name, "Bot") or obj.Name == "Mimic" or obj.Name == "Trash Man" or obj:FindFirstChild("Mimic") then
                applyHighlightToBot(obj)
            end
        end
    end

    for bot, hl in pairs(activeBotHighlights) do
        if not bot or not bot.Parent or not bot:IsDescendantOf(workspace) then
            if hl then hl:Destroy() end
            activeBotHighlights[bot] = nil
        end
    end
end

local function refreshPlayerList()
    for _, child in ipairs(DropdownBG:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local count = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            count = count + 1
            local PBtn = Instance.new("TextButton")
            PBtn.Size = UDim2.new(1, 0, 0, 28)
            PBtn.BackgroundTransparency = 1
            PBtn.Text = "  " .. player.DisplayName .. " (@" .. player.Name .. ")"
            PBtn.TextColor3 = excludedPlayers[player.Name] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 255, 255)
            PBtn.TextSize = 14
            PBtn.Font = Enum.Font.SourceSansBold
            PBtn.TextXAlignment = Enum.TextXAlignment.Left
            PBtn.Parent = DropdownBG
            
            PBtn.MouseButton1Click:Connect(function()
                excludedPlayers[player.Name] = not excludedPlayers[player.Name]
                PBtn.TextColor3 = excludedPlayers[player.Name] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 255, 255)
                updateVisibility()
            end)
        end
    end
    DropdownBG.CanvasSize = UDim2.new(0, 0, 0, count * 28)
end

local function toggleDropdown(show)
    local targetHeight = show and 120 or 0
    local targetMainHeight = show and 300 or 180
    if show then refreshPlayerList() end
    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -145, 0, targetHeight)}):Play()
    if not menuCollapsed then
        TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 420, 0, targetMainHeight)}):Play()
    end
end

local function selectTab(activeBtn, pageKey)
    for _, btn in ipairs(tabsList) do
        if btn == activeBtn then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
    end
    
    for key, page in pairs(pagesList) do
        if key == pageKey then
            page.Visible = true
        else
            page.Visible = false
        end
    end

    if not menuCollapsed then
        if pageKey == "Tab1" and exceptionsEnabled then
            toggleDropdown(true)
        else
            toggleDropdown(false)
        end
    end
end

local Tab1 = createTabButton("Игроки", 1)
local Tab2 = createTabButton("Gui", 2)
local Tab3 = createTabButton("Боты", 3)

selectTab(Tab1, "Tab1")

Tab1.MouseButton1Click:Connect(function() selectTab(Tab1, "Tab1") end)
Tab2.MouseButton1Click:Connect(function() selectTab(Tab2, "Tab2") end)
Tab3.MouseButton1Click:Connect(function() selectTab(Tab3, "Tab3") end)

ToggleHideBtn.MouseButton1Click:Connect(function()
    playersHidden = not playersHidden
    setHideStatus(playersHidden)
    updateVisibility()
end)

ToggleTimerBtn.MouseButton1Click:Connect(function()
    timerEnabled = not timerEnabled
    setTimerStatus(timerEnabled)
end)

ToggleBotsEspBtn.MouseButton1Click:Connect(function()
    botsEspEnabled = not botsEspEnabled
    setBotsEspStatus(botsEspEnabled)
    scanBotsFast()
end)

local npcTags = {"Bot", "NPC", "Nextbot", "Enemy"}
for _, tag in ipairs(npcTags) do
    CollectionService:GetInstanceAddedSignal(tag):Connect(function(obj)
        if botsEspEnabled and obj:IsA("Model") then
            applyHighlightToBot(obj)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if playersHidden then
            updateVisibility()
        end
        if botsEspEnabled then
            scanBotsFast()
        end
    end
end)

ToggleExceptBtn.MouseButton1Click:Connect(function()
    exceptionsEnabled = not exceptionsEnabled
    setExceptStatus(exceptionsEnabled)
    toggleDropdown(exceptionsEnabled)
    updateVisibility()
end)

ToggleMenuBtn.MouseButton1Click:Connect(function()
    menuCollapsed = not menuCollapsed
    local currentTarget = exceptionsEnabled and PagePlayers.Visible and 300 or 180
    local targetHeight = menuCollapsed and 40 or currentTarget
    ToggleMenuBtn.Text = menuCollapsed and "+" or "-"
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 420, 0, targetHeight)}):Play()
    ContentFrame.Visible = not menuCollapsed
    SidebarFrame.Visible = not menuCollapsed
    if DropdownFrame then 
        DropdownFrame.Visible = not menuCollapsed and exceptionsEnabled and PagePlayers.Visible 
    end
end)

CloseMenuBtn.MouseButton1Click:Connect(function()
    playersHidden = false
    timerEnabled = false
    botsEspEnabled = false
    updateVisibility()
    clearBotHighlights()
    ContentFrame.Visible = false
    SidebarFrame.Visible = false
    local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 420, 0, 0)})
    closeTween:Play()
    closeTween.Completed:Connect(function()
        if HiddenStorage then
            HiddenStorage:Destroy()
        end
        ScreenGui:Destroy()
    end)
end)

local dragging, dragInput, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
