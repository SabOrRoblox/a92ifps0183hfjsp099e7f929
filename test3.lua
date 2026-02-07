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
    self.hlConnections={}
    self.hlCache={}
    self.fruitESP=false
    self.speedEnabled=false
    self.speedAmount=100
    self.curPlatform=nil
    self.fruitHLs={}
    
    self.hlSettings={
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
    self:InitializeHL()
    self:InitializeSaveBtn()
    self:InitializeFruitBtn()
    self:InitializeSpeedBtn()
    self:InitializeFastAttack()
    self:InitializeSpeedBoost()
    
    return self
end

function D:InitializeSpeedBoost()
    R.Heartbeat:Connect(function()
        if not self.speedEnabled then return end
        local c=self.p.Character
        if not c then return end
        local h=c:FindFirstChild("Humanoid")
        if not h then return end
        
        h.WalkSpeed=self.speedAmount
        
        for _,v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide=false
            end
        end
    end)
end

function D:InitializeSaveBtn()
    local b=Instance.new("TextButton")
    b.Name="SaveBtn"
    b.Size=UDim2.new(0,80,0,35)
    b.Position=UDim2.new(0.5,170,0,10)
    b.BackgroundColor3=Color3.fromRGB(20,20,30)
    b.BackgroundTransparency=0.1
    b.Text="SAVE"
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextSize=13
    b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0
    
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,8)
    c.Parent=b
    
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(85,170,255)
    s.Thickness=2
    s.Parent=b
    
    b.MouseButton1Click:Connect(function()
        self:SavePosition()
    end)
    
    b.Parent=self.sg
end

function D:InitializeFruitBtn()
    local b=Instance.new("TextButton")
    b.Name="FruitBtn"
    b.Size=UDim2.new(0,120,0,35)
    b.Position=UDim2.new(0.5,170,0,50)
    b.BackgroundColor3=Color3.fromRGB(20,30,20)
    b.BackgroundTransparency=0.1
    b.Text="ESP/Fruits OFF"
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextSize=12
    b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0
    
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,8)
    c.Parent=b
    
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(0,255,0)
    s.Thickness=2
    s.Parent=b
    
    b.MouseButton1Click:Connect(function()
        self.fruitESP=not self.fruitESP
        b.Text=self.fruitESP and "ESP/Fruits ON" or "ESP/Fruits OFF"
        s.Color=self.fruitESP and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,50,50)
        
        if self.fruitESP then
            self:StartFruitESP()
        else
            self:StopFruitESP()
        end
    end)
    
    b.Parent=self.sg
end

function D:InitializeSpeedBtn()
    local b=Instance.new("TextButton")
    b.Name="SpeedBtn"
    b.Size=UDim2.new(0,80,0,35)
    b.Position=UDim2.new(0.5,300,0,50)
    b.BackgroundColor3=Color3.fromRGB(30,20,20)
    b.BackgroundTransparency=0.1
    b.Text="SPEED OFF"
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextSize=12
    b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0
    
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,8)
    c.Parent=b
    
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(255,50,50)
    s.Thickness=2
    s.Parent=b
    
    b.MouseButton1Click:Connect(function()
        self.speedEnabled=not self.speedEnabled
        b.Text=self.speedEnabled and "SPEED ON" or "SPEED OFF"
        s.Color=self.speedEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,50,50)
    end)
    
    b.Parent=self.sg
end

function D:SavePosition()
    if self.curPlatform then
        self.curPlatform:Destroy()
        self.curPlatform=nil
    end
    
    local c=self.p.Character
    if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    
    local o=h.Position
    local nh=3000
    local np=o+Vector3.new(0,nh,0)
    
    local d=(np-o).Magnitude
    local sp=350
    
    for _,v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide=false end
    end
    
    local t=T:Create(h,TweenInfo.new(d/sp,Enum.EasingStyle.Linear),{CFrame=CFrame.new(np)})
    t:Play()
    
    task.wait(d/sp)
    
    local p=Instance.new("Part")
    p.Name="SavePlatform"
    p.Size=Vector3.new(100,5,100)
    p.Position=o+Vector3.new(0,-10,0)
    p.Anchored=true
    p.CanCollide=true
    p.Transparency=0.4
    p.Color=Color3.fromRGB(85,170,255)
    p.Material=Enum.Material.Neon
    p.Parent=W
    
    self.curPlatform=p
    
    task.wait(0.1)
    h.CFrame=CFrame.new(p.Position+Vector3.new(0,10,0))
end

function D:StartFruitESP()
    task.spawn(function()
        while self.fruitESP do
            task.wait(0.5)
            
            for _,h in pairs(self.fruitHLs) do
                if h then h:Destroy() end
            end
            self.fruitHLs={}
            
            local c=self.p.Character
            if not c then continue end
            local h=c:FindFirstChild("HumanoidRootPart")
            if not h then continue end
            
            for _,o in pairs(W:GetChildren()) do
                if o.Name=="Fruit" or (o:IsA("Model") and o:FindFirstChild("Handle")) then
                    local ha=o:FindFirstChild("Handle") or o.PrimaryPart
                    if not ha then continue end
                    
                    local d=(h.Position-ha.Position).Magnitude
                    
                    if d>300 then
                        local hl=Instance.new("Highlight")
                        hl.Name="FruitESP"
                        hl.Adornee=o
                        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor=Color3.fromRGB(255,215,0)
                        hl.FillTransparency=0.7
                        hl.OutlineColor=Color3.fromRGB(255,255,0)
                        hl.OutlineTransparency=0
                        hl.Enabled=true
                        hl.Parent=o
                        
                        local bb=Instance.new("BillboardGui")
                        bb.Name="FruitInfo"
                        bb.Adornee=ha
                        bb.Size=UDim2.new(0,200,0,50)
                        bb.StudsOffset=Vector3.new(0,5,0)
                        bb.AlwaysOnTop=true
                        bb.MaxDistance=5000
                        
                        local tl=Instance.new("TextLabel")
                        tl.Name="FruitText"
                        tl.Size=UDim2.new(1,0,1,0)
                        tl.BackgroundTransparency=1
                        tl.TextColor3=Color3.fromRGB(255,255,0)
                        tl.TextSize=12
                        tl.Font=Enum.Font.GothamBold
                        tl.TextStrokeTransparency=0
                        tl.TextStrokeColor3=Color3.fromRGB(0,0,0)
                        tl.Text=string.format("{ ??? } | %dm",math.floor(d))
                        tl.Parent=bb
                        bb.Parent=o
                        
                        table.insert(self.fruitHLs,hl)
                        table.insert(self.fruitHLs,bb)
                    else
                        task.spawn(function()
                            local hrp=c:FindFirstChild("HumanoidRootPart")
                            if not hrp then return end
                            
                            while o.Parent and (hrp.Position-ha.Position).Magnitude>10 and self.fruitESP do
                                local nd=(hrp.Position-ha.Position).Magnitude
                                local sp=200
                                if nd<100 then sp=100 end
                                
                                local t=T:Create(hrp,TweenInfo.new(nd/sp,Enum.EasingStyle.Linear),
                                    {CFrame=CFrame.new(ha.Position)})
                                t:Play()
                                task.wait(nd/sp)
                            end
                        end)
                    end
                end
            end
        end
    end)
end

function D:StopFruitESP()
    for _,h in pairs(self.fruitHLs) do
        if h then h:Destroy() end
    end
    self.fruitHLs={}
end

function D:InitializeFastAttack()
    task.spawn(function()
        while task.wait() do
            local c=self.p.Character
            if not c then continue end
            local h=c:FindFirstChild("HumanoidRootPart")
            if not h then continue end
            
            local s=c:FindFirstChild("Stun")
            if s then s.Value=0 end
            local b=c:FindFirstChild("Busy")
            if b then b.Value=false end
            
            local ts={}
            local p=h.Position
            
            for _,e in pairs(W.Enemies:GetChildren()) do
                if e:FindFirstChild("HumanoidRootPart") and e:FindFirstChildOfClass("Humanoid") then
                    local d=(e.HumanoidRootPart.Position-p).Magnitude
                    if d<50 and e:FindFirstChildOfClass("Humanoid").Health>0 then
                        table.insert(ts,e)
                    end
                end
            end
            
            for _,pl in pairs(P:GetPlayers()) do
                if pl~=self.p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    local tc=pl.Character
                    local d=(tc.HumanoidRootPart.Position-p).Magnitude
                    if d<50 and tc:FindFirstChildOfClass("Humanoid").Health>0 then
                        if not self.p.Team or not pl.Team or self.p.Team~=pl.Team then
                            table.insert(ts,tc)
                        end
                    end
                end
            end
            
            if #ts>0 then
                local suc,ar=pcall(function()
                    return require(S.Modules.Net):RemoteEvent("RegisterAttack")
                end)
                
                if suc and ar then
                    for i=1,3 do
                        pcall(function() ar:FireServer(1) end)
                        task.wait(0.01)
                    end
                end
                
                task.wait(0.05)
            end
        end
    end)
end

function D:InitializeHL()
    for pl,d in pairs(self.hlCache) do
        if d.H then d.H:Destroy() end
        if d.B then d.B:Destroy() end
    end
    
    self.hlCache={}
    
    for _,pl in ipairs(P:GetPlayers()) do
        if pl~=self.p then
            self:onPAdded(pl)
        end
    end
    
    table.insert(self.hlConnections,P.PlayerAdded:Connect(function(pl)
        self:onPAdded(pl)
    end))
    
    table.insert(self.hlConnections,P.PlayerRemoving:Connect(function(pl)
        self:onPRemoving(pl)
    end))
    
    R.Heartbeat:Connect(function()
        if not self.hlSettings.Enabled then return end
        for pl,hd in pairs(self.hlCache) do
            if not self:updateNT(hd) then
                self.hlCache[pl]=nil
            end
        end
    end)
end

function D:createHPBar(m)
    local b=Instance.new("Frame")
    b.Name="HPBar"
    b.Size=UDim2.new(1.5,0,0,6)
    b.Position=UDim2.new(-0.25,0,0,-12)
    b.BackgroundColor3=Color3.fromRGB(60,60,60)
    b.BorderSizePixel=0
    
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,3)
    c.Parent=b
    
    local f=Instance.new("Frame")
    f.Name="Fill"
    f.Size=UDim2.new(1,0,1,0)
    f.BackgroundColor3=Color3.fromRGB(0,255,0)
    f.BorderSizePixel=0
    f.Parent=b
    
    local fc=Instance.new("UICorner")
    fc.CornerRadius=UDim.new(0,3)
    fc.Parent=f
    
    return b
end

function D:createHL(m,pl)
    if not m or not m:IsA("Model") then return nil end
    
    local h=Instance.new("Highlight")
    h.Name="PlayerHL"
    h.Adornee=m
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency=1
    h.OutlineColor=self.hlSettings.OutlineColor
    h.OutlineTransparency=self.hlSettings.OutlineTransparency
    h.Enabled=self.hlSettings.Enabled
    
    if self.hlSettings.TeamColor and pl.Team then
        h.OutlineColor=pl.Team.TeamColor.Color
    end
    
    h.Parent=m
    
    local b=Instance.new("BillboardGui")
    b.Name="PlayerNT"
    b.Adornee=m:FindFirstChild("Head") or m.PrimaryPart or m
    b.Size=UDim2.new(0,200,0,50)
    b.StudsOffset=Vector3.new(0,8.5,0)
    b.AlwaysOnTop=true
    b.MaxDistance=self.hlSettings.MaxDistance
    b.Enabled=self.hlSettings.Enabled
    
    local t=Instance.new("TextLabel")
    t.Name="NameText"
    t.Size=UDim2.new(1,0,1,0)
    t.BackgroundTransparency=1
    t.TextColor3=self.hlSettings.NameTagColor
    t.TextSize=self.hlSettings.NameTagSize
    t.Font=self.hlSettings.NameTagFont
    t.TextStrokeTransparency=0
    t.TextStrokeColor3=self.hlSettings.NameTagOutlineColor
    t.Text=pl.Name
    t.TextYAlignment=Enum.TextYAlignment.Center
    t.Parent=b
    b.Parent=m
    
    local hp
    if self.hlSettings.ShowHPBar then
        hp=self:createHPBar(b)
        hp.Parent=b
        t.Position=UDim2.new(0,0,0,10)
        t.Size=UDim2.new(1,0,0,20)
    end
    
    return {
        H=h,
        B=b,
        P=pl,
        M=m,
        HPBar=hp
    }
end

function D:updateNT(hd)
    if not hd or not hd.M or not hd.M.PrimaryPart then
        return false
    end
    
    local pl=hd.P
    local m=hd.M
    local b=hd.B
    local h=hd.H
    
    if not pl or pl.Parent~=P or not m.Parent then
        if h then h:Destroy() end
        if b then b:Destroy() end
        return false
    end
    
    local d=(self.p.Character and m.PrimaryPart and 
                 (self.p.Character.PrimaryPart.Position - m.PrimaryPart.Position).Magnitude) or 0
    
    if d>self.hlSettings.MaxDistance then
        h.Enabled=false
        b.Enabled=false
        return true
    end
    
    h.Enabled=self.hlSettings.Enabled
    b.Enabled=self.hlSettings.Enabled
    
    local ht=""
    local hp=1
    local hu=m:FindFirstChildOfClass("Humanoid")
    
    if hu then
        local cur=math.floor(hu.Health)
        local max=math.floor(hu.MaxHealth)
        ht=string.format("[%d/%d]",cur,max)
        hp=math.max(0,math.min(1,hu.Health/hu.MaxHealth))
    else
        local da=m:FindFirstChild("Data")
        if da then
            local l=da:FindFirstChild("Level")
            if l then
                ht=string.format("[LVL:%d]",l.Value)
            end
        end
    end
    
    if b and b.NameText then
        if self.hlSettings.ShowDistance then
            b.NameText.Text=string.format("%s [%dm]\n<font color='#00FF00'>%s</font>", 
                pl.Name, 
                math.floor(d), 
                ht)
        else
            b.NameText.Text=string.format("%s\n<font color='#00FF00'>%s</font>",pl.Name,ht)
        end
        b.NameText.RichText=true
    end
    
    if hd.HPBar then
        hd.HPBar.Fill.Size=UDim2.new(hp,0,1,0)
    end
    
    if self.hlSettings.TeamColor and pl.Team then
        h.OutlineColor=pl.Team.TeamColor.Color
    end
    
    return true
end

function D:onPAdded(pl)
    if pl==self.p then return end
    
    local function ca(ch)
        if not ch then return end
        task.wait(0.5)
        if ch and ch:IsA("Model") then
            if self.hlCache[pl] then
                local o=self.hlCache[pl]
                if o.H then o.H:Destroy() end
                if o.B then o.B:Destroy() end
            end
            local hd=self:createHL(ch,pl)
            if hd then
                self.hlCache[pl]=hd
            end
        end
    end
    
    local cn=pl.CharacterAdded:Connect(ca)
    table.insert(self.hlConnections,cn)
    
    if pl.Character then
        ca(pl.Character)
    end
    
    local rc=pl.AncestryChanged:Connect(function(_,pa)
        if not pa then
            if self.hlCache[pl] then
                local d=self.hlCache[pl]
                if d.H then d.H:Destroy() end
                if d.B then d.B:Destroy() end
                self.hlCache[pl]=nil
            end
        end
    end)
    table.insert(self.hlConnections,rc)
end

function D:onPRemoving(pl)
    if self.hlCache[pl] then
        local d=self.hlCache[pl]
        if d.H then d.H:Destroy() end
        if d.B then d.B:Destroy() end
        self.hlCache[pl]=nil
    end
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
    
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(255,255,255)
    s.Transparency=0.85
    s.Thickness=1
    s.Parent=self.mf
    
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
            local b=Instance.new("TextButton")
            b.Name="ToggleBtn"
            b.Size=UDim2.new(1,0,1,0)
            b.Position=UDim2.new(0,0,0,0)
            b.BackgroundTransparency=1
            b.Text=""
            b.Parent=sf
            
            table.insert(self.connections,b.MouseButton1Click:Connect(function()
                self.showGameTime=not self.showGameTime
                self:UpdateInfo()
            end))
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
        
        self.secs[i]={
            f=sf,
            t=tl,
            v=vl
        }
    end
    
    self.secs[1].v.TextColor3=Color3.fromRGB(85,230,130)
    self.secs[2].v.TextColor3=Color3.fromRGB(80,170,240)
    self.secs[3].v.TextColor3=Color3.fromRGB(180,110,230)
    
    self.mf.Parent=self.sg
    self.sg.Parent=self.p:WaitForChild("PlayerGui")
    
    self:SetupConnections()
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
    
    for _,c in ipairs(self.hlConnections) do
        c:Disconnect()
    end
    
    for pl,d in pairs(self.hlCache) do
        if d.H then d.H:Destroy() end
        if d.B then d.B:Destroy() end
    end
    
    self.hlCache={}
    
    if self.sg then
        self.sg:Destroy()
    end
end

return D.new()