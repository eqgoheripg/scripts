return function(env)
    local Settings = env.Settings
    local createDrawing = env.createDrawing
    local getCustomIconAsset = env.getCustomIconAsset
    local getPlayerColor = env.getPlayerColor
    local getPlayerClass = env.getPlayerClass
    local getPlayerSquadIcon = env.getPlayerSquadIcon
    local getEquippedWeapon = env.getEquippedWeapon
    local getCharacterHead = env.getCharacterHead
    local getCharacterRoot = env.getCharacterRoot
    local isIgnoredSCP = env.isIgnoredSCP

    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    local EspGui = Instance.new("ScreenGui")
    EspGui.Name = "Neverlose_ESP_Gui"
    EspGui.ResetOnSpawn = false
    EspGui.DisplayOrder = 999999
    EspGui.IgnoreGuiInset = true
    pcall(function()
        local parent = nil
        local ok, res = pcall(function()
            if gethui then return gethui() end
            local core = game:GetService("CoreGui")
            if core and pcall(function() return core.Name end) then return core end
            return LocalPlayer:WaitForChild("PlayerGui")
        end)
        if ok and res then parent = res end
        if parent then EspGui.Parent = parent end
    end)

    local ESPObjects = {}
    local SCPEntities = {}

local function removeESP(player)
    if ESPObjects[player] then
        for _, item in pairs(ESPObjects[player].Drawings) do
            pcall(function() item:Remove() end)
        end
        if ESPObjects[player].Highlight then
            pcall(function() ESPObjects[player].Highlight:Destroy() end)
        end
        if ESPObjects[player].SquadIcon then
            pcall(function() ESPObjects[player].SquadIcon:Destroy() end)
        end
        ESPObjects[player] = nil
    end
end

local function initPlayerESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then removeESP(player) end

    local squadIcon = Instance.new("ImageLabel")
    squadIcon.Name = "ESP_SquadIcon"
    squadIcon.BackgroundTransparency = 1
    squadIcon.BorderSizePixel = 0
    squadIcon.Size = UDim2.fromOffset(Settings.SquadIconSize or 22, Settings.SquadIconSize or 22)
    squadIcon.Visible = false
    squadIcon.ZIndex = 10
    squadIcon.Parent = EspGui

    local drawings = {
        BoxOutline     = createDrawing("Square", { Thickness = 3, Filled = false, Color = Color3.fromRGB(0, 0, 0), Visible = false, ZIndex = 1 }),
        Box            = createDrawing("Square", { Thickness = 1, Filled = false, Color = Settings.BoxColor, Visible = false, ZIndex = 2 }),
        NameText       = createDrawing("Text",   { Size = Settings.TextSize, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Color = Settings.NameColor, Visible = false, ZIndex = 3 }),
        ClassText      = createDrawing("Text",   { Size = Settings.TextSize - 1, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Color = Color3.fromRGB(255, 200, 0), Visible = false, ZIndex = 3 }),
        HealthBarBg    = createDrawing("Line",   { Thickness = 4, Color = Color3.fromRGB(20, 20, 20), Visible = false, ZIndex = 1 }),
        HealthBar      = createDrawing("Line",   { Thickness = 2, Color = Settings.HealthBarColor, Visible = false, ZIndex = 2 }),
        HealthText     = createDrawing("Text",   { Size = Settings.TextSize - 2, Center = false, Outline = true, OutlineColor = Color3.new(0, 0, 0), Color = Color3.fromRGB(255, 255, 255), Visible = false, ZIndex = 3 }),
        DistanceText   = createDrawing("Text",   { Size = Settings.TextSize - 2, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Color = Color3.fromRGB(200, 200, 200), Visible = false, ZIndex = 3 }),
        WeaponText     = createDrawing("Text",   { Size = Settings.TextSize - 2, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Color = Color3.fromRGB(180, 220, 255), Visible = false, ZIndex = 3 }),
        Tracer         = createDrawing("Line",   { Thickness = 1.5, Color = Settings.TracerColor, Visible = false, ZIndex = 1 })
    }

    ESPObjects[player] = {
        Drawings = drawings,
        Highlight = nil,
        SquadIcon = squadIcon
    }
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        initPlayerESP(player)
    end
end

local PlayerAddedESPConn = Players.PlayerAdded:Connect(initPlayerESP)
local PlayerRemovingESPConn = Players.PlayerRemoving:Connect(removeESP)

local function getSCPPrimaryPart(model)
    if not model then return nil end
    if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
        return model.PrimaryPart
    end
    local hrp = model:FindFirstChild("HumanoidRootPart", true) or model:FindFirstChild("RootPart", true) or model:FindFirstChild("Torso", true) or model:FindFirstChild("UpperTorso", true) or model:FindFirstChild("Head", true) or model:FindFirstChild("Entity", true)
    if hrp and hrp:IsA("BasePart") then
        return hrp
    end
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Transparency < 1 and desc.Size.Magnitude > 0.5 then
            return desc
        end
    end
    return model:FindFirstChildWhichIsA("BasePart", true)
end

local function removeSCPESP(model)
    if SCPEntities[model] then
        for _, item in pairs(SCPEntities[model].Drawings) do
            pcall(function() item:Remove() end)
        end
        if SCPEntities[model].Highlight then
            pcall(function() SCPEntities[model].Highlight:Destroy() end)
        end
        if SCPEntities[model].SquadIcon then
            pcall(function() SCPEntities[model].SquadIcon:Destroy() end)
        end
        SCPEntities[model] = nil
    end
end

local function initSCPESP(model, primaryPart)
    if not model or not model:IsA("Model") then return end
    if isIgnoredSCP(model.Name) then
        if SCPEntities[model] then removeSCPESP(model) end
        return
    end
    if SCPEntities[model] then removeSCPESP(model) end

    local squadIcon = Instance.new("ImageLabel")
    squadIcon.Name = "SCP_Icon"
    squadIcon.BackgroundTransparency = 1
    squadIcon.BorderSizePixel = 0
    squadIcon.Size = UDim2.fromOffset(Settings.SquadIconSize or 22, Settings.SquadIconSize or 22)
    squadIcon.Image = getCustomIconAsset("SCP")
    squadIcon.Visible = false
    squadIcon.ZIndex = 10
    squadIcon.Parent = EspGui

    local scpTextSize = Settings.SCP_TextSize or (Settings.TextSize + 1)
    local drawings = {
        BoxOutline   = createDrawing("Square", { Thickness = 3, Filled = false, Color = Color3.fromRGB(0, 0, 0), Visible = false, ZIndex = 1 }),
        Box          = createDrawing("Square", { Thickness = 1.5, Filled = false, Color = Settings.SCP_Color, Visible = false, ZIndex = 2 }),
        NameText     = createDrawing("Text",   { Size = scpTextSize, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Color = Settings.SCP_Color, Visible = false, ZIndex = 3 }),
        DistanceText = createDrawing("Text",   { Size = scpTextSize - 1, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Color = Color3.fromRGB(255, 200, 200), Visible = false, ZIndex = 3 })
    }

    SCPEntities[model] = {
        Drawings = drawings,
        Highlight = nil,
        SquadIcon = squadIcon,
        PrimaryPart = primaryPart
    }
end

local function registerSCPModel(model)
    if not model or not model:IsA("Model") then return end
    if isIgnoredSCP(model.Name) then return end

    local primaryPart = getSCPPrimaryPart(model)
    if primaryPart and not SCPEntities[model] then
        initSCPESP(model, primaryPart)
    elseif primaryPart and SCPEntities[model] then
        SCPEntities[model].PrimaryPart = primaryPart
    end
end

local function scanAllSCPs()
    local scpFolder = Workspace:FindFirstChild("SCPs")
    if scpFolder then
        for _, child in ipairs(scpFolder:GetChildren()) do
            if child:IsA("Model") then
                registerSCPModel(child)
                for _, sub in ipairs(child:GetChildren()) do
                    if sub:IsA("Model") and not isIgnoredSCP(sub.Name) then
                        registerSCPModel(sub)
                    end
                end
            end
        end
    end

    for _, item in ipairs(Workspace:GetChildren()) do
        if item:IsA("Model") and item.Name:upper():find("SCP") and not isIgnoredSCP(item.Name) and item ~= scpFolder then
            registerSCPModel(item)
        end
    end
end


    task.spawn(scanAllSCPs)

    local lastPeriodicScpScan = 0

    local function renderESP()
        local Camera = Workspace.CurrentCamera
        if not Camera then return end
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        local mousePos = UserInputService:GetMouseLocation()

        for player, esp in pairs(ESPObjects) do
            local d = esp.Drawings
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local rootPart = character and getCharacterRoot(character)
            local head = character and getCharacterHead(character)

            local isVisible = false

            if Settings.ESP_Enabled and character and humanoid and rootPart and head and rootPart:IsA("BasePart") and head:IsA("BasePart") and humanoid.Health > 0 then
                if not Settings.TeamCheck or (player.Team ~= LocalPlayer.Team) then
                    local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude

                    if onScreen and dist <= Settings.MaxDistance then
                        isVisible = true
                        local teamColor = getPlayerColor(player)
                        local className = getPlayerClass(player)

                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
                        local legPos  = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

                        local boxHeight = math.abs(headPos.Y - legPos.Y)
                        local boxWidth  = math.clamp(boxHeight * 0.6, 12, 1000)
                        local boxTopLeft = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y)

                        if Settings.ShowBox then
                            d.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                            d.BoxOutline.Position = boxTopLeft
                            d.BoxOutline.Visible = true

                            d.Box.Size = Vector2.new(boxWidth, boxHeight)
                            d.Box.Position = boxTopLeft
                            d.Box.Color = Settings.UseTeamColors and teamColor or Settings.BoxColor
                            d.Box.Visible = true
                        else
                            d.BoxOutline.Visible = false
                            d.Box.Visible = false
                        end

                        local topOffset = 0
                        if Settings.ShowNames then
                            local nameStr = Settings.ShowDisplayNames and (player.DisplayName .. " @" .. player.Name) or player.Name
                            d.NameText.Text = nameStr
                            d.NameText.Size = Settings.TextSize
                            d.NameText.Color = Settings.UseTeamColors and teamColor or Settings.NameColor
                            d.NameText.Position = Vector2.new(boxTopLeft.X + boxWidth / 2, boxTopLeft.Y - Settings.TextSize - 3)
                            d.NameText.Visible = true
                            topOffset = topOffset + Settings.TextSize + 2

                            local iconAsset = getPlayerSquadIcon(player)
                            if Settings.ShowSquadBadges and iconAsset and iconAsset ~= "" and esp.SquadIcon then
                                local textW = d.NameText.TextBounds and d.NameText.TextBounds.X or (#nameStr * (Settings.TextSize * 0.52))
                                local iconSize = Settings.Player_IconSize or Settings.SquadIconSize or 22
                                local iconX = (boxTopLeft.X + boxWidth / 2) + (textW / 2) + 6
                                local iconY = (boxTopLeft.Y - Settings.TextSize - 3) + ((Settings.TextSize - iconSize) / 2)
                                esp.SquadIcon.Image = iconAsset
                                esp.SquadIcon.Position = UDim2.fromOffset(iconX, iconY)
                                esp.SquadIcon.Size = UDim2.fromOffset(iconSize, iconSize)
                                esp.SquadIcon.Visible = true
                            elseif esp.SquadIcon then
                                esp.SquadIcon.Visible = false
                            end
                        else
                            d.NameText.Visible = false
                            if esp.SquadIcon then esp.SquadIcon.Visible = false end
                        end

                        if Settings.ShowClass then
                            d.ClassText.Text = className
                            d.ClassText.Size = Settings.TextSize - 1
                            d.ClassText.Color = teamColor
                            d.ClassText.Position = Vector2.new(boxTopLeft.X + boxWidth / 2, boxTopLeft.Y - topOffset - (Settings.TextSize - 1) - 2)
                            d.ClassText.Visible = true
                        else
                            d.ClassText.Visible = false
                        end

                        local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local healthColor = Color3.fromHSV(healthPct * 0.33, 1, 1)

                        if Settings.ShowHealthBar then
                            local barX = boxTopLeft.X - 6
                            local barTop = boxTopLeft.Y
                            local barBottom = boxTopLeft.Y + boxHeight

                            d.HealthBarBg.From = Vector2.new(barX, barTop - 1)
                            d.HealthBarBg.To = Vector2.new(barX, barBottom + 1)
                            d.HealthBarBg.Visible = true

                            local fillTop = barBottom - (boxHeight * healthPct)
                            d.HealthBar.From = Vector2.new(barX, fillTop)
                            d.HealthBar.To = Vector2.new(barX, barBottom)
                            d.HealthBar.Color = healthColor
                            d.HealthBar.Visible = true
                        else
                            d.HealthBarBg.Visible = false
                            d.HealthBar.Visible = false
                        end

                        if Settings.ShowHealth then
                            local barX = boxTopLeft.X - 10
                            local fillTop = (boxTopLeft.Y + boxHeight) - (boxHeight * healthPct)
                            d.HealthText.Text = math.floor(humanoid.Health) .. " HP"
                            d.HealthText.Position = Vector2.new(barX - 25, math.clamp(fillTop - 4, boxTopLeft.Y, boxTopLeft.Y + boxHeight))
                            d.HealthText.Color = healthColor
                            d.HealthText.Visible = true
                        else
                            d.HealthText.Visible = false
                        end

                        local bottomOffset = 2
                        if Settings.ShowDistance then
                            d.DistanceText.Text = string.format("%d m", math.floor(dist * 0.28))
                            d.DistanceText.Position = Vector2.new(boxTopLeft.X + boxWidth / 2, boxTopLeft.Y + boxHeight + bottomOffset)
                            d.DistanceText.Visible = true
                            bottomOffset = bottomOffset + Settings.TextSize
                        else
                            d.DistanceText.Visible = false
                        end

                        if Settings.ShowWeapon then
                            local weapon = getEquippedWeapon(character)
                            if weapon ~= "None" then
                                d.WeaponText.Text = weapon
                                d.WeaponText.Position = Vector2.new(boxTopLeft.X + boxWidth / 2, boxTopLeft.Y + boxHeight + bottomOffset)
                                d.WeaponText.Visible = true
                            else
                                d.WeaponText.Visible = false
                            end
                        else
                            d.WeaponText.Visible = false
                        end

                        if Settings.ShowTracers then
                            local origin = screenBottom
                            if Settings.TracerOrigin == "Center" then
                                origin = screenCenter
                            elseif Settings.TracerOrigin == "Mouse" then
                                origin = mousePos
                            end

                            d.Tracer.From = origin
                            d.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            d.Tracer.Color = Settings.UseTeamColors and teamColor or Settings.TracerColor
                            d.Tracer.Visible = true
                        else
                            d.Tracer.Visible = false
                        end

                        if Settings.ShowChams then
                            if not esp.Highlight then
                                esp.Highlight = Instance.new("Highlight")
                                esp.Highlight.Name = "NEVERLOSE_Cham"
                                esp.Highlight.Adornee = character
                                esp.Highlight.Parent = EspGui
                            end
                            esp.Highlight.Enabled = true
                            esp.Highlight.FillColor = Settings.UseTeamColors and teamColor or Settings.ChamsColor
                            esp.Highlight.FillTransparency = Settings.ChamsTransparency
                            esp.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            esp.Highlight.OutlineTransparency = 0.2
                        elseif esp.Highlight then
                            esp.Highlight.Enabled = false
                        end
                    end
                end
            end

            if not isVisible then
                for _, drawing in pairs(d) do
                    drawing.Visible = false
                end
                if esp.Highlight then
                    esp.Highlight.Enabled = false
                end
                if esp.SquadIcon then
                    esp.SquadIcon.Visible = false
                end
            end
        end

        if Settings.SCP_ESP_Enabled and (tick() - lastPeriodicScpScan >= 1.5) then
            lastPeriodicScpScan = tick()
            scanAllSCPs()
        end

        for model, esp in pairs(SCPEntities) do
            local d = esp.Drawings
            local isVisible = false

            if Settings.SCP_ESP_Enabled and model and model.Parent and not isIgnoredSCP(model.Name) then
                local primaryPart = esp.PrimaryPart
                if not primaryPart or not primaryPart.Parent then 
                    primaryPart = getSCPPrimaryPart(model)
                    esp.PrimaryPart = primaryPart
                end
                if primaryPart then
                    local pos, onScreen = Camera:WorldToViewportPoint(primaryPart.Position)
                    local dist = (Camera.CFrame.Position - primaryPart.Position).Magnitude

                    if onScreen and dist <= Settings.SCP_MaxDistance then
                        isVisible = true
                        local scpName = model.Name

                        local successExt, extents = pcall(function() return model:GetExtentsSize() end)
                        if not successExt or not extents or extents.Y < 1 then
                            extents = Vector3.new(4, 6, 4)
                        end

                        local topPos = Camera:WorldToViewportPoint(primaryPart.Position + Vector3.new(0, extents.Y / 2, 0))
                        local btmPos = Camera:WorldToViewportPoint(primaryPart.Position - Vector3.new(0, extents.Y / 2, 0))
                        local boxH = math.max(12, math.abs(topPos.Y - btmPos.Y))
                        local boxW = math.clamp(boxH * 0.65, 12, 1000)
                        local bTopLeft = Vector2.new(pos.X - boxW / 2, topPos.Y)

                        local textSize = Settings.SCP_TextSize or (Settings.TextSize + 1)

                        if Settings.SCP_ShowBox then
                            d.BoxOutline.Size = Vector2.new(boxW, boxH)
                            d.BoxOutline.Position = bTopLeft
                            d.BoxOutline.Visible = true

                            d.Box.Size = Vector2.new(boxW, boxH)
                            d.Box.Position = bTopLeft
                            d.Box.Color = Settings.SCP_Color
                            d.Box.Visible = true
                        else
                            d.BoxOutline.Visible = false
                            d.Box.Visible = false
                        end

                        if Settings.SCP_ShowNames then
                            d.NameText.Text = scpName
                            d.NameText.Size = textSize
                            d.NameText.Position = Vector2.new(bTopLeft.X + boxW / 2, bTopLeft.Y - textSize - 3)
                            d.NameText.Color = Settings.SCP_Color
                            d.NameText.Visible = true

                            if Settings.SCP_ShowBadges and esp.SquadIcon then
                                local textW = d.NameText.TextBounds and d.NameText.TextBounds.X or (#scpName * (textSize * 0.52))
                                local iconSize = Settings.SCP_IconSize or 22
                                local iconX = (bTopLeft.X + boxW / 2) + (textW / 2) + 6
                                local iconY = (bTopLeft.Y - textSize - 3) + ((textSize - iconSize) / 2)
                                esp.SquadIcon.Image = getCustomIconAsset("SCP")
                                esp.SquadIcon.Position = UDim2.fromOffset(iconX, iconY)
                                esp.SquadIcon.Size = UDim2.fromOffset(iconSize, iconSize)
                                esp.SquadIcon.Visible = true
                            elseif esp.SquadIcon then
                                esp.SquadIcon.Visible = false
                            end
                        else
                            d.NameText.Visible = false
                            if esp.SquadIcon then esp.SquadIcon.Visible = false end
                        end

                        if Settings.SCP_ShowDistance then
                            d.DistanceText.Text = string.format("%d m", math.floor(dist * 0.28))
                            d.DistanceText.Size = textSize - 1
                            d.DistanceText.Position = Vector2.new(bTopLeft.X + boxW / 2, bTopLeft.Y + boxH + 2)
                            d.DistanceText.Visible = true
                        else
                            d.DistanceText.Visible = false
                        end

                        if Settings.SCP_ShowChams then
                            if not esp.Highlight then
                                esp.Highlight = Instance.new("Highlight")
                                esp.Highlight.Name = "NEVERLOSE_SCPCham"
                                esp.Highlight.Adornee = model
                                esp.Highlight.Parent = EspGui
                            end
                            esp.Highlight.Enabled = true
                            esp.Highlight.FillColor = Settings.SCP_Color
                            esp.Highlight.FillTransparency = Settings.SCP_ChamsTransparency or 0.4
                            esp.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            esp.Highlight.OutlineTransparency = 0.2
                        elseif esp.Highlight then
                            esp.Highlight.Enabled = false
                        end
                    end
                end
            end

            if not isVisible then
                for _, drawing in pairs(d) do
                    drawing.Visible = false
                end
                if esp.Highlight then
                    esp.Highlight.Enabled = false
                end
                if esp.SquadIcon then
                    esp.SquadIcon.Visible = false
                end
            end
        end
    end

    local function destroyESP()
        for player in pairs(ESPObjects) do
            removeESP(player)
        end
        for model in pairs(SCPEntities) do
            removeSCPESP(model)
        end
        if EspGui then
            pcall(function() EspGui:Destroy() end)
        end
    end

    return {
        Render = renderESP,
        ScanAll = scanAllSCPs,
        RegisterSCPModel = registerSCPModel,
        RemoveSCPESP = removeSCPESP,
        Destroy = destroyESP,
    }
end
