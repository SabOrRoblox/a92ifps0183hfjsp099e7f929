local Players,RunService,Workspace,UserInputService,ReplicatedStorage,TweenService,VirtualInputManager = game:GetService("Players"),game:GetService("RunService"),game:GetService("Workspace"),game:GetService("UserInputService"),game:GetService("ReplicatedStorage"),game:GetService("TweenService"),game:GetService("VirtualInputManager")

local DeltaHUD={};DeltaHUD.__index=DeltaHUD;getgenv().DeltaHUD=DeltaHUD

function DeltaHUD.new()
    if getgenv()._DeltaHUDInstance then getgenv()._DeltaHUDInstance:Destroy() end
    local self=setmetatable({},DeltaHUD)
    self.player=Players.LocalPlayer;self.showHUD=true;self.lastUpdate=0;self.updateInterval=0.3
    self.fps=0;self.fpsCounter=0;self.fpsTime=0;self.startTime=os.clock();self.showGameTime=false
    self.connections={};self.highlightCache={};self.highlighterConnections={}
    
    self.settings={
        FastAttack={Enabled=true,Speed=0.1,AutoClick=false},
        KillAura={Enabled=true,Range=50,AttackNPC=true,AttackPlayers=true,TeamCheck=false},
        PlayerFollow={Target=nil,Following=false,Distance=5,Height=3},
        ESP={Enabled=true,ShowHealth=true,ShowDistance=true,MaxDist=5000},
        Misc={AutoBuso=true,AutoKen=true}
    }
    
    getgenv()._DeltaHUDInstance=self
    self:Initialize();self:InitializeESP();self:InitializeKillAura()
    self:InitializeFastAttack();self:InitializePlayerFollow()
    
    return self
end

function DeltaHUD:Initialize()
    if self.player.PlayerGui:FindFirstChild("DeltaHUD") then
        self.player.PlayerGui.DeltaHUD:Destroy()
    end
    
    -- Main GUI
    self.screenGui=Instance.new("ScreenGui")
    self.screenGui.Name="DeltaHUD";self.screenGui.DisplayOrder=999
    self.screenGui.ResetOnSpawn=false
    
    -- HUD Frame
    self.hudFrame=Instance.new("Frame")
    self.hudFrame.Name="HUD";self.hudFrame.Size=UDim2.new(0,300,0,40)
    self.hudFrame.Position=UDim2.new(0.5,-150,0,10)
    self.hudFrame.BackgroundColor3=Color3.fromRGB(15,15,20)
    self.hudFrame.BackgroundTransparency=0.2;self.hudFrame.BorderSizePixel=0
    
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,6);corner.Parent=self.hudFrame
    local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(255,255,255)
    stroke.Transparency=0.85;stroke.Thickness=1;stroke.Parent=self.hudFrame
    
    -- HUD Sections
    self.sections={}
    for i=1,3 do
        local sec=Instance.new("Frame")
        sec.Name="Sec"..i;sec.Size=UDim2.new(0,100,1,0)
        sec.Position=UDim2.new(0,(i-1)*100,0,0);sec.BackgroundTransparency=1
        sec.BorderSizePixel=0;sec.Parent=self.hudFrame
        
        local title=Instance.new("TextLabel")
        title.Name="Title";title.Size=UDim2.new(1,0,0,16)
        title.Position=UDim2.new(0,0,0,4);title.BackgroundTransparency=1
        title.TextColor3=Color3.fromRGB(180,180,180);title.TextSize=11
        title.Font=Enum.Font.GothamMedium;title.TextXAlignment=Enum.TextXAlignment.Center
        title.Text=i==1 and "FPS" or (i==2 and "PING" or "INFO");title.Parent=sec
        
        local value=Instance.new("TextLabel")
        value.Name="Value";value.Size=UDim2.new(1,0,0,18)
        value.Position=UDim2.new(0,0,0,18);value.BackgroundTransparency=1
        value.TextColor3=i==1 and Color3.fromRGB(85,230,130) or (i==2 and Color3.fromRGB(80,170,240) or Color3.fromRGB(180,110,230))
        value.TextSize=13;value.Font=Enum.Font.GothamBold
        value.Text=i==1 and "0" or (i==2 and "0ms" or "CV:0")
        value.TextXAlignment=Enum.TextXAlignment.Center;value.Parent=sec
        
        if i<3 then
            local div=Instance.new("Frame");div.Name="Divider"
            div.Size=UDim2.new(0,1,0,20)
            div.Position=UDim2.new(1,-1,0.5,-10)
            div.BackgroundColor3=Color3.fromRGB(255,255,255)
            div.BackgroundTransparency=0.9;div.BorderSizePixel=0;div.Parent=sec
        end
        
        self.sections[i]={frame=sec,title=title,value=value}
    end
    
    -- Control Panel
    self.controlGui=Instance.new("ScreenGui")
    self.controlGui.Name="DeltaControl";self.controlGui.DisplayOrder=998
    self.controlGui.ResetOnSpawn=false;self.controlGui.Enabled=false
    
    self.controlFrame=Instance.new("Frame")
    self.controlFrame.Name="ControlFrame";self.controlFrame.Size=UDim2.new(0,250,0,400)
    self.controlFrame.Position=UDim2.new(0,10,0.5,-200)
    self.controlFrame.BackgroundColor3=Color3.fromRGB(20,20,25)
    self.controlFrame.BackgroundTransparency=0.15;self.controlFrame.BorderSizePixel=0
    
    local cCorner=Instance.new("UICorner");cCorner.CornerRadius=UDim.new(0,8);cCorner.Parent=self.controlFrame
    local cStroke=Instance.new("UIStroke");cStroke.Color=Color3.fromRGB(255,255,255)
    cStroke.Transparency=0.8;cStroke.Thickness=1;cStroke.Parent=self.controlFrame
    
    local cTitle=Instance.new("TextLabel")
    cTitle.Name="Title";cTitle.Size=UDim2.new(1,0,0,40)
    cTitle.Position=UDim2.new(0,0,0,0);cTitle.BackgroundTransparency=1
    cTitle.TextColor3=Color3.fromRGB(255,255,255);cTitle.TextSize=20
    cTitle.Font=Enum.Font.GothamBold;cTitle.Text="DELTA CONTROL"
    cTitle.TextXAlignment=Enum.TextXAlignment.Center;cTitle.Parent=self.controlFrame
    
    -- Control Buttons
    local buttons={
        {Name="ESP",Tooltip="Toggle ESP"},
        {Name="KillAura",Tooltip="Toggle KillAura"},
        {Name="FastAttack",Tooltip="Toggle Fast Attack"},
        {Name="AutoBuso",Tooltip="Toggle Auto Buso"},
        {Name="PlayerList",Tooltip="Show Player List"},
        {Name="Follow",Tooltip="Follow Selected"},
        {Name="Settings",Tooltip="Open Settings"}
    }
    
    self.controlButtons={}
    for i,btn in ipairs(buttons) do
        local button=Instance.new("TextButton")
        button.Name=btn.Name;button.Size=UDim2.new(0.45,0,0,35)
        button.Position=UDim2.new((i%2==0 and 0.5 or 0),5,0,45+math.floor((i-1)/2)*40)
        button.BackgroundColor3=Color3.fromRGB(40,40,50)
        button.BackgroundTransparency=0.1;button.BorderSizePixel=0
        button.TextColor3=Color3.fromRGB(255,255,255);button.TextSize=13
        button.Font=Enum.Font.GothamMedium;button.Text=btn.Name
        button.Parent=self.controlFrame
        
        local btnCorner=Instance.new("UICorner")
        btnCorner.CornerRadius=UDim.new(0,4);btnCorner.Parent=button
        
        self.controlButtons[btn.Name]=button
    end
    
    -- Player List
    self.playerListGui=Instance.new("ScreenGui")
    self.playerListGui.Name="DeltaPlayerList";self.playerListGui.DisplayOrder=997
    self.playerListGui.ResetOnSpawn=false;self.playerListGui.Enabled=false
    
    self.playerListFrame=Instance.new("Frame")
    self.playerListFrame.Name="PlayerListFrame";self.playerListFrame.Size=UDim2.new(0,280,0,350)
    self.playerListFrame.Position=UDim2.new(1,-290,0.5,-175)
    self.playerListFrame.BackgroundColor3=Color3.fromRGB(20,20,25)
    self.playerListFrame.BackgroundTransparency=0.15;self.playerListFrame.BorderSizePixel=0
    
    local plCorner=Instance.new("UICorner");plCorner.CornerRadius=UDim.new(0,8);plCorner.Parent=self.playerListFrame
    local plStroke=Instance.new("UIStroke");plStroke.Color=Color3.fromRGB(255,255,255)
    plStroke.Transparency=0.8;plStroke.Thickness=1;plStroke.Parent=self.playerListFrame
    
    local plTitle=Instance.new("TextLabel")
    plTitle.Name="Title";plTitle.Size=UDim2.new(1,0,0,40)
    plTitle.Position=UDim2.new(0,0,0,0);plTitle.BackgroundTransparency=1
    plTitle.TextColor3=Color3.fromRGB(255,255,255);plTitle.TextSize=18
    plTitle.Font=Enum.Font.GothamBold;plTitle.Text="PLAYER LIST"
    plTitle.TextXAlignment=Enum.TextXAlignment.Center;plTitle.Parent=self.playerListFrame
    
    self.playerScroll=Instance.new("ScrollingFrame")
    self.playerScroll.Name="ScrollFrame";self.playerScroll.Size=UDim2.new(1,-10,1,-50)
    self.playerScroll.Position=UDim2.new(0,5,0,45);self.playerScroll.BackgroundTransparency=1
    self.playerScroll.BorderSizePixel=0;self.playerScroll.ScrollBarThickness=4
    self.playerScroll.ScrollBarImageColor3=Color3.fromRGB(100,100,100)
    self.playerScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;self.playerScroll.Parent=self.playerListFrame
    
    self.playerListGui.Parent=self.player.PlayerGui
    self.controlGui.Parent=self.player.PlayerGui
    self.screenGui.Parent=self.player.PlayerGui
    
    self:SetupControls()
    self:SetupConnections()
end

function DeltaHUD:SetupControls()
    self.controlButtons.ESP.MouseButton1Click:Connect(function()
        self.settings.ESP.Enabled=not self.settings.ESP.Enabled
        self.controlButtons.ESP.BackgroundColor3=self.settings.ESP.Enabled and Color3.fromRGB(60,180,80) or Color3.fromRGB(40,40,50)
        for _,data in pairs(self.highlightCache) do
            if data.Highlight then data.Highlight.Enabled=self.settings.ESP.Enabled end
            if data.Billboard then data.Billboard.Enabled=self.settings.ESP.Enabled end
        end
    end)
    
    self.controlButtons.KillAura.MouseButton1Click:Connect(function()
        self.settings.KillAura.Enabled=not self.settings.KillAura.Enabled
        self.controlButtons.KillAura.BackgroundColor3=self.settings.KillAura.Enabled and Color3.fromRGB(200,60,60) or Color3.fromRGB(40,40,50)
    end)
    
    self.controlButtons.FastAttack.MouseButton1Click:Connect(function()
        self.settings.FastAttack.Enabled=not self.settings.FastAttack.Enabled
        self.controlButtons.FastAttack.BackgroundColor3=self.settings.FastAttack.Enabled and Color3.fromRGB(60,120,200) or Color3.fromRGB(40,40,50)
    end)
    
    self.controlButtons.AutoBuso.MouseButton1Click:Connect(function()
        self.settings.Misc.AutoBuso=not self.settings.Misc.AutoBuso
        self.controlButtons.AutoBuso.BackgroundColor3=self.settings.Misc.AutoBuso and Color3.fromRGB(180,80,180) or Color3.fromRGB(40,40,50)
    end)
    
    self.controlButtons.PlayerList.MouseButton1Click:Connect(function()
        self.playerListGui.Enabled=not self.playerListGui.Enabled
        self.controlButtons.PlayerList.BackgroundColor3=self.playerListGui.Enabled and Color3.fromRGB(80,160,220) or Color3.fromRGB(40,40,50)
        if self.playerListGui.Enabled then self:UpdatePlayerList() end
    end)
    
    self.controlButtons.Follow.MouseButton1Click:Connect(function()
        if self.settings.PlayerFollow.Target then
            self.settings.PlayerFollow.Following=not self.settings.PlayerFollow.Following
            self.controlButtons.Follow.BackgroundColor3=self.settings.PlayerFollow.Following and Color3.fromRGB(220,160,60) or Color3.fromRGB(40,40,50)
        end
    end)
    
    self.controlButtons.Settings.MouseButton1Click:Connect(function()
        self.controlGui.Enabled=not self.controlGui.Enabled
        self.controlButtons.Settings.BackgroundColor3=self.controlGui.Enabled and Color3.fromRGB(100,100,100) or Color3.fromRGB(40,40,50)
    end)
end

function DeltaHUD:SetupConnections()
    table.insert(self.connections,RunService.RenderStepped:Connect(function(dt)
        self:UpdateFPS(dt)
        self.lastUpdate=self.lastUpdate+dt
        if self.lastUpdate>=self.updateInterval then
            self:UpdatePing();self:UpdateInfo();self.lastUpdate=0
        end
    end))
    
    table.insert(self.connections,UserInputService.InputBegan:Connect(function(input,processed)
        if not processed and input.KeyCode==Enum.KeyCode.RightControl then
            self.controlGui.Enabled=not self.controlGui.Enabled
        elseif not processed and input.KeyCode==Enum.KeyCode.F5 then
            self.showHUD=not self.showHUD;self.screenGui.Enabled=self.showHUD
        end
    end))
end

function DeltaHUD:UpdateFPS(dt)
    self.fpsTime=self.fpsTime+dt;self.fpsCounter=self.fpsCounter+1
    if self.fpsTime>=1 then
        self.fps=math.floor(self.fpsCounter/self.fpsTime)
        self.fpsCounter=0;self.fpsTime=0
        self.sections[1].value.Text=tostring(self.fps)
    end
end

function DeltaHUD:UpdatePing()
    local success,ping=pcall(function()
        return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    self.sections[2].value.Text=(success and ping or -1).."ms"
end

function DeltaHUD:UpdateInfo()
    if self.showGameTime then
        local elapsed=os.clock()-self.startTime
        local minutes=math.floor(elapsed/60)
        local seconds=math.floor(elapsed%60)
        self.sections[3].value.Text=string.format("%02d:%02d",minutes,seconds)
    else
        local camera=workspace.CurrentCamera
        if camera then
            local look=camera.CFrame.LookVector
            local pitch=math.deg(math.asin(-look.Y))
            local yaw=math.deg(math.atan2(-look.X,-look.Z))
            self.sections[3].value.Text=string.format("%.0f°,%.0f°",yaw%360,pitch)
        else
            self.sections[3].value.Text="CV:N/A"
        end
    end
end

function DeltaHUD:InitializeESP()
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=self.player then self:onPlayerAdded(player) end
    end
    
    table.insert(self.highlighterConnections,Players.PlayerAdded:Connect(function(player)
        self:onPlayerAdded(player)
    end))
    
    table.insert(self.highlighterConnections,Players.PlayerRemoving:Connect(function(player)
        self:onPlayerRemoving(player)
    end))
    
    RunService.Heartbeat:Connect(function()
        if not self.settings.ESP.Enabled then return end
        for player,data in pairs(self.highlightCache) do
            self:updateESP(data)
        end
    end)
end

function DeltaHUD:createESP(model,player)
    local highlight=Instance.new("Highlight")
    highlight.Name="PlayerESP";highlight.Adornee=model
    highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency=1;highlight.OutlineTransparency=0
    highlight.OutlineColor=Color3.fromRGB(85,170,255)
    highlight.Enabled=self.settings.ESP.Enabled
    highlight.Parent=model
    
    local billboard=Instance.new("BillboardGui")
    billboard.Name="PlayerTag";billboard.Adornee=model.PrimaryPart or model
    billboard.Size=UDim2.new(0,200,0,50)
    billboard.StudsOffset=Vector3.new(0,8.5,0)
    billboard.AlwaysOnTop=true;billboard.MaxDistance=self.settings.ESP.MaxDist
    billboard.Enabled=self.settings.ESP.Enabled
    
    local text=Instance.new("TextLabel")
    text.Name="Text";text.Size=UDim2.new(1,0,1,0)
    text.BackgroundTransparency=1;text.TextColor3=Color3.fromRGB(255,255,255)
    text.TextSize=13;text.Font=Enum.Font.GothamMedium
    text.TextStrokeTransparency=0;text.TextStrokeColor3=Color3.fromRGB(0,0,0)
    text.TextYAlignment=Enum.TextYAlignment.Center;text.Parent=billboard
    billboard.Parent=model
    
    return{Highlight=highlight,Billboard=billboard,Player=player,Model=model}
end

function DeltaHUD:updateESP(data)
    if not data.Model.PrimaryPart then return false end
    local player=data.Player;local model=data.Model
    if not player or player.Parent~=Players then return false end
    
    local dist=(self.player.Character.PrimaryPart.Position-model.PrimaryPart.Position).Magnitude
    if dist>self.settings.ESP.MaxDist then
        data.Highlight.Enabled=false;data.Billboard.Enabled=false
        return true
    end
    
    data.Highlight.Enabled=self.settings.ESP.Enabled
    data.Billboard.Enabled=self.settings.ESP.Enabled
    
    local info=player.Name
    if self.settings.ESP.ShowDistance then
        info=info.." ["..math.floor(dist).."m]"
    end
    
    if self.settings.ESP.ShowHealth and model:FindFirstChildOfClass("Humanoid") then
        local hum=model:FindFirstChildOfClass("Humanoid")
        info=info.."\nHP:"..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
    end
    
    data.Billboard.Text.Text=info
    
    if player.Team then
        data.Highlight.OutlineColor=player.Team.TeamColor.Color
    end
    
    return true
end

function DeltaHUD:onPlayerAdded(player)
    if player==self.player then return end
    local function charAdded(char)
        if not char then return end;task.wait(0.5)
        if self.highlightCache[player] then
            local old=self.highlightCache[player]
            if old.Highlight then old.Highlight:Destroy() end
            if old.Billboard then old.Billboard:Destroy() end
        end
        local espData=self:createESP(char,player)
        if espData then self.highlightCache[player]=espData end
    end
    local conn=player.CharacterAdded:Connect(charAdded)
    table.insert(self.highlighterConnections,conn)
    if player.Character then charAdded(player.Character) end
end

function DeltaHUD:onPlayerRemoving(player)
    if self.highlightCache[player] then
        local data=self.highlightCache[player]
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        self.highlightCache[player]=nil
    end
end

function DeltaHUD:InitializeKillAura()
    local function getRemotes()
        local remotes={}
        local success,net=pcall(function()
            return require(ReplicatedStorage.Modules.Net)
        end)
        if success and net then
            if net.RemoteEvent then
                remotes.Attack=net:RemoteEvent("RegisterAttack")
                remotes.Hit=net:RemoteEvent("RegisterHit",true)
            end
        end
        return remotes
    end
    
    task.spawn(function()
        local remotes=getRemotes();if not remotes.Attack then return end
        while task.wait(0) do
            if not self.settings.KillAura.Enabled then continue end
            if not self.player.Character or not self.player.Character.PrimaryPart then continue end
            
            local pos=self.player.Character.PrimaryPart.Position
            
            if self.settings.KillAura.AttackNPC then
                for _,enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChildOfClass("Humanoid") then
                        local dist=(enemy.HumanoidRootPart.Position-pos).Magnitude
                        if dist<=self.settings.KillAura.Range and enemy:FindFirstChildOfClass("Humanoid").Health>0 then
                            pcall(function() remotes.Attack:FireServer(1) end)
                            if remotes.Hit then
                                pcall(function()
                                    remotes.Hit:FireServer(enemy.HumanoidRootPart,{{enemy,enemy.HumanoidRootPart}},nil,tostring(tick()))
                                end)
                            end
                            break
                        end
                    end
                end
            end
            
            if self.settings.KillAura.AttackPlayers then
                for _,target in pairs(Players:GetPlayers()) do
                    if target~=self.player and target.Character and target.Character.PrimaryPart then
                        local tChar=target.Character
                        if tChar:FindFirstChildOfClass("Humanoid") then
                            local dist=(tChar.PrimaryPart.Position-pos).Magnitude
                            local canAttack=true
                            if self.settings.KillAura.TeamCheck and self.player.Team and target.Team then
                                canAttack=self.player.Team~=target.Team
                            end
                            if dist<=self.settings.KillAura.Range and canAttack and tChar:FindFirstChildOfClass("Humanoid").Health>0 then
                                pcall(function() remotes.Attack:FireServer(1) end)
                                if remotes.Hit then
                                    pcall(function()
                                        remotes.Hit:FireServer(tChar.PrimaryPart,{{tChar,tChar.PrimaryPart}},nil,tostring(tick()))
                                    end)
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
end

function DeltaHUD:InitializeFastAttack()
    task.spawn(function()
        while task.wait(self.settings.FastAttack.Speed) do
            if not self.settings.FastAttack.Enabled then continue end
            if not self.player.Character then continue end
            
            VirtualInputManager:SendKeyEvent(true,"One",false,game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false,"One",false,game)
            
            if self.settings.FastAttack.AutoClick then
                VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
            end
        end
    end)
end

function DeltaHUD:InitializePlayerFollow()
    task.spawn(function()
        while task.wait(0.1) do
            if not self.settings.PlayerFollow.Following then continue end
            if not self.settings.PlayerFollow.Target then continue end
            if not self.player.Character or not self.player.Character.PrimaryPart then continue end
            
            local target=self.settings.PlayerFollow.Target
            if not target.Character or not target.Character.PrimaryPart then
                self.settings.PlayerFollow.Following=false
                self.controlButtons.Follow.BackgroundColor3=Color3.fromRGB(40,40,50)
                continue
            end
            
            local targetPos=target.Character.PrimaryPart.Position
            local offset=Vector3.new(0,self.settings.PlayerFollow.Height,self.settings.PlayerFollow.Distance)
            local followCFrame=CFrame.new(targetPos+offset,targetPos)
            
            self.player.Character.PrimaryPart.CFrame=followCFrame
        end
    end)
end

function DeltaHUD:UpdatePlayerList()
    for _,child in pairs(self.playerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local players={}
    for _,player in pairs(Players:GetPlayers()) do
        if player~=self.player then table.insert(players,player) end
    end
    
    if self.playerListSettings.SortByDistance and self.player.Character and self.player.Character.PrimaryPart then
        table.sort(players,function(a,b)
            local aDist=a.Character and a.Character.PrimaryPart and (a.Character.PrimaryPart.Position-self.player.Character.PrimaryPart.Position).Magnitude or math.huge
            local bDist=b.Character and b.Character.PrimaryPart and (b.Character.PrimaryPart.Position-self.player.Character.PrimaryPart.Position).Magnitude or math.huge
            return aDist<bDist
        end)
    end
    
    for i,player in ipairs(players) do
        if i>self.playerListSettings.MaxPlayers then break end
        
        local entry=Instance.new("Frame")
        entry.Name="Entry"..player.UserId;entry.Size=UDim2.new(1,0,0,60)
        entry.Position=UDim2.new(0,0,0,(i-1)*62)
        entry.BackgroundColor3=Color3.fromRGB(30,30,40)
        entry.BackgroundTransparency=0.1;entry.BorderSizePixel=0
        entry.Parent=self.playerScroll
        
        local eCorner=Instance.new("UICorner")
        eCorner.CornerRadius=UDim.new(0,4);eCorner.Parent=entry
        
        local name=Instance.new("TextLabel")
        name.Name="Name";name.Size=UDim2.new(0.7,0,0,25)
        name.Position=UDim2.new(0,5,0,5);name.BackgroundTransparency=1
        name.TextColor3=Color3.fromRGB(255,255,255);name.TextSize=14
        name.Font=Enum.Font.GothamMedium;name.Text=player.Name
        name.TextXAlignment=Enum.TextXAlignment.Left;name.Parent=entry
        
        local selectBtn=Instance.new("TextButton")
        selectBtn.Name="Select";selectBtn.Size=UDim2.new(0.25,0,0,25)
        selectBtn.Position=UDim2.new(0.73,0,0,5)
        selectBtn.BackgroundColor3=Color3.fromRGB(60,120,200)
        selectBtn.BackgroundTransparency=0.1;selectBtn.BorderSizePixel=0
        selectBtn.TextColor3=Color3.fromRGB(255,255,255);selectBtn.TextSize=12
        selectBtn.Font=Enum.Font.GothamMedium;selectBtn.Text="SELECT"
        selectBtn.Parent=entry
        
        local sCorner=Instance.new("UICorner")
        sCorner.CornerRadius=UDim.new(0,3);sCorner.Parent=selectBtn
        
        selectBtn.MouseButton1Click:Connect(function()
            self.settings.PlayerFollow.Target=player
            self.controlButtons.Follow.Text="FOLLOW "..string.sub(player.Name,1,8)
        end)
        
        local info=Instance.new("TextLabel")
        info.Name="Info";info.Size=UDim2.new(1,-10,0,25)
        info.Position=UDim2.new(0,5,0,32);info.BackgroundTransparency=1
        info.TextColor3=Color3.fromRGB(200,200,200);info.TextSize=11
        info.Font=Enum.Font.Gotham;info.Text=""
        info.TextXAlignment=Enum.TextXAlignment.Left;info.Parent=entry
        
        -- Update info
        task.spawn(function()
            while entry.Parent do
                local text=""
                if player.Character and player.Character.PrimaryPart and self.player.Character and self.player.Character.PrimaryPart then
                    local dist=math.floor((player.Character.PrimaryPart.Position-self.player.Character.PrimaryPart.Position).Magnitude)
                    text=text..dist.."m "
                end
                
                if player.Team then
                    text=text.."| "..player.Team.Name.." "
                end
                
                if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    local hum=player.Character:FindFirstChildOfClass("Humanoid")
                    text=text.."| HP:"..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
                end
                
                info.Text=text
                task.wait(1)
            end
        end)
    end
    
    self.playerScroll.CanvasSize=UDim2.new(0,0,0,#players*62)
end

function DeltaHUD:Toggle()
    self.showHUD=not self.showHUD
    self.screenGui.Enabled=self.showHUD
    return self.showHUD
end

function DeltaHUD:Destroy()
    for _,conn in pairs(self.connections) do conn:Disconnect() end
    for _,conn in pairs(self.highlighterConnections) do conn:Disconnect() end
    for _,data in pairs(self.highlightCache) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    if self.screenGui then self.screenGui:Destroy() end
    if self.controlGui then self.controlGui:Destroy() end
    if self.playerListGui then self.playerListGui:Destroy() end
    getgenv()._DeltaHUDInstance=nil
end

local hud=DeltaHUD.new()
return hud