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
    
    self.highlighterSettings = {
        Enabled = true,
        OutlineColor = Color3.fromRGB(85, 170, 255),
        OutlineTransparency = 0,
        OutlineThickness = 3,
        NameTagColor = Color3.fromRGB(255, 255, 255),
        NameTagOutlineColor = Color3.fromRGB(0, 0, 0),
        NameTagSize = 14,
        NameTagFont = Enum.Font.GothamMedium,
        NameTagOffset = Vector3.new(0, 8.5, 0),
        TeamColor = false,
        ShowDistance = true,
        MaxDistance = 10000
    }
    
    self.killAuraSettings = {
        Enabled = true,
        Range = 50,
        AttackNPC = true,
        AttackPlayers = true,
        TeamCheck = false,
        Cooldown = 0.1
    }
    
    self.highlightCache = {}
    self.highlighterConnections = {}
    
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
    
    RunService.Heartbeat:Connect(function()
        if not self.highlighterSettings.Enabled then return end
        for player, highlightData in pairs(self.highlightCache) do
            if not self:updateNameTag(highlightData) then
                self.highlightCache[player] = nil
            end
        end
    end)
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
    highlight.Enabled = self.highlighterSettings.Enabled
    
    if self.highlighterSettings.TeamColor and player.Team then
        highlight.OutlineColor = player.Team.TeamColor.Color
    end
    
    highlight.Parent = model
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerNameTag"
    billboard.Adornee = model:FindFirstChild("Head") or model.PrimaryPart or model
    billboard.Size = UDim2.new(0, 250, 0, 70)
    billboard.StudsOffset = Vector3.new(0, 8.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = self.highlighterSettings.MaxDistance
    billboard.Enabled = self.highlighterSettings.Enabled
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "NameText"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = self.highlighterSettings.NameTagColor
    textLabel.TextSize = self.highlighterSettings.NameTagSize
    textLabel.Font = self.highlighterSettings.NameTagFont
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = self.highlighterSettings.NameTagOutlineColor
    textLabel.Text = player.Name
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = billboard
    billboard.Parent = model
    
    return {
        Highlight = highlight,
        Billboard = billboard,
        Player = player,
        Model = model
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
    
    local distance = (self.player.Character and model.PrimaryPart and 
                     (self.player.Character.PrimaryPart.Position - model.PrimaryPart.Position).Magnitude) or 0
    
    if distance > self.highlighterSettings.MaxDistance then
        highlight.Enabled = false
        billboard.Enabled = false
        return true
    end
    
    highlight.Enabled = self.highlighterSettings.Enabled
    billboard.Enabled = self.highlighterSettings.Enabled
    
    local healthInfo = ""
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        healthInfo = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
    else
        local data = model:FindFirstChild("Data")
        if data then
            local level = data:FindFirstChild("Level")
            if level then
                healthInfo = string.format("LVL: %d", level.Value)
            end
        end
    end
    
    if billboard and billboard.NameText then
        if self.highlighterSettings.ShowDistance then
            billboard.NameText.Text = string.format("%s [%dm]\n%s", 
                player.Name, 
                math.floor(distance), 
                healthInfo)
        else
            billboard.NameText.Text = string.format("%s\n%s", player.Name, healthInfo)
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
        task.wait(0.5)
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
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    self.mainFrame.BackgroundTransparency = 0.2
    self.mainFrame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.85
    stroke.Thickness = 1
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
        titleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
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
            divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            divider.BackgroundTransparency = 0.9
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
    
    self:SetupConnections()
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
    end
end

function DeltaHUD:UpdatePing()
    local success, ping = pcall(function()
        return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    self.sections[2].value.Text = (success and ping or -1) .. "ms"
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
        local success, netModule = pcall(function()
            return require(ReplicatedStorage.Modules.Net)
        end)
        
        if success and netModule then
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
            remotes.RegisterAttack = ReplicatedStorage:FindFirstChild("RegisterAttack", true)
            remotes.RegisterHit = ReplicatedStorage:FindFirstChild("RegisterHit", true)
        end
        
        return remotes
    end
    
    task.spawn(function()
        while task.wait(0.5) do
            if self.player.Character then
                local stun = self.player.Character:FindFirstChild("Stun")
                if stun then stun.Value = 0 end
                local busy = self.player.Character:FindFirstChild("Busy")
                if busy then busy.Value = false end
            end
        end
    end)
    
    task.spawn(function()
        local remotes = getRemoteEvents()
        if not remotes.RegisterAttack then return end
        
        local lastAttack = 0
        
        while task.wait(0) do
            if not self.killAuraSettings.Enabled then
                task.wait(0.1)
                continue
            end
            
            local currentTime = tick()
            if currentTime - lastAttack < self.killAuraSettings.Cooldown then
                continue
            end
            
            if self.player.Character and self.player.Character:FindFirstChild("HumanoidRootPart") then
                local characterPos = self.player.Character.HumanoidRootPart.Position
                
                if self.killAuraSettings.AttackNPC then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChildOfClass("Humanoid") then
                            local distance = (enemy.HumanoidRootPart.Position - characterPos).Magnitude
                            if distance <= self.killAuraSettings.Range and enemy:FindFirstChildOfClass("Humanoid").Health > 0 then
                                pcall(function()
                                    remotes.RegisterAttack:FireServer(1)
                                end)
                                if remotes.RegisterHit then
                                    pcall(function()
                                        remotes.RegisterHit:FireServer(
                                            enemy.HumanoidRootPart, 
                                            {{enemy, enemy.HumanoidRootPart}},
                                            nil,
                                            tostring(tick())
                                        )
                                    end)
                                end
                                lastAttack = currentTime
                                break
                            end
                        end
                    end
                end
                
                if self.killAuraSettings.AttackPlayers then
                    for _, targetPlayer in pairs(Players:GetPlayers()) do
                        if targetPlayer ~= self.player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local targetCharacter = targetPlayer.Character
                            if targetCharacter:FindFirstChildOfClass("Humanoid") then
                                local distance = (targetCharacter.HumanoidRootPart.Position - characterPos).Magnitude
                                local canAttack = true
                                
                                if self.killAuraSettings.TeamCheck and self.player.Team and targetPlayer.Team then
                                    canAttack = self.player.Team ~= targetPlayer.Team
                                end
                                
                                if distance <= self.killAuraSettings.Range and canAttack and targetCharacter:FindFirstChildOfClass("Humanoid").Health > 0 then
                                    pcall(function()
                                        remotes.RegisterAttack:FireServer(1)
                                    end)
                                    if remotes.RegisterHit then
                                        pcall(function()
                                            remotes.RegisterHit:FireServer(
                                                targetCharacter.HumanoidRootPart, 
                                                {{targetCharacter, targetCharacter.HumanoidRootPart}},
                                                nil,
                                                tostring(tick())
                                            )
                                        end)
                                    end
                                    lastAttack = currentTime
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

function DeltaHUD:Toggle()
    self.showHUD = not self.showHUD
    self.screenGui.Enabled = self.showHUD
    return self.showHUD
end

function DeltaHUD:toggleHighlighter()
    self.highlighterSettings.Enabled = not self.highlighterSettings.Enabled
    for _, data in pairs(self.highlightCache) do
        if data.Highlight then
            data.Highlight.Enabled = self.highlighterSettings.Enabled
        end
        if data.Billboard then
            data.Billboard.Enabled = self.highlighterSettings.Enabled
        end
    end
    return self.highlighterSettings.Enabled
end

function DeltaHUD:toggleKillAura()
    self.killAuraSettings.Enabled = not self.killAuraSettings.Enabled
    return self.killAuraSettings.Enabled
end

function DeltaHUD:setKillAuraRange(range)
    if type(range) == "number" and range > 0 then
        self.killAuraSettings.Range = range
        return true
    end
    return false
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