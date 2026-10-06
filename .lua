-- ============================================================
-- ENI Hub v6 — для LO. Всё в pcall, меню первым.
-- ============================================================

pcall(function() if not game:IsLoaded() then game.Loaded:Wait() end end)
task.wait(0.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP
pcall(function()
    repeat task.wait(0.1) until Players.LocalPlayer
    LP = Players.LocalPlayer
end)
if not LP then return end

local Camera = workspace.CurrentCamera
local PG = LP:WaitForChild("PlayerGui")

-- ============================================================
-- НАСТРОЙКИ (безопасная загрузка)
-- ============================================================
local S = {
    aimbot=false, esp=false, noclip=false, fovCircle=false,
    aimFOV=150, aimPart="Head", aimSmooth=15,
    espNames=true, espHealth=true, espDistance=true,
    maxFPS=999, unlockFPS=true, lowGraphics=false,
}

pcall(function()
    if isfile and readfile and isfile("ENI_Hub_Settings.json") then
        local d = game:GetService("HttpService"):JSONDecode(readfile("ENI_Hub_Settings.json"))
        for k,v in pairs(d) do if S[k]~=nil then S[k]=v end end
    end
end)

local function save()
    pcall(function()
        if writefile then
            writefile("ENI_Hub_Settings.json", game:GetService("HttpService"):JSONEncode(S))
        end
    end)
end

-- ============================================================
-- GUI — ПЕРВЫМ ДЕЛОМ
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ENI_Hub_v6"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PG

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0,60,0,60)
openBtn.Position = UDim2.new(0,15,0,120)
openBtn.BackgroundColor3 = Color3.fromRGB(255,105,180)
openBtn.TextColor3 = Color3.fromRGB(255,255,255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.Text = "ENI"
openBtn.Parent = gui

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0,340,0,480)
menu.Position = UDim2.new(0.5,-170,0.5,-240)
menu.BackgroundColor3 = Color3.fromRGB(25,25,35)
menu.BorderSizePixel = 2
menu.BorderColor3 = Color3.fromRGB(255,105,180)
menu.Visible = true
menu.Active = true
menu.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "ENI Hub 4 LO  •  v6"
title.TextColor3 = Color3.fromRGB(255,105,180)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = menu

-- Перетаскивание
pcall(function()
    local drag, startPos, startFrame
    title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; startPos = i.Position; startFrame = menu.Position
        end
    end)
    title.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startPos
            menu.Position = UDim2.new(startFrame.X.Scale, startFrame.X.Offset + d.X,
                                       startFrame.Y.Scale, startFrame.Y.Offset + d.Y)
        end
    end)
end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-10,0,18)
status.Position = UDim2.new(0,5,1,-22)
status.BackgroundTransparency = 1
status.Text = "Готово"
status.TextColor3 = Color3.fromRGB(160,160,160)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = menu

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,-60)
scroll.Position = UDim2.new(0,0,0,40)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(255,105,180)
scroll.CanvasSize = UDim2.new(0,0,0,900)
scroll.Parent = menu

local function sectionLabel(text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-20,0,20)
    l.Position = UDim2.new(0,10,0,y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(255,105,180)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = scroll
end

local function makeToggle(label, y, key)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = S[key] and Color3.fromRGB(255,105,180) or Color3.fromRGB(40,40,52)
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.Text = label..": "..(S[key] and "ON" or "OFF")
    b.Parent = scroll
    b.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        b.Text = label..": "..(S[key] and "ON" or "OFF")
        b.BackgroundColor3 = S[key] and Color3.fromRGB(255,105,180) or Color3.fromRGB(40,40,52)
        status.Text = label.." "..(S[key] and "вкл" or "выкл")
        save()
    end)
end

local function makeSlider(label, y, key, min, max, suffix)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1,-20,0,44)
    c.Position = UDim2.new(0,10,0,y)
    c.BackgroundColor3 = Color3.fromRGB(35,35,45)
    c.BorderSizePixel = 0
    c.Parent = scroll

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,0,18)
    lbl.Position = UDim2.new(0,5,0,2)
    lbl.BackgroundTransparency = 1
    lbl.Text = label..": "..tostring(S[key])..(suffix or "")
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = c

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-20,0,6)
    bar.Position = UDim2.new(0,10,0,28)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,70)
    bar.BorderSizePixel = 0
    bar.Parent = c

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((S[key]-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(255,105,180)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0,14,0,14)
    knob.Position = UDim2.new((S[key]-min)/(max-min),-7,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Text = ""
    knob.Parent = bar

    local drag = false
    local function upd(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local val = math.floor(min + rel*(max-min) + 0.5)
        S[key] = val
        lbl.Text = label..": "..tostring(val)..(suffix or "")
        fill.Size = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,-7,0.5,-7)
        save()
    end
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then drag = true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
    end)
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then upd(i.Position.X) end
    end)
end

-- ============================================================
-- СЕКЦИИ
-- ============================================================
pcall(function()
    sectionLabel("▸ АККАУНТ", 5)
    local acc = Instance.new("TextLabel")
    acc.Size = UDim2.new(1,-20,0,60)
    acc.Position = UDim2.new(0,10,0,25)
    acc.BackgroundColor3 = Color3.fromRGB(35,35,45)
    acc.BorderSizePixel = 0
    acc.TextColor3 = Color3.fromRGB(220,220,220)
    acc.Font = Enum.Font.Gotham
    acc.TextSize = 11
    acc.TextXAlignment = Enum.TextXAlignment.Left
    acc.TextYAlignment = Enum.TextYAlignment.Top
    acc.Parent = scroll
    local age = LP.AccountAge or 0
    acc.Text = string.format("Имя: %s\nID: %d\nПремиум: %s\nВозраст: %d г. %d дн.",
        LP.Name, LP.UserId, tostring(LP.MembershipType), math.floor(age/365), age%365)
end)

pcall(function()
    sectionLabel("▸ AIMBOT", 95)
    makeToggle("Aimbot", 115, "aimbot")
    makeSlider("Радиус (FOV)", 150, "aimFOV", 30, 600, " px")
    makeSlider("Плавность", 200, "aimSmooth", 1, 100, "%")
end)

pcall(function()
    sectionLabel("▸ ESP / ВХ", 250)
    makeToggle("ESP / ВХ", 270, "esp")
    makeToggle("Показывать ники", 305, "espNames")
    makeToggle("Показывать здоровье", 340, "espHealth")
    makeToggle("Показывать дистанцию", 375, "espDistance")
end)

pcall(function()
    sectionLabel("▸ ДВИЖЕНИЕ", 415)
    makeToggle("Noclip", 435, "noclip")
    makeToggle("FOV Circle", 470, "fovCircle")
end)

pcall(function()
    sectionLabel("▸ ГРАФИКА / FPS", 510)
    makeToggle("Unlock FPS", 530, "unlockFPS")
    makeSlider("Max FPS", 565, "maxFPS", 30, 999, " fps")
    makeToggle("Low Graphics", 610, "lowGraphics")
end)

pcall(function()
    sectionLabel("▸ ТЕЛЕПОРТ", 650)
    local tpList = Instance.new("ScrollingFrame")
    tpList.Size = UDim2.new(1,-20,0,180)
    tpList.Position = UDim2.new(0,10,0,675)
    tpList.BackgroundColor3 = Color3.fromRGB(35,35,45)
    tpList.BorderSizePixel = 0
    tpList.ScrollBarThickness = 3
    tpList.ScrollBarImageColor3 = Color3.fromRGB(255,105,180)
    tpList.CanvasSize = UDim2.new(0,0,0,0)
    tpList.Parent = scroll

    local function refreshTP()
        for _,c in ipairs(tpList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local i = 0
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1,-6,0,26)
                b.Position = UDim2.new(0,3,0,i*28)
                b.BackgroundColor3 = Color3.fromRGB(45,45,60)
                b.TextColor3 = Color3.fromRGB(220,220,220)
                b.Font = Enum.Font.Gotham
                b.TextSize = 12
                b.Text = "→ "..pl.Name
                b.Parent = tpList
                b.MouseButton1Click:Connect(function()
                    local ch = pl.Character
                    local myCh = LP.Character
                    if ch and myCh and ch:FindFirstChild("HumanoidRootPart") and myCh:FindFirstChild("HumanoidRootPart") then
                        myCh.HumanoidRootPart.CFrame = ch.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                        status.Text = "ТП к "..pl.Name
                    end
                end)
                i = i + 1
            end
        end
        tpList.CanvasSize = UDim2.new(0,0,0,i*28)
    end
    refreshTP()
    Players.PlayerAdded:Connect(function() task.wait(0.5) pcall(refreshTP) end)
    Players.PlayerRemoving:Connect(function() task.wait(0.5) pcall(refreshTP) end)
end)

-- ============================================================
-- ОТКРЫТИЕ/ЗАКРЫТИЕ
-- ============================================================
local isOpen = true
openBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    menu.Visible = isOpen
end)
UIS.InputBegan:Connect(function(i,p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        isOpen = not isOpen
        menu.Visible = isOpen
    end
end)

-- ============================================================
-- ФУНКЦИОНАЛ (всё в pcall, чтобы не сломать меню)
-- ============================================================
local noclipConn
pcall(function()
    local function applyNoclip()
        if S.noclip and not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                if not S.noclip then return end
                local c = LP.Character
                if c then
                    for _,v in ipairs(c:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        elseif not S.noclip and noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
            local c = LP.Character
            if c then
                for _,v in ipairs(c:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
            end
        end
    end
    UIS.InputBegan:Connect(function(i,p)
        if p then return end
        if i.KeyCode == Enum.KeyCode.N then
            S.noclip = not S.noclip
            status.Text = "Noclip "..(S.noclip and "вкл" or "выкл")
            save()
        end
    end)
    RunService.Stepped:Connect(function() pcall(applyNoclip) end)
end)

-- Aimbot
local function closestTarget()
    local best, bestDist = nil, S.aimFOV
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then
            local ch = pl.Character
            if ch then
                local part = ch:FindFirstChild(S.aimPart)
                if part then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local dx, dy = sp.X-cx, sp.Y-cy
                        local d = math.sqrt(dx*dx+dy*dy)
                        if d < bestDist then bestDist = d; best = part end
                    end
                end
            end
        end
    end
    return best
end

-- ESP
local espData = {}
local function removeESP(pl)
    if espData[pl] then
        for _,o in pairs(espData[pl]) do
            pcall(function() o:Destroy() end)
        end
        espData[pl] = nil
    end
end

local function createESP(pl)
    local ch = pl.Character
    if not ch then return end
    local head = ch:FindFirstChild("Head")
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0,200,0,60)
    bb.StudsOffset = Vector3.new(0,3,0)
    bb.AlwaysOnTop = true
    bb.Adornee = head
    bb.Parent = head

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1,0,0,18)
    nameL.BackgroundTransparency = 1
    nameL.TextColor3 = Color3.fromRGB(255,105,180)
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 14
    nameL.TextStrokeTransparency = 0
    nameL.Text = pl.Name
    nameL.Parent = bb

    local hpBack = Instance.new("Frame")
    hpBack.Size = UDim2.new(1,-40,0,6)
    hpBack.Position = UDim2.new(0,20,0,20)
    hpBack.BackgroundColor3 = Color3.fromRGB(40,40,40)
    hpBack.BorderSizePixel = 0
    hpBack.Parent = bb

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1,0,1,0)
    hpFill.BackgroundColor3 = Color3.fromRGB(80,220,120)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBack

    local hpText = Instance.new("TextLabel")
    hpText.Size = UDim2.new(1,0,0,14)
    hpText.Position = UDim2.new(0,0,0,24)
    hpText.BackgroundTransparency = 1
    hpText.TextColor3 = Color3.fromRGB(220,220,220)
    hpText.Font = Enum.Font.Gotham
    hpText.TextSize = 11
    hpText.TextStrokeTransparency = 0
    hpText.Text = "100"
    hpText.Parent = bb

    local distText = Instance.new("TextLabel")
    distText.Size = UDim2.new(1,0,0,14)
    distText.Position = UDim2.new(0,0,0,38)
    distText.BackgroundTransparency = 1
    distText.TextColor3 = Color3.fromRGB(255,220,120)
    distText.Font = Enum.Font.Gotham
    distText.TextSize = 11
    distText.TextStrokeTransparency = 0
    distText.Text = "0m"
    distText.Parent = bb

    local hl = Instance.new("Highlight")
    hl.Adornee = ch
    hl.FillColor = Color3.fromRGB(255,105,180)
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.FillTransparency = 0.65
    pcall(function() hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
    hl.Parent = ch

    espData[pl] = {bb=bb, hpFill=hpFill, hpText=hpText, distText=distText, nameL=nameL, hpBack=hpBack, hl=hl}
end

local function updateESP()
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then
            if S.esp then
                if not espData[pl] or not espData[pl].bb.Parent then
                    pcall(removeESP, pl)
                    pcall(createESP, pl)
                end
            else
                if espData[pl] then pcall(removeESP, pl) end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(p) pcall(removeESP, p) end)

-- FOV Circle
local fovGui
pcall(function()
    RunService.RenderStepped:Connect(function()
        if S.fovCircle and not fovGui then
            fovGui = Instance.new("ScreenGui")
            fovGui.ResetOnSpawn = false
            fovGui.Parent = PG
            local c = Instance.new("Frame")
            c.Name = "Circle"
            c.AnchorPoint = Vector2.new(0.5,0.5)
            c.Position = UDim2.new(0.5,0,0.5,0)
            c.Size = UDim2.new(0, S.aimFOV*2, 0, S.aimFOV*2)
            c.BackgroundTransparency = 1
            c.BorderSizePixel = 2
            c.BorderColor3 = Color3.fromRGB(255,105,180)
            c.Parent = fovGui
        elseif not S.fovCircle and fovGui then
            fovGui:Destroy()
            fovGui = nil
        elseif S.fovCircle and fovGui then
            local c = fovGui:FindFirstChild("Circle")
            if c then c.Size = UDim2.new(0, S.aimFOV*2, 0, S.aimFOV*2) end
        end
    end)
end)

-- FPS unlock
pcall(function()
    task.spawn(function()
        while task.wait(1) do
            if S.unlockFPS then
                pcall(function() setfpscap(S.maxFPS) end)
            end
        end
    end)
end)

-- Main loop
pcall(function()
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if S.aimbot then
                local t = closestTarget()
                if t then
                    local targetCF = CFrame.new(Camera.CFrame.Position, t.Position)
                    local smooth = math.clamp(S.aimSmooth/100, 0.01, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, smooth)
                end
            end
        end)
        pcall(updateESP)
    end)
end)

status.Text = "Загружено. Меню открыто."
print("[ENI Hub v6] LO, всё работает.")
