return (function()
    local L_I_1 = (newcclosure)((loadstring)([[
        local L_I_2 = {}
        
        (function()
            local L_I_100 = {
                ["P".."layers"] = function() return game:GetService("Players") end,
                ["R".."unService"] = function() return game:GetService("RunService") end,
                ["W".."orkspace"] = function() return game:GetService("Workspace") end,
                ["U".."serInputService"] = function() return game:GetService("UserInputService") end,
                ["R".."eplicatedStorage"] = function() return game:GetService("ReplicatedStorage") end
            }
            
            for L_I_101, L_I_102 in pairs(L_I_100) do
                L_I_2[L_I_101] = L_I_102()
            end
        end)()
        
        local L_I_3 = {}
        local L_I_4 = setmetatable({}, L_I_3)
        
        (function()
            local L_I_103 = {"g", "e", "t", "g", "e", "n", "v"}
            local L_I_104 = _G[table.concat(L_I_103)]
            if L_I_104 then
                L_I_104().DeltaHUD = L_I_3
            end
        end)()
        
        L_I_3.__index = L_I_3
        
        local L_I_5 = function()
            (function()
                local L_I_105 = {"g", "e", "t", "g", "e", "n", "v"}
                local L_I_106 = _G[table.concat(L_I_105)]
                if L_I_106 and L_I_106()._DeltaHUDInstance then
                    local L_I_107 = L_I_106()._DeltaHUDInstance
                    if L_I_107.Destroy then
                        L_I_107:Destroy()
                    end
                end
            end)()
            
            local L_I_6 = setmetatable({}, L_I_3)
            
            local L_I_7 = L_I_2["Players"]
            L_I_6.player = L_I_7.LocalPlayer
            L_I_6.showHUD = true
            L_I_6.lastUpdate = 0
            L_I_6.updateInterval = 0.3
            L_I_6.fps = 0
            L_I_6.fpsCounter = 0
            L_I_6.fpsTime = 0
            L_I_6.startTime = os.clock()
            L_I_6.showGameTime = false
            L_I_6.connections = {}
            
            L_I_6.highlighterSettings = {
                Enabled = true,
                OutlineColor = (function()
                    local L_I_108 = {85, 170, 255}
                    return Color3.fromRGB(L_I_108[1], L_I_108[2], L_I_108[3])
                end)(),
                OutlineTransparency = 0,
                OutlineThickness = 3,
                NameTagColor = (function()
                    local L_I_109 = {255, 255, 255}
                    return Color3.fromRGB(L_I_109[1], L_I_109[2], L_I_109[3])
                end)(),
                NameTagOutlineColor = (function()
                    local L_I_110 = {0, 0, 0}
                    return Color3.fromRGB(L_I_110[1], L_I_110[2], L_I_110[3])
                end)(),
                NameTagSize = 14,
                NameTagFont = Enum.Font.GothamMedium,
                NameTagOffset = Vector3.new(0, 8.5, 0),
                TeamColor = false,
                ShowDistance = true,
                MaxDistance = 10000
            }
            
            L_I_6.killAuraSettings = {
                Enabled = true,
                Range = 50,
                AttackNPC = true,
                AttackPlayers = true,
                TeamCheck = false,
                Cooldown = 0.1
            }
            
            L_I_6.highlightCache = {}
            L_I_6.highlighterConnections = {}
            
            (function()
                local L_I_111 = {"g", "e", "t", "g", "e", "n", "v"}
                local L_I_112 = _G[table.concat(L_I_111)]
                if L_I_112 then
                    L_I_112()._DeltaHUDInstance = L_I_6
                end
            end)()
            
            local L_I_8 = {}
            L_I_8[1] = function() L_I_6:Initialize() end
            L_I_8[2] = function() L_I_6:InitializeHighlighter() end
            L_I_8[3] = function() L_I_6:InitializeKillAura() end
            
            for L_I_113 = 1, 3 do
                local L_I_114 = L_I_8[L_I_113]
                if L_I_114 then
                    L_I_114()
                end
            end
            
            return L_I_6
        end
        
        L_I_3.new = L_I_5
        
        local L_I_9 = function(L_I_115, L_I_116)
            local L_I_117 = L_I_115
            if L_I_116 then
                for L_I_118, L_I_119 in pairs(L_I_116) do
                    L_I_117[L_I_118] = L_I_119
                end
            end
            return L_I_117
        end
        
        L_I_3.InitializeHighlighter = function(L_I_120)
            for L_I_121, L_I_122 in pairs(L_I_120.highlightCache) do
                if L_I_122.Highlight then
                    L_I_122.Highlight:Destroy()
                end
                if L_I_122.Billboard then
                    L_I_122.Billboard:Destroy()
                end
            end
            
            L_I_120.highlightCache = {}
            
            local L_I_123 = L_I_2["Players"]
            for L_I_124, L_I_125 in ipairs(L_I_123:GetPlayers()) do
                if L_I_125 ~= L_I_120.player then
                    L_I_120:onPlayerAdded(L_I_125)
                end
            end
            
            table.insert(L_I_120.highlighterConnections, 
                L_I_123.PlayerAdded:Connect(function(L_I_126)
                    L_I_120:onPlayerAdded(L_I_126)
                end)
            )
            
            table.insert(L_I_120.highlighterConnections,
                L_I_123.PlayerRemoving:Connect(function(L_I_127)
                    L_I_120:onPlayerRemoving(L_I_127)
                end)
            )
            
            local L_I_128 = L_I_2["RunService"]
            L_I_128.Heartbeat:Connect(function()
                if not L_I_120.highlighterSettings.Enabled then return end
                for L_I_129, L_I_130 in pairs(L_I_120.highlightCache) do
                    if not L_I_120:updateNameTag(L_I_130) then
                        L_I_120.highlightCache[L_I_129] = nil
                    end
                end
            end)
        end
        
        L_I_3.createHighlight = function(L_I_131, L_I_132, L_I_133)
            if not L_I_132 or not L_I_132:IsA("Model") then return nil end
            
            local L_I_134 = Instance.new("Highlight")
            L_I_134.Name = "PlayerHighlight"
            L_I_134.Adornee = L_I_132
            L_I_134.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            L_I_134.FillTransparency = 1
            L_I_134.OutlineColor = L_I_131.highlighterSettings.OutlineColor
            L_I_134.OutlineTransparency = L_I_131.highlighterSettings.OutlineTransparency
            L_I_134.Enabled = L_I_131.highlighterSettings.Enabled
            
            if L_I_131.highlighterSettings.TeamColor and L_I_133.Team then
                L_I_134.OutlineColor = L_I_133.Team.TeamColor.Color
            end
            
            L_I_134.Parent = L_I_132
            
            local L_I_135 = Instance.new("BillboardGui")
            L_I_135.Name = "PlayerNameTag"
            L_I_135.Adornee = L_I_132:FindFirstChild("Head") or L_I_132.PrimaryPart or L_I_132
            L_I_135.Size = UDim2.new(0, 250, 0, 70)
            L_I_135.StudsOffset = Vector3.new(0, 8.5, 0)
            L_I_135.AlwaysOnTop = true
            L_I_135.MaxDistance = L_I_131.highlighterSettings.MaxDistance
            L_I_135.Enabled = L_I_131.highlighterSettings.Enabled
            
            local L_I_136 = Instance.new("TextLabel")
            L_I_136.Name = "NameText"
            L_I_136.Size = UDim2.new(1, 0, 1, 0)
            L_I_136.BackgroundTransparency = 1
            L_I_136.TextColor3 = L_I_131.highlighterSettings.NameTagColor
            L_I_136.TextSize = L_I_131.highlighterSettings.NameTagSize
            L_I_136.Font = L_I_131.highlighterSettings.NameTagFont
            L_I_136.TextStrokeTransparency = 0
            L_I_136.TextStrokeColor3 = L_I_131.highlighterSettings.NameTagOutlineColor
            L_I_136.Text = L_I_133.Name
            L_I_136.TextYAlignment = Enum.TextYAlignment.Center
            L_I_136.Parent = L_I_135
            
            L_I_135.Parent = L_I_132
            
            return {
                Highlight = L_I_134,
                Billboard = L_I_135,
                Player = L_I_133,
                Model = L_I_132
            }
        end
        
        L_I_3.updateNameTag = function(L_I_137, L_I_138)
            if not L_I_138 or not L_I_138.Model or not L_I_138.Model.PrimaryPart then
                return false
            end
            
            local L_I_139 = L_I_138.Player
            local L_I_140 = L_I_138.Model
            local L_I_141 = L_I_138.Billboard
            local L_I_142 = L_I_138.Highlight
            
            if not L_I_139 or L_I_139.Parent ~= L_I_2["Players"] or not L_I_140.Parent then
                if L_I_142 then L_I_142:Destroy() end
                if L_I_141 then L_I_141:Destroy() end
                return false
            end
            
            local L_I_143 = (function()
                local L_I_144 = L_I_137.player.Character
                local L_I_145 = L_I_140.PrimaryPart
                if L_I_144 and L_I_145 and L_I_144.PrimaryPart then
                    return (L_I_144.PrimaryPart.Position - L_I_145.Position).Magnitude
                end
                return 0
            end)()
            
            if L_I_143 > L_I_137.highlighterSettings.MaxDistance then
                if L_I_142 then L_I_142.Enabled = false end
                if L_I_141 then L_I_141.Enabled = false end
                return true
            end
            
            if L_I_142 then
                L_I_142.Enabled = L_I_137.highlighterSettings.Enabled
            end
            if L_I_141 then
                L_I_141.Enabled = L_I_137.highlighterSettings.Enabled
            end
            
            local L_I_146 = ""
            local L_I_147 = L_I_140:FindFirstChildOfClass("Humanoid")
            
            if L_I_147 then
                L_I_146 = string.format("HP: %d/%d", math.floor(L_I_147.Health), math.floor(L_I_147.MaxHealth))
            else
                local L_I_148 = L_I_140:FindFirstChild("Data")
                if L_I_148 then
                    local L_I_149 = L_I_148:FindFirstChild("Level")
                    if L_I_149 then
                        L_I_146 = string.format("LVL: %d", L_I_149.Value)
                    end
                end
            end
            
            if L_I_141 and L_I_141.NameText then
                if L_I_137.highlighterSettings.ShowDistance then
                    L_I_141.NameText.Text = string.format("%s [%dm]\n%s", 
                        L_I_139.Name, 
                        math.floor(L_I_143), 
                        L_I_146)
                else
                    L_I_141.NameText.Text = string.format("%s\n%s", L_I_139.Name, L_I_146)
                end
            end
            
            if L_I_137.highlighterSettings.TeamColor and L_I_139.Team and L_I_142 then
                L_I_142.OutlineColor = L_I_139.Team.TeamColor.Color
            end
            
            return true
        end
        
        L_I_3.onPlayerAdded = function(L_I_150, L_I_151)
            if L_I_151 == L_I_150.player then return end
            
            local L_I_152 = function(L_I_153)
                if not L_I_153 then return end
                task.wait(0.5)
                if L_I_153 and L_I_153:IsA("Model") then
                    if L_I_150.highlightCache[L_I_151] then
                        local L_I_154 = L_I_150.highlightCache[L_I_151]
                        if L_I_154.Highlight then L_I_154.Highlight:Destroy() end
                        if L_I_154.Billboard then L_I_154.Billboard:Destroy() end
                    end
                    local L_I_155 = L_I_150:createHighlight(L_I_153, L_I_151)
                    if L_I_155 then
                        L_I_150.highlightCache[L_I_151] = L_I_155
                    end
                end
            end
            
            local L_I_156 = L_I_151.CharacterAdded:Connect(L_I_152)
            table.insert(L_I_150.highlighterConnections, L_I_156)
            
            if L_I_151.Character then
                L_I_152(L_I_151.Character)
            end
            
            local L_I_157 = L_I_151.AncestryChanged:Connect(function(_, L_I_158)
                if not L_I_158 then
                    if L_I_150.highlightCache[L_I_151] then
                        local L_I_159 = L_I_150.highlightCache[L_I_151]
                        if L_I_159.Highlight then L_I_159.Highlight:Destroy() end
                        if L_I_159.Billboard then L_I_159.Billboard:Destroy() end
                        L_I_150.highlightCache[L_I_151] = nil
                    end
                end
            end)
            table.insert(L_I_150.highlighterConnections, L_I_157)
        end
        
        L_I_3.onPlayerRemoving = function(L_I_160, L_I_161)
            if L_I_160.highlightCache[L_I_161] then
                local L_I_162 = L_I_160.highlightCache[L_I_161]
                if L_I_162.Highlight then L_I_162.Highlight:Destroy() end
                if L_I_162.Billboard then L_I_162.Billboard:Destroy() end
                L_I_160.highlightCache[L_I_161] = nil
            end
        end
        
        L_I_3.Initialize = function(L_I_163)
            if L_I_163.player.PlayerGui:FindFirstChild("DeltaHUD") then
                L_I_163.player.PlayerGui.DeltaHUD:Destroy()
            end
            
            L_I_163.screenGui = Instance.new("ScreenGui")
            L_I_163.screenGui.Name = "DeltaHUD"
            L_I_163.screenGui.DisplayOrder = 999
            L_I_163.screenGui.IgnoreGuiInset = true
            L_I_163.screenGui.ResetOnSpawn = false
            
            L_I_163.mainFrame = Instance.new("Frame")
            L_I_163.mainFrame.Name = "MainFrame"
            L_I_163.mainFrame.Size = UDim2.new(0, 300, 0, 40)
            L_I_163.mainFrame.Position = UDim2.new(0.5, -150, 0, 10)
            L_I_163.mainFrame.BackgroundColor3 = (function()
                local L_I_164 = {15, 15, 20}
                return Color3.fromRGB(L_I_164[1], L_I_164[2], L_I_164[3])
            end)()
            L_I_163.mainFrame.BackgroundTransparency = 0.2
            L_I_163.mainFrame.BorderSizePixel = 0
            
            local L_I_165 = Instance.new("UICorner")
            L_I_165.CornerRadius = UDim.new(0, 6)
            L_I_165.Parent = L_I_163.mainFrame
            
            local L_I_166 = Instance.new("UIStroke")
            L_I_166.Color = (function()
                local L_I_167 = {255, 255, 255}
                return Color3.fromRGB(L_I_167[1], L_I_167[2], L_I_167[3])
            end)()
            L_I_166.Transparency = 0.85
            L_I_166.Thickness = 1
            L_I_166.Parent = L_I_163.mainFrame
            
            L_I_163.sections = {}
            local L_I_168 = 100
            
            for L_I_169 = 1, 3 do
                local L_I_170 = Instance.new("Frame")
                L_I_170.Name = "Section" .. L_I_169
                L_I_170.Size = UDim2.new(0, L_I_168, 1, 0)
                L_I_170.Position = UDim2.new(0, (L_I_169-1) * L_I_168, 0, 0)
                L_I_170.BackgroundTransparency = 1
                L_I_170.BorderSizePixel = 0
                L_I_170.Parent = L_I_163.mainFrame
                
                local L_I_171 = Instance.new("TextLabel")
                L_I_171.Name = "Title"
                L_I_171.Size = UDim2.new(1, 0, 0, 16)
                L_I_171.Position = UDim2.new(0, 0, 0, 4)
                L_I_171.BackgroundTransparency = 1
                L_I_171.TextColor3 = (function()
                    local L_I_172 = {180, 180, 180}
                    return Color3.fromRGB(L_I_172[1], L_I_172[2], L_I_172[3])
                end)()
                L_I_171.TextSize = 11
                L_I_171.Font = Enum.Font.GothamMedium
                L_I_171.Text = (function()
                    local L_I_173 = {"FPS", "PING", "INFO"}
                    return L_I_173[L_I_169]
                end)()
                L_I_171.TextXAlignment = Enum.TextXAlignment.Center
                L_I_171.Parent = L_I_170
                
                local L_I_174 = Instance.new("TextLabel")
                L_I_174.Name = "Value"
                L_I_174.Size = UDim2.new(1, 0, 0, 18)
                L_I_174.Position = UDim2.new(0, 0, 0, 18)
                L_I_174.BackgroundTransparency = 1
                L_I_174.TextColor3 = (function()
                    local L_I_175 = {255, 255, 255}
                    return Color3.fromRGB(L_I_175[1], L_I_175[2], L_I_175[3])
                end)()
                L_I_174.TextSize = 13
                L_I_174.Font = Enum.Font.GothamBold
                L_I_174.Text = (function()
                    local L_I_176 = {"0", "0ms", "CV: 0"}
                    return L_I_176[L_I_169]
                end)()
                L_I_174.TextXAlignment = Enum.TextXAlignment.Center
                L_I_174.Parent = L_I_170
                
                if L_I_169 == 3 then
                    local L_I_177 = Instance.new("TextButton")
                    L_I_177.Name = "ToggleButton"
                    L_I_177.Size = UDim2.new(1, 0, 1, 0)
                    L_I_177.Position = UDim2.new(0, 0, 0, 0)
                    L_I_177.BackgroundTransparency = 1
                    L_I_177.Text = ""
                    L_I_177.Parent = L_I_170
                    
                    table.insert(L_I_163.connections, L_I_177.MouseButton1Click:Connect(function()
                        L_I_163.showGameTime = not L_I_163.showGameTime
                        L_I_163:UpdateInfo()
                    end))
                end
                
                if L_I_169 < 3 then
                    local L_I_178 = Instance.new("Frame")
                    L_I_178.Name = "Divider"
                    L_I_178.Size = UDim2.new(0, 1, 0, 20)
                    L_I_178.Position = UDim2.new(1, -1, 0.5, -10)
                    L_I_178.BackgroundColor3 = (function()
                        local L_I_179 = {255, 255, 255}
                        return Color3.fromRGB(L_I_179[1], L_I_179[2], L_I_179[3])
                    end)()
                    L_I_178.BackgroundTransparency = 0.9
                    L_I_178.BorderSizePixel = 0
                    L_I_178.Parent = L_I_170
                end
                
                L_I_163.sections[L_I_169] = {
                    frame = L_I_170,
                    title = L_I_171,
                    value = L_I_174
                }
            end
            
            (function()
                local L_I_180 = {
                    {85, 230, 130},
                    {80, 170, 240},
                    {180, 110, 230}
                }
                
                for L_I_181 = 1, 3 do
                    local L_I_182 = L_I_163.sections[L_I_181].value
                    local L_I_183 = L_I_180[L_I_181]
                    if L_I_182 and L_I_183 then
                        L_I_182.TextColor3 = Color3.fromRGB(L_I_183[1], L_I_183[2], L_I_183[3])
                    end
                end
            end)()
            
            L_I_163.mainFrame.Parent = L_I_163.screenGui
            L_I_163.screenGui.Parent = L_I_163.player:WaitForChild("PlayerGui")
            
            L_I_163:SetupConnections()
        end
        
        L_I_3.SetupConnections = function(L_I_184)
            local L_I_185 = L_I_2["RunService"]
            table.insert(L_I_184.connections, L_I_185.RenderStepped:Connect(function(L_I_186)
                L_I_184:UpdateFPS(L_I_186)
                L_I_184.lastUpdate = L_I_184.lastUpdate + L_I_186
                if L_I_184.lastUpdate >= L_I_184.updateInterval then
                    L_I_184:UpdatePing()
                    L_I_184:UpdateInfo()
                    L_I_184.lastUpdate = 0
                end
            end))
            
            local L_I_187 = L_I_2["UserInputService"]
            table.insert(L_I_184.connections, L_I_187.InputBegan:Connect(function(L_I_188, L_I_189)
                if not L_I_189 and L_I_188.KeyCode == Enum.KeyCode.F5 then
                    L_I_184.showHUD = not L_I_184.showHUD
                    L_I_184.screenGui.Enabled = L_I_184.showHUD
                end
            end))
        end
        
        L_I_3.UpdateFPS = function(L_I_190, L_I_191)
            L_I_190.fpsTime = L_I_190.fpsTime + L_I_191
            L_I_190.fpsCounter = L_I_190.fpsCounter + 1
            if L_I_190.fpsTime >= 1 then
                L_I_190.fps = math.floor(L_I_190.fpsCounter / L_I_190.fpsTime)
                L_I_190.fpsCounter = 0
                L_I_190.fpsTime = 0
                L_I_190.sections[1].value.Text = tostring(L_I_190.fps)
            end
        end
        
        L_I_3.UpdatePing = function(L_I_192)
            local L_I_193, L_I_194 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            L_I_192.sections[2].value.Text = (L_I_193 and L_I_194 or -1) .. "ms"
        end
        
        L_I_3.UpdateInfo = function(L_I_195)
            if L_I_195.showGameTime then
                local L_I_196 = os.clock() - L_I_195.startTime
                local L_I_197 = math.floor(L_I_196 / 60)
                local L_I_198 = math.floor(L_I_196 % 60)
                L_I_195.sections[3].value.Text = string.format("%02d:%02d", L_I_197, L_I_198)
            else
                local L_I_199 = L_I_2["Workspace"].CurrentCamera
                if L_I_199 then
                    local L_I_200 = L_I_199.CFrame.LookVector
                    local L_I_201 = math.deg(math.asin(-L_I_200.Y))
                    local L_I_202 = math.deg(math.atan2(-L_I_200.X, -L_I_200.Z))
                    L_I_195.sections[3].value.Text = string.format("%.0f°,%.0f°", L_I_202 % 360, L_I_201)
                else
                    L_I_195.sections[3].value.Text = "CV: N/A"
                end
            end
        end
        
        L_I_3.InitializeKillAura = function(L_I_203)
            local L_I_204 = function()
                local L_I_205 = {}
                local L_I_206, L_I_207 = pcall(function()
                    return require(L_I_2["ReplicatedStorage"].Modules.Net)
                end)
                
                if L_I_206 and L_I_207 then
                    if L_I_207.RemoteEvent then
                        L_I_205.RegisterAttack = L_I_207:RemoteEvent("RegisterAttack")
                        L_I_205.RegisterHit = L_I_207:RemoteEvent("RegisterHit", true)
                    elseif L_I_207.RE then
                        L_I_205.RegisterAttack = L_I_207.RE:WaitForChild("RegisterAttack")
                        L_I_205.RegisterHit = L_I_207.RE:WaitForChild("RegisterHit")
                    end
                end
                
                if not L_I_205.RegisterAttack then
                    local L_I_208 = L_I_2["ReplicatedStorage"]:FindFirstChild("Modules")
                    if L_I_208 and L_I_208:FindFirstChild("Net") then
                        local L_I_209 = L_I_208.Net
                        if L_I_209:FindFirstChild("RE") then
                            L_I_205.RegisterAttack = L_I_209.RE:WaitForChild("RegisterAttack")
                            L_I_205.RegisterHit = L_I_209.RE:WaitForChild("RegisterHit")
                        elseif L_I_209:FindFirstChild("RemoteEvent") then
                            L_I_205.RegisterAttack = L_I_209.RemoteEvent:WaitForChild("RegisterAttack")
                            L_I_205.RegisterHit = L_I_209.RemoteEvent:WaitForChild("RegisterHit")
                        end
                    end
                end
                
                if not L_I_205.RegisterAttack then
                    L_I_205.RegisterAttack = L_I_2["ReplicatedStorage"]:FindFirstChild("RegisterAttack", true)
                    L_I_205.RegisterHit = L_I_2["ReplicatedStorage"]:FindFirstChild("RegisterHit", true)
                end
                
                return L_I_205
            end
            
            task.spawn(function()
                while task.wait(0.5) do
                    if L_I_203.player.Character then
                        local L_I_210 = L_I_203.player.Character:FindFirstChild("Stun")
                        if L_I_210 then L_I_210.Value = 0 end
                        local L_I_211 = L_I_203.player.Character:FindFirstChild("Busy")
                        if L_I_211 then L_I_211.Value = false end
                    end
                end
            end)
            
            task.spawn(function()
                local L_I_212 = L_I_204()
                if not L_I_212.RegisterAttack then return end
                
                local L_I_213 = 0
                
                while task.wait(0) do
                    if not L_I_203.killAuraSettings.Enabled then
                        task.wait(0.1)
                        continue
                    end
                    
                    local L_I_214 = tick()
                    if L_I_214 - L_I_213 < L_I_203.killAuraSettings.Cooldown then
                        continue
                    end
                    
                    if L_I_203.player.Character and L_I_203.player.Character:FindFirstChild("HumanoidRootPart") then
                        local L_I_215 = L_I_203.player.Character.HumanoidRootPart.Position
                        
                        if L_I_203.killAuraSettings.AttackNPC then
                            local L_I_216 = L_I_2["Workspace"]:FindFirstChild("Enemies")
                            if L_I_216 then
                                for L_I_217, L_I_218 in pairs(L_I_216:GetChildren()) do
                                    if L_I_218:FindFirstChild("HumanoidRootPart") and L_I_218:FindFirstChildOfClass("Humanoid") then
                                        local L_I_219 = (L_I_218.HumanoidRootPart.Position - L_I_215).Magnitude
                                        if L_I_219 <= L_I_203.killAuraSettings.Range and L_I_218:FindFirstChildOfClass("Humanoid").Health > 0 then
                                            pcall(function()
                                                L_I_212.RegisterAttack:FireServer(1)
                                            end)
                                            if L_I_212.RegisterHit then
                                                pcall(function()
                                                    L_I_212.RegisterHit:FireServer(
                                                        L_I_218.HumanoidRootPart, 
                                                        {{L_I_218, L_I_218.HumanoidRootPart}},
                                                        nil,
                                                        tostring(tick())
                                                    )
                                                end)
                                            end
                                            L_I_213 = L_I_214
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        
                        if L_I_203.killAuraSettings.AttackPlayers then
                            for L_I_220, L_I_221 in pairs(L_I_2["Players"]:GetPlayers()) do
                                if L_I_221 ~= L_I_203.player and L_I_221.Character and L_I_221.Character:FindFirstChild("HumanoidRootPart") then
                                    local L_I_222 = L_I_221.Character
                                    if L_I_222:FindFirstChildOfClass("Humanoid") then
                                        local L_I_223 = (L_I_222.HumanoidRootPart.Position - L_I_215).Magnitude
                                        local L_I_224 = true
                                        
                                        if L_I_203.killAuraSettings.TeamCheck and L_I_203.player.Team and L_I_221.Team then
                                            L_I_224 = L_I_203.player.Team ~= L_I_221.Team
                                        end
                                        
                                        if L_I_223 <= L_I_203.killAuraSettings.Range and L_I_224 and L_I_222:FindFirstChildOfClass("Humanoid").Health > 0 then
                                            pcall(function()
                                                L_I_212.RegisterAttack:FireServer(1)
                                            end)
                                            if L_I_212.RegisterHit then
                                                pcall(function()
                                                    L_I_212.RegisterHit:FireServer(
                                                        L_I_222.HumanoidRootPart, 
                                                        {{L_I_222, L_I_222.HumanoidRootPart}},
                                                        nil,
                                                        tostring(tick())
                                                    )
                                                end)
                                            end
                                            L_I_213 = L_I_214
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
        
        L_I_3.Toggle = function(L_I_225)
            L_I_225.showHUD = not L_I_225.showHUD
            L_I_225.screenGui.Enabled = L_I_225.showHUD
            return L_I_225.showHUD
        end
        
        L_I_3.toggleHighlighter = function(L_I_226)
            L_I_226.highlighterSettings.Enabled = not L_I_226.highlighterSettings.Enabled
            for L_I_227, L_I_228 in pairs(L_I_226.highlightCache) do
                if L_I_228.Highlight then
                    L_I_228.Highlight.Enabled = L_I_226.highlighterSettings.Enabled
                end
                if L_I_228.Billboard then
                    L_I_228.Billboard.Enabled = L_I_226.highlighterSettings.Enabled
                end
            end
            return L_I_226.highlighterSettings.Enabled
        end
        
        L_I_3.toggleKillAura = function(L_I_229)
            L_I_229.killAuraSettings.Enabled = not L_I_229.killAuraSettings.Enabled
            return L_I_229.killAuraSettings.Enabled
        end
        
        L_I_3.setKillAuraRange = function(L_I_230, L_I_231)
            if type(L_I_231) == "number" and L_I_231 > 0 then
                L_I_230.killAuraSettings.Range = L_I_231
                return true
            end
            return false
        end
        
        L_I_3.Destroy = function(L_I_232)
            for L_I_233, L_I_234 in pairs(L_I_232.connections) do
                L_I_234:Disconnect()
            end
            for L_I_235, L_I_236 in pairs(L_I_232.highlighterConnections) do
                L_I_236:Disconnect()
            end
            for L_I_237, L_I_238 in pairs(L_I_232.highlightCache) do
                if L_I_238.Highlight then L_I_238.Highlight:Destroy() end
                if L_I_238.Billboard then L_I_238.Billboard:Destroy() end
            end
            if L_I_232.screenGui then
                L_I_232.screenGui:Destroy()
            end
            (function()
                local L_I_239 = {"g", "e", "t", "g", "e", "n", "v"}
                local L_I_240 = _G[table.concat(L_I_239)]
                if L_I_240 then
                    L_I_240()._DeltaHUDInstance = nil
                end
            end)()
        end
        
        local L_I_10 = L_I_3.new()
        return L_I_10
    ]]))
    
    if L_I_1 then
        local L_I_241 = (function()
            local L_I_242 = {"p", "c", "a", "l", "l"}
            return _G[table.concat(L_I_242)]
        end)()
        
        local L_I_243, L_I_244 = L_I_241(L_I_1)
        
        (function()
            if not L_I_243 then
                local L_I_245 = function() end
                for L_I_246 = 1, 10 do
                    L_I_245()
                end
            end
        end)()
    end
end)()