local P=game:GetService("Players")
local R=game:GetService("RunService")
local W=game:GetService("Workspace")
local U=game:GetService("UserInputService")
local S=game:GetService("ReplicatedStorage")
local T=game:GetService("TweenService")

local D={}
D.__index=D

getgenv().DeltaHUD=D

function D.new()
    if getgenv()._DeltaHUDInstance then
        getgenv()._DeltaHUDInstance:Destroy()
    end
    
    local self=setmetatable({},D)
    
    self.p=P.LocalPlayer
    self.showHUD=true
    self.lastUpdate=0
    self.updateInterval=0.3
    self.fps=0
    self.fpsCounter=0
    self.fpsTime=0
    self.startTime=os.clock()
    self.showGameTime=false
    self.connections={}
    self.highlighterConnections={}
    self.highlightCache={}
    self.speedEnabled=false
    self.espEnabled=false
    self.fruitESP={}
    self.farmFruits=false
    self.currentFruit=nil
    self.platforms={}
    self.speedValue=100
    self.speedStep=1
    
    self.highlighterSettings={
        Enabled=true,
        OutlineColor=Color3.fromRGB(85,170,255),
        OutlineTransparency=0,
        OutlineThickness=3,
        NameTagColor=Color3.fromRGB(255,255,255),
        NameTagOutlineColor=Color3.fromRGB(0,0,0),
        NameTagSize=14,
        NameTagFont=Enum.Font.GothamMedium,
        NameTagOffset=Vector3.new(0,8.5,0),
        TeamColor=false,
        ShowDistance=true,
        MaxDistance=10000,
        ShowHPBar=true
    }
    
    getgenv()._DeltaHUDInstance=self
    
    self:Initialize()
    self:InitializeHighlighter()
    self:InitializeSpeed()
    self:InitializeFruitESP()
    
    return self
end

function D:InitializeSpeed()
    local function applySpeed()
        local c=self.p.Character
        if not c then return end
        local h=c:FindFirstChild("Humanoid")
        local r=c:FindFirstChild("HumanoidRootPart")
        if not h or not r then return end
        
        h.WalkSpeed=self.speedEnabled and self.speedValue or 16
        
        if self.speedEnabled then
            local bv=r:FindFirstChild("DeltaSpeedBV")
            if not bv then
                bv=Instance.new("BodyVelocity")
                bv.Name="DeltaSpeedBV"
                bv.MaxForce=Vector3.new(100000,0,100000)
                bv.Velocity=Vector3.new(0,0,0)
                bv.P=r
            end
        else
            local bv=r:FindFirstChild("DeltaSpeedBV")
            if bv then bv:Destroy() end
        end
    end
    
    table.insert(self.connections,R.Heartbeat:Connect(function()
        if self.speedEnabled then
            self.speedValue=math.min(self.speedValue+self.speedStep,100)
            applySpeed()
        end
    end))
    
    self.p.CharacterAdded:Connect(applySpeed)
    if self.p.Character then applySpeed() end
end

function D:InitializeFruitESP()
    local function updateFruitESP()
        for f,_ in pairs(self.fruitESP) do
            if not f or not f.Parent then
                self.fruitESP[f]=nil
            end
        end
        
        if not self.espEnabled then return end
        
        local fruitsFolder=W:FindFirstChild("Fruits") or W:FindFirstChild("Fruit") or W:FindFirstChild("Drops")
        if not fruitsFolder then return end
        
        local c=self.p.Character
        local r=c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        
        for _,f in pairs(fruitsFolder:GetChildren()) do
            if f:IsA("BasePart") or (f:IsA("Model") and f.PrimaryPart) then
                local pos=f:IsA("BasePart") and f.Position or f.PrimaryPart.Position
                local dist=(pos-r.Position).Magnitude
                
                if dist<300 then
                    if not self.fruitESP[f] then
                        local h=Instance.new("Highlight")
                        h.Name="FruitESP"
                        h.Adornee=f
                        h.FillColor=Color3.fromRGB(255,255,0)
                        h.FillTransparency=0.7
                        h.OutlineColor=Color3.fromRGB(255,100,0)
                        h.OutlineTransparency=0
                        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent=f
                        
                        local b=Instance.new("BillboardGui")
                        b.Name="FruitTag"
                        b.Adornee=f:IsA("BasePart") and f or f.PrimaryPart
                        b.Size=UDim2.new(0,200,0,30)
                        b.StudsOffset=Vector3.new(0,3,0)
                        b.AlwaysOnTop=true
                        b.MaxDistance=1000
                        
                        local t=Instance.new("TextLabel")
                        t.Name="Label"
                        t.Size=UDim2.new(1,0,1,0)
                        t.BackgroundTransparency=1
                        t.TextColor3=Color3.fromRGB(255,255,0)
                        t.TextStrokeColor3=Color3.fromRGB(0,0,0)
                        t.TextStrokeTransparency=0
                        t.TextSize=14
                        t.Font=Enum.Font.GothamBold
                        t.Text=f.Name~="" and string.format("{ %s } | %dm",f.Name,math.floor(dist)) or "{ ??? } | "..math.floor(dist).."m"
                        t.Parent=b
                        b.Parent=f
                        
                        self.fruitESP[f]={h=h,b=b}
                    else
                        local tag=self.fruitESP[f].b
                        if tag and tag.Label then
                            tag.Label.Text=f.Name~="" and string.format("{ %s } | %dm",f.Name,math.floor(dist)) or "{ ??? } | "..math.floor(dist).."m"
                            tag.Label.TextColor3=dist>200 and Color3.fromRGB(255,50,50) or Color3.fromRGB(255,255,0)
                        end
                    end
                elseif self.fruitESP[f] then
                    self.fruitESP[f].h:Destroy()
                    self.fruitESP[f].b:Destroy()
                    self.fruitESP[f]=nil
                end
            end
        end
    end
    
    table.insert(self.connections,R.Heartbeat:Connect(function()
        if self.farmFruits then
            local c=self.p.Character
            local r=c and c:FindFirstChild("HumanoidRootPart")
            if not r then return end
            
            local closest=nil
            local minDist=math.huge
            
            local fruitsFolder=W:FindFirstChild("Fruits") or W:FindFirstChild("Fruit") or W:FindFirstChild("Drops")
            if not fruitsFolder then return end
            
            for _,f in pairs(fruitsFolder:GetChildren()) do
                if f:IsA("BasePart") or (f:IsA("Model") and f.PrimaryPart) then
                    local pos=f:IsA("BasePart") and f.Position or f.PrimaryPart.Position
                    local dist=(pos-r.Position).Magnitude
                    if dist<minDist then
                        minDist=dist
                        closest=f
                    end
                end
            end
            
            if closest then
                local pos=closest:IsA("BasePart") and closest.Position or closest.PrimaryPart.Position
                local bv=r:FindFirstChild("DeltaFlyBV")
                if not bv then
                    bv=Instance.new("BodyVelocity")
                    bv.Name="DeltaFlyBV"
                    bv.MaxForce=Vector3.new(100000,100000,100000)
                    bv.P=r
                end
                
                local dir=(pos-r.Position).Unit
                bv.Velocity=dir*400
                self.currentFruit=closest
            elseif self.currentFruit then
                local bv=r:FindFirstChild("DeltaFlyBV")
                if bv then bv.Velocity=Vector3.new(0,0,0) end
                self.currentFruit=nil
            end
        else
            local bv=self.p.Character and self.p.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("DeltaFlyBV")
            if bv then bv:Destroy() end
        end
        
        updateFruitESP()
    end))
end

function D:Initialize()
    if self.p.PlayerGui:FindFirstChild("DeltaHUD") then
        self.p.PlayerGui.DeltaHUD:Destroy()
    end
    
    self.sg=Instance.new("ScreenGui")
    self.sg.Name="DeltaHUD"
    self.sg.DisplayOrder=999
    self.sg.IgnoreGuiInset=true
    self.sg.ResetOnSpawn=false
    
    self.mf=Instance.new("Frame")
    self.mf.Name="MainFrame"
    self.mf.Size=UDim2.new(0,300,0,40)
    self.mf.Position=UDim2.new(0.5,-150,0,10)
    self.mf.BackgroundColor3=Color3.fromRGB(15,15,20)
    self.mf.BackgroundTransparency=0.2
    self.mf.BorderSizePixel=0
    
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,6)
    c.Parent=self.mf
    
    self.secs={}
    local w=100
    
    for i=1,3 do
        local sf=Instance.new("Frame")
        sf.Name="Sec"..i
        sf.Size=UDim2.new(0,w,1,0)
        sf.Position=UDim2.new(0,(i-1)*w,0,0)
        sf.BackgroundTransparency=1
        sf.BorderSizePixel=0
        sf.Parent=self.mf
        
        local tl=Instance.new("TextLabel")
        tl.Name="Title"
        tl.Size=UDim2.new(1,0,0,16)
        tl.Position=UDim2.new(0,0,0,4)
        tl.BackgroundTransparency=1
        tl.TextColor3=Color3.fromRGB(180,180,180)
        tl.TextSize=11
        tl.Font=Enum.Font.GothamMedium
        tl.Text=i==1 and "FPS" or (i==2 and "PING" or "INFO")
        tl.TextXAlignment=Enum.TextXAlignment.Center
        tl.Parent=sf
        
        local vl=Instance.new("TextLabel")
        vl.Name="Value"
        vl.Size=UDim2.new(1,0,0,18)
        vl.Position=UDim2.new(0,0,0,18)
        vl.BackgroundTransparency=1
        vl.TextColor3=Color3.fromRGB(255,255,255)
        vl.TextSize=13
        vl.Font=Enum.Font.GothamBold
        vl.Text=i==1 and "0" or (i==2 and "0ms" or "CV:0")
        vl.TextXAlignment=Enum.TextXAlignment.Center
        vl.Parent=sf
        
        if i==3 then
            local btn=Instance.new("TextButton")
            btn.Name="ToggleBtn"
            btn.Size=UDim2.new(1,0,1,0)
            btn.Position=UDim2.new(0,0,0,0)
            btn.BackgroundTransparency=1
            btn.Text=""
            btn.Parent=sf
        end
        
        if i<3 then
            local d=Instance.new("Frame")
            d.Name="Divider"
            d.Size=UDim2.new(0,1,0,20)
            d.Position=UDim2.new(1,-1,0.5,-10)
            d.BackgroundColor3=Color3.fromRGB(255,255,255)
            d.BackgroundTransparency=0.9
            d.BorderSizePixel=0
            d.Parent=sf
        end
        
        self.secs[i]={f=sf,t=tl,v=vl}
    end
    
    self:CreateButtons()
    self.mf.Parent=self.sg
    self.sg.Parent=self.p:WaitForChild("PlayerGui")
    
    self:SetupConnections()
end

function D:CreateButtons()
    local btnFrame=Instance.new("Frame")
    btnFrame.Name="Buttons"
    btnFrame.Size=UDim2.new(0,350,0,80)
    btnFrame.Position=UDim2.new(0.5,-175,0,60)
    btnFrame.BackgroundTransparency=1
    btnFrame.Parent=self.sg
    
    local buttons={
        {name="Speed", color=Color3.fromRGB(85,170,255), toggle="speedEnabled"},
        {name="Esp/Farm", color=Color3.fromRGB(255,170,0), toggle="espEnabled"},
        {name="Farm Fruits", color=Color3.fromRGB(255,85,85), toggle="farmFruits"},
        {name="Save Pos", color=Color3.fromRGB(0,200,0), func="SavePosition"}
    }
    
    for i,btnData in ipairs(buttons) do
        local btn=Instance.new("TextButton")
        btn.Name=btnData.name
        btn.Size=UDim2.new(0,80,0,30)
        btn.Position=UDim2.new(0,(i-1)*85,0,0)
        btn.BackgroundColor3=btnData.color
        btn.BackgroundTransparency=0.2
        btn.Text=btnData.name
        btn.TextColor3=Color3.fromRGB(255,255,255)
        btn.TextSize=12
        btn.Font=Enum.Font.GothamBold
        btn.BorderSizePixel=0
        
        local c=Instance.new("UICorner")
        c.CornerRadius=UDim.new(0,6)
        c.Parent=btn
        
        if btnData.toggle then
            btn.MouseButton1Click:Connect(function()
                self[btnData.toggle]=not self[btnData.toggle]
                btn.BackgroundTransparency=self[btnData.toggle] and 0 or 0.2
            end)
        elseif btnData.func then
            btn.MouseButton1Click:Connect(function()
                self[btnData.func]()
            end)
        end
        
        if btnData.toggle=="farmFruits" then
            btn.MouseButton1Click:Connect(function()
                self.espEnabled=true
                for _,esp in pairs(self.fruitESP) do
                    if esp.h then esp.h.Enabled=true end
                    if esp.b then esp.b.Enabled=true end
                end
            end)
        end
        
        btn.Parent=btnFrame
    end
    
    local platBtn=Instance.new("TextButton")
    platBtn.Name="HighPlatform"
    platBtn.Size=UDim2.new(0,80,0,30)
    platBtn.Position=UDim2.new(0,0,0,40)
    platBtn.BackgroundColor3=Color3.fromRGB(170,85,255)
    platBtn.BackgroundTransparency=0.2
    platBtn.Text="High Platform"
    platBtn.TextColor3=Color3.fromRGB(255,255,255)
    platBtn.TextSize=12
    platBtn.Font=Enum.Font.GothamBold
    platBtn.BorderSizePixel=0
    
    local c2=Instance.new("UICorner")
    c2.CornerRadius=UDim.new(0,6)
    c2.Parent=platBtn
    
    platBtn.MouseButton1Click:Connect(function()
        self:CreateHighPlatform()
    end)
    platBtn.Parent=btnFrame
end

function D:SavePosition()
    local c=self.p.Character
    if not c then return end
    local r=c:FindFirstChild("HumanoidRootPart")
    if not r then return end
    
    for _,p in pairs(self.platforms) do
        if p then p:Destroy() end
    end
    self.platforms={}
    
    local origPos=r.Position
    local plat=Instance.new("Part")
    plat.Name="DeltaPlatform"
    plat.Size=Vector3.new(100,1,100)
    plat.Position=origPos
    plat.Anchored=true
    plat.CanCollide=true
    plat.Transparency=0.3
    plat.Color=Color3.fromRGB(85,170,255)
    plat.Material=Enum.Material.Neon
    plat.Parent=W
    table.insert(self.platforms,plat)
    
    r.CFrame=CFrame.new(origPos+Vector3.new(0,5,0))
end

function D:CreateHighPlatform()
    local c=self.p.Character
    if not c then return end
    local r=c:FindFirstChild("HumanoidRootPart")
    if not r then return end
    
    for _,p in pairs(self.platforms) do
        if p then p:Destroy() end
    end
    self.platforms={}
    
    local targetPos=r.Position+Vector3.new(0,2500,0)
    local plat=Instance.new("Part")
    plat.Name="DeltaHighPlatform"
    plat.Size=Vector3.new(100,1,100)
    plat.Position=targetPos
    plat.Anchored=true
    plat.CanCollide=true
    plat.Transparency=0.3
    plat.Color=Color3.fromRGB(255,85,170)
    plat.Material=Enum.Material.Neon
    plat.Parent=W
    table.insert(self.platforms,plat)
    
    local bv=r:FindFirstChild("DeltaPlatformBV")
    if not bv then
        bv=Instance.new("BodyVelocity")
        bv.Name="DeltaPlatformBV"
        bv.MaxForce=Vector3.new(100000,100000,100000)
        bv.P=r
    end
    
    local dir=(targetPos-r.Position).Unit
    bv.Velocity=dir*350
    
    R.Heartbeat:Connect(function()
        if not bv then return end
        local dist=(targetPos-r.Position).Magnitude
        if dist<10 then
            bv:Destroy()
            r.CFrame=CFrame.new(targetPos+Vector3.new(0,5,0))
        else
            dir=(targetPos-r.Position).Unit
            bv.Velocity=dir*350
        end
    end)
end

function D:InitializeFastAttack()
    local remotes={}
    local success,netModule=pcall(function() return require(S.Modules.Net) end)
    
    if success and netModule then
        if netModule.RemoteEvent then
            remotes.Attack=netModule:RemoteEvent("RegisterAttack")
            remotes.Hit=netModule:RemoteEvent("RegisterHit",true)
        elseif netModule.RE then
            remotes.Attack=netModule.RE:WaitForChild("RegisterAttack")
            remotes.Hit=netModule.RE:WaitForChild("RegisterHit")
        end
    end
    
    task.spawn(function()
        local lastAttack=0
        while task.wait(0) do
            local now=tick()
            if now-lastAttack<0.05 then continue end
            
            local c=self.p.Character
            if not c then continue end
            local r=c:FindFirstChild("HumanoidRootPart")
            if not r then continue end
            
            local stun=c:FindFirstChild("Stun")
            if stun then stun.Value=0 end
            local busy=c:FindFirstChild("Busy")
            if busy then busy.Value=false end
            
            local targets={}
            local pos=r.Position
            
            for _,e in pairs(W.Enemies:GetChildren()) do
                if e:FindFirstChild("HumanoidRootPart") then
                    local dist=(e.HumanoidRootPart.Position-pos).Magnitude
                    if dist<50 then table.insert(targets,e) end
                end
            end
            
            for _,plr in pairs(P:GetPlayers()) do
                if plr~=self.p and plr.Character then
                    local tc=plr.Character
                    local tr=tc:FindFirstChild("HumanoidRootPart")
                    if tr then
                        local dist=(tr.Position-pos).Magnitude
                        if dist<50 then table.insert(targets,tc) end
                    end
                end
            end
            
            if #targets>0 and remotes.Attack then
                pcall(function()
                    remotes.Attack:FireServer(1)
                    lastAttack=now
                end)
            end
        end
    end)
end

function D:InitializeHighlighter()
    for plr,d in pairs(self.highlightCache) do
        if d.H then d.H:Destroy() end
        if d.B then d.B:Destroy() end
    end
    
    self.highlightCache={}
    
    for _,plr in ipairs(P:GetPlayers()) do
        if plr~=self.p then
            self:onPlayerAdded(plr)
        end
    end
    
    table.insert(self.highlighterConnections,P.PlayerAdded:Connect(function(plr)
        self:onPlayerAdded(plr)
    end))
    
    table.insert(self.highlighterConnections,P.PlayerRemoving:Connect(function(plr)
        self:onPlayerRemoving(plr)
    end))
    
    R.Heartbeat:Connect(function()
        if not self.highlighterSettings.Enabled then return end
        for plr,hd in pairs(self.highlightCache) do
            if not self:updateNameTag(hd) then
                self.highlightCache[plr]=nil
            end
        end
    end)
end

function D:createHPBar(model)
    local bar=Instance.new("Frame")
    bar.Name="HPBar"
    bar.Size=UDim2.new(1.5,0,0,6)
    bar.Position=UDim2.new(-0.25,0,0,-12)
    bar.BackgroundColor3=Color3.fromRGB(60,60,60)
    bar.BorderSizePixel=0
    
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,3)
    corner.Parent=bar
    
    local fill=Instance.new("Frame")
    fill.Name="Fill"
    fill.Size=UDim2.new(1,0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(0,255,0)
    fill.BorderSizePixel=0
    fill.Parent=bar
    
    local fCorner=Instance.new("UICorner")
    fCorner.CornerRadius=UDim.new(0,3)
    fCorner.Parent=fill
    
    return bar
end

function D:createHighlight(model,plr)
    if not model or not model:IsA("Model") then return nil end
    
    local h=Instance.new("Highlight")
    h.Name="PlayerHighlight"
    h.Adornee=model
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency=1
    h.OutlineColor=self.highlighterSettings.OutlineColor
    h.OutlineTransparency=self.highlighterSettings.OutlineTransparency
    h.Enabled=self.highlighterSettings.Enabled
    
    if self.highlighterSettings.TeamColor and plr.Team then
        h.OutlineColor=plr.Team.TeamColor.Color
    end
    
    h.Parent=model
    
    local b=Instance.new("BillboardGui")
    b.Name="PlayerNameTag"
    b.Adornee=model:FindFirstChild("Head") or model.PrimaryPart or model
    b.Size=UDim2.new(0,200,0,50)
    b.StudsOffset=Vector3.new(0,8.5,0)
    b.AlwaysOnTop=true
    b.MaxDistance=self.highlighterSettings.MaxDistance
    b.Enabled=self.highlighterSettings.Enabled
    
    local t=Instance.new("TextLabel")
    t.Name="NameText"
    t.Size=UDim2.new(1,0,1,0)
    t.BackgroundTransparency=1
    t.TextColor3=self.highlighterSettings.NameTagColor
    t.TextSize=self.highlighterSettings.NameTagSize
    t.Font=self.highlighterSettings.NameTagFont
    t.TextStrokeTransparency=0
    t.TextStrokeColor3=self.highlighterSettings.NameTagOutlineColor
    t.Text=plr.Name
    t.TextYAlignment=Enum.TextYAlignment.Center
    t.Parent=b
    b.Parent=model
    
    local hpBar
    if self.highlighterSettings.ShowHPBar then
        hpBar=self:createHPBar(b)
        hpBar.Parent=b
        t.Position=UDim2.new(0,0,0,10)
        t.Size=UDim2.new(1,0,0,20)
    end
    
    return {H=h,B=b,P=plr,M=model,HPBar=hpBar}
end

function D:updateNameTag(hd)
    if not hd or not hd.M or not hd.M.PrimaryPart then return false end
    local plr=hd.P
    local m=hd.M
    local b=hd.B
    local h=hd.H
    
    if not plr or plr.Parent~=P or not m.Parent then
        if h then h:Destroy() end
        if b then b:Destroy() end
        return false
    end
    
    local c=self.p.Character
    if not c or not c.PrimaryPart then return true end
    local dist=(c.PrimaryPart.Position-m.PrimaryPart.Position).Magnitude
    
    if dist>self.highlighterSettings.MaxDistance then
        h.Enabled=false
        b.Enabled=false
        return true
    end
    
    h.Enabled=self.highlighterSettings.Enabled
    b.Enabled=self.highlighterSettings.Enabled
    
    local hpText=""
    local hpPercent=1
    local hum=m:FindFirstChildOfClass("Humanoid")
    
    if hum then
        local hp=math.floor(hum.Health)
        local max=math.floor(hum.MaxHealth)
        hpText=string.format("[%d/%d]",hp,max)
        hpPercent=math.max(0,math.min(1,hum.Health/hum.MaxHealth))
    else
        local data=m:FindFirstChild("Data")
        if data then
            local lvl=data:FindFirstChild("Level")
            if lvl then hpText=string.format("[LVL:%d]",lvl.Value) end
        end
    end
    
    if b and b.NameText then
        if self.highlighterSettings.ShowDistance then
            b.NameText.Text=string.format("%s [%dm]\n%s", plr.Name, math.floor(dist), hpText)
        else
            b.NameText.Text=string.format("%s\n%s",plr.Name,hpText)
        end
    end
    
    if hd.HPBar then
        hd.HPBar.Fill.Size=UDim2.new(hpPercent,0,1,0)
    end
    
    if self.highlighterSettings.TeamColor and plr.Team then
        h.OutlineColor=plr.Team.TeamColor.Color
    end
    
    return true
end

function D:onPlayerAdded(plr)
    if plr==self.p then return end
    
    local function charAdded(char)
        if not char then return end
        task.wait(0.5)
        if char and char:IsA("Model") then
            if self.highlightCache[plr] then
                local old=self.highlightCache[plr]
                if old.H then old.H:Destroy() end
                if old.B then old.B:Destroy() end
            end
            local hd=self:createHighlight(char,plr)
            if hd then self.highlightCache[plr]=hd end
        end
    end
    
    local conn=plr.CharacterAdded:Connect(charAdded)
    table.insert(self.highlighterConnections,conn)
    
    if plr.Character then charAdded(plr.Character) end
    
    local remConn=plr.AncestryChanged:Connect(function(_,par)
        if not par then
            if self.highlightCache[plr] then
                local d=self.highlightCache[plr]
                if d.H then d.H:Destroy() end
                if d.B then d.B:Destroy() end
                self.highlightCache[plr]=nil
            end
        end
    end)
    table.insert(self.highlighterConnections,remConn)
end

function D:onPlayerRemoving(plr)
    if self.highlightCache[plr] then
        local d=self.highlightCache[plr]
        if d.H then d.H:Destroy() end
        if d.B then d.B:Destroy() end
        self.highlightCache[plr]=nil
    end
end

function D:SetupConnections()
    table.insert(self.connections,R.RenderStepped:Connect(function(dt)
        self:UpdateFPS(dt)
        self.lastUpdate=self.lastUpdate+dt
        if self.lastUpdate>=self.updateInterval then
            self:UpdatePing()
            self:UpdateInfo()
            self.lastUpdate=0
        end
    end))
    
    table.insert(self.connections,U.InputBegan:Connect(function(i,pr)
        if not pr and i.KeyCode==Enum.KeyCode.F5 then
            self.showHUD=not self.showHUD
            self.sg.Enabled=self.showHUD
        end
    end))
end

function D:UpdateFPS(dt)
    self.fpsTime=self.fpsTime+dt
    self.fpsCounter=self.fpsCounter+1
    if self.fpsTime>=1 then
        self.fps=math.floor(self.fpsCounter/self.fpsTime)
        self.fpsCounter=0
        self.fpsTime=0
        self.secs[1].v.Text=tostring(self.fps)
    end
end

function D:UpdatePing()
    local suc,ping=pcall(function()
        return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    self.secs[2].v.Text=(suc and ping or -1).."ms"
end

function D:UpdateInfo()
    if self.showGameTime then
        local el=os.clock()-self.startTime
        local m=math.floor(el/60)
        local s=math.floor(el%60)
        self.secs[3].v.Text=string.format("%02d:%02d",m,s)
    else
        local cam=W.CurrentCamera
        if cam then
            local l=cam.CFrame.LookVector
            local p=math.deg(math.asin(-l.Y))
            local y=math.deg(math.atan2(-l.X,-l.Z))
            self.secs[3].v.Text=string.format("%.0f°,%.0f°",y%360,p)
        else
            self.secs[3].v.Text="CV:N/A"
        end
    end
end

function D:Destroy()
    for _,c in ipairs(self.connections) do
        c:Disconnect()
    end
    
    for _,c in ipairs(self.highlighterConnections) do
        c:Disconnect()
    end
    
    for plr,d in pairs(self.highlightCache) do
        if d.H then d.H:Destroy() end
        if d.B then d.B:Destroy() end
    end
    
    for _,esp in pairs(self.fruitESP) do
        if esp.h then esp.h:Destroy() end
        if esp.b then esp.b:Destroy() end
    end
    
    for _,p in pairs(self.platforms) do
        if p then p:Destroy() end
    end
    
    self.highlightCache={}
    self.fruitESP={}
    self.platforms={}
    
    if self.sg then self.sg:Destroy() end
end

return D.new()