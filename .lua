-- ============================================================
-- ENI Hub v3 — для LO. Меню создаётся ПЕРВЫМ.
-- ============================================================

-- Ждём загрузку игры
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Ждём LocalPlayer
local LP
repeat task.wait(0.1) until Players.LocalPlayer
LP = Players.LocalPlayer

local Camera = workspace.CurrentCamera

-- ============================================================
-- ШАГ 1: GUI (создаётся СРАЗУ, чтобы точно появилось)
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ENI_Hub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")

-- Кнопка открытия (всегда видна)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 60, 0, 60)
openBtn.Position = UDim2.new(0, 15, 0, 120)
openBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.Text = "ENI"
openBtn.Active = true
openBtn.Draggable = true
openBtn.Parent = gui

-- Основное окно меню
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 260, 0, 380)
menu.Position = UDim2.new(0.5, -130, 0.5, -190)
menu.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
menu.BorderSizePixel = 2
menu.BorderColor3 = Color3.fromRGB(255, 105, 180)
menu.Visible = false
menu.Active = true
menu.Draggable = true
menu.Parent = gui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "ENI Hub 4 LO"
title.TextColor3 = Color3.fromRGB(255, 105, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = menu

-- Статус
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 18)
status.Position = UDim2.new(0, 5, 1, -22)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(160, 160, 160)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = menu

-- Открытие/закрытие
local open = false
openBtn.MouseButton1Click:Connect(function()
    open = not open
    menu.Visible = open
end)
UIS.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        open = not open
        menu.Visible = open
    end
end)

-- ============================================================
-- ШАГ 2: Кнопки-переключатели
-- ============================================================
local S = {
    aimbot = false,
    esp = false,
    noclip = false,
    fov = false,
}

local function mkBtn(label, y, key)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0, 32)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    b.TextColor3 = Color3.fromRGB(230, 230, 230)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.Text = label .. ": OFF"
    b.Parent = menu
    b.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        b.Text = label .. ": " .. (S[key] and "ON" or "OFF")
        b.BackgroundColor3 = S[key] and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(40, 40, 52)
        status.Text = label .. (S[key] and " ON" or " OFF")
    end)
end

mkBtn("Aimbot", 45, "aimbot")
mkBtn("ESP / ВХ", 82, "esp")
mkBtn("Noclip", 119, "noclip")
mkBtn("FOV Circle", 156, "fov")

-- ============================================================
-- ШАГ 3: Noclip
-- ============================================================
local noclipConn
local function applyNoclip()
    if S.noclip and not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            if not S.noclip then return end
            local c = LP.Character
            if c then
                for _, v in ipairs(c:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    elseif not S.noclip and noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
        local c = LP.Character
        if c then
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end

-- Хоткей N
UIS.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.N then
        S.noclip = not S.noclip
        status.Text = "Noclip " .. (S.noclip and "ON" or "OFF")
    end
end)

-- ============================================================
-- ШАГ 4: Aimbot (универсальный)
-- ============================================================
local FOV_RADIUS = 150

local function closestTarget()
    local best, bestDist = nil, FOV_RADIUS
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LP then continue end
        local ch = pl.Character
        if not ch then continue end
        local head = ch:FindFirstChild("Head")
        if not head then continue end
        local sp, on = Camera:WorldToViewportPoint(head.Position)
        if not on then continue end
        local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(cx, cy)).Magnitude
        if d < bestDist then
            bestDist = d
            best = head
        end
    end
    return best
end

-- ============================================================
-- ШАГ 5: ESP (Highlight)
-- ============================================================
local espMap = {}
local function updateESP()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LP then continue end
        if S.esp then
            local ch = pl.Character
            if ch and not espMap[pl] then
                local h = Instance.new("Highlight")
                h.Name = "ENI_ESP"
                h.Adornee = ch
                h.FillColor = Color3.fromRGB(255, 105, 180)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.55
                h.Parent = ch
                espMap[pl] = h
            end
        else
            if espMap[pl] then
                espMap[pl]:Destroy()
                espMap[pl] = nil
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(p)
    if espMap[p] then espMap[p]:Destroy() espMap[p] = nil end
end)

-- ============================================================
-- ШАГ 6: FOV Circle
-- ============================================================
local fovGui
local function toggleFOV()
    if S.fov and not fovGui then
        fovGui = Instance.new("ScreenGui")
        fovGui.Name = "ENI_FOV"
        fovGui.Parent = LP:WaitForChild("PlayerGui")
        local c = Instance.new("Frame")
        c.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
        c.Position = UDim2.new(0.5, -FOV_RADIUS, 0.5, -FOV_RADIUS)
        c.BackgroundTransparency = 1
        c.BorderSizePixel = 2
        c.BorderColor3 = Color3.fromRGB(255, 105, 180)
        c.Parent = fovGui
    elseif not S.fov and fovGui then
        fovGui:Destroy()
        fovGui = nil
    end
end

-- ============================================================
-- ШАГ 7: Главный цикл
-- ============================================================
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if S.aimbot then
        local t = closestTarget()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end
    -- Noclip
    applyNoclip()
    -- FOV
    toggleFOV()
    -- ESP
    updateESP()
end)

status.Text = "Загружено. Кнопка ENI справа."
print("[ENI Hub v3] LO, всё готово.")
