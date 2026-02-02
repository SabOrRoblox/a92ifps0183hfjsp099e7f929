local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DeltaHUD = {}
DeltaHUD.__index = DeltaHUD

getgenv().DeltaHUD = DeltaHUD

local PERF_MODE_THRESHOLD = 30
local PERF_MODE_HYSTERESIS = 4

function DeltaHUD.new()
    if getgenv()._DeltaHUDInstance then
        getgenv()._DeltaHUDInstance:Destroy()
    end
    
    local self = setmetatable({}, DeltaHUD)
    
    self.player = Players.LocalPlayer
    self.showHUD = true
    self.lastUpdate = 0
    self.updateInterval = 0.3
    self.fps = 0
    self.fpsCounter = 0
    self.fpsTime = 0
    self.startTime = os.clock()
    self.showGameTime = false
    self.connections = {}
    
    self._performanceMode = false
    self._lowFpsCount = 0
    self._lastPerfCheck = 0
    
    self.settings = {
        ESP = true,
        KillAura = false,
        ShowInfo = true
    }
    
    self.highlighterSettings = {
        Enabled = true,
        OutlineColor = Color3.fromRGB(85, 170, 255),
        OutlineTransparency = 0,
        OutlineThickness = 1.5,
        NameTagColor = Color3.fromRGB(255, 100, 100),
        DistanceColor = Color3.fromRGB(100, 150, 255),
        HealthColor = Color3.fromRGB(100, 255, 100),
        NameTagSize = 12,
        NameTagFont = Enum.Font.GothamMedium,
        NameTagOffset = Vector3.new(0, 9.5, 0),
        TeamColor = false,
        MaxDistance = 10000
    }
    
    self.highlightCache = {}
    self.highlighterConnections = {}
    self._highlightUpdateIndex = 1
    
    getgenv()._DeltaHUDInstance = self
    
    self:Initialize()
    self:InitializeControls()
    self:InitializeHighlighter()
    self:InitializeKillAura()
    
    return self
end

function DeltaHUD:InitializeControls()
    if self.player.PlayerGui:FindFirstChild("DeltaControls") then
        self.player.PlayerGui.DeltaControls:Destroy()
    end
    
    self.controlsGui = Instance.new("ScreenGui")
    self.controlsGui.Name = "DeltaControls"
    self.controlsGui.DisplayOrder = 1000
    self.controlsGui.ResetOnSpawn = false
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 160, 0, 150)
    main.Position = UDim2.new(0.02, 0, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
    })
    gradient.Rotation = 45
    gradient.Parent = main
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 120, 200)
    stroke.Transparency = 0.3
    stroke.Thickness = 1.5
    stroke.Parent = main
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceScale = 0.05
    shadow.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "DELTA HUD"
    title.TextColor3 = Color3.fromRGB(180, 180, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = main
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(200, 100, 100)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 2
    closeBtn.Parent = title
    
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(1, -20, 1, -40)
    controls.Position = UDim2.new(0, 10, 0, 35)
    controls.BackgroundTransparency = 1
    controls.Parent = main
    
    local buttonHeight = 30
    local buttonSpacing = 5
    
    local function createToggle(name, text, yPos)
        local btn = Instance.new("Frame")
        btn.Name = name
        btn.Size = UDim2.new(1, 0, 0, buttonHeight)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.BackgroundTransparency = 1
        btn.Parent = controls
        
        local btnBtn = Instance.new("TextButton")
        btnBtn.Name = "Button"
        btnBtn.Size = UDim2.new(1, 0, 1, 0)
        btnBtn.Position = UDim2.new(0, 0, 0, 0)
        btnBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btnBtn.BackgroundTransparency = 0.3
        btnBtn.Text = ""
        btnBtn.AutoButtonColor = false
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btnBtn
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(80, 120, 200)
        btnStroke.Transparency = 0.5
        btnStroke.Thickness = 1
        btnStroke.Parent = btnBtn
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(220, 220, 240)
        label.TextSize = 13
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btnBtn
        
        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = UDim2.new(1, -30, 0.5, -8)
        indicator.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        indicator.Parent = btnBtn
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = indicator
        
        btnBtn.MouseEnter:Connect(function()
            TweenService:Create(btnBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        end)
        
        btnBtn.MouseLeave:Connect(function()
            TweenService:Create(btnBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
        end)
        
        btnBtn.Parent = btn
        return {button = btnBtn, indicator = indicator}
    end
    
    self.toggles = {
        ESP = createToggle("ESPToggle", "ESP Players", 0),
        KillAura = createToggle("KillAuraToggle", "Kill Aura", buttonHeight + buttonSpacing),
        ShowInfo = createToggle("ShowInfoToggle", "Show Info", (buttonHeight + buttonSpacing) * 2)
    }
    
    self.toggles.ESP.button.MouseButton1Click:Connect(function()
        self.settings.ESP = not self.settings.ESP
        self:toggleHighlighter()
        local color = self.settings.ESP and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(150, 50, 50)
        TweenService:Create(self.toggles.ESP.indicator, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    self.toggles.KillAura.button.MouseButton1Click:Connect(function()
        self.settings.KillAura = not self.settings.KillAura
        local color = self.settings.KillAura and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(150, 50, 50)
        TweenService:Create(self.toggles.KillAura.indicator, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    self.toggles.ShowInfo.button.MouseButton1Click:Connect(function()
        self.settings.ShowInfo = not self.settings.ShowInfo
        self.showHUD = self.settings.ShowInfo
        self.screenGui.Enabled = self.showHUD
        local color = self.settings.ShowInfo and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(150, 50, 50)
        TweenService:Create(self.toggles.ShowInfo.indicator, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self.controlsGui.Enabled = not self.controlsGui.Enabled
    end)
    
    local dragToggle
    local dragStart
    local startPos
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    main.Parent = self.controlsGui
    self.controlsGui.Parent = self.player:WaitForChild("PlayerGui")
end

function DeltaHUD:InitializeHighlighter()
    for _,data in pairs(self.highlightCache) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    
    self.highlightCache = {}
    
    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= self.player then
            self:onPlayerAdded(player)
        end
    end
    
    table.insert(self.highlighterConnections, Players.PlayerAdded:Connect(function(player)
        self:onPlayerAdded(player)
    end))
    
    table.insert(self.highlighterConnections, Players.PlayerRemoving:Connect(function(player)
        self:onPlayerRemoving(player)
    end))
    
    RunService.Heartbeat:Connect(function(dt)
        if not self.highlighterSettings.Enabled then return end
        if not next(self.highlightCache) then return end
        
        local playerChar = self.player.Character
        if not playerChar then return end
        
        local playerRoot = playerChar.PrimaryPart
        if not playerRoot then return end
        
        local playerPos = playerRoot.Position
        local cacheKeys = {}
        local idx = 0
        
        for player in pairs(self.highlightCache) do
            idx = idx + 1
            cacheKeys[idx] = player
        end
        
        local updateCount = 0
        local maxPerFrame = self._performanceMode and 1 or 2
        
        for i = self._highlightUpdateIndex, math.min(self._highlightUpdateIndex + maxPerFrame - 1, #cacheKeys) do
            local player = cacheKeys[i]
            local data = self.highlightCache[player]
            if data and self:_fastUpdate(data, playerPos) then
                updateCount = updateCount + 1
            end
        end
        
        self._highlightUpdateIndex = self._highlightUpdateIndex + maxPerFrame
        if self._highlightUpdateIndex > #cacheKeys then
            self._highlightUpdateIndex = 1
        end
    end)
end

function DeltaHUD:_fastUpdate(data, playerPos)
    if not data.Model then return false end
    local model = data.Model
    local primary = model.PrimaryPart
    if not primary or not primary.Parent then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        return false
    end
    
    local distance = (playerPos - primary.Position).Magnitude
    
    if distance > self.highlighterSettings.MaxDistance then
        if data.Highlight then data.Highlight.Enabled = false end
        if data.Billboard then data.Billboard.Enabled = false end
        return true
    end
    
    if self.highlighterSettings.Enabled then
        if data.Highlight then
            data.Highlight.Enabled = true
            if self.highlighterSettings.TeamColor and data.Player.Team then
                data.Highlight.OutlineColor = data.Player.Team.TeamColor.Color
            end
        end
        if data.Billboard and data.Billboard.NameText then
            data.Billboard.Enabled = true
            
            local health = "N/A"
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid then
                health = math.floor(humanoid.Health)
            end
            
            local nameText = data.Player.Name
            local distanceText = "[" .. math.floor(distance) .. "]"
            local healthText = health .. " HP"
            
            data.Billboard.NameText.Text = string.format(
                '<font color="rgb(%d,%d,%d)">%s</font> '..
                '<font color="rgb(%d,%d,%d)">%s</font>\n'..
                '<font color="rgb(%d,%d,%d)">%s</font>',
                255, 100, 100, nameText,
                100, 150, 255, distanceText,
                100, 255, 100, healthText
            )
        end
    end
    
    return true
end

function DeltaHUD:createHighlight(model, player)
    if not model or not model:IsA("Model") then return nil end
    
    local highlight = Instance.new("BoxHandleAdornment")
    highlight.Name = "PlayerESP"
    highlight.Adornee = model.PrimaryPart or model:WaitForChild("HumanoidRootPart", 2) or model
    highlight.Size = Vector3.new(4, 6, 4)
    highlight.Transparency = 0.7
    highlight.Color3 = self.highlighterSettings.OutlineColor
    highlight.AlwaysOnTop = true
    highlight.ZIndex = 1
    highlight.Enabled = self.highlighterSettings.Enabled
    
    if self.highlighterSettings.TeamColor and player.Team then
        highlight.Color3 = player.Team.TeamColor.Color
    end
    
    highlight.Parent = model
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerInfo"
    billboard.Adornee = highlight.Adornee
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = self.highlighterSettings.NameTagOffset
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = self.highlighterSettings.MaxDistance
    billboard.Enabled = self.highlighterSettings.Enabled
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "NameText"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = self.highlighterSettings.NameTagSize
    textLabel.Font = self.highlighterSettings.NameTagFont
    textLabel.RichText = true
    textLabel.TextStrokeTransparency = 0.7
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Text = player.Name
    textLabel.Parent = billboard
    billboard.Parent = model
    
    return {
        Highlight = highlight,
        Billboard = billboard,
        Player = player,
        Model = model
    }
end

function DeltaHUD:onPlayerAdded(player)
    if player == self.player then return end
    
    local function characterAdded(character)
        if not character then return end
        task.wait(1)
        if character and character:IsA("Model") then
            if self.highlightCache[player] then
                local old = self.highlightCache[player]
                if old.Highlight then old.Highlight:Destroy() end
                if old.Billboard then old.Billboard:Destroy() end
            end
            local data = self:createHighlight(character, player)
            if data then self.highlightCache[player] = data end
        end
    end
    
    local conn = player.CharacterAdded:Connect(characterAdded)
    table.insert(self.highlighterConnections, conn)
    
    if player.Character then characterAdded(player.Character) end
    
    local remConn = player.AncestryChanged:Connect(function(_,parent)
        if not parent then
            local data = self.highlightCache[player]
            if data then
                if data.Highlight then data.Highlight:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
                self.highlightCache[player] = nil
            end
        end
    end)
    table.insert(self.highlighterConnections, remConn)
end

function DeltaHUD:onPlayerRemoving(player)
    local data = self.highlightCache[player]
    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        self.highlightCache[player] = nil
    end
end

function DeltaHUD:Initialize()
    local gui = self.player.PlayerGui:FindFirstChild("DeltaHUD")
    if gui then gui:Destroy() end
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "DeltaHUD"
    self.screenGui.DisplayOrder = 999
    self.screenGui.IgnoreGuiInset = true
    self.screenGui.ResetOnSpawn = false
    
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 300, 0, 40)
    self.mainFrame.Position = UDim2.new(0.5, -150, 0, 10)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    self.mainFrame.BackgroundTransparency = 0.15
    self.mainFrame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 140, 220)
    stroke.Transparency = 0.4
    stroke.Thickness = 1.2
    stroke.Parent = self.mainFrame
    
    self.sections = {}
    local width = 100
    
    for i=1,3 do
        local section = Instance.new("Frame")
        section.Name = "Section"..i
        section.Size = UDim2.new(0, width, 1, 0)
        section.Position = UDim2.new(0, (i-1)*width, 0, 0)
        section.BackgroundTransparency = 1
        section.BorderSizePixel = 0
        section.Parent = self.mainFrame
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1,0,0,16)
        title.Position = UDim2.new(0,0,0,4)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(180,200,255)
        title.TextSize = 11
        title.Font = Enum.Font.GothamMedium
        title.Text = i==1 and "FPS" or (i==2 and "PING" or "INFO")
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.Parent = section
        
        local value = Instance.new("TextLabel")
        value.Name = "Value"
        value.Size = UDim2.new(1,0,0,18)
        value.Position = UDim2.new(0,0,0,18)
        value.BackgroundTransparency = 1
        value.TextColor3 = i==1 and Color3.fromRGB(100,255,150) or (i==2 and Color3.fromRGB(100,180,255) or Color3.fromRGB(200,150,255))
        value.TextSize = 13
        value.Font = Enum.Font.GothamBold
        value.Text = i==1 and "0" or (i==2 and "0ms" or "CV:0")
        value.TextXAlignment = Enum.TextXAlignment.Center
        value.Parent = section
        
        if i==3 then
            local btn = Instance.new("TextButton")
            btn.Name = "ToggleButton"
            btn.Size = UDim2.new(1,0,1,0)
            btn.Position = UDim2.new(0,0,0,0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = section
            
            table.insert(self.connections, btn.MouseButton1Click:Connect(function()
                self.showGameTime = not self.showGameTime
                self:UpdateInfo()
            end))
        end
        
        if i<3 then
            local div = Instance.new("Frame")
            div.Name = "Divider"
            div.Size = UDim2.new(0,1,0,20)
            div.Position = UDim2.new(1,-1,0.5,-10)
            div.BackgroundColor3 = Color3.fromRGB(100,150,220)
            div.BackgroundTransparency = 0.7
            div.BorderSizePixel = 0
            div.Parent = section
        end
        
        self.sections[i] = {frame=section, title=title, value=value}
    end
    
    self.mainFrame.Parent = self.screenGui
    self.screenGui.Parent = self.player:WaitForChild("PlayerGui")
    
    self:SetupConnections()
end

function DeltaHUD:_checkPerformanceMode()
    local now = os.clock()
    if now - self._lastPerfCheck < 0.5 then return end
    self._lastPerfCheck = now
    
    if self.fps < PERF_MODE_THRESHOLD then
        self._lowFpsCount = self._lowFpsCount + 1
        if self._lowFpsCount >= PERF_MODE_HYSTERESIS then
            if not self._performanceMode then
                self._performanceMode = true
                self.updateInterval = 0.5
                self.highlighterSettings.MaxDistance = 500
            end
        end
    else
        self._lowFpsCount = math.max(0, self._lowFpsCount - 1)
        if self._performanceMode and self._lowFpsCount == 0 then
            self._performanceMode = false
            self.updateInterval = 0.3
            self.highlighterSettings.MaxDistance = 10000
        end
    end
end

function DeltaHUD:SetupConnections()
    table.insert(self.connections, RunService.RenderStepped:Connect(function(dt)
        self:UpdateFPS(dt)
        self:_checkPerformanceMode()
        self.lastUpdate = self.lastUpdate + dt
        if self.lastUpdate >= self.updateInterval then
            self:UpdatePing()
            self:UpdateInfo()
            self.lastUpdate = 0
        end
    end))
    
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input,proc)
        if not proc and input.KeyCode == Enum.KeyCode.F5 then
            self.controlsGui.Enabled = not self.controlsGui.Enabled
        end
    end))
end

function DeltaHUD:UpdateFPS(dt)
    self.fpsTime = self.fpsTime + dt
    self.fpsCounter = self.fpsCounter + 1
    if self.fpsTime >= 0.5 then
        self.fps = math.floor(self.fpsCounter / self.fpsTime)
        self.fpsCounter = 0
        self.fpsTime = 0
        self.sections[1].value.Text = tostring(self.fps)
    end
end

function DeltaHUD:UpdatePing()
    local ok, ping = pcall(function()
        return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    self.sections[2].value.Text = (ok and ping or -1) .. "ms"
end

function DeltaHUD:UpdateInfo()
    if self.showGameTime then
        local elapsed = os.clock() - self.startTime
        local min = math.floor(elapsed/60)
        local sec = math.floor(elapsed%60)
        self.sections[3].value.Text = string.format("%02d:%02d", min, sec)
    else
        local cam = workspace.CurrentCamera
        if cam then
            local look = cam.CFrame.LookVector
            local pitch = math.deg(math.asin(-look.Y))
            local yaw = math.deg(math.atan2(-look.X, -look.Z))
            self.sections[3].value.Text = string.format("%.0f°,%.0f°", yaw%360, pitch)
        else
            self.sections[3].value.Text = "CV:N/A"
        end
    end
end

function DeltaHUD:_getCachedRemotes()
    if self._remotesCache then return self._remotesCache end
    
    local remotes = {}
    local ok, netModule = pcall(function()
        return require(ReplicatedStorage.Modules.Net)
    end)
    
    if ok and netModule then
        if netModule.RemoteEvent then
            remotes.RegisterAttack = netModule:RemoteEvent("RegisterAttack")
            remotes.RegisterHit = netModule:RemoteEvent("RegisterHit", true)
        elseif netModule.RE then
            remotes.RegisterAttack = netModule.RE:WaitForChild("RegisterAttack")
            remotes.RegisterHit = netModule.RE:WaitForChild("RegisterHit")
        end
    end
    
    if not remotes.RegisterAttack then
        local netFolder = ReplicatedStorage:FindFirstChild("Modules")
        if netFolder and netFolder:FindFirstChild("Net") then
            local net = netFolder.Net
            if net:FindFirstChild("RE") then
                remotes.RegisterAttack = net.RE:WaitForChild("RegisterAttack")
                remotes.RegisterHit = net.RE:WaitForChild("RegisterHit")
            elseif net:FindFirstChild("RemoteEvent") then
                remotes.RegisterAttack = net.RemoteEvent:WaitForChild("RegisterAttack")
                remotes.RegisterHit = net.RemoteEvent:WaitForChild("RegisterHit")
            end
        end
    end
    
    if not remotes.RegisterAttack then
        remotes.RegisterAttack = ReplicatedStorage:FindFirstChild("RegisterAttack",true)
        remotes.RegisterHit = ReplicatedStorage:FindFirstChild("RegisterHit",true)
    end
    
    self._remotesCache = remotes
    return remotes
end

function DeltaHUD:InitializeKillAura()
    local remotes = self:_getCachedRemotes()
    if not remotes.RegisterAttack then return end
    
    local lastAttack = 0
    local attackDelay = 0.2
    
    task.spawn(function()
        while task.wait(0.3) do
            if self.player.Character then
                local stun = self.player.Character:FindFirstChild("Stun")
                if stun then stun.Value = 0 end
                local busy = self.player.Character:FindFirstChild("Busy")
                if busy then busy.Value = false end
            end
        end
    end)
    
    task.spawn(function()
        while task.wait(0.05) do
            if not self.settings.KillAura then continue end
            if self.player.Character and self.player.Character:FindFirstChild("HumanoidRootPart") then
                local pos = self.player.Character.HumanoidRootPart.Position
                local enemies = Workspace.Enemies:GetChildren()
                
                if #enemies == 0 then continue end
                
                local closest = nil
                local closestDist = 50
                
                for _,enemy in ipairs(enemies) do
                    if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChildOfClass("Humanoid") then
                        local dist = (enemy.HumanoidRootPart.Position - pos).Magnitude
                        if dist <= closestDist and enemy:FindFirstChildOfClass("Humanoid").Health > 0 then
                            closestDist = dist
                            closest = enemy
                        end
                    end
                end
                
                if closest and tick() - lastAttack >= attackDelay then
                    pcall(function() remotes.RegisterAttack:FireServer(1) end)
                    if remotes.RegisterHit then
                        pcall(function()
                            remotes.RegisterHit:FireServer(
                                closest.HumanoidRootPart,
                                {{closest, closest.HumanoidRootPart}},
                                nil,
                                tostring(tick())
                            )
                        end)
                    end
                    lastAttack = tick()
                end
            end
        end
    end)
end

function DeltaHUD:toggleHighlighter()
    self.highlighterSettings.Enabled = not self.highlighterSettings.Enabled
    for _,data in pairs(self.highlightCache) do
        if data.Highlight then data.Highlight.Enabled = self.highlighterSettings.Enabled end
        if data.Billboard then data.Billboard.Enabled = self.highlighterSettings.Enabled end
    end
    return self.highlighterSettings.Enabled
end

function DeltaHUD:Destroy()
    for _,conn in ipairs(self.connections) do conn:Disconnect() end
    for _,conn in ipairs(self.highlighterConnections) do conn:Disconnect() end
    for _,data in pairs(self.highlightCache) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    if self.screenGui then self.screenGui:Destroy() end
    if self.controlsGui then self.controlsGui:Destroy() end
    getgenv()._DeltaHUDInstance = nil
end

local hud = DeltaHUD.new()
return hud
  