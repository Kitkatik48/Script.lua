local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Безопасное ожидание полной загрузки игры
if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(0.5)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Файл для сохранения настроек автозапуска
local CONFIG_FILE = "player_menu_config.json"
local config = {AutoExec = false}

-- Загрузка сохраненных настроек
pcall(function()
    if readfile and isfile and isfile(CONFIG_FILE) then
        config = HttpService:JSONDecode(readfile(CONFIG_FILE))
    end
end)

-- ГЛАВНАЯ ПРОВЕРКА: Если скрипт в autoexec, но авто-инжект был выключен в меню — скрипт полностью завершает работу
if not config.AutoExec and script and script.Parent == nil then
    -- Этот блок сработает только при автоматическом запуске инжектором из autoexec
    return
end

-- Безопасное создание скрытой папки
local HiddenStorage
pcall(function()
    HiddenStorage = game:GetService("ReplicatedStorage"):FindFirstChild("HiddenPlayersStorage")
    if not HiddenStorage then
        HiddenStorage = Instance.new("Folder")
        HiddenStorage.Name = "HiddenPlayersStorage"
        HiddenStorage.Parent = game:GetService("ReplicatedStorage")
    end
end)

-- Переменные состояний
local menuCollapsed = false
local playersHidden = false
local exceptionsEnabled = false
local hiddenConnections = {}
local excludedPlayers = {}

-- Функции перемещения персонажей
local function hideCharacter(character)
    if character and character:IsDescendantOf(workspace) and HiddenStorage then
        character.Parent = HiddenStorage
    end
end

local function restoreCharacter(character)
    if character and HiddenStorage and character:IsDescendantOf(HiddenStorage) then
        character.Parent = workspace
    end
end

-- Обновление видимости игроков на карте
local function updateVisibility()
    if not HiddenStorage then return end
    
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
-- Удаление дубликатов интерфейса
if PlayerGui:FindFirstChild("ScriptMenuGui") then
    PlayerGui.ScriptMenuGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Главное окно: Компактное и Прозрачно-серое
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 160)
MainFrame.Position = UDim2.new(0, 20, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.65 
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Выделенная прозрачно-серая обводка
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(80, 80, 80)
MainStroke.Transparency = 0.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Заголовок: Белый текст
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "PLAYER MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Кнопка Свернуть (Всегда остаётся со знаком "-")
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 25, 0, 25)
ToggleMenuBtn.Position = UDim2.new(1, -60, 0, 5)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleMenuBtn.BackgroundTransparency = 0.65
ToggleMenuBtn.Text = "-"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.TextSize = 18
ToggleMenuBtn.Font = Enum.Font.SourceSansBold
ToggleMenuBtn.Parent = MainFrame

Instance.new("UICorner", ToggleMenuBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ToggleMenuBtn).Color = Color3.fromRGB(80, 80, 80)

-- Кнопка Закрыть
local CloseMenuBtn = Instance.new("TextButton")
CloseMenuBtn.Size = UDim2.new(0, 25, 0, 25)
CloseMenuBtn.Position = UDim2.new(1, -30, 0, 5)
CloseMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseMenuBtn.BackgroundTransparency = 0.65
CloseMenuBtn.Text = "X"
CloseMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseMenuBtn.TextSize = 14
CloseMenuBtn.Font = Enum.Font.SourceSansBold
CloseMenuBtn.Parent = MainFrame

Instance.new("UICorner", CloseMenuBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", CloseMenuBtn).Color = Color3.fromRGB(80, 80, 80)

-- Контейнер для функций
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -35)
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Одинаковое расстояние между кнопками
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ContentFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft, UIPadding.PaddingRight, UIPadding.PaddingTop = UDim.new(0, 15), UDim.new(0, 15), UDim.new(0, 5)
UIPadding.Parent = ContentFrame

-- Шаблон генерации функций (Свитчей) с белым текстом
local function createToggle(parent, text, layoutOrder)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundTransparency = 1
    Frame.LayoutOrder = layoutOrder
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -55, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 15
    Label.Font = Enum.Font.SourceSansBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SwitchBG = Instance.new("TextButton")
    SwitchBG.Size = UDim2.new(0, 45, 0, 22)
    SwitchBG.Position = UDim2.new(1, -45, 0.5, -11)
    SwitchBG.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SwitchBG.BackgroundTransparency = 0.3
    SwitchBG.Text = ""
    SwitchBG.Parent = Frame

    Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 3, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Parent = SwitchBG

    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local function setStatus(state)
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetColor = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(80, 80, 80)
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(SwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
    end

    return SwitchBG, setStatus
end

local ToggleHideBtn, setHideStatus = createToggle(ContentFrame, "Скрыть игроков", 1)
local ToggleExceptBtn, setExceptStatus = createToggle(ContentFrame, "Исключения", 2)
local ToggleAutoBtn, setAutoStatus = createToggle(ContentFrame, "Авто-инжект", 3)

-- Фрейм списка вынесен ИЗ контент-фрейма, чтобы не ломать отступы между кнопками
local DropdownFrame = Instance.new("Frame")
DropdownFrame.Name = "DropdownFrame"
DropdownFrame.Size = UDim2.new(1, -30, 0, 0)
DropdownFrame.Position = UDim2.new(0, 15, 0, 160)
DropdownFrame.BackgroundTransparency = 1
DropdownFrame.ClipsDescendants = true
DropdownFrame.Parent = MainFrame

local DropdownBG = Instance.new("ScrollingFrame")
DropdownBG.Size = UDim2.new(1, 0, 0, 100)
DropdownBG.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
DropdownBG.BackgroundTransparency = 0.4
DropdownBG.BorderSizePixel = 0
DropdownBG.ScrollBarThickness = 4
DropdownBG.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownBG.Parent = DropdownFrame

Instance.new("UICorner", DropdownBG).CornerRadius = UDim.new(0, 6)

local DropdownList = Instance.new("UIListLayout")
DropdownList.SortOrder = Enum.SortOrder.Name
DropdownList.Parent = DropdownBG
-- Работа функций глобального скрытия
local function enableHiding()
    playersHidden = true
    updateVisibility()
    
    local c1 = Players.PlayerAdded:Connect(function(player)
        local c2 = player.CharacterAdded:Connect(function(char)
            task.wait(0.05)
            if playersHidden then
                if exceptionsEnabled and excludedPlayers[player.Name] then return end
                hideCharacter(char)
            end
        end)
        table.insert(hiddenConnections, c2)
    end)
    table.insert(hiddenConnections, c1)
end

local function disableHiding()
    playersHidden = false
    for _, conn in ipairs(hiddenConnections) do
        if conn then conn:Disconnect() end
    end
    table.clear(hiddenConnections)
    updateVisibility()
end

ToggleHideBtn.MouseButton1Click:Connect(function()
    playersHidden = not playersHidden
    setHideStatus(playersHidden)
    if playersHidden then enableHiding() else disableHiding() end
end)

-- Обновление белых никнеймов игроков в ScrollingFrame
local function refreshPlayerList()
    for _, child in ipairs(DropdownBG:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local count = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            count = count + 1
            local PBtn = Instance.new("TextButton")
            PBtn.Size = UDim2.new(1, 0, 0, 25)
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
    DropdownBG.CanvasSize = UDim2.new(0, 0, 0, count * 25)
end

-- Анимация раскрытия списка под кнопками
local function toggleDropdown(show)
    local targetHeight = show and 100 or 0
    local targetMainHeight = show and 275 or 160
    
    if show then refreshPlayerList() end
    
    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -30, 0, targetHeight)}):Play()
    if not menuCollapsed then
        TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 240, 0, targetMainHeight)}):Play()
    end
end

ToggleExceptBtn.MouseButton1Click:Connect(function()
    exceptionsEnabled = not exceptionsEnabled
    setExceptStatus(exceptionsEnabled)
    toggleDropdown(exceptionsEnabled)
    updateVisibility()
end)

-- Схлопывание списка при нажатии мимо меню
UserInputService.InputBegan:Connect(function(input, processed)
    if exceptionsEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = input.Position
        local guiObjects = PlayerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
        
        local clickedInsideMenu = false
        for _, obj in ipairs(guiObjects) do
            if obj:IsDescendantOf(MainFrame) or obj == MainFrame then
                clickedInsideMenu = true
                break
            end
        end
        
        if not clickedInsideMenu then
            exceptionsEnabled = false
            setExceptStatus(false)
            toggleDropdown(false)
        end
    end
end)

-- Инициализация отображения кнопки авто-инжекта
if config.AutoExec then setAutoStatus(true) end

ToggleAutoBtn.MouseButton1Click:Connect(function()
    config.AutoExec = not config.AutoExec
    setAutoStatus(config.AutoExec)
    if writefile then
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode(config))
        end)
    end
end)

-- Логика кнопки Свернуть (-)
ToggleMenuBtn.MouseButton1Click:Connect(function()
    menuCollapsed = not menuCollapsed
    local currentTarget = exceptionsEnabled and 275 or 160
    local targetHeight = menuCollapsed and 35 or currentTarget
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 240, 0, targetHeight)}):Play()
    ContentFrame.Visible = not menuCollapsed
    if DropdownFrame then DropdownFrame.Visible = not menuCollapsed and exceptionsEnabled end
end)

-- Логика кнопки Закрыть (X)
CloseMenuBtn.MouseButton1Click:Connect(function()
    disableHiding()
    ScreenGui:Destroy()
end)

-- Система перетаскивания (Dragging) за любое место панели
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
