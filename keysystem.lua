local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local sdk = loadstring(game:HttpGet("https://oracle.soteria.rip/sdk.lua"))()

local Config = {
    MaxKeyLength = 80,
    ParticleCount = 60,
    ParticleSpeed = 60,
    ScriptId = "b73de69dca3e4916400af4db1f47da18",
    KeyFile = "failhub_key.txt",
    DiscordLink = "https://discord.gg/2Y4fBEna7F"
}

sdk.script_id = Config.ScriptId

local Colors = {
    Background = Color3.fromRGB(15, 15, 15),
    Surface = Color3.fromRGB(25, 25, 25),
    Primary = Color3.fromRGB(200, 200, 200),
    Border = Color3.fromRGB(60, 60, 60),
    TextPrimary = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(150, 150, 150),
    Success = Color3.fromRGB(100, 255, 100),
    Error = Color3.fromRGB(255, 80, 80),
    Warning = Color3.fromRGB(255, 200, 80),
    Discord = Color3.fromRGB(50, 50, 50),
    GetKey = Color3.fromRGB(40, 40, 40),
    HoverPrimary = Color3.fromRGB(230, 230, 230),
    HoverDiscord = Color3.fromRGB(70, 70, 70),
    HoverGetKey = Color3.fromRGB(60, 60, 60),
    NeonWhite = Color3.fromRGB(240, 240, 240),
    Cyan = Color3.fromRGB(80, 80, 80),
    LightCyan = Color3.fromRGB(160, 160, 160)
}

local State = {
    IsLoading = false,
    IsDestroyed = false,
    Particles = {},
    Animations = {},
    MousePosition = { X = 0, Y = 0 },
    FocusStates = {
        InputFocused = false,
        ButtonHovered = {}
    }
}

local UI = {}
local key = ""

local function GetHWID()
    if syn and syn.get_hwid then return syn.get_hwid() end
    if get_hwid then return get_hwid() end
    if gethwid then return gethwid() end
    return tostring(Player.UserId)
end

local function SaveKey(k)
    if writefile then
        pcall(writefile, Config.KeyFile, k .. "|" .. GetHWID())
    end
end

local function LoadSavedKey()
    if not (readfile and isfile) then return "" end
    local ok, data = pcall(function()
        if isfile(Config.KeyFile) then return readfile(Config.KeyFile) end
        return ""
    end)
    if not ok or not data or data == "" then return "" end
    local parts = string.split(data, "|")
    if parts[2] and parts[2] ~= GetHWID() then return "" end
    return parts[1] or ""
end

local function DeleteSavedKey()
    if delfile and isfile then
        pcall(function()
            if isfile(Config.KeyFile) then delfile(Config.KeyFile) end
        end)
    end
end

local function ValidateKey(k)
    local status = sdk.check_key(k)
    return status.valid, status
end

local function CreateMainGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "KeySystemGUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 100
    sg.Parent = PlayerGui
    UI.ScreenGui = sg
    return sg
end

local function CreateBackdrop(parent)
    local bd = Instance.new("Frame")
    bd.Name = "Backdrop"
    bd.Size = UDim2.new(1, 0, 1, 0)
    bd.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bd.BackgroundTransparency = 0.15
    bd.BorderSizePixel = 0
    bd.ZIndex = 100
    bd.Parent = parent
    UI.Backdrop = bd
    return bd
end

local function CreateContainer(parent)
    local c = Instance.new("Frame")
    c.Name = "MainContainer"
    c.Size = UDim2.new(0, 420, 0, 620)
    c.Position = UDim2.new(0.5, -210, 0.5, -310)
    c.BackgroundColor3 = Colors.Background
    c.BorderSizePixel = 0
    c.ZIndex = 110
    c.Selectable = false
    c.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = c

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Cyan
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = c

    UI.Container = c
    return c
end

local function CreateAnimatedBorder(parent)
    local b = Instance.new("Frame")
    b.Name = "AnimatedBorder"
    b.Size = UDim2.new(1, 6, 1, 6)
    b.Position = UDim2.new(0, -3, 0, -3)
    b.BackgroundTransparency = 1
    b.ZIndex = 109
    b.Selectable = false
    b.Parent = parent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 23)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.LightCyan
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = b

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Cyan),
        ColorSequenceKeypoint.new(0.5, Colors.LightCyan),
        ColorSequenceKeypoint.new(1, Colors.Cyan),
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.2, 0.1),
        NumberSequenceKeypoint.new(0.8, 0.1),
        NumberSequenceKeypoint.new(1, 0.9),
    }
    gradient.Parent = stroke

    UI.AnimatedBorder = { Frame = b, Gradient = gradient, Stroke = stroke }
    return b
end

local function CreateHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 100)
    header.BackgroundTransparency = 1
    header.ZIndex = 111
    header.Selectable = false
    header.Parent = parent

    local iconContainer = Instance.new("Frame")
    iconContainer.Size = UDim2.new(0, 56, 0, 56)
    iconContainer.Position = UDim2.new(0.5, -28, 0, 24)
    iconContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    iconContainer.BorderSizePixel = 0
    iconContainer.ZIndex = 112
    iconContainer.Selectable = false
    iconContainer.Parent = header

    Instance.new("UICorner", iconContainer).CornerRadius = UDim.new(0, 14)

    local iconGlow = Instance.new("Frame")
    iconGlow.Size = UDim2.new(1, 12, 1, 12)
    iconGlow.Position = UDim2.new(0, -6, 0, -6)
    iconGlow.BackgroundTransparency = 1
    iconGlow.ZIndex = 111
    iconGlow.Selectable = false
    iconGlow.Parent = iconContainer

    Instance.new("UICorner", iconGlow).CornerRadius = UDim.new(0, 20)

    local glowStroke = Instance.new("UIStroke")
    glowStroke.Color = Colors.LightCyan
    glowStroke.Thickness = 3
    glowStroke.Transparency = 0.2
    glowStroke.Parent = iconGlow

    local glowGradient = Instance.new("UIGradient")
    glowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Cyan),
        ColorSequenceKeypoint.new(0.5, Colors.LightCyan),
        ColorSequenceKeypoint.new(1, Colors.Cyan),
    }
    glowGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.2, 0.05),
        NumberSequenceKeypoint.new(0.8, 0.05),
        NumberSequenceKeypoint.new(1, 0.8),
    }
    glowGradient.Parent = glowStroke

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0.8, 0, 0.8, 0)
    img.Position = UDim2.new(0.1, 0, 0.1, 0)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://126768595333803"
    img.ImageColor3 = Colors.NeonWhite
    img.ImageTransparency = 0.1
    img.ScaleType = Enum.ScaleType.Fit
    img.ZIndex = 113
    img.Parent = iconContainer

    UI.Header = { Container = header, IconGlow = glowGradient, IconStroke = glowStroke }
    return header
end

local function CreateContent(parent)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -64, 0, 480)
    content.Position = UDim2.new(0, 32, 0, 115)
    content.BackgroundTransparency = 1
    content.ZIndex = 111
    content.Selectable = false
    content.Parent = parent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundTransparency = 1
    title.Text = "Access Key Required"
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 112
    title.Parent = content

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 36)
    subtitle.Position = UDim2.new(0, 0, 0, 38)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Run /key in our Discord to receive your key"
    subtitle.TextColor3 = Colors.TextSecondary
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.TextWrapped = true
    subtitle.ZIndex = 112
    subtitle.Parent = content

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 180, 0, 26)
    badge.Position = UDim2.new(0.5, -90, 0, 82)
    badge.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    badge.BorderSizePixel = 0
    badge.ZIndex = 112
    badge.Parent = content

    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 8)

    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Color = Colors.LightCyan
    badgeStroke.Thickness = 1
    badgeStroke.Transparency = 0.55
    badgeStroke.Parent = badge

    local badgeLabel = Instance.new("TextLabel")
    badgeLabel.Size = UDim2.new(1, 0, 1, 0)
    badgeLabel.BackgroundTransparency = 1
    badgeLabel.Text = "Secured by Soteria Oracle"
    badgeLabel.TextColor3 = Colors.TextSecondary
    badgeLabel.TextSize = 12
    badgeLabel.Font = Enum.Font.GothamMedium
    badgeLabel.TextXAlignment = Enum.TextXAlignment.Center
    badgeLabel.ZIndex = 113
    badgeLabel.Parent = badge

    UI.Content = content
    return content
end

local function CreateInputSection(parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 90)
    section.Position = UDim2.new(0, 0, 0, 122)
    section.BackgroundTransparency = 1
    section.ZIndex = 112
    section.Selectable = false
    section.Parent = parent

    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, 0, 0, 52)
    inputContainer.BackgroundColor3 = Colors.Surface
    inputContainer.BorderSizePixel = 0
    inputContainer.ZIndex = 113
    inputContainer.Selectable = false
    inputContainer.Parent = section

    Instance.new("UICorner", inputContainer).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = inputContainer

    local inputGlow = Instance.new("Frame")
    inputGlow.Size = UDim2.new(1, 8, 1, 8)
    inputGlow.Position = UDim2.new(0, -4, 0, -4)
    inputGlow.BackgroundTransparency = 1
    inputGlow.ZIndex = 112
    inputGlow.Visible = false
    inputGlow.Selectable = false
    inputGlow.Parent = inputContainer

    Instance.new("UICorner", inputGlow).CornerRadius = UDim.new(0, 16)

    local glowStroke = Instance.new("UIStroke")
    glowStroke.Color = Colors.LightCyan
    glowStroke.Thickness = 2
    glowStroke.Transparency = 0.3
    glowStroke.Parent = inputGlow

    local glowGradient = Instance.new("UIGradient")
    glowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Cyan),
        ColorSequenceKeypoint.new(0.5, Colors.LightCyan),
        ColorSequenceKeypoint.new(1, Colors.Cyan),
    }
    glowGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.2, 0.1),
        NumberSequenceKeypoint.new(0.8, 0.1),
        NumberSequenceKeypoint.new(1, 0.8),
    }
    glowGradient.Parent = glowStroke

    local textInput = Instance.new("TextBox")
    textInput.Size = UDim2.new(1, -24, 1, 0)
    textInput.Position = UDim2.new(0, 12, 0, 0)
    textInput.BackgroundTransparency = 1
    textInput.Text = ""
    textInput.PlaceholderText = "Paste your Soteria key here..."
    textInput.TextColor3 = Colors.TextPrimary
    textInput.PlaceholderColor3 = Colors.TextSecondary
    textInput.TextSize = 14
    textInput.Font = Enum.Font.Code
    textInput.TextXAlignment = Enum.TextXAlignment.Left
    textInput.ClearTextOnFocus = false
    textInput.ZIndex = 114
    textInput.Selectable = true
    textInput.Parent = inputContainer

    local charCounter = Instance.new("TextLabel")
    charCounter.Size = UDim2.new(0, 90, 0, 20)
    charCounter.Position = UDim2.new(1, -90, 0, 58)
    charCounter.BackgroundTransparency = 1
    charCounter.Text = "0/" .. Config.MaxKeyLength
    charCounter.TextColor3 = Colors.TextSecondary
    charCounter.TextSize = 12
    charCounter.Font = Enum.Font.Gotham
    charCounter.TextXAlignment = Enum.TextXAlignment.Right
    charCounter.ZIndex = 113
    charCounter.Parent = section

    UI.Input = {
        Container = inputContainer,
        TextBox = textInput,
        Counter = charCounter,
        Stroke = stroke,
        Glow = { Frame = inputGlow, Stroke = glowStroke, Gradient = glowGradient },
    }
    return section
end

local function CreateButtons(parent)
    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(1, 0, 0, 48)
    submitButton.Position = UDim2.new(0, 0, 0, 226)
    submitButton.BackgroundColor3 = Colors.Primary
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Verify Access Key"
    submitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    submitButton.TextSize = 16
    submitButton.Font = Enum.Font.GothamMedium
    submitButton.AutoButtonColor = false
    submitButton.ZIndex = 113
    submitButton.Selectable = true
    submitButton.Parent = parent

    Instance.new("UICorner", submitButton).CornerRadius = UDim.new(0, 12)

    local loadingContainer = Instance.new("Frame")
    loadingContainer.Size = UDim2.new(0, 24, 0, 24)
    loadingContainer.Position = UDim2.new(0.5, -12, 0, 12)
    loadingContainer.BackgroundTransparency = 1
    loadingContainer.Visible = false
    loadingContainer.ZIndex = 114
    loadingContainer.Selectable = false
    loadingContainer.Parent = submitButton

    local spinner = Instance.new("Frame")
    spinner.Size = UDim2.new(1, 0, 1, 0)
    spinner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    spinner.BorderSizePixel = 0
    spinner.ZIndex = 115
    spinner.Selectable = false
    spinner.Parent = loadingContainer

    Instance.new("UICorner", spinner).CornerRadius = UDim.new(1, 0)

    local spinnerGradient = Instance.new("UIGradient")
    spinnerGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.8, 0.8),
        NumberSequenceKeypoint.new(1, 1),
    }
    spinnerGradient.Parent = spinner

    local buttonsContainer = Instance.new("Frame")
    buttonsContainer.Size = UDim2.new(1, 0, 0, 48)
    buttonsContainer.Position = UDim2.new(0, 0, 0, 286)
    buttonsContainer.BackgroundTransparency = 1
    buttonsContainer.ZIndex = 112
    buttonsContainer.Selectable = false
    buttonsContainer.Parent = parent

    local getKeyButton = Instance.new("TextButton")
    getKeyButton.Size = UDim2.new(0.48, 0, 1, 0)
    getKeyButton.BackgroundColor3 = Colors.GetKey
    getKeyButton.BorderSizePixel = 0
    getKeyButton.Text = "Get Key"
    getKeyButton.TextColor3 = Colors.TextPrimary
    getKeyButton.TextSize = 14
    getKeyButton.Font = Enum.Font.GothamMedium
    getKeyButton.AutoButtonColor = false
    getKeyButton.ZIndex = 113
    getKeyButton.Selectable = true
    getKeyButton.Parent = buttonsContainer

    Instance.new("UICorner", getKeyButton).CornerRadius = UDim.new(0, 10)

    local discordButton = Instance.new("TextButton")
    discordButton.Size = UDim2.new(0.48, 0, 1, 0)
    discordButton.Position = UDim2.new(0.52, 0, 0, 0)
    discordButton.BackgroundColor3 = Colors.Discord
    discordButton.BorderSizePixel = 0
    discordButton.Text = "Discord"
    discordButton.TextColor3 = Colors.TextPrimary
    discordButton.TextSize = 14
    discordButton.Font = Enum.Font.GothamMedium
    discordButton.AutoButtonColor = false
    discordButton.ZIndex = 113
    discordButton.Selectable = true
    discordButton.Parent = buttonsContainer

    Instance.new("UICorner", discordButton).CornerRadius = UDim.new(0, 10)

    UI.Buttons = {
        Submit = submitButton,
        GetKey = getKeyButton,
        Discord = discordButton,
        Loading = { Container = loadingContainer, Spinner = spinner },
    }

    return { submitButton, getKeyButton, discordButton }
end

local function CreateStatus(parent)
    local statusContainer = Instance.new("Frame")
    statusContainer.Size = UDim2.new(1, 0, 0, 60)
    statusContainer.Position = UDim2.new(0, 0, 0, 348)
    statusContainer.BackgroundTransparency = 1
    statusContainer.ZIndex = 112
    statusContainer.Selectable = false
    statusContainer.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = ""
    label.TextColor3 = Colors.Error
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextWrapped = true
    label.ZIndex = 113
    label.Parent = statusContainer

    UI.Status = label
    return label
end

local function CreateParticleContainer(parent)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 1, 0)
    c.BackgroundTransparency = 1
    c.ZIndex = 105
    c.Selectable = false
    c.Parent = parent
    UI.ParticleContainer = c
    return c
end

local function CreateParticle()
    if State.IsDestroyed or not UI.ParticleContainer or not UI.ParticleContainer.Parent then return end
    local size = math.random(8, 24)

    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, size, 0, size)
    p.Position = UDim2.new(math.random() * 1.4 - 0.2, 0, 1.2, 0)
    p.BackgroundColor3 = Colors.LightCyan
    p.BackgroundTransparency = math.random(60, 85) / 100
    p.BorderSizePixel = 0
    p.ZIndex = 106
    p.Selectable = false
    p.Parent = UI.ParticleContainer
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)

    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1.8, 0, 1.8, 0)
    glow.Position = UDim2.new(-0.4, 0, -0.4, 0)
    glow.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
    glow.BackgroundTransparency = 0.9
    glow.BorderSizePixel = 0
    glow.ZIndex = 105
    glow.Parent = p
    Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)

    local hl = Instance.new("Frame")
    hl.Size = UDim2.new(0.3, 0, 0.3, 0)
    hl.Position = UDim2.new(0.2, 0, 0.15, 0)
    hl.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    hl.BackgroundTransparency = 0.3
    hl.BorderSizePixel = 0
    hl.ZIndex = 107
    hl.Parent = p
    Instance.new("UICorner", hl).CornerRadius = UDim.new(1, 0)

    table.insert(State.Particles, {
        frame = p,
        vx = (math.random() - 0.5) * 0.004,
        vy = -math.random(20, 50) / 10000,
        created = tick(),
        rotation = 0,
        rotationSpeed = (math.random() - 0.5) * 2,
        pulsePhase = math.random() * math.pi * 2,
        wobblePhase = math.random() * math.pi * 2,
        originalTransparency = p.BackgroundTransparency,
        glow = glow,
        highlight = hl,
        lifetime = math.random(30, 60),
        originalSize = size,
        repelForce = { x = 0, y = 0 },
        mass = size / 10,
    })
end

local function UpdateParticles()
    if State.IsDestroyed or not UI.ParticleContainer then return end
    local ss = UI.ScreenGui.AbsoluteSize
    local mx = State.MousePosition.X / ss.X
    local my = State.MousePosition.Y / ss.Y

    for i = #State.Particles, 1, -1 do
        local pd = State.Particles[i]
        if not pd or not pd.frame or not pd.frame.Parent then
            table.remove(State.Particles, i)
            continue
        end

        local pos = pd.frame.Position
        local age = tick() - pd.created

        if pos.Y.Scale < -0.3 or age > pd.lifetime then
            pd.frame:Destroy()
            table.remove(State.Particles, i)
            continue
        end

        local dx = pos.X.Scale - mx
        local dy = pos.Y.Scale - my
        local dist = math.sqrt(dx * dx + dy * dy)
        local rfx, rfy = 0, 0
        local repelR = 0.15

        if dist < repelR and dist > 0 then
            local power = ((repelR - dist) / repelR) * 0.08 / pd.mass
            rfx = (dx / dist) * power
            rfy = (dy / dist) * power
        end

        pd.repelForce.x = pd.repelForce.x * 0.85 + rfx * 0.15
        pd.repelForce.y = pd.repelForce.y * 0.85 + rfy * 0.15

        local nx = pos.X.Scale + pd.vx + pd.repelForce.x
        local ny = pos.Y.Scale + pd.vy + pd.repelForce.y
        if nx <= -0.2 then nx = 1.2 elseif nx >= 1.2 then nx = -0.2 end

        local wt = tick() * 1.5 + pd.wobblePhase
        nx = nx + math.sin(wt) * 0.002
        ny = ny + math.cos(wt * 0.7) * 0.001

        pd.rotation = pd.rotation + pd.rotationSpeed
        pd.frame.Rotation = pd.rotation

        local breathe = math.sin(tick() * 2.5 + pd.pulsePhase) * 0.1 + 1
        pd.frame.Size = UDim2.new(0, pd.originalSize * breathe, 0, pd.originalSize * breathe)
        pd.frame.BackgroundTransparency = math.clamp(
            pd.originalTransparency + math.sin(tick() * 3 + pd.pulsePhase) * 0.1, 0.5, 0.95)
        pd.highlight.BackgroundTransparency = math.sin(tick() * 4 + pd.pulsePhase) * 0.2 + 0.3
        pd.glow.BackgroundTransparency = dist < 0.2 and (0.7 + dist / 0.2 * 0.2) or 0.9
        pd.vx = pd.vx * 0.995
        pd.vy = pd.vy * 0.998
        pd.frame.Position = UDim2.new(nx, 0, ny, 0)
    end
end

local function CreateButtonGlow(button, hoverColor, originalColor)
    local gb = Instance.new("Frame")
    gb.Size = UDim2.new(1, 8, 1, 8)
    gb.Position = UDim2.new(0, -4, 0, -4)
    gb.BackgroundTransparency = 1
    gb.ZIndex = button.ZIndex - 1
    gb.Visible = false
    gb.Selectable = false
    gb.Parent = button
    Instance.new("UICorner", gb).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.LightCyan
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = gb

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Cyan),
        ColorSequenceKeypoint.new(0.5, Colors.LightCyan),
        ColorSequenceKeypoint.new(1, Colors.Cyan),
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.2, 0.1),
        NumberSequenceKeypoint.new(0.8, 0.1),
        NumberSequenceKeypoint.new(1, 0.8),
    }
    gradient.Parent = stroke

    local tw = nil
    local id = tostring(button)

    button.MouseEnter:Connect(function()
        State.FocusStates.ButtonHovered[id] = true
        gb.Visible = true
        Services.TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = hoverColor }):Play()
        Services.TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 0.1 }):Play()
        if tw then tw:Cancel() end
        tw = Services.TweenService:Create(gradient,
            TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
            { Rotation = 360 })
        tw:Play()
    end)

    button.MouseLeave:Connect(function()
        State.FocusStates.ButtonHovered[id] = false
        Services.TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = originalColor }):Play()
        Services.TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 0.8 }):Play()
        if tw then tw:Cancel(); gradient.Rotation = 0 end
        task.delay(0.3, function()
            if gb and gb.Parent then gb.Visible = false end
        end)
    end)
end

local function ShowStatus(msg, isError, isSuccess)
    if not UI.Status then return end
    UI.Status.Text = msg
    UI.Status.TextColor3 = isSuccess and Colors.Success
        or isError and Colors.Error
        or Colors.Warning
    UI.Status.TextTransparency = 1
    Services.TweenService:Create(UI.Status, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
end

local function ClearStatus()
    if UI.Status then
        Services.TweenService:Create(UI.Status, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
    end
end

local function SetLoading(on)
    State.IsLoading = on
    if not UI.Buttons then return end
    UI.Buttons.Loading.Container.Visible = on
    UI.Buttons.Submit.Text = on and "" or "Verify Access Key"
    if on then
        local t = Services.TweenService:Create(UI.Buttons.Loading.Spinner,
            TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
            { Rotation = 360 })
        t:Play()
        State.Animations.SpinTween = t
    else
        if State.Animations.SpinTween then
            State.Animations.SpinTween:Cancel()
            UI.Buttons.Loading.Spinner.Rotation = 0
        end
    end
end

local function UpdateCharCounter()
    if not UI.Input then return end
    local n = #UI.Input.TextBox.Text
    UI.Input.Counter.Text = n .. "/" .. Config.MaxKeyLength
    UI.Input.Counter.TextColor3 =
        n >= Config.MaxKeyLength and Colors.Error or
        n >= Config.MaxKeyLength * 0.8 and Colors.Warning or
        Colors.TextSecondary
end

local StatusMessages = {
    KEY_INVALID = "Invalid key. Use /key in Discord to get yours.",
    KEY_EXPIRED = "Your key has expired. Run /key in Discord for a new one.",
    RATE_LIMITED = "Too many attempts. Please wait a moment and try again.",
    MISSING_KEY = "Please enter your access key.",
    MISSING_SCRIPT_ID = "Configuration error. Contact the developer."
}

local function MessageForCode(code)
    return StatusMessages[code] or ("Verification failed: " .. tostring(code))
end

local function CloseGUI()
    State.IsDestroyed = true
    UI.Container:TweenPosition(
        UDim2.new(0.5, -210, 0.5, 700), "Out", "Quad", 0.5, true)
    task.delay(0.55, function()
        if UI.ScreenGui and UI.ScreenGui.Parent then
            UI.ScreenGui:Destroy()
        end
    end)
end

local function RunVerification(k, silent)
    local isValid, status = ValidateKey(k)

    if isValid then
        SaveKey(k)
        if not silent then
            SetLoading(false)
            ShowStatus("Key verified! Loading script...", false, true)
        end
        task.wait(silent and 0.6 or 1.2)
        CloseGUI()
        task.wait(0.55)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/eqgoheripg/setgenvpidoras/refs/heads/main/pdf.lua"))()
        return true
    else
        if not silent then
            SetLoading(false)
        end
        if status.code == "KEY_EXPIRED" then
            DeleteSavedKey()
        end
        return false, status
    end
end

local function ConnectEvents()
    Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            State.MousePosition.X = input.Position.X
            State.MousePosition.Y = input.Position.Y
        end
    end)

    UI.Input.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local t = UI.Input.TextBox.Text
        if #t > Config.MaxKeyLength then
            UI.Input.TextBox.Text = t:sub(1, Config.MaxKeyLength)
            ShowStatus("Maximum " .. Config.MaxKeyLength .. " characters allowed.", true)
            return
        end
        key = t
        UpdateCharCounter()
        ClearStatus()
    end)

    local glowTween = nil

    UI.Input.TextBox.Focused:Connect(function()
        State.FocusStates.InputFocused = true
        UI.Input.Glow.Frame.Visible = true
        Services.TweenService:Create(UI.Input.Stroke, TweenInfo.new(0.2),
            { Color = Colors.LightCyan, Transparency = 0.1 }):Play()
        if glowTween then glowTween:Cancel() end
        glowTween = Services.TweenService:Create(UI.Input.Glow.Gradient,
            TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
            { Rotation = 360 })
        glowTween:Play()
        ClearStatus()
    end)

    UI.Input.TextBox.FocusLost:Connect(function()
        State.FocusStates.InputFocused = false
        Services.TweenService:Create(UI.Input.Stroke, TweenInfo.new(0.2),
            { Color = Colors.Border, Transparency = 0.3 }):Play()
        if glowTween then glowTween:Cancel(); UI.Input.Glow.Gradient.Rotation = 0 end
        task.delay(0.3, function()
            if UI.Input.Glow.Frame and UI.Input.Glow.Frame.Parent then
                UI.Input.Glow.Frame.Visible = false
            end
        end)
    end)

    local function Submit()
        if State.IsLoading then return end

        local trimmed = key:match("^%s*(.-)%s*$")
        if trimmed == "" then
            ShowStatus("Please enter your Soteria access key.", true)
            UI.Input.TextBox:CaptureFocus()
            return
        end

        SetLoading(true)
        ShowStatus("Connecting to Soteria...", false, false)
        task.wait(0.4)
        ShowStatus("Validating key...", false, false)

        task.spawn(function()
            local ok, status = RunVerification(trimmed, false)
            if not ok then
                ShowStatus(MessageForCode(status.code), true)
                if status.code == "KEY_INVALID" and setclipboard then
                    pcall(setclipboard, sdk.get_gate_link())
                end
            end
        end)
    end

    Services.UserInputService.InputBegan:Connect(function(input, gp)
        if gp or State.IsDestroyed then return end
        if input.KeyCode == Enum.KeyCode.Return and UI.Input.TextBox:IsFocused() then
            Submit()
        end
    end)

    UI.Buttons.Submit.MouseButton1Click:Connect(Submit)

    UI.Buttons.GetKey.MouseButton1Click:Connect(function()
        if setclipboard then
            pcall(setclipboard, Config.DiscordLink)
            ShowStatus("Discord link copied! Run /key to get your key.", false, true)
        else
            ShowStatus(Config.DiscordLink, false, true)
        end
    end)

    UI.Buttons.Discord.MouseButton1Click:Connect(function()
        if setclipboard then
            pcall(setclipboard, Config.DiscordLink)
            ShowStatus("Discord link copied!", false, true)
        else
            ShowStatus(Config.DiscordLink, false, true)
        end
    end)
end

local function StartAnimationLoops()
    task.spawn(function()
        for _ = 1, 25 do
            if State.IsDestroyed then return end
            CreateParticle()
            task.wait(math.random(20, 100) / 1000)
        end
        while not State.IsDestroyed and UI.ScreenGui and UI.ScreenGui.Parent do
            if #State.Particles < Config.ParticleCount then CreateParticle() end
            task.wait(math.random(400, 1200) / 1000)
        end
    end)

    task.spawn(function()
        while not State.IsDestroyed and UI.ScreenGui and UI.ScreenGui.Parent do
            pcall(UpdateParticles)
            task.wait(1 / Config.ParticleSpeed)
        end
    end)

    task.spawn(function()
        while not State.IsDestroyed and UI.AnimatedBorder and UI.AnimatedBorder.Frame.Parent do
            if State.Animations.BorderTween then State.Animations.BorderTween:Cancel() end
            local t = Services.TweenService:Create(UI.AnimatedBorder.Gradient,
                TweenInfo.new(4, Enum.EasingStyle.Linear),
                { Rotation = UI.AnimatedBorder.Gradient.Rotation + 360 })
            State.Animations.BorderTween = t
            t:Play()
            pcall(function() t.Completed:Wait() end)
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while not State.IsDestroyed and UI.Header and UI.Header.IconGlow and UI.Header.IconGlow.Parent do
            if State.Animations.IconTween then State.Animations.IconTween:Cancel() end
            local t = Services.TweenService:Create(UI.Header.IconGlow,
                TweenInfo.new(3, Enum.EasingStyle.Linear),
                { Rotation = UI.Header.IconGlow.Rotation + 360 })
            State.Animations.IconTween = t
            t:Play()
            pcall(function() t.Completed:Wait() end)
            task.wait(0.1)
        end
    end)
end

local function PlayEntranceAnimation()
    UI.Container.Size = UDim2.new(0, 0, 0, 0)
    UI.Container.BackgroundTransparency = 1
    UI.Backdrop.BackgroundTransparency = 1
    Services.TweenService:Create(UI.Backdrop, TweenInfo.new(0.3),
        { BackgroundTransparency = 0.15 }):Play()
    task.wait(0.1)
    Services.TweenService:Create(UI.Container,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, 420, 0, 620), BackgroundTransparency = 0 }):Play()
    task.wait(0.5)
    UI.Input.TextBox:CaptureFocus()
end

local function BuildGUI()
    local sg = CreateMainGUI()
    local backdrop = CreateBackdrop(sg)
    CreateParticleContainer(backdrop)
    local container = CreateContainer(sg)
    CreateAnimatedBorder(container)
    CreateHeader(container)
    local content = CreateContent(container)
    CreateInputSection(content)
    CreateButtons(content)
    CreateStatus(content)

    CreateButtonGlow(UI.Buttons.Submit, Colors.HoverPrimary, Colors.Primary)
    CreateButtonGlow(UI.Buttons.GetKey, Colors.HoverGetKey, Colors.GetKey)
    CreateButtonGlow(UI.Buttons.Discord, Colors.HoverDiscord, Colors.Discord)

    UpdateCharCounter()
    ClearStatus()
    ConnectEvents()
    StartAnimationLoops()
    PlayEntranceAnimation()
end

local function Initialize()
    local savedKey = LoadSavedKey()

    if savedKey ~= "" then
        local tempGui = Instance.new("ScreenGui")
        tempGui.Name = "KeyCheckGUI"
        tempGui.ResetOnSpawn = false
        tempGui.IgnoreGuiInset = true
        tempGui.DisplayOrder = 100
        tempGui.Parent = PlayerGui

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        label.TextColor3 = Colors.TextSecondary
        label.Text = "Verifying saved key..."
        label.TextSize = 18
        label.Font = Enum.Font.GothamMedium
        label.BackgroundTransparency = 0
        label.ZIndex = 1
        label.Parent = tempGui

        task.spawn(function()
            local isValid, status = ValidateKey(savedKey)

            if isValid then
                label.Text = "Access granted!"
                label.TextColor3 = Colors.Success
                task.wait(0.7)
                tempGui:Destroy()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/eqgoheripg/setgenvpidoras/refs/heads/main/pdf.lua"))()
            else
                if status.code == "KEY_EXPIRED" then
                    DeleteSavedKey()
                end
                local failMsg = MessageForCode(status.code)
                tempGui:Destroy()
                BuildGUI()
                task.wait(0.9)
                ShowStatus(failMsg, true)
            end
        end)
    else
        BuildGUI()
    end
end

Initialize()
