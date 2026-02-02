local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeltaHUD = {}
DeltaHUD.__index = DeltaHUD

getgenv().DeltaHUD = DeltaHUD

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
    
    self.perfMode = false
    self.lowFpsCount = 0
    self.lastFpsCheck = os.clock()
    
    self.highlighterSettings = {
        Enabled = true,
        OutlineColor = Color3.fromRGB(85, 170, 255),
        OutlineTransparency = 0,
        OutlineThickness = 2,
        NameTagColor = Color3.fromRGB(255, 200, 200),
        NameTagOutlineColor = Color3.fromRGB(0, 0, 0),
        DistanceColor = Color3.fromRGB(170, 210, 255),
        HealthColor = Color3.fromRGB(120, 255, 140),
        NameTagSize = 12,
        NameTagFont = Enum.Font.GothamMedium,
        NameTagOffset = Vector3.new(0, 8.5, 0),
        TeamColor = false,
        ShowDistance = true,
        ShowHealth = true,
        MaxDistance = 500,
        UpdateRate = 0.1
    }
    
    self.highlightCache = {}
    self.highlighterConnections = {}
    self.lastHighlighterUpdate = 0
    
    self.killAuraSettings = {
        Enabled = false,
        Range = 50,
        Delay = 0.1,
        LastAttack = 0
    }
    
    getgenv()._DeltaHUDInstance = self
    
    self:Initialize()
    self:InitializeHighlighter()
    self:InitializeKillAura()
    
    return self
end

function DeltaHUD:InitializeHighlighter()
    for _, data in pairs(self.highlightCache) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    
    self.highlightCache = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
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
    
    table.insert(self.highlighterConnections, RunService.Heartbeat:Connect(function(dt)
        self.lastHighlighterUpdate = self.lastHighlighterUpdate + dt
        if self.lastHighlighterUpdate >= self.highlighterSettings.UpdateRate then
            if self.highlighterSettings.Enabled then
                for player, highlightData in pairs(self.highlightCache) do
                    if not self:updateNameTag(highlightData) then
                        self.highlightCache[player] = nil
                    end
                end
            end
            self.lastHighlighterUpdate = 0
        end
    end))
end

function DeltaHUD:createHighlight(model, player)
    if not model or not model:IsA("Model") then return nil end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.Adornee = model
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 1
    highlight.OutlineColor = self.highlighterSettings.OutlineColor
    highlight.OutlineTransparency = self.highlighterSettings.OutlineTransparency
    highlight.Enabled = self.highlighterSettings.Enabled and not self.perfMode
    
    if self.highlighterSettings.TeamColor and player.Team then
        highlight.OutlineColor = player.Team.TeamColor.Color
    end
    
    highlight.Parent = model
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerNameTag"
    billboard.Adornee = model:FindFirstChild("Head") or model.PrimaryPart or model
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = self.highlighterSettings.NameTagOffset
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = self.highlighterSettings.MaxDistance
    billboard.Enabled = self.highlighterSettings.Enabled and not self.perfMode
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameText"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = self.highlighterSettings.NameTagColor
    nameLabel.TextSize = self.highlighterSettings.NameTagSize
    nameLabel.Font = self.highlighterSettings.NameTagFont
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = self.highlighterSettings.NameTagOutlineColor
    nameLabel.Text = player.Name
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = billboard
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceText"
    distanceLabel.Size = UDim2.new(1, 0, 0, 18)
    distanceLabel.Position = UDim2.new(0, 0, 0, 20)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = self.highlighterSettings.DistanceColor
    distanceLabel.TextSize = self.highlighterSettings.NameTagSize - 2
    distanceLabel.Font = self.highlighterSettings.NameTagFont
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.Text = "0m"
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
    distanceLabel.Parent = billboard
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthText"
    healthLabel.Size = UDim2.new(1, 0, 0, 18)
    healthLabel.Position = UDim2.new(0, 0, 0, 38)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = self.highlighterSettings.HealthColor
    healthLabel.TextSize = self.highlighterSettings.NameTagSize - 2
    healthLabel.Font = self.highlighterSettings.NameTagFont
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.Text = "100"
    healthLabel.TextXAlignment = Enum.TextXAlignment.Center
    healthLabel.Parent = billboard
    
    billboard.Parent = model
    
    return {
        Highlight = highlight,
        Billboard = billboard,
        Player = player,
        Model = model,
        LastUpdate = 0
    }
end

function DeltaHUD:updateNameTag(highlightData)
    if not highlightData or not highlightData.Model or not highlightData.Model.PrimaryPart then
        return false
    end
    
    local player = highlightData.Player
    local model = highlightData.Model
    local billboard = highlightData.Billboard
    local highlight = highlightData.Highlight
    
    if not player or player.Parent ~= Players or not model.Parent then
        if highlight then highlight:Destroy() end
        if billboard then billboard:Destroy() end
        return false
    end
    
    local char = self.player.Character
    if not char or not char.PrimaryPart then return true end
    
    local distance = (char.PrimaryPart.Position - model.PrimaryPart.Position).Magnitude
    
    if distance > self.highlighterSettings.MaxDistance then
        highlight.Enabled = false
        billboard.Enabled = false
        return true
    end
    
    highlight.Enabled = self.highlighterSettings.Enabled and not self.perfMode
    billboard.Enabled = self.highlighterSettings.Enabled and not self.perfMode
    
    if billboard and billboard:FindFirstChild("DistanceText") then
        billboard.DistanceText.Text = string.format("%dm", math.floor(distance))
    end
    
    if billboard and billboard:FindFirstChild("HealthText") and self.highlighterSettings.ShowHealth then
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if humanoid then
            billboard.HealthText.Text = string.format("%d", math.floor(humanoid.Health))
        else
            billboard.HealthText.Text = "0"
        end
    end
    
    if self.highlighterSettings.TeamColor and player.Team then
        highlight.OutlineColor = player.Team.TeamColor.Color
    end
    
    return true
end

function DeltaHUD:onPlayerAdded(player)
    if player == self.player then return end
    
    local function characterAdded(character)
        if not character then return end
        task.wait(0.3)
        if character and character:IsA("Model") then
            if self.highlightCache[player] then
                local oldData = self.highlightCache[player]
                if oldData.Highlight then oldData.Highlight:Destroy() end
                if oldData.Billboard then oldData.Billboard:Destroy() end
            end
            local highlightData = self:createHighlight(character, player)
            if highlightData then
                self.highlightCache[player] = highlightData
            end
        end
    end
    
    local conn = player.CharacterAdded:Connect(characterAdded)
    table.insert(self.highlighterConnections, conn)
    
    if player.Character then
        characterAdded(player.Character)
    end
    
    local removedConn = player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if self.highlightCache[player] then
                local data = self.highlightCache[player]
                if data.Highlight then data.Highlight:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
                self.highlightCache[player] = nil
            end
        end
    end)
    table.insert(self.highlighterConnections, removedConn)
end

function DeltaHUD:onPlayerRemoving(player)
    if self.highlightCache[player] then
        local data = self.highlightCache[player]
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        self.highlightCache[player] = nil
    end
end

function DeltaHUD:Initialize()
    if self.player.PlayerGui:FindFirstChild("DeltaHUD") then
        self.player.PlayerGui.DeltaHUD:Destroy()
    end
    
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
    
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
    })
    uiGradient.Parent = self.mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 140, 200)
    stroke.Transparency = 0.3
    stroke.Thickness = 1.5
    stroke.Parent = self.mainFrame
    
    self.sections = {}
    local sectionWidth = 100
    
    for i = 1, 3 do
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = "Section" .. i
        sectionFrame.Size = UDim2.new(0, sectionWidth, 1, 0)
        sectionFrame.Position = UDim2.new(0, (i-1) * sectionWidth, 0, 0)
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.BorderSizePixel = 0
        sectionFrame.Parent = self.mainFrame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, 0, 0, 16)
        titleLabel.Position = UDim2.new(0, 0, 0, 4)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
        titleLabel.TextSize = 11
        titleLabel.Font = Enum.Font.GothamMedium
        titleLabel.Text = i == 1 and "FPS" or (i == 2 and "PING" or "INFO")
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.Parent = sectionFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "Value"
        valueLabel.Size = UDim2.new(1, 0, 0, 18)
        valueLabel.Position = UDim2.new(0, 0, 0, 18)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueLabel.TextSize = 13
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.Text = i == 1 and "0" or (i == 2 and "0ms" or "CV: 0")
        valueLabel.TextXAlignment = Enum.TextXAlignment.Center
        valueLabel.Parent = sectionFrame
        
        if i == 3 then
            local button = Instance.new("TextButton")
            button.Name = "ToggleButton"
            button.Size = UDim2.new(1, 0, 1, 0)
            button.Position = UDim2.new(0, 0, 0, 0)
            button.BackgroundTransparency = 1
            button.Text = ""
            button.Parent = sectionFrame
            
            table.insert(self.connections, button.MouseButton1Click:Connect(function()
                self.showGameTime = not self.showGameTime
                self:UpdateInfo()
            end))
        end
        
        if i < 3 then
            local divider = Instance.new("Frame")
            divider.Name = "Divider"
            divider.Size = UDim2.new(0, 1, 0, 20)
            divider.Position = UDim2.new(1, -1, 0.5, -10)
            divider.BackgroundColor3 = Color3.fromRGB(80, 150, 220)
            divider.BackgroundTransparency = 0.7
            divider.BorderSizePixel = 0
            divider.Parent = sectionFrame
        end
        
        self.sections[i] = {
            frame = sectionFrame,
            title = titleLabel,
            value = valueLabel
        }
    end
    
    self.sections[1].value.TextColor3 = Color3.fromRGB(85, 230, 130)
    self.sections[2].value.TextColor3 = Color3.fromRGB(80, 170, 240)
    self.sections[3].value.TextColor3 = Color3.fromRGB(180, 110, 230)
    
    self.mainFrame.Parent = self.screenGui
    self.screenGui.Parent = self.player:WaitForChild("PlayerGui")
    
    self:CreateControlPanel()
    self:SetupConnections()
end

function DeltaHUD:CreateControlPanel()
    self.controlFrame = Instance.new("Frame")
    self.controlFrame.Name = "ControlPanel"
    self.controlFrame.Size = UDim2.new(0, 220, 0, 130)
    self.controlFrame.Position = UDim2.new(0.5, -110, 0, 60)
    self.controlFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    self.controlFrame.BackgroundTransparency = 0.15
    self.controlFrame.BorderSizePixel = 0
    
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
    })
    uiGradient.Parent = self.controlFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.controlFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 150, 210)
    stroke.Transparency = 0.25
    stroke.Thickness = 1.5
    stroke.Parent = self.controlFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 24)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(220, 220, 240)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Text = "Delta HUD Controls"
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = self.controlFrame
    
    local buttonHeight = 28
    local buttonSpacing = 32
    local startY = 30
    
    local function createButton(text, yPos, callback)
        local button = Instance.new("TextButton")
        button.Name = text .. "Button"
        button.Size = UDim2.new(0.9, 0, 0, buttonHeight)
        button.Position = UDim2.new(0.05, 0, 0, yPos)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        button.BackgroundTransparency = 0.2
        button.Text = text
        button.TextColor3 = Color3.fromRGB(240, 240, 255)
        button.TextSize = 13
        button.Font = Enum.Font.GothamMedium
        button.AutoButtonColor = true
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = button
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(80, 160, 220)
        btnStroke.Transparency = 0.5
        btnStroke.Thickness = 1
        btnStroke.Parent = button
        
        local status = Instance.new("Frame")
        status.Name = "Status"
        status.Size = UDim2.new(0, 8, 0, 8)
        status.Position = UDim2.new(1, -12, 0.5, -4)
        status.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        status.BorderSizePixel = 0
        
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(1, 0)
        statusCorner.Parent = status
        
        status.Parent = button
        
        button.MouseButton1Click:Connect(callback)
        button.Parent = self.controlFrame
        
        return {Button = button, Status = status}
    end
    
    self.espButton = createButton("ESP Players", startY, function()
        self:toggleHighlighter()
        self.espButton.Status.BackgroundColor3 = self.highlighterSettings.Enabled and 
            Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
    end)
    
    self.killAuraButton = createButton("Kill Aura", startY + buttonSpacing, function()
        self.killAuraSettings.Enabled = not self.killAuraSettings.Enabled
        self.killAuraButton.Status.BackgroundColor3 = self.killAuraSettings.Enabled and 
            Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
    end)
    
    self.infoButton = createButton("Show Info", startY + buttonSpacing * 2, function()
        self.showHUD = not self.showHUD
        self.screenGui.Enabled = self.showHUD
        self.infoButton.Status.BackgroundColor3 = self.showHUD and 
            Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
    end)
    
    self.controlFrame.Visible = false
    self.controlFrame.Parent = self.screenGui
    
    local dragButton = Instance.new("TextButton")
    dragButton.Name = "DragButton"
    dragButton.Size = UDim2.new(0, 20, 0, 20)
    dragButton.Position = UDim2.new(1, -25, 0, 5)
    dragButton.BackgroundTransparency = 1
    dragButton.Text = "⋮⋮"
    dragButton.TextColor3 = Color3.fromRGB(180, 180, 200)
    dragButton.TextSize = 12
    dragButton.Parent = self.controlFrame
    
    local dragging = false
    local dragOffset
    dragButton.MouseButton1Down:Connect(function()
        dragging = true
        dragOffset = self.controlFrame.Position - UDim2.new(0, UserInputService:GetMouseLocation().X, 0, UserInputService:GetMouseLocation().Y)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            self.controlFrame.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y) + dragOffset
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F6 then
            self.controlFrame.Visible = not self.controlFrame.Visible
        end
    end))
end

function DeltaHUD:SetupConnections()
    table.insert(self.connections, RunService.RenderStepped:Connect(function(dt)
        self:UpdateFPS(dt)
        self.lastUpdate = self.lastUpdate + dt
        if self.lastUpdate >= self.updateInterval then
            self:UpdatePing()
            self:UpdateInfo()
            self.lastUpdate = 0
        end
        
        if os.clock() - self.lastFpsCheck >= 1 then
            self.lastFpsCheck = os.clock()
            if self.fps < 30 then
                self.lowFpsCount = self.lowFpsCount + 1
                if self.lowFpsCount >= 4 and not self.perfMode then
                    self.perfMode = true
                    for _, data in pairs(self.highlightCache) do
                        if data.Highlight then
                            data.Highlight.Enabled = false
                        end
                        if data.Billboard then
                            data.Billboard.Enabled = false
                        end
                    end
                end
            else
                self.lowFpsCount = 0
                if self.perfMode and self.fps > 40 then
                    self.perfMode = false
                    if self.highlighterSettings.Enabled then
                        for _, data in pairs(self.highlightCache) do
                            if data.Highlight then
                                data.Highlight.Enabled = true
                            end
                            if data.Billboard then
                                data.Billboard.Enabled = true
                            end
                        end
                    end
                end
            end
        end
    end))
    
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F5 then
            self.showHUD = not self.showHUD
            self.screenGui.Enabled = self.showHUD
        end
    end))
end

function DeltaHUD:UpdateFPS(dt)
    self.fpsTime = self.fpsTime + dt
    self.fpsCounter = self.fpsCounter + 1
    if self.fpsTime >= 1 then
        self.fps = math.floor(self.fpsCounter / self.fpsTime)
        self.fpsCounter = 0
        self.fpsTime = 0
        self.sections[1].value.Text = tostring(self.fps)
        self.sections[1].value.TextColor3 = self.fps >= 60 and Color3.fromRGB(85, 230, 130) or
                                           self.fps >= 30 and Color3.fromRGB(230, 180, 60) or
                                           Color3.fromRGB(230, 80, 80)
    end
end

function DeltaHUD:UpdatePing()
    local success, ping = pcall(function()
        return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    self.sections[2].value.Text = (success and ping or -1) .. "ms"
    self.sections[2].value.TextColor3 = (success and ping < 100) and Color3.fromRGB(80, 170, 240) or
                                       (ping < 200) and Color3.fromRGB(230, 180, 60) or
                                       Color3.fromRGB(230, 80, 80)
end

function DeltaHUD:UpdateInfo()
    if self.showGameTime then
        local elapsed = os.clock() - self.startTime
        local minutes = math.floor(elapsed / 60)
        local seconds = math.floor(elapsed % 60)
        self.sections[3].value.Text = string.format("%02d:%02d", minutes, seconds)
    else
        local camera = workspace.CurrentCamera
        if camera then
            local look = camera.CFrame.LookVector
            local pitch = math.deg(math.asin(-look.Y))
            local yaw = math.deg(math.atan2(-look.X, -look.Z))
            self.sections[3].value.Text = string.format("%.0f°,%.0f°", yaw % 360, pitch)
        else
            self.sections[3].value.Text = "CV: N/A"
        end
    end
end

function DeltaHUD:InitializeKillAura()
    local function getRemoteEvents()
        local remotes = {}
        local function findRemote(name)
            local found = ReplicatedStorage:FindFirstChild(name, true)
            if not found then
                found = Workspace:FindFirstChild(name, true)
            end
            return found
        end
        
        remotes.RegisterAttack = findRemote("RegisterAttack")
        remotes.RegisterHit = findRemote("RegisterHit")
        
        return remotes
    end
    
    local function attackEnemy(remotes)
        if not self.player.Character then return end
        local char = self.player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local characterPos = hrp.Position
        local enemies = Workspace:FindFirstChild("Enemies") or Workspace
        
        local closestEnemy
        local closestDistance = self.killAuraSettings.Range
        
        for _, enemy in pairs(enemies:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                local enemyHrp = enemy.HumanoidRootPart
                local humanoid = enemy:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local distance = (enemyHrp.Position - characterPos).Magnitude
                    if distance <= closestDistance then
                        closestDistance = distance
                        closestEnemy = enemy
                    end
                end
            end
        end
        
        if closestEnemy then
            local now = tick()
            if now - self.killAuraSettings.LastAttack >= self.killAuraSettings.Delay then
                pcall(function()
                    if remotes.RegisterAttack then
                        remotes.RegisterAttack:FireServer(1)
                    end
                end)
                
                task.wait(0.05)
                
                pcall(function()
                    if remotes.RegisterHit then
                        remotes.RegisterHit:FireServer(
                            closestEnemy.HumanoidRootPart,
                            {{closestEnemy, closestEnemy.HumanoidRootPart}},
                            nil,
                            tostring(now)
                        )
                    end
                end)
                
                self.killAuraSettings.LastAttack = now
            end
        end
    end
    
    task.spawn(function()
        local remotes = getRemoteEvents()
        
        local function resetBools()
            if self.player.Character then
                local char = self.player.Character
                local stun = char:FindFirstChild("Stun")
                if stun then stun.Value = 0 end
                local busy = char:FindFirstChild("Busy")
                if busy then busy.Value = false end
            end
        end
        
        while task.wait(0.3) do
            if self.killAuraSettings.Enabled then
                resetBools()
            end
        end
    end)
    
    task.spawn(function()
        local remotes = getRemoteEvents()
        
        while task.wait() do
            if self.killAuraSettings.Enabled and remotes.RegisterAttack then
                attackEnemy(remotes)
            end
            task.wait(self.killAuraSettings.Delay * 0.5)
        end
    end)
end

function DeltaHUD:toggleHighlighter()
    self.highlighterSettings.Enabled = not self.highlighterSettings.Enabled
    for _, data in pairs(self.highlightCache) do
        if data.Highlight then
            data.Highlight.Enabled = self.highlighterSettings.Enabled and not self.perfMode
        end
        if data.Billboard then
            data.Billboard.Enabled = self.highlighterSettings.Enabled and not self.perfMode
        end
    end
    return self.highlighterSettings.Enabled
end

function DeltaHUD:Destroy()
    for _, conn in pairs(self.connections) do
        conn:Disconnect()
    end
    for _, conn in pairs(self.highlighterConnections) do
        conn:Disconnect()
    end
    for _, data in pairs(self.highlightCache) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    if self.screenGui then
        self.screenGui:Destroy()
    end
    getgenv()._DeltaHUDInstance = nil
end

local hud = DeltaHUD.new()
return hud