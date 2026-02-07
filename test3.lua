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
    self.s=true
    self.u=0
    self.i=0.3
    self.f=0
    self.c=0
    self.t=0
    self.st=os.clock()
    self.g=false
    self.cx={}
    self.hx={}
    self.hc={}
    self.te=false
    self.ka=false
    
    self.hs={
        e=true,
        oc=Color3.fromRGB(85,170,255),
        ot=0,
        oth=3,
        ntc=Color3.fromRGB(255,255,255),
        nto=Color3.fromRGB(0,0,0),
        ns=14,
        nf=Enum.Font.GothamMedium,
        no=Vector3.new(0,8.5,0),
        tc=false,
        sd=true,
        md=10000,
        sh=true
    }
    
    getgenv()._DeltaHUDInstance=self
    
    self:I()
    self:IH()
    self:ISB()
    self:ITB()
    self:IKA()
    
    return self
end

function D:ISB()
    local b=Instance.new("TextButton")
    b.Name="SaveBtn"
    b.Size=UDim2.new(0,85,0,38)
    b.Position=UDim2.new(0.5,180,0,12)
    b.BackgroundColor3=Color3.fromRGB(20,20,30)
    b.BackgroundTransparency=0.1
    b.Text="SAVE"
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextSize=13
    b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0
    
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,6)
    c.Parent=b
    
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(85,170,255)
    s.Thickness=1.5
    s.Parent=b
    
    local hf=Instance.new("Frame")
    hf.Size=UDim2.new(1,0,1,0)
    hf.BackgroundColor3=Color3.fromRGB(85,170,255)
    hf.BackgroundTransparency=0.9
    hf.BorderSizePixel=0
    hf.Visible=false
    hf.Parent=b
    
    local hc=Instance.new("UICorner")
    hc.CornerRadius=UDim.new(0,6)
    hc.Parent=hf
    
    b.MouseEnter:Connect(function()
        hf.Visible=true
        s.Thickness=2
    end)
    
    b.MouseLeave:Connect(function()
        hf.Visible=false
        s.Thickness=1.5
    end)
    
    local dg,di,sp,dp
    
    b.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dg=true
            dp=i.Position
            sp=b.Position
        end
    end)
    
    b.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dg=false
        end
    end)
    
    b.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement then
            di=i
        end
    end)
    
    U.InputChanged:Connect(function(i)
        if dg and i==di then
            local dl=i.Position-dp
            b.Position=UDim2.new(sp.X.Scale,sp.X.Offset+dl.X,
                               sp.Y.Scale,sp.Y.Offset+dl.Y)
        end
    end)
    
    b.MouseButton1Click:Connect(function()
        self:SP()
    end)
    
    b.Parent=self.sg
end

function D:ITB()
    local b=Instance.new("TextButton")
    b.Name="TurboBtn"
    b.Size=UDim2.new(0,85,0,38)
    b.Position=UDim2.new(0.5,270,0,12)
    b.BackgroundColor3=Color3.fromRGB(20,20,30)
    b.BackgroundTransparency=0.1
    b.Text="TURBO"
    b.TextColor3=Color3.fromRGB(255,170,85)
    b.TextSize=13
    b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0
    
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,6)
    c.Parent=b
    
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(255,170,85)
    s.Thickness=1.5
    s.Parent=b
    
    local hf=Instance.new("Frame")
    hf.Size=UDim2.new(1,0,1,0)
    hf.BackgroundColor3=Color3.fromRGB(255,170,85)
    hf.BackgroundTransparency=0.9
    hf.BorderSizePixel=0
    hf.Visible=false
    hf.Parent=b
    
    local hc=Instance.new("UICorner")
    hc.CornerRadius=UDim.new(0,6)
    hc.Parent=hf
    
    b.MouseEnter:Connect(function()
        hf.Visible=true
        s.Thickness=2
    end)
    
    b.MouseLeave:Connect(function()
        hf.Visible=false
        s.Thickness=1.5
    end)
    
    local dg,di,sp,dp
    
    b.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dg=true
            dp=i.Position
            sp=b.Position
        end
    end)
    
    b.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dg=false
        end
    end)
    
    b.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement then
            di=i
        end
    end)
    
    U.InputChanged:Connect(function(i)
        if dg and i==di then
            local dl=i.Position-dp
            b.Position=UDim2.new(sp.X.Scale,sp.X.Offset+dl.X,
                               sp.Y.Scale,sp.Y.Offset+dl.Y)
        end
    end)
    
    b.MouseButton1Click:Connect(function()
        self.te=not self.te
        if self.te then
            b.Text="TURBO:ON"
            b.TextColor3=Color3.fromRGB(85,255,85)
            s.Color=Color3.fromRGB(85,255,85)
            self:AT()
        else
            b.Text="TURBO"
            b.TextColor3=Color3.fromRGB(255,170,85)
            s.Color=Color3.fromRGB(255,170,85)
        end
    end)
    
    b.Parent=self.sg
end

function D:AT()
    if not self.te then return end
    
    local hc
    hc=R.Heartbeat:Connect(function()
        if not self.te then
            hc:Disconnect()
            return
        end
        
        local c=self.p.Character
        if not c then return end
        
        local h=c:FindFirstChildOfClass("Humanoid")
        if not h then return end
        
        h.WalkSpeed=110
    end)
    
    table.insert(self.cx,hc)
end

function D:SP()
    local c=self.p.Character
    if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    
    local op=h.Position
    local th=3000
    local np=op+Vector3.new(0,th,0)
    local spd=250
    local d=(np-op).Magnitude
    local tt=d/spd
    
    for _,v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide=false
        end
    end
    
    local ti=TweenInfo.new(tt,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
    local t=T:Create(h,ti,{CFrame=CFrame.new(np)})
    t:Play()
    
    task.wait(tt)
    
    local pl=Instance.new("Part")
    pl.Name="SavePlatform"
    pl.Size=Vector3.new(100,5,100)
    pl.Position=Vector3.new(op.X,op.Y-10,op.Z)
    pl.Anchored=true
    pl.CanCollide=true
    pl.Transparency=0.3
    pl.Color=Color3.fromRGB(85,170,255)
    pl.Material=Enum.Material.Neon
    
    local pt=Instance.new("PointLight")
    pt.Brightness=0.5
    pt.Range=50
    pt.Color=Color3.fromRGB(85,170,255)
    pt.Parent=pl
    
    pl.Parent=W
    
    local rp=pl.Position+Vector3.new(0,10,0)
    local rd=(h.Position-rp).Magnitude
    local rt=rd/spd
    
    local rti=TweenInfo.new(rt,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    local rt=T:Create(h,rti,{CFrame=CFrame.new(rp)})
    rt:Play()
    
    task.wait(rt)
    
    task.delay(20,function()
        if pl and pl.Parent then
            pl:Destroy()
        end
    end)
end

function D:IKA()
    local r={}
    local su,n=pcall(function()
        return require(S.Modules.Net)
    end)
    
    if su and n then
        if n.RemoteEvent then
            r.Attack=n:RemoteEvent("RegisterAttack")
            r.Hit=n:RemoteEvent("RegisterHit",true)
        elseif n.RE then
            r.Attack=n.RE:WaitForChild("RegisterAttack")
            r.Hit=n.RE:WaitForChild("RegisterHit")
        end
    end
    
    local hc
    hc=R.Heartbeat:Connect(function()
        if not self.ka then return end
        
        local c=self.p.Character
        if not c then return end
        
        local h=c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        
        local p=h.Position
        local ti=false
        
        for _,e in pairs(W.Enemies:GetChildren()) do
            if e:FindFirstChild("HumanoidRootPart") and e:FindFirstChildOfClass("Humanoid") then
                local d=(e.HumanoidRootPart.Position-p).Magnitude
                if d<30 and e:FindFirstChildOfClass("Humanoid").Health>0 then
                    ti=true
                    break
                end
            end
        end
        
        if not ti then
            for _,pl in pairs(P:GetPlayers()) do
                if pl~=self.p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    local tc=pl.Character
                    local d=(tc.HumanoidRootPart.Position-p).Magnitude
                    if d<30 and tc:FindFirstChildOfClass("Humanoid").Health>0 then
                        if not self.p.Team or not pl.Team or self.p.Team~=pl.Team then
                            ti=true
                            break
                        end
                    end
                end
            end
        end
        
        if ti and r.Attack then
            local sn=c:FindFirstChild("Stun")
            if sn then sn.Value=0 end
            local by=c:FindFirstChild("Busy")
            if by then by.Value=false end
            
            for i=1,3 do
                pcall(function()
                    r.Attack:FireServer(1)
                end)
                task.wait(0.01)
            end
        end
    end)
    
    table.insert(self.cx,hc)
    
    table.insert(self.cx,U.InputBegan:Connect(function(i,gp)
        if not gp and i.KeyCode==Enum.KeyCode.F6 then
            self.ka=not self.ka
        end
    end))
end

function D:IH()
    for p,d in pairs(self.hc) do
        if d.H then d.H:Destroy() end
        if d.B then d.B:Destroy() end
    end
    
    self.hc={}
    
    for _,p in ipairs(P:GetPlayers()) do
        if p~=self.p then
            self:PA(p)
        end
    end
    
    table.insert(self.hx,P.PlayerAdded:Connect(function(p)
        self:PA(p)
    end))
    
    table.insert(self.hx,P.PlayerRemoving:Connect(function(p)
        self:PR(p)
    end))
    
    R.Heartbeat:Connect(function()
        if not self.hs.e then return end
        for p,hd in pairs(self.hc) do
            if not self:UNT(hd) then
                self.hc[p]=nil
            end
        end
    end)
end

function D:CHB(m)
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

function D:CHL(m,p)
    if not m or not m:IsA("Model") then return nil end
    
    local h=Instance.new("Highlight")
    h.Name="PlayerHighlight"
    h.Adornee=m
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency=1
    h.OutlineColor=self.hs.oc
    h.OutlineTransparency=self.hs.ot
    h.Enabled=self.hs.e
    
    if self.hs.tc and p.Team then
        h.OutlineColor=p.Team.TeamColor.Color
    end
    
    h.Parent=m
    
    local b=Instance.new("BillboardGui")
    b.Name="PlayerNameTag"
    b.Adornee=m:FindFirstChild("Head") or m.PrimaryPart or m
    b.Size=UDim2.new(0,200,0,50)
    b.StudsOffset=Vector3.new(0,8.5,0)
    b.AlwaysOnTop=true
    b.MaxDistance=self.hs.md
    b.Enabled=self.hs.e
    
    local t=Instance.new("TextLabel")
    t.Name="NameText"
    t.Size=UDim2.new(1,0,1,0)
    t.BackgroundTransparency=1
    t.TextColor3=self.hs.ntc
    t.TextSize=self.hs.ns
    t.Font=self.hs.nf
    t.TextStrokeTransparency=0
    t.TextStrokeColor3=self.hs.nto
    t.Text=p.Name
    t.TextYAlignment=Enum.TextYAlignment.Center
    t.Parent=b
    b.Parent=m
    
    local hb
    if self.hs.sh then
        hb=self:CHB(b)
        hb.Parent=b
        t.Position=UDim2.new(0,0,0,10)
        t.Size=UDim2.new(1,0,0,20)
    end
    
    return {
        H=h,
        B=b,
        P=p,
        M=m,
        HPBar=hb
    }
end

function D:UNT(hd)
    if not hd or not hd.M or not hd.M.PrimaryPart then
        return false
    end
    
    local p=hd.P
    local m=hd.M
    local b=hd.B
    local h=hd.H
    
    if not p or p.Parent~=P or not m.Parent then
        if h then h:Destroy() end
        if b then b:Destroy() end
        return false
    end
    
    local d=(self.p.Character and m.PrimaryPart and 
             (self.p.Character.PrimaryPart.Position - m.PrimaryPart.Position).Magnitude) or 0
    
    if d>self.hs.md then
        h.Enabled=false
        b.Enabled=false
        return true
    end
    
    h.Enabled=self.hs.e
    b.Enabled=self.hs.e
    
    local ht=""
    local hp=1
    local hm=m:FindFirstChildOfClass("Humanoid")
    
    if hm then
        local hh=math.floor(hm.Health)
        local mh=math.floor(hm.MaxHealth)
        ht=string.format("[%d/%d]",hh,mh)
        hp=math.max(0,math.min(1,hm.Health/hm.MaxHealth))
    else
        local dt=m:FindFirstChild("Data")
        if dt then
            local lv=dt:FindFirstChild("Level")
            if lv then
                ht=string.format("[LVL:%d]",lv.Value)
            end
        end
    end
    
    if b and b.NameText then
        if self.hs.sd then
            b.NameText.Text=string.format("%s [%dm]\n<font color='#00FF00'>%s</font>", 
                p.Name, 
                math.floor(d), 
                ht)
        else
            b.NameText.Text=string.format("%s\n<font color='#00FF00'>%s</font>",p.Name,ht)
        end
        b.NameText.RichText=true
    end
    
    if hd.HPBar then
        hd.HPBar.Fill.Size=UDim2.new(hp,0,1,0)
    end
    
    if self.hs.tc and p.Team then
        h.OutlineColor=p.Team.TeamColor.Color
    end
    
    return true
end

function D:PA(p)
    if p==self.p then return end
    
    local function ca(c)
        if not c then return end
        task.wait(0.5)
        if c and c:IsA("Model") then
            if self.hc[p] then
                local o=self.hc[p]
                if o.H then o.H:Destroy() end
                if o.B then o.B:Destroy() end
            end
            local hd=self:CHL(c,p)
            if hd then
                self.hc[p]=hd
            end
        end
    end
    
    local cn=p.CharacterAdded:Connect(ca)
    table.insert(self.hx,cn)
    
    if p.Character then
        ca(p.Character)
    end
    
    local rc=p.AncestryChanged:Connect(function(_,pa)
        if not pa then
            if self.hc[p] then
                local d=self.hc[p]
                if d.H then d.H:Destroy() end
                if d.B then d.B:Destroy() end
                self.hc[p]=nil
            end
        end
    end)
    table.insert(self.hx,rc)
end

function D:PR(p)
    if self.hc[p] then
        local d=self.hc[p]
        if d.H then d.H:Destroy() end
        if d.B then d.B:Destroy() end
        self.hc[p]=nil
    end
end

function D:I()
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
    
    self.sx={}
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
            
            table.insert(self.cx,b.MouseButton1Click:Connect(function()
                self.g=not self.g
                self:UI()
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
        
        self.sx[i]={
            f=sf,
            t=tl,
            v=vl
        }
    end
    
    self.sx[1].v.TextColor3=Color3.fromRGB(85,230,130)
    self.sx[2].v.TextColor3=Color3.fromRGB(80,170,240)
    self.sx[3].v.TextColor3=Color3.fromRGB(180,110,230)
    
    self.mf.Parent=self.sg
    self.sg.Parent=self.p:WaitForChild("PlayerGui")
    
    self:SC()
end

function D:SC()
    table.insert(self.cx,R.RenderStepped:Connect(function(d)
        self:UF(d)
        self.u=self.u+d
        if self.u>=self.i then
            self:UP()
            self:UI()
            self.u=0
        end
    end))
    
    table.insert(self.cx,U.InputBegan:Connect(function(i,pr)
        if not pr and i.KeyCode==Enum.KeyCode.F5 then
            self.s=not self.s
            self.sg.Enabled=self.s
        end
    end))
end

function D:UF(d)
    self.t=self.t+d
    self.c=self.c+1
    if self.t>=1 then
        self.f=math.floor(self.c/self.t)
        self.c=0
        self.t=0
        self.sx[1].v.Text=tostring(self.f)
    end
end

function D:UP()
    local su,pi=pcall(function()
        return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    self.sx[2].v.Text=(su and pi or -1).."ms"
end

function D:UI()
    if self.g then
        local el=os.clock()-self.st
        local m=math.floor(el/60)
        local s=math.floor(el%60)
        self.sx[3].v.Text=string.format("%02d:%02d",m,s)
    else
        local ca=W.CurrentCamera
        if ca then
            local l=ca.CFrame.LookVector
            local p=math.deg(math.asin(-l.Y))
            local y=math.deg(math.atan2(-l.X,-l.Z))
            self.sx[3].v.Text=string.format("%.0f°,%.0f°",y%360,p)
        else
            self.sx[3].v.Text="CV:N/A"
        end
    end
end

function D:Destroy()
    for _,c in ipairs(self.cx) do
        c:Disconnect()
    end
    
    for _,c in ipairs(self.hx) do
        c:Disconnect()
    end
    
    for p,d in pairs(self.hc) do
        if d.H then d.H:Destroy() end
        if d.B then d.B:Destroy() end
    end
    
    self.hc={}
    
    if self.sg then
        self.sg:Destroy()
    end
end

return D.new()