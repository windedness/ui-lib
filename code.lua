-- DarkMenu Library | Author: You | Version: 1.0
-- Usage: local Menu = loadstring(game:HttpGet("URL"))()

local UIS, TS = game:GetService("UserInputService"), game:GetService("TweenService")

local Menu = {}
Menu.__index = Menu

local COLORS = {
    bg        = Color3.fromRGB(22,22,26),
    grad1     = Color3.fromRGB(30,30,36),
    grad2     = Color3.fromRGB(20,20,24),
    header    = Color3.fromRGB(32,32,38),
    stroke    = Color3.fromRGB(55,55,65),
    box       = Color3.fromRGB(38,38,46),
    boxStroke = Color3.fromRGB(60,60,72),
    text      = Color3.fromRGB(190,190,200),
    textTitle = Color3.fromRGB(215,215,225),
    accent    = Color3.fromRGB(80,110,90),
    accentChk = Color3.fromRGB(90,160,110),
    check     = Color3.fromRGB(120,200,140),
}

-- Создание базового окна
function Menu.new(titleText)
    local self = setmetatable({}, Menu)
    self.collapsed = false
    self.elements = {}

    self.gui = Instance.new("ScreenGui")
    self.gui.Name, self.gui.ResetOnSpawn, self.gui.Parent = "DarkMenu", false, game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local main = Instance.new("Frame", self.gui)
    main.Size, main.Position, main.BackgroundColor3 = UDim2.new(0,200,0,32), UDim2.new(0,60,0,60), COLORS.bg
    main.BorderSizePixel, main.Active = 0, true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)
    self.main = main

    self.stroke = Instance.new("UIStroke", main)
    self.stroke.Color, self.stroke.Thickness = COLORS.stroke, 1
    local grad = Instance.new("UIGradient", main)
    grad.Color, grad.Rotation = ColorSequence.new(COLORS.grad1, COLORS.grad2), 90

    local header = Instance.new("Frame", main)
    header.Size, header.BackgroundColor3, header.BorderSizePixel, header.ZIndex = UDim2.new(1,0,0,26), COLORS.header, 0, 2
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,10)
    local hfix = Instance.new("Frame", header)
    hfix.Size, hfix.Position, hfix.BackgroundColor3, hfix.BorderSizePixel, hfix.ZIndex = UDim2.new(1,0,0,10), UDim2.new(0,0,1,-10), COLORS.header, 0, 2

    local title = Instance.new("TextLabel", header)
    title.Size, title.BackgroundTransparency, title.Text = UDim2.new(1,-44,1,0), 1, "☰  " .. titleText
    title.TextColor3, title.Font, title.TextSize, title.TextXAlignment, title.ZIndex = COLORS.textTitle, Enum.Font.GothamBold, 13, Enum.TextXAlignment.Left, 3
    title.Position = UDim2.new(0,10,0,0)

    local arrow = Instance.new("TextButton", header)
    arrow.Size, arrow.Position, arrow.BackgroundTransparency, arrow.Text = UDim2.new(0,30,0,22), UDim2.new(1,-34,0,2), 1, "▼"
    arrow.TextColor3, arrow.Font, arrow.TextSize, arrow.ZIndex = Color3.fromRGB(180,180,195), Enum.Font.GothamBold, 18, 3

    self.content = Instance.new("Frame", main)
    self.content.Size, self.content.Position, self.content.BackgroundTransparency = UDim2.new(1,-20,0,0), UDim2.new(0,10,0,32), 1
    self.content.AutomaticSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", self.content)
    layout.Padding, layout.SortOrder = UDim.new(0,6), Enum.SortOrder.LayoutOrder
    self.layout = layout

    -- Перетаскивание за шапку
    local dg, ds, sp
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dg, ds, sp = true, i.Position, main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dg = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)

    arrow.MouseButton1Click:Connect(function()
        self.collapsed = not self.collapsed
        arrow.Text = self.collapsed and "▲" or "▼"
        self.content.Visible = not self.collapsed
        self.stroke.Transparency = self.collapsed and 1 or 0
        local target = self.collapsed and UDim2.new(0,200,0,26) or UDim2.new(0,200,0,32 + self.content.AbsoluteSize.Y)
        TS:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = target}):Play()
    end)

    -- Авто-обновление высоты окна при добавлении элементов
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not self.collapsed then
            TS:Create(main, TweenInfo.new(0.2), {Size = UDim2.new(0,200,0,32 + self.content.AbsoluteSize.Y)}):Play()
        end
    end)

    return self
end

-- Чекбокс
function Menu:Checkbox(text, default, callback)
    local f = Instance.new("Frame", self.content)
    f.Size, f.BackgroundTransparency = UDim2.new(1,0,0,18), 1
    f.LayoutOrder = #self.elements + 1

    local box = Instance.new("TextButton", f)
    box.Size, box.Position, box.BackgroundColor3, box.Text = UDim2.new(0,16,0,16), UDim2.new(0,0,0,1), COLORS.box, ""
    box.BorderSizePixel = 0
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,4)
    local s = Instance.new("UIStroke", box); s.Color, s.Thickness = COLORS.boxStroke, 1

    local chk = Instance.new("TextLabel", box)
    chk.Size, chk.BackgroundTransparency, chk.Text = UDim2.new(1,0,1,0), 1, "✓"
    chk.TextColor3, chk.Font, chk.TextSize = COLORS.check, Enum.Font.GothamBold, 13
    chk.Visible = default or false

    local lbl = Instance.new("TextLabel", f)
    lbl.Size, lbl.Position, lbl.BackgroundTransparency, lbl.Text = UDim2.new(1,-22,1,0), UDim2.new(0,22,0,0), 1, text
    lbl.TextColor3, lbl.Font, lbl.TextSize, lbl.TextXAlignment = COLORS.text, Enum.Font.Gotham, 12, Enum.TextXAlignment.Left

    local state = default or false
    if state then s.Color = COLORS.accentChk end

    box.MouseButton1Click:Connect(function()
        state = not state
        chk.Visible = state
        s.Color = state and COLORS.accentChk or COLORS.boxStroke
        if callback then callback(state) end
    end)

    local el = {type = "checkbox", set = function(v) state = v; chk.Visible = v; s.Color = v and COLORS.accentChk or COLORS.boxStroke end,
                get = function() return state end}
    table.insert(self.elements, el)
    return el
end

-- Слайдер
function Menu:Slider(text, min, max, default, callback)
    min, max, default = min or 0, max or 100, default or ((min+max)//2)

    local f = Instance.new("Frame", self.content)
    f.Size, f.BackgroundTransparency = UDim2.new(1,0,0,28), 1
    f.LayoutOrder = #self.elements + 1

    local lbl = Instance.new("TextLabel", f)
    lbl.Size, lbl.BackgroundTransparency, lbl.TextColor3 = UDim2.new(1,0,0,14), 1, Color3.fromRGB(170,170,182)
    lbl.Font, lbl.TextSize, lbl.TextXAlignment = Enum.Font.Gotham, 11, Enum.TextXAlignment.Left
    lbl.Text = text .. ": " .. default

    local bg = Instance.new("Frame", f)
    bg.Size, bg.Position, bg.BackgroundColor3, bg.BorderSizePixel = UDim2.new(1,0,0,8), UDim2.new(0,0,0,18), COLORS.box, 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,2)
    local bs = Instance.new("UIStroke", bg); bs.Color, bs.Thickness = COLORS.stroke, 1

    local fill = Instance.new("Frame", bg)
    fill.BackgroundColor3, fill.BorderSizePixel = COLORS.accent, 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,2)

    local knob = Instance.new("Frame", bg)
    knob.Size, knob.BackgroundColor3, knob.BorderSizePixel = UDim2.new(0,10,0,14), Color3.fromRGB(150,150,165), 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0,2)
    local ks = Instance.new("UIStroke", knob); ks.Color, ks.Thickness = Color3.fromRGB(65,65,78), 1

    local val, drag = default, false
    local function apply(x)
        local r = math.clamp((x - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        val = math.floor(min + r * (max - min) + 0.5)
        fill.Size, knob.Position = UDim2.new(r,0,1,0), UDim2.new(r,-5,0,-3)
        lbl.Text = text .. ": " .. val
        if callback then callback(val) end
    end
    apply(bg.AbsolutePosition.X + bg.AbsoluteSize.X * ((default - min) / (max - min)))
    task.wait()
    apply(bg.AbsolutePosition.X + bg.AbsoluteSize.X * ((default - min) / (max - min)))

    bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; apply(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then apply(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)

    local el = {type = "slider", set = function(v) apply(bg.AbsolutePosition.X + bg.AbsoluteSize.X * ((v - min) / (max - min))) end,
                get = function() return val end}
    table.insert(self.elements, el)
    return el
end

-- Кнопка
function Menu:Button(text, callback)
    local row = self.content
    local b = Instance.new("TextButton", row)
    b.Size, b.BackgroundColor3, b.Text, b.LayoutOrder = UDim2.new(1,0,0,22), Color3.fromRGB(40,40,48), text, #self.elements + 1
    b.TextColor3, b.Font, b.TextSize, b.BorderSizePixel, b.AutoButtonColor = COLORS.text, Enum.Font.Gotham, 11, 0, false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(58,58,70)

    b.MouseButton1Click:Connect(function() if callback then callback() end end)

    table.insert(self.elements, {type = "button"})
    return b
end

-- Утилиты
function Menu:Close() self.gui.Enabled = false end
function Menu:Open() self.gui.Enabled = true end

return Menu
