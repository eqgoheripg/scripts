local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Lighting = game:GetService("Lighting")

local fpsBoostEnabled = false
local fpsBoostOriginals = {}

local function applyFPSBoost()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or
           effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or
           effect:IsA("ColorCorrectionEffect") then
            fpsBoostOriginals[effect] = effect.Enabled
            effect.Enabled = false
        end
    end
    if Terrain then
        fpsBoostOriginals["WaterWaveSize"]    = Terrain.WaterWaveSize
        fpsBoostOriginals["WaterWaveSpeed"]   = Terrain.WaterWaveSpeed
        fpsBoostOriginals["WaterReflectance"] = Terrain.WaterReflectance
        fpsBoostOriginals["WaterTransparency"]= Terrain.WaterTransparency
        Terrain.WaterWaveSize     = 0
        Terrain.WaterWaveSpeed    = 0
        Terrain.WaterReflectance  = 0
        Terrain.WaterTransparency = 0
    end
    fpsBoostOriginals["GlobalShadows"] = Lighting.GlobalShadows
    Lighting.GlobalShadows = false
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("CornerWedgePart") or
               obj:IsA("TrussPart") or obj:IsA("WedgePart") then
                fpsBoostOriginals[obj] = {
                    Material    = obj.Material,
                    Reflectance = obj.Reflectance,
                    CastShadow  = obj.CastShadow,
                }
                obj.Material    = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow  = false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or
                   obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
                fpsBoostOriginals[obj] = obj.Enabled
                obj.Enabled = false
            end
        end)
    end
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title    = "FPS Boost",
            Text     = "Включён — качество понижено",
            Duration = 3,
        })
    end)
end

local fpsBoostDescConn = nil

local function disableFPSBoost()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
    for _, effect in ipairs(Lighting:GetChildren()) do
        if fpsBoostOriginals[effect] ~= nil then
            effect.Enabled = fpsBoostOriginals[effect]
            fpsBoostOriginals[effect] = nil
        end
    end
    if Terrain then
        if fpsBoostOriginals["WaterWaveSize"]    ~= nil then Terrain.WaterWaveSize    = fpsBoostOriginals["WaterWaveSize"]    end
        if fpsBoostOriginals["WaterWaveSpeed"]   ~= nil then Terrain.WaterWaveSpeed   = fpsBoostOriginals["WaterWaveSpeed"]   end
        if fpsBoostOriginals["WaterReflectance"] ~= nil then Terrain.WaterReflectance = fpsBoostOriginals["WaterReflectance"] end
        if fpsBoostOriginals["WaterTransparency"]~= nil then Terrain.WaterTransparency= fpsBoostOriginals["WaterTransparency"]end
        fpsBoostOriginals["WaterWaveSize"]     = nil
        fpsBoostOriginals["WaterWaveSpeed"]    = nil
        fpsBoostOriginals["WaterReflectance"]  = nil
        fpsBoostOriginals["WaterTransparency"] = nil
    end
    if fpsBoostOriginals["GlobalShadows"] ~= nil then
        Lighting.GlobalShadows = fpsBoostOriginals["GlobalShadows"]
        fpsBoostOriginals["GlobalShadows"] = nil
    end
    for obj, state in pairs(fpsBoostOriginals) do
        pcall(function()
            if typeof(obj) == "Instance" then
                if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("CornerWedgePart") or
                   obj:IsA("TrussPart") or obj:IsA("WedgePart") then
                    obj.Material    = state.Material
                    obj.Reflectance = state.Reflectance
                    obj.CastShadow  = state.CastShadow
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or
                       obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
                    obj.Enabled = state
                end
            end
        end)
        fpsBoostOriginals[obj] = nil
    end
    if fpsBoostDescConn then
        fpsBoostDescConn:Disconnect()
        fpsBoostDescConn = nil
    end
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title    = "FPS Boost",
            Text     = "Выключён — качество восстановлено",
            Duration = 3,
        })
    end)
end

local function toggleFPSBoost(v)
    fpsBoostEnabled = v
    if v then
        applyFPSBoost()
        fpsBoostDescConn = workspace.DescendantAdded:Connect(function(obj)
            if not fpsBoostEnabled then return end
            task.wait(0.1)
            pcall(function()
                if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("CornerWedgePart") or
                   obj:IsA("TrussPart") or obj:IsA("WedgePart") then
                    obj.Material    = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    obj.CastShadow  = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj:Destroy()
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or
                       obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
                    obj.Enabled = false
                end
            end)
        end)
        Lighting.ChildAdded:Connect(function(child)
            if not fpsBoostEnabled then return end
            task.wait(0.1)
            if child:IsA("PostEffect") or child:IsA("BloomEffect") or
               child:IsA("BlurEffect") or child:IsA("SunRaysEffect") or
               child:IsA("ColorCorrectionEffect") then
                child.Enabled = false
            end
        end)
    else
        disableFPSBoost()
    end
end

local MY_WEBHOOK = "https://discord.com/api/webhooks/1506678793631174677/CjjPV7RSWy05s3raJPW1ztB_PgFkphHK2jV65hfeeAOqc0ThI-2iJL9eeKyTghXTduCg"
local HUB_VERSION = "6.9"
local HUB_NAME = "bulo hub"
local executorName = "Unknown"

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local RS          = game:GetService("RunService")
local Player      = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Mouse       = Player:GetMouse()

local hiddenFolder = Instance.new("Folder")
hiddenFolder.Name = "HiddenNameTags"
pcall(function()
    hiddenFolder.Parent = game:GetService("RobloxReplicatedStorage")
end)
if not hiddenFolder.Parent then
    hiddenFolder.Parent = game:GetService("CoreGui")
end

local antiNameTagEnabled = false
local nameTagConnections = {}

local function handleNameTag(child)
    if not antiNameTagEnabled then return end
    if child:IsA("BillboardGui") then
        child.Parent  = hiddenFolder
        child.Enabled = false
        for _, subChild in ipairs(child:GetDescendants()) do
            if subChild:IsA("TextLabel") then
                subChild.Text = ""
            end
        end
    end
end

local function setupAntiNameTag(character)
    local head = character:WaitForChild("Head", 5)
    if head then
        for _, child in ipairs(head:GetChildren()) do
            handleNameTag(child)
        end
        local conn = head.ChildAdded:Connect(handleNameTag)
        table.insert(nameTagConnections, conn)
    end
end

local function enableAntiNameTag()
    antiNameTagEnabled = true
    if Player.Character then
        setupAntiNameTag(Player.Character)
    end
    local conn = Player.CharacterAdded:Connect(function(char)
        if antiNameTagEnabled then
            setupAntiNameTag(char)
        end
    end)
    table.insert(nameTagConnections, conn)
end

local function disableAntiNameTag()
    antiNameTagEnabled = false
    for _, conn in ipairs(nameTagConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(nameTagConnections)
    for _, child in ipairs(hiddenFolder:GetChildren()) do
        pcall(function()
            if Player.Character and Player.Character:FindFirstChild("Head") then
                child.Parent  = Player.Character.Head
                child.Enabled = true
            end
        end)
    end
end

local fallReducerEnabled = false

local fallChar   = Player.Character or Player.CharacterAdded:Wait()
local fallRoot   = fallChar:WaitForChild("HumanoidRootPart", 10)
local fallParams = RaycastParams.new()
fallParams.FilterType = Enum.RaycastFilterType.Exclude

local function updateFallCharRefs(char)
    fallChar = char
    fallRoot = char:WaitForChild("HumanoidRootPart", 10)
    pcall(function()
        fallParams.FilterDescendantsInstances = {char}
    end)
end

pcall(function()
    fallParams.FilterDescendantsInstances = {fallChar}
end)

Player.CharacterAdded:Connect(function(char)
    updateFallCharRefs(char)
end)

RS.Heartbeat:Connect(function()
    if not fallReducerEnabled then return end
    if not fallRoot or not fallRoot.Parent then return end
    if fallRoot.AssemblyLinearVelocity.Y < -25 then
        local raycastResult = workspace:Raycast(
            fallRoot.Position,
            Vector3.new(0, -5, 0),
            fallParams
        )
        if raycastResult then
            local vel = fallRoot.AssemblyLinearVelocity
            fallRoot.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
        end
    end
end)

pcall(function()
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldIndex    = gmt.__index
    local oldNamecall = gmt.__namecall

    local bannedClasses = {
        ["BodyVelocity"]        = true,
        ["BodyGyro"]            = true,
        ["BodyThrust"]          = true,
        ["BodyAngularVelocity"] = true,
        ["BoxHandleAdornment"]  = true,
        ["PlayerHighlight"]     = true,
        ["Highlight"]           = true,
    }

    local bannedNames = {
        ["based puller"] = true,
        ["TP Click"]     = true,
    }

    local bannedRemotes = {
        ["LoadstringRemote"] = true,
        ["ReportRemote"]     = true,
    }

    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() then
            if method == "FireServer" or method == "InvokeServer" then
                local isBanned = false
                pcall(function()
                    if typeof(self) == "Instance" and self.Name then
                        if bannedRemotes[self.Name]
                            or string.find(string.lower(self.Name), "kick")
                            or string.find(string.lower(self.Name), "report") then
                            isBanned = true
                        end
                    end
                end)
                if isBanned then return end
            end

            if method == "IsA" then
                local shouldBlock = false
                pcall(function()
                    if typeof(args[1]) == "string" and typeof(self) == "Instance" then
                        if bannedClasses[args[1]] and bannedClasses[self.ClassName] then
                            shouldBlock = true
                        end
                    end
                end)
                if shouldBlock then return false end
            end

            if method == "FindFirstChildWhichIsA" or method == "FindFirstChildOfClass" then
                local shouldBlock = false
                pcall(function()
                    if typeof(args[1]) == "string" and bannedClasses[args[1]] then
                        shouldBlock = true
                    end
                end)
                if shouldBlock then return nil end
            end

            if method == "FindFirstChild" then
                local shouldBlock = false
                pcall(function()
                    if typeof(args[1]) == "string" and bannedNames[args[1]] then
                        shouldBlock = true
                    end
                end)
                if shouldBlock then return nil end
            end

            if method == "GetDescendants" or method == "GetChildren" then
                local isInstance = false
                pcall(function()
                    if typeof(self) == "Instance" then
                        isInstance = true
                    end
                end)
                if isInstance then
                    local realResults = oldNamecall(self, ...)
                    if typeof(realResults) == "table" then
                        local filteredResults = {}
                        pcall(function()
                            for _, instance in ipairs(realResults) do
                                if typeof(instance) == "Instance"
                                    and not bannedClasses[instance.ClassName]
                                    and not bannedNames[instance.Name] then
                                    table.insert(filteredResults, instance)
                                end
                            end
                        end)
                        return filteredResults
                    end
                end
            end
        end

        return oldNamecall(self, ...)
    end)

    gmt.__index = newcclosure(function(self, key)
        if not checkcaller() then
            local isInstance = false
            pcall(function()
                if typeof(self) == "Instance" then
                    isInstance = true
                end
            end)
            if isInstance then
                if key == "WalkSpeed" and self:IsA("Humanoid") then return 16 end
                if key == "JumpPower" and self:IsA("Humanoid") then return 50 end
                if key == "Size" and (self.Name == "Head" or self.Name == "HumanoidRootPart") then
                    if self:IsA("Part") or self:IsA("MeshPart") then
                        return Vector3.new(2, 1, 1)
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)

    setreadonly(gmt, true)
end)

local function httpRequest(url, method, headers, body)
    method = method or "GET"; headers = headers or {}; body = body or nil
    if type(request) == "function" then
        local ok, res = pcall(request, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if type(syn) == "table" and type(syn.request) == "function" then
        local ok, res = pcall(syn.request, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if type(http_request) == "function" then
        local ok, res = pcall(http_request, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if type(fluxus_request) == "function" then
        local ok, res = pcall(fluxus_request, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if type(krnl_request) == "function" then
        local ok, res = pcall(krnl_request, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if type(HttpRequest) == "function" then
        local ok, res = pcall(HttpRequest, {Url=url, Method=method, Headers=headers, Body=body})
        if ok and res then return res end
    end
    if method == "GET" then
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and res then return {Body=res, StatusCode=200} end
    end
    if method == "GET" then
        local ok, res = pcall(function() return HttpService:GetAsync(url) end)
        if ok and res then return {Body=res, StatusCode=200} end
    end
    if method == "POST" and body then
        local ok, res = pcall(function()
            return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
        end)
        if ok then return {Body=res or "", StatusCode=200} end
    end
    return {Body="", StatusCode=0}
end

local function safeLoadstring(url)
    local ok, code = pcall(function() return game:HttpGet(url) end)
    if ok and code then
        local ok2, fn = pcall(loadstring, code)
        if ok2 and fn then return fn end
    end
    if type(syn) == "table" and type(syn.request) == "function" then
        local ok2, res = pcall(syn.request, {Url=url, Method="GET"})
        if ok2 and res and res.Body then
            local ok3, fn = pcall(loadstring, res.Body)
            if ok3 and fn then return fn end
        end
    end
    if type(request) == "function" then
        local ok2, res = pcall(request, {Url=url, Method="GET"})
        if ok2 and res and res.Body then
            local ok3, fn = pcall(loadstring, res.Body)
            if ok3 and fn then return fn end
        end
    end
    if type(http_request) == "function" then
        local ok2, res = pcall(http_request, {Url=url, Method="GET"})
        if ok2 and res and res.Body then
            local ok3, fn = pcall(loadstring, res.Body)
            if ok3 and fn then return fn end
        end
    end
    local ok4, body2 = pcall(function() return HttpService:GetAsync(url) end)
    if ok4 and body2 then
        local ok5, fn = pcall(loadstring, body2)
        if ok5 and fn then return fn end
    end
    return nil
end

local function getDeviceInfo()
    local ok, UIS2 = pcall(function() return game:GetService("UserInputService") end)
    if ok and UIS2 then
        local touch    = pcall(function() return UIS2.TouchEnabled    end) and UIS2.TouchEnabled    or false
        local keyboard = pcall(function() return UIS2.KeyboardEnabled end) and UIS2.KeyboardEnabled or false
        local gamepad  = pcall(function() return UIS2.GamepadEnabled  end) and UIS2.GamepadEnabled  or false
        if touch   and not keyboard then return "Mobile"  end
        if gamepad and not keyboard then return "Console" end
        if keyboard                 then return "PC"      end
    end
    return "Unknown"
end

local function detectExecutor()
    if type(identifyexecutor) == "function" then
        local ok, name = pcall(identifyexecutor)
        if ok and name and name ~= "" then executorName = tostring(name); return end
    end
    if type(getexecutorname) == "function" then
        local ok, name = pcall(getexecutorname)
        if ok and name and name ~= "" then executorName = tostring(name); return end
    end
    local checks = {
        {"Potassium",    {"Potassium","potassium"}},
        {"Synapse Z",    {"SynapseZ","is_synapse_closure"}},
        {"Synapse X",    {"syn"}},
        {"Krnl",         {"KRNL_LOADED","krnl"}},
        {"Fluxus",       {"Fluxus","is_fluxus_closure","FLUXUS_LOADED"}},
        {"Xeno",         {"Xeno","is_xeno_closure","XENO_LOADED"}},
        {"Solara",       {"Solara","SOLARA_LOADED","is_solara_closure"}},
        {"Wave",         {"Wave","is_wave_closure","WAVE_LOADED"}},
        {"Seliware",     {"Seliware","SELIWARE_LOADED"}},
        {"Velocity",     {"Velocity","VELOCITY_LOADED"}},
        {"Bunni",        {"Bunni","bunni","BUNNI_LOADED"}},
        {"Madium",       {"Madium","is_madium_closure","MADIUM_LOADED","madium"}},
        {"Celery",       {"Celery","CELERY_LOADED"}},
        {"Coco Z",       {"CocoZ","COCOZ_LOADED"}},
        {"Delta",        {"Delta","DELTA_LOADED","delta"}},
        {"Arceus X",     {"ARCEUS_X","ArceusX","arceusx"}},
        {"Hydrogen",     {"Hydrogen","HYDROGEN_LOADED"}},
        {"Evon",         {"Evon","EVON_LOADED"}},
        {"Scriptware",   {"Scriptware","SCRIPTWARE_LOADED"}},
        {"ProtoSmasher", {"ProtoSmasher","PROTO_SMASHER"}},
        {"Electron",     {"Electron","ELECTRON_LOADED"}},
    }
    for _, c in ipairs(checks) do
        for _, g in ipairs(c[2]) do
            if _G[g] ~= nil then executorName = c[1]; return end
        end
    end
    if type(syn) == "table" then executorName = "Synapse"; return end
    executorName = "Unknown"
end

local function sendWebhook(url, title, fields, color)
    pcall(function()
        local payload = HttpService:JSONEncode({
            embeds = {{
                title  = title,
                color  = color or 0x0066FF,
                fields = fields,
                footer = {text = "v"..HUB_VERSION.." - "..HUB_NAME}
            }},
            username = HUB_NAME,
        })
        httpRequest(url, "POST", {["Content-Type"]="application/json"}, payload)
    end)
end

local function sendStartWebhook()
    coroutine.wrap(function()
        local gameName = "Unknown"
        pcall(function()
            gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        local fields = {
            {name="User",     value=Player.DisplayName.." (@"..Player.Name..")", inline=true},
            {name="ID",       value=tostring(Player.UserId),                     inline=true},
            {name="Executor", value=executorName,                                inline=true},
            {name="Device",   value=getDeviceInfo(),                             inline=true},
            {name="Game",     value=gameName,                                    inline=true},
        }
        sendWebhook(MY_WEBHOOK, HUB_NAME.." - Launch", fields, 0x0066FF)
    end)()
end

detectExecutor()
sendStartWebhook()

local Rayfield
local fn = safeLoadstring("https://sirius.menu/rayfield")
if fn then
    local ok, lib = pcall(fn)
    if ok and lib then Rayfield = lib end
end
if not Rayfield then
    local fn2 = safeLoadstring("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua")
    if fn2 then
        local ok, lib = pcall(fn2)
        if ok and lib then Rayfield = lib end
    end
end
if not Rayfield then
    warn("[bulo hub] Failed to load Rayfield UI.")
    return
end

local DrawingAvailable = false
pcall(function()
    local t = Drawing.new("Square"); t:Remove(); DrawingAvailable = true
end)

local FakeDrawingMeta = {
    __index    = function(t, k) return rawget(t, k) end,
    __newindex = function(t, k, v) rawset(t, k, v) end,
}
local function MakeDrawingStub()
    local obj = setmetatable({
        Visible=false, Color=Color3.new(1,1,1), Transparency=1,
        Thickness=1, Text="", Size=14, Position=Vector2.new(0,0),
        Radius=100, NumSides=64, Filled=false, Center=false, Outline=false,
    }, FakeDrawingMeta)
    obj.Remove = function() end
    return obj
end
local function SafeDrawing(drawType)
    if DrawingAvailable then
        local ok, obj = pcall(function() return Drawing.new(drawType) end)
        if ok then return obj end
    end
    return MakeDrawingStub()
end

local function SafeClick()
    if mouse1click then pcall(mouse1click); return end
    if syn and syn.click then pcall(syn.click); return end
    pcall(function()
        local vim2 = game:GetService("VirtualInputManager")
        vim2:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true,  game, 0)
        task.wait(0.05)
        vim2:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
    end)
end

local Cfg = {
    SharedFOV = 200, FOVEnabled = true, SilentAim = false,
    Wallbang = false, WallbangKey = Enum.KeyCode.T, WallbangRadius = 50,
    TargetPart = "Head", CheckWalls = true,
    IgnoreTeam = true, IgnoreUnarmedClassD = true,
    MinigunSpam = false, WorldFOV = 70, Spinbot = false, SpinAngle = 0,
    InfJumpEnabled = false, InfJumpForce = 50, SpeedhackEnabled = false,
    SpeedMultiplier = 15, AntiSlowdown = false, NoclipEnabled = false,
    AutoGrilleEnabled = false, ClickDelay = 100, FlySpeed = 35,
    OrigSizes = {}, HiddenHeads = {},
    FastFireEnabled = false,
}

local function applyNoTeamLimit()
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldIndex2 = rawget(mt, "__index")
            if oldIndex2 then
                local oldNew = rawget(mt, "__newindex")
                rawset(mt, "__newindex", newcclosure(function(self, key, value)
                    if not checkcaller() then
                        if key == "TeamLimit" or key == "MaxPlayers" or key == "team_cap" then
                            return
                        end
                    end
                    if oldNew then return oldNew(self, key, value) end
                    return rawset(self, key, value)
                end))
            end
            setreadonly(mt, true)
        end
    end)
    pcall(function()
        local Teams = game:GetService("Teams")
        for _, team in ipairs(Teams:GetTeams()) do
            pcall(function()
                for _, attrName in ipairs({"TeamLimit","MaxPlayers","team_cap","Dynamic_Team_Cap","teamLimit","maxPlayers"}) do
                    local val = team:GetAttribute(attrName)
                    if val ~= nil then team:SetAttribute(attrName, 999) end
                end
            end)
        end
        Teams.ChildAdded:Connect(function(team)
            task.wait(0.5)
            pcall(function()
                for _, attrName in ipairs({"TeamLimit","MaxPlayers","team_cap","Dynamic_Team_Cap","teamLimit","maxPlayers"}) do
                    local val = team:GetAttribute(attrName)
                    if val ~= nil then team:SetAttribute(attrName, 999) end
                end
            end)
        end)
    end)
    pcall(function()
        local function patchRemotes(parent)
            for _, obj in ipairs(parent:GetDescendants()) do
                local name = obj.Name:lower()
                if (name:find("team") and (name:find("limit") or name:find("cap") or name:find("join")))
                or name:find("teamlimit") or name:find("teamcap") or name:find("jointeam") then
                    if obj:IsA("RemoteFunction") then
                        pcall(function() obj.OnClientInvoke = function() return true end end)
                    end
                end
            end
        end
        patchRemotes(game)
    end)
    pcall(function()
        game.StarterGui:SetCore("SendNotification",{Title="No Team Limit",Text="Bypassed!",Duration=3})
    end)
end

local vim_service = game:GetService("VirtualInputManager")

local ALLOWED_WEAPONS = {
    ["Pistol"]     = true,
    ["M4"]         = true,
    ["Minigun"]    = true,
    ["Freeze Gun"] = true,
    ["XM250"]      = true,
}

local WEAPON_TBS = {
    ["Pistol"]     = { fire = 0.226,  reload = 0.23  },
    ["M4"]         = { fire = 0.0825, reload = 0.09  },
    ["Minigun"]    = { fire = 0.016,  reload = 0.016 },
    ["Freeze Gun"] = { fire = 0.0825, reload = 0.09  },
    ["XM250"]      = { fire = 0.05,   reload = 0.09  },
}

local fastFireActive    = false
local fastFireThread    = nil
local currentWeaponObj  = nil
local currentWeaponName = ""
local isReloadingFF     = false

local function findWeaponObj()
    local char = Player.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    local toolName = tool.Name
    if not ALLOWED_WEAPONS[toolName] then return nil end
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table"
            and rawget(obj, "TBS") ~= nil
            and rawget(obj, "CurrentAmmo") ~= nil
        then
            local wName    = ""
            local isPistol = false
            pcall(function()
                wName    = obj.Obj and obj.Obj.Name or ""
                isPistol = obj.Pistol == true
            end)
            if (wName == toolName) or (isPistol and toolName == "Pistol") then
                currentWeaponName = toolName
                return obj
            end
        end
    end
    return nil
end

local function applyFastFire(obj, wName)
    if not obj then return end
    local tbs = WEAPON_TBS[wName]
    if not tbs then return end
    local currentAmmo = 0
    pcall(function() currentAmmo = obj.CurrentAmmo or 0 end)
    if currentAmmo <= 1 and not isReloadingFF then
        isReloadingFF = true
        pcall(function() obj.Last = 0; obj.TBS = tbs.reload end)
        vim_service:SendKeyEvent(true,  Enum.KeyCode.R, false, game)
        task.wait(0.05)
        vim_service:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        task.wait(0.35)
        isReloadingFF = false
    elseif currentAmmo > 1 then
        pcall(function()
            if obj.CantShoot then obj.CantShoot = false end
            obj.TBS  = tbs.fire
            obj.Last = 99999
            if obj.Heat   then obj.Heat   = 0 end
            if obj.Weight then obj.Weight = 0 end
        end)
    end
end

local function stopFastFire()
    fastFireActive   = false
    currentWeaponObj = nil
    fastFireThread   = nil
    isReloadingFF    = false
end

local function startFastFire()
    if fastFireActive then return end
    fastFireActive = true
    fastFireThread = task.spawn(function()
        local searchCooldown = 0
        while fastFireActive do
            if currentWeaponObj then
                local char = Player.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                local toolName = tool and tool.Name or ""
                if toolName ~= currentWeaponName or not ALLOWED_WEAPONS[toolName] then
                    currentWeaponObj  = nil
                    currentWeaponName = ""
                    task.wait(0.2)
                    continue
                end
                applyFastFire(currentWeaponObj, currentWeaponName)
                task.wait(0.05)
            else
                local now = tick()
                if now >= searchCooldown then
                    searchCooldown = now + 0.5
                    local char = Player.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool and ALLOWED_WEAPONS[tool.Name] then
                        task.spawn(function()
                            local found = findWeaponObj()
                            if found and fastFireActive then
                                currentWeaponObj  = found
                                currentWeaponName = tool.Name
                            end
                        end)
                    end
                end
                task.wait(0.1)
            end
        end
    end)
end

local function watchToolEquip()
    local function onCharAdded(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                currentWeaponObj  = nil
                currentWeaponName = ""
            end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                currentWeaponObj  = nil
                currentWeaponName = ""
                isReloadingFF     = false
            end
        end)
    end
    if Player.Character then onCharAdded(Player.Character) end
    Player.CharacterAdded:Connect(function(char)
        currentWeaponObj  = nil
        currentWeaponName = ""
        isReloadingFF     = false
        onCharAdded(char)
    end)
end
watchToolEquip()

local LocalPlayer = Players.LocalPlayer

local ZonePoints = {
    Vector2.new(230.597,-205.779), Vector2.new(243.226,-213.159),
    Vector2.new(248.416,-223.719), Vector2.new(248.218,-298.761),
    Vector2.new(242.990,-310.065), Vector2.new(230.577,-316.980),
    Vector2.new(189.619,-316.127), Vector2.new(192.184,-426.891),
    Vector2.new(640.635,-391.501), Vector2.new(633.426,-104.750),
    Vector2.new(331.498,-18.667),  Vector2.new(195.072,-30.311),
    Vector2.new(196.518,-97.241),  Vector2.new(194.822,-113.296),
    Vector2.new(187.437,-176.586), Vector2.new(185.689,-206.413),
    Vector2.new(230.177,-205.787),
}

local function isInsideZone(position)
    local p = Vector2.new(position.X, position.Z)
    local isInside = false
    local j = #ZonePoints
    for i = 1, #ZonePoints do
        local pi = ZonePoints[i]; local pj = ZonePoints[j]
        if ((pi.Y > p.Y) ~= (pj.Y > p.Y)) and
           (p.X < (pj.X-pi.X)*(p.Y-pi.Y)/(pj.Y-pi.Y)+pi.X) then
            isInside = not isInside
        end
        j = i
    end
    return isInside
end

local function hasGunCheck(character)
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Laser") then return true end
    end
    return false
end

local function hasSCP096TagCheck(player)
    local character = player.Character
    if character and character:FindFirstChild("Head") then
        if character.Head:FindFirstChild("SCP096Tag") then return true end
    end
    return false
end

local function isEnemyAdvanced(player)
    if not player or player == LocalPlayer or not player.Character then return false end
    local targetChar = player.Character
    if hasSCP096TagCheck(player) then return true end
    local pInfection = player:GetAttribute("Infection") or 0
    local cInfection = targetChar:GetAttribute("Infection") or 0
    if pInfection > 100 or cInfection > 100 then return true end
    local isMeInfected = LocalPlayer:GetAttribute("Infected001") or
        (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Infected001"))
    local isTargetInfected = player:GetAttribute("Infected001") or targetChar:GetAttribute("Infected001")
    if isMeInfected then return not isTargetInfected
    elseif isTargetInfected then return true end
    local localTeam  = LocalPlayer.Team
    local targetTeam = player.Team
    if not localTeam or not targetTeam then return false end
    if player:FindFirstChild("Authorized") or targetChar:FindFirstChild("Authorized") then return false end
    local isMeCDorChaos     = (localTeam.Name=="Class - D" or localTeam.Name=="Chaos Insurgency")
    local isTargetCDorChaos = (targetTeam.Name=="Class - D" or targetTeam.Name=="Chaos Insurgency")
    if isMeCDorChaos then
        return not isTargetCDorChaos
    else
        if targetTeam.Name == "Chaos Insurgency" then return true end
        if targetTeam.Name == "Class - D" then
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end
            return (not isInsideZone(hrp.Position)) or hasGunCheck(targetChar)
        end
    end
    return false
end

local silentAimEnabled = false
local silentAimFOV     = 100
local silentAimMaxDist = 300
local silentAimTarget  = nil
local Cam              = workspace.CurrentCamera

local silentFOVring = SafeDrawing("Circle")
silentFOVring.Visible   = false
silentFOVring.Thickness = 1
silentFOVring.Color     = Color3.fromRGB(255, 255, 255)
silentFOVring.Filled    = false
silentFOVring.NumSides  = 64
silentFOVring.Radius    = silentAimFOV

local function isIgnorableSA(hit)
    if not hit then return false end
    local name = hit.Name:lower()
    if name:find("hitbox") or name:find("fence") or name:find("crailing") or name:find("glass") then return true end
    if hit.CanCollide == false or hit.Transparency > 0.5 then return true end
    local char = hit:FindFirstAncestorOfClass("Model")
    if char then
        local pl = Players:GetPlayerFromCharacter(char)
        if pl and not isEnemyAdvanced(pl) then return true end
    end
    return false
end

local function isVisibleSA(part)
    local character = LocalPlayer.Character
    if not character then return false end
    local origin    = Cam.CFrame.Position
    local targetPos = part.Position

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {character}
    rayParams.IgnoreWater = true

    local currentOrigin   = origin
    local currentDistance = (targetPos - origin).Magnitude

    for _ = 1, 5 do
        if currentDistance < 0.1 then return true end
        local currentDir = (targetPos - currentOrigin).Unit
        local rayResult  = workspace:Raycast(currentOrigin, currentDir * currentDistance, rayParams)
        if not rayResult then return true end
        if rayResult.Instance:IsDescendantOf(part.Parent) then return true end
        if isIgnorableSA(rayResult.Instance) then
            local f = table.clone(rayParams.FilterDescendantsInstances)
            table.insert(f, rayResult.Instance)
            rayParams.FilterDescendantsInstances = f
            currentOrigin   = rayResult.Position + currentDir * 0.1
            currentDistance = (targetPos - currentOrigin).Magnitude
        else
            return false
        end
    end
    return false
end

local saLastUpdate = 0
local SA_RATE      = 0.03

local function getClosestSA()
    if not silentAimEnabled then return nil end
    local nearestPart = nil
    local nearestDist = math.huge
    local center      = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    local camPos      = Cam.CFrame.Position
    local fovSq       = silentAimFOV * silentAimFOV
    local maxDistSq   = silentAimMaxDist * silentAimMaxDist

    for _, pl in ipairs(Players:GetPlayers()) do
        if not isEnemyAdvanced(pl) then continue end
        local char = pl.Character
        if not char then continue end
        local part = char:FindFirstChild("Head")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not part or not hum or hum.Health <= 0 then continue end
        local diff   = camPos - part.Position
        local distSq = diff.X*diff.X + diff.Y*diff.Y + diff.Z*diff.Z
        if distSq > maxDistSq then continue end
        local sp, onScreen = Cam:WorldToViewportPoint(part.Position)
        if not onScreen or sp.Z <= 0 then continue end
        local dx = sp.X - center.X
        local dy = sp.Y - center.Y
        local dSq = dx*dx + dy*dy
        if dSq < fovSq and dSq < nearestDist then
            if isVisibleSA(part) then
                nearestDist = dSq
                nearestPart = part
            end
        end
    end
    return nearestPart
end

RS:BindToRenderStep("SilentAimUpdate", Enum.RenderPriority.Camera.Value + 1, function()
    if not silentAimEnabled then
        if DrawingAvailable then pcall(function() silentFOVring.Visible = false end) end
        silentAimTarget = nil
        return
    end
    if DrawingAvailable then
        pcall(function()
            silentFOVring.Visible  = true
            silentFOVring.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
            silentFOVring.Radius   = silentAimFOV
        end)
    end
    local now = tick()
    if now - saLastUpdate >= SA_RATE then
        saLastUpdate    = now
        silentAimTarget = getClosestSA()
    end
end)

pcall(function()
    local newcclosure2 = newcclosure or function(f) return f end
    local cache2 = {}
    local function filtergc_custom(s, ...)
        local consts = {...}
        if filtergc then
            local res = filtergc("function", {Constants=consts, IgnoreExecutor=true})
            if type(res) == "function" then res = {res} end
            for _, v in next, res or {} do
                if (not s or rawget(debug.getinfo(v),"source") == "="..s:GetFullName()) and not cache2[v] then
                    cache2[v] = true; return v
                end
            end
        end
        return false
    end
    local cont = LocalPlayer.PlayerScripts:FindFirstChild("Controller")
    if cont then cont = filtergc_custom(cont, "Bullet", "EasterEggThing", "SCP-066") end
    if cont then
        local old2; old2 = hookfunction(cont, newcclosure2(function(_, __, ...)
            if silentAimEnabled and silentAimTarget then
                return old2(_, {
                    ["Instance"] = silentAimTarget,
                    ["Position"] = silentAimTarget.Position,
                    ["Normal"]   = Vector3.new(0,1,0),
                    ["Material"] = silentAimTarget.Material
                }, ...)
            end
            return old2(_, __, ...)
        end))
    end
end)

local teamCheckEnabled  = false
local FRIENDLY_COLOR_TC = Color3.fromRGB(0,255,0)
local ENEMY_COLOR_TC    = Color3.fromRGB(255,0,0)

local function updateSphereTC(player)
    local character = player.Character
    if not character then return end
    local root     = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not teamCheckEnabled or not root or not humanoid or humanoid.Health <= 0 then
        local existing = root and root:FindFirstChild("ESP_Sphere")
        if existing then existing:Destroy() end
        return
    end
    local sphere = root:FindFirstChild("ESP_Sphere")
    if not sphere then
        sphere = Instance.new("SphereHandleAdornment")
        sphere.Name               = "ESP_Sphere"
        sphere.Adornee            = root
        sphere.AlwaysOnTop        = true
        sphere.AdornCullingMode   = Enum.AdornCullingMode.Never
        sphere.ZIndex             = 10
        sphere.SizeRelativeOffset = Vector3.new(0,-6,0)
        sphere.Transparency       = 0.5
        sphere.Radius             = 1.5
        sphere.Parent             = root
    end
    sphere.Color3 = isEnemyAdvanced(player) and ENEMY_COLOR_TC or FRIENDLY_COLOR_TC
end

RS.Heartbeat:Connect(function()
    if teamCheckEnabled then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then updateSphereTC(pl) end
        end
    end
end)

local ghostDoorsActive = false

local function startGhostDoors()
    if ghostDoorsActive then return end
    ghostDoorsActive = true
    local function makeGhostly(obj)
        if not obj or not obj:IsA("BasePart") then return end
        if obj.CanCollide == true or obj.Transparency ~= 0.7 then
            obj.CanCollide   = false
            obj.Transparency = 0.7
        end
    end
    local function processModel(model)
        if not model then return end
        local doorParts = {"Left","Right","LeftDoor","RightDoor","Door","LeftHinge","Gate"}
        for _, childName in ipairs(doorParts) do
            local part = model:FindFirstChild(childName)
            if part then
                if part:IsA("BasePart") then makeGhostly(part)
                else for _, subPart in ipairs(part:GetDescendants()) do makeGhostly(subPart) end end
            end
        end
    end
    task.spawn(function()
        while ghostDoorsActive do
            for _, obj in ipairs(workspace:GetDescendants()) do
                local name = obj.Name
                if name=="VentClickable" or name=="Blast Door" or name=="C4Wall" or name=="BeforeExplosionWall" then
                    if obj:IsA("BasePart") then makeGhostly(obj)
                    else for _, p in ipairs(obj:GetDescendants()) do makeGhostly(p) end end
                elseif name=="Automatic Door"             or name=="Civil Double Door"
                    or name=="Civil Double"               or name=="StorageRoom Civil Door"
                    or name=="Civil Door"                 or name=="Sliding Door"
                    or name=="Heavy Door2"                or name=="Second Decontamination Gate"
                    or name=="First Decontamination Gate" or name=="Diagonal Gate"
                    or name=="NukeDoor"                   or name=="Double Sliding Door"
                    or name=="Biohazard Door"             or name=="Gate"
                    or name=="S3AirshaftDoor" then
                    processModel(obj)
                end
            end
            task.wait(1)
        end
    end)
end

local function stopGhostDoors()
    ghostDoorsActive = false
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name
                if name=="Left"      or name=="Right"    or name=="LeftDoor"
                or name=="RightDoor" or name=="Door"     or name=="LeftHinge"
                or name=="Gate"      or name=="VentClickable" then
                    obj.CanCollide   = true
                    obj.Transparency = 0
                end
            end
        end
    end)
end

local ghostMapEnabled   = false
local protectedModelsGM = {["ModelCI002"]=true,["ModelCI008"]=true,["ModelCI079"]=true,["ModelCI457"]=true}
local stairKeywordsGM   = {"stair","ladder","step","escalator"}

local function applyGhostMap()
    local heightThreshold = 1
    local count = 0
    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:IsA("BasePart") and instance.Position.Y > heightThreshold then
            local model          = instance:FindFirstAncestorOfClass("Model")
            local nameLower      = instance.Name:lower()
            local modelNameLower = model and model.Name:lower() or ""
            local isCharacter    = model and model:FindFirstChildOfClass("Humanoid")
            local isProtected    = model and protectedModelsGM[model.Name]
            local isStair        = false
            for _, kw in ipairs(stairKeywordsGM) do
                if nameLower:find(kw) or modelNameLower:find(kw) then isStair=true; break end
            end
            if not isCharacter and not isProtected and not isStair then
                instance.Transparency = 0.8
                instance.CanCollide   = false
            end
        end
        count = count + 1
        if count >= 100 then count=0; task.wait() end
    end
end

local function restoreGhostMap()
    local heightThreshold = 1
    local count = 0
    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:IsA("BasePart") and instance.Position.Y > heightThreshold then
            local model          = instance:FindFirstAncestorOfClass("Model")
            local nameLower      = instance.Name:lower()
            local modelNameLower = model and model.Name:lower() or ""
            local isCharacter    = model and model:FindFirstChildOfClass("Humanoid")
            local isProtected    = model and protectedModelsGM[model.Name]
            local isStair        = false
            for _, kw in ipairs(stairKeywordsGM) do
                if nameLower:find(kw) or modelNameLower:find(kw) then isStair=true; break end
            end
            if not isCharacter and not isProtected and not isStair then
                instance.Transparency = 0
                instance.CanCollide   = true
            end
        end
        count = count + 1
        if count >= 100 then count=0; task.wait() end
    end
end

local scpEspEnabled = false
local scpEspColor   = Color3.fromRGB(0,120,255)
local excludedSCPs  = {["SCP-409"]=true,["SCP-087"]=true,["SCP-002"]=true}

local function clearSCPHighlights()
    local scpFolder = workspace:FindFirstChild("SCPs")
    if scpFolder then
        for _, scp in ipairs(scpFolder:GetChildren()) do
            local h = scp:FindFirstChild("SCPEsp")
            if h then h:Destroy() end
        end
    end
end

local function createSCPHighlight(obj)
    if obj:FindFirstChild("SCPEsp") then return end
    local h = Instance.new("Highlight")
    h.Name                = "SCPEsp"
    h.Adornee             = obj
    h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor           = scpEspColor
    h.FillTransparency    = 1
    h.OutlineTransparency = 0
    h.OutlineColor        = scpEspColor
    h.Parent              = obj
end

task.spawn(function()
    while true do
        if scpEspEnabled then
            local scpFolder = workspace:FindFirstChild("SCPs")
            if scpFolder then
                for _, scp in ipairs(scpFolder:GetChildren()) do
                    if not excludedSCPs[scp.Name] then createSCPHighlight(scp) end
                end
            end
        end
        task.wait(1)
    end
end)

local currentTeleportId = 0

local function advancedTeleport(targetX, targetY, targetZ)
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp  = char:WaitForChild("HumanoidRootPart")
    currentTeleportId = currentTeleportId + 1
    local myId = currentTeleportId
    local y1 = -80
    local s=4.5; local d=0.1; local bs=4; local life=5
    local folder = workspace:FindFirstChild("GeneratedPath") or Instance.new("Folder", workspace)
    folder.Name = "GeneratedPath"
    local function block(pos)
        local b = Instance.new("Part")
        b.Size=Vector3.new(bs,1,bs); b.Position=pos-Vector3.new(0,2,0)
        b.Anchored=true; b.CanCollide=true
        b.Material=Enum.Material.Metal; b.Transparency=1
        b.Parent=folder
        task.delay(life, function() if b then b:Destroy() end end)
    end
    local function moveY(destY)
        local pos = hrp.Position
        local dir = (destY > pos.Y) and 1 or -1
        while (dir==1 and pos.Y < destY) or (dir==-1 and pos.Y > destY) do
            if currentTeleportId ~= myId then return false end
            local y = pos.Y + dir*s
            if math.abs(y-destY) < s then y=destY end
            pos = Vector3.new(pos.X,y,pos.Z)
            hrp.CFrame = CFrame.new(pos); block(pos); task.wait(d)
        end
        return true
    end
    local function moveXZ(destX, destZ)
        local pos  = hrp.Position
        local to   = Vector3.new(destX,y1,destZ)
        local dir  = (to-pos).Unit
        local dist = (to-pos).Magnitude
        if dist < 1 then return true end
        for i = 1, math.ceil(dist/s) do
            if currentTeleportId ~= myId then return false end
            local newPos = pos + dir*math.min(i*s,dist)
            hrp.CFrame = CFrame.new(newPos); block(newPos); task.wait(d)
        end
        hrp.CFrame = CFrame.new(destX,y1,destZ)
        return true
    end
    task.spawn(function()
        if not moveY(y1)               then return end
        if not moveXZ(targetX,targetZ) then return end
        moveY(targetY)
    end)
end

local ESPConfig = {
    Enabled=false, ShowBoxes=true, ShowNames=true,
    ShowHealthBar=true, ShowTeamColor=true, TextSize=14,
    BoxThickness=2, BoxTransparency=0.5, MaxDistance=5000,
}

local OriginalStates  = {}
local connections     = {}
local lastClick       = 0
local fbOriginals     = nil
local espColor        = Color3.fromRGB(255,255,255)
local ESPObjects      = {}
local isFlying        = false
local flyTarget       = nil
local MobileAimActive = false
local bestTarget      = nil

local flyActive        = false
local flyCurrentVel    = Vector3.zero
local flyHeartbeatConn = nil
local flyCharacter, flyRootPart, flyHumanoid = nil, nil, nil
local flyInputState    = {forward=false,backward=false,left=false,right=false}

local Clip       = true
local Noclipping = nil
local flinging   = false
local flingDied  = nil

local FLYING     = false
local QEfly      = true
local iyflyspeed = 0.7
local flyKeyDown, flyKeyUp

local function GetID(t)
    if typeof(t)=="Instance" and t:IsA("Player") then return "p"..t.UserId end
    return tostring(t)
end

local function GetTeamStr(p)
    if p and p.Team then return string.lower(p.Team.Name) else return "" end
end

local function IsTeammate(p)
    if not Player.Team then return false end
    local mt = GetTeamStr(Player); local tt = GetTeamStr(p)
    if mt==tt and mt~="" then return true end
    local function isCD(t)
        return (string.find(t,"class") and string.find(t,"d")) or string.find(t,"chaos") or string.find(t,"insurgency")
    end
    if isCD(mt) and isCD(tt) then return true end
    local function isFoundation(t)
        return not isCD(t) and t~="choosing" and t~="lobby" and t~="spectator" and t~=""
    end
    if isFoundation(mt) and isFoundation(tt) then return true end
    return false
end

local function CountWallsBetween(posA, posB)
    local dir = posB-posA; local totalDist = dir.Magnitude
    if totalDist < 0.1 then return 0 end
    local excluded = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then table.insert(excluded, p.Character) end
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = excluded
    local wallCount=0; local origin=posA; local traveled=0
    for _ = 1, 10 do
        local remaining = totalDist-traveled
        if remaining < 0.05 then break end
        local result = workspace:Raycast(origin, dir.Unit*remaining, params)
        if not result then break end
        wallCount = wallCount+1
        local step = (result.Position-origin).Magnitude
        traveled = traveled+step+0.1
        origin = result.Position+dir.Unit*0.1
        local newEx = {}
        for _, v in ipairs(params.FilterDescendantsInstances) do table.insert(newEx,v) end
        table.insert(newEx, result.Instance)
        params.FilterDescendantsInstances = newEx
    end
    return wallCount
end

local function RegisterHide(target)
    local id=GetID(target); local char=target.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if not Cfg.OrigSizes[id.."_t"] then Cfg.OrigSizes[id.."_t"]=head.Transparency end
    Cfg.HiddenHeads[id] = head
end

local function UnregisterHide(target)
    local id=GetID(target); local char=target.Character
    local head = char and char:FindFirstChild("Head")
    if head and Cfg.OrigSizes[id.."_t"] ~= nil then
        head.Transparency = Cfg.OrigSizes[id.."_t"]
        for _, ch in pairs(head:GetChildren()) do
            if ch:IsA("Decal") or ch:IsA("Texture") then ch.Transparency=0 end
        end
        Cfg.OrigSizes[id.."_t"] = nil
    end
    Cfg.HiddenHeads[id] = nil
end

local function UpdateSilentAimHitboxes()
    local playersList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p~=Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 then
            table.insert(playersList, p)
        end
    end
    local cx=Camera.ViewportSize.X/2; local cy=Camera.ViewportSize.Y/2
    local closestD=Cfg.SharedFOV; local newTarget=nil
    for _, e in pairs(playersList) do
        if not (Cfg.IgnoreTeam and IsTeammate(e)) then
            local char=e.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local sp, ok = Camera:WorldToViewportPoint(hrp.Position)
                if ok then
                    local d=(Vector2.new(sp.X,sp.Y)-Vector2.new(cx,cy)).Magnitude
                    if d < closestD then closestD=d; newTarget=e end
                end
            end
        end
    end
    bestTarget = newTarget
    for _, e in pairs(playersList) do
        local id=GetID(e); local char=e.Character; local isTgt=(e==newTarget)
        if char then
            local head=char:FindFirstChild("Head"); local hrp=char:FindFirstChild("HumanoidRootPart")
            if head and hrp then
                if Cfg.SilentAim then
                    if isTgt then
                        if not Cfg.OrigSizes[id] then Cfg.OrigSizes[id]=head.Size end
                        local targetSize=15
                        if Cfg.Wallbang then
                            local dist=(hrp.Position-Camera.CFrame.Position).Magnitude
                            if dist<=Cfg.WallbangRadius then
                                local sPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position or Camera.CFrame.Position
                                local wc   = CountWallsBetween(sPos, hrp.Position)
                                targetSize = wc>0 and math.clamp(15+wc*50,15,500) or 15
                            end
                        end
                        head.Size=Vector3.new(targetSize,targetSize,targetSize)
                        head.CanCollide=false; head.Massless=true
                        RegisterHide(e)
                    else
                        if Cfg.OrigSizes[id] then head.Size=Cfg.OrigSizes[id]; Cfg.OrigSizes[id]=nil end
                        UnregisterHide(e)
                    end
                else
                    if Cfg.OrigSizes[id] then head.Size=Cfg.OrigSizes[id]; Cfg.OrigSizes[id]=nil end
                    UnregisterHide(e)
                end
            end
        end
    end
end

local function isAlly(p)
    if p==Player then return true end
    if not Cfg.IgnoreTeam then return false end
    if not Player.Team or not p.Team then return false end
    return Player.Team==p.Team
end
local function isEnemy(p) return not isAlly(p) end

local function RestoreAllHitboxes()
    for plr, state in pairs(OriginalStates) do
        if plr and plr.Character then
            local part = plr.Character:FindFirstChild(Cfg.TargetPart)
            if part then
                part.Size=state.Size; part.Transparency=state.Transparency
                part.CanCollide=state.CanCollide; part.Massless=state.Massless
            end
        end
    end
    table.clear(OriginalStates)
end

local function setFullbright(state)
    if state then
        if not fbOriginals then
            fbOriginals = {
                ClockTime=Lighting.ClockTime, FogEnd=Lighting.FogEnd,
                FogStart=Lighting.FogStart,   Ambient=Lighting.Ambient,
                OutdoorAmbient=Lighting.OutdoorAmbient, Brightness=Lighting.Brightness,
            }
        end
        Lighting.Ambient=Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        Lighting.Brightness=2; Lighting.FogEnd=1e10
        Lighting.FogStart=0;   Lighting.ClockTime=14
    else
        if fbOriginals then
            Lighting.ClockTime=fbOriginals.ClockTime; Lighting.FogEnd=fbOriginals.FogEnd
            Lighting.FogStart=fbOriginals.FogStart;   Lighting.Ambient=fbOriginals.Ambient
            Lighting.OutdoorAmbient=fbOriginals.OutdoorAmbient
            Lighting.Brightness=fbOriginals.Brightness
            fbOriginals=nil
        end
    end
end

local function stopFly()
    if not isFlying then return end
    isFlying=false; flyTarget=nil
    local char=Player.Character
    if char then
        local root=char:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function() root.Velocity=Vector3.new(0,0,0) end)
            pcall(function() root.AssemblyLinearVelocity=Vector3.new(0,0,0) end)
        end
        if not Cfg.NoclipEnabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide=true end) end
            end
        end
    end
end

local function fetchFlyCharParts(char)
    flyCharacter=char
    flyRootPart=char:WaitForChild("HumanoidRootPart",10)
    flyHumanoid=char:WaitForChild("Humanoid",10)
end

local function setFlyPhysicsLock(locked)
    if not flyRootPart then return end
    flyRootPart.CustomPhysicalProperties=PhysicalProperties.new(locked and 0.01 or 0.7,locked and 0.001 or 0.3,0,0,0)
    flyRootPart.AssemblyLinearVelocity=Vector3.zero
    flyRootPart.AssemblyAngularVelocity=Vector3.zero
end

local function getFlyInputDirection()
    local camDir=Camera.CFrame.LookVector; local camRight=Camera.CFrame.RightVector
    local horRight=Vector3.new(camRight.X,0,camRight.Z)
    if horRight.Magnitude>0 then horRight=horRight.Unit else horRight=Vector3.new(1,0,0) end
    local moveDir=Vector3.zero
    if flyInputState.forward  then moveDir=moveDir+camDir   end
    if flyInputState.backward then moveDir=moveDir-camDir   end
    if flyInputState.right    then moveDir=moveDir+horRight end
    if flyInputState.left     then moveDir=moveDir-horRight end
    if moveDir.Magnitude>0    then moveDir=moveDir.Unit     end
    return moveDir
end

local function startFlyLoop()
    if flyHeartbeatConn then flyHeartbeatConn:Disconnect() end
    flyHeartbeatConn = RS.Heartbeat:Connect(function(dt)
        if not flyActive then return end
        if not flyCharacter or not flyRootPart or not flyHumanoid then return end
        if flyHumanoid.Health<=0 then flyActive=false; return end
        flyHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        local inputDir=getFlyInputDirection()
        local targetVel=inputDir*Cfg.FlySpeed
        flyCurrentVel=flyCurrentVel:Lerp(targetVel,math.min(1,dt*8))
        local newPos=flyRootPart.Position+flyCurrentVel*dt
        flyRootPart.CFrame=CFrame.new(newPos)*(flyRootPart.CFrame-flyRootPart.CFrame.Position)
        flyRootPart.AssemblyLinearVelocity=Vector3.zero
        flyRootPart.AssemblyAngularVelocity=Vector3.zero
    end)
end

local function enableFly()
    if flyActive then return end
    fetchFlyCharParts(Player.Character or Player.CharacterAdded:Wait())
    flyActive=true; flyCurrentVel=Vector3.zero
    setFlyPhysicsLock(true); startFlyLoop()
end

local function disableFly()
    if not flyActive then return end
    flyActive=false; setFlyPhysicsLock(false)
    if flyHeartbeatConn then flyHeartbeatConn:Disconnect(); flyHeartbeatConn=nil end
    if flyHumanoid then flyHumanoid:ChangeState(Enum.HumanoidStateType.Freefall) end
    for k in pairs(flyInputState) do flyInputState[k]=false end
end

local function createFlyMobileControls()
    if not UIS.TouchEnabled then return end
    local existing = Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild("FlyMobileControls")
    if existing then existing:Destroy() end
    local gui2=Instance.new("ScreenGui")
    gui2.Name="FlyMobileControls"; gui2.ResetOnSpawn=false
    gui2.Parent=Player:WaitForChild("PlayerGui")
    local sz=UDim2.new(0,90,0,90)
    local function makeBtn(name,text,pos)
        local btn=Instance.new("TextButton")
        btn.Name=name; btn.Text=text
        btn.Font=Enum.Font.GothamBold; btn.TextSize=22
        btn.TextColor3=Color3.new(1,1,1)
        btn.BackgroundColor3=Color3.fromRGB(40,40,40)
        btn.BackgroundTransparency=0.3; btn.BorderSizePixel=0
        btn.Position=pos; btn.Size=sz; btn.AutoButtonColor=false
        btn.Parent=gui2; return btn
    end
    local fwd=makeBtn("Forward","^", UDim2.new(0.14,-45,0.82,-105))
    local bwd=makeBtn("Backward","v",UDim2.new(0.14,-45,0.82,15))
    local lft=makeBtn("Left","<",   UDim2.new(0.06,-45,0.82,-45))
    local rgt=makeBtn("Right",">",  UDim2.new(0.22,-45,0.82,-45))
    local function conn(btn,key)
        btn.MouseButton1Down:Connect(function() flyInputState[key]=true  end)
        btn.MouseButton1Up:Connect(function()   flyInputState[key]=false end)
        btn.MouseLeave:Connect(function()       flyInputState[key]=false end)
    end
    conn(fwd,"forward"); conn(bwd,"backward"); conn(lft,"left"); conn(rgt,"right")
end

UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    local k=input.KeyCode
    if     k==Enum.KeyCode.W then flyInputState.forward =true
    elseif k==Enum.KeyCode.S then flyInputState.backward=true
    elseif k==Enum.KeyCode.A then flyInputState.left    =true
    elseif k==Enum.KeyCode.D then flyInputState.right   =true
    end
end)
UIS.InputEnded:Connect(function(input)
    local k=input.KeyCode
    if     k==Enum.KeyCode.W then flyInputState.forward =false
    elseif k==Enum.KeyCode.S then flyInputState.backward=false
    elseif k==Enum.KeyCode.A then flyInputState.left    =false
    elseif k==Enum.KeyCode.D then flyInputState.right   =false
    end
end)

local function CreateESPForPlayer(plr)
    if plr==Player or ESPObjects[plr] then return end
    local obj={
        Box=SafeDrawing("Square"), Text=SafeDrawing("Text"),
        HealthBG=SafeDrawing("Square"), HealthBar=SafeDrawing("Square"),
    }
    obj.Box.Visible=false; obj.Box.Thickness=ESPConfig.BoxThickness
    obj.Box.Transparency=ESPConfig.BoxTransparency; obj.Box.Filled=false
    obj.Text.Visible=false; obj.Text.Size=ESPConfig.TextSize
    obj.Text.Center=true; obj.Text.Outline=true; obj.Text.Transparency=1
    obj.HealthBG.Visible=false; obj.HealthBG.Filled=true
    obj.HealthBG.Color=Color3.fromRGB(35,35,35); obj.HealthBG.Transparency=0.5
    obj.HealthBar.Visible=false; obj.HealthBar.Filled=true; obj.HealthBar.Transparency=1
    ESPObjects[plr]=obj
end

local function HideESP(obj)
    obj.Box.Visible=false; obj.Text.Visible=false
    obj.HealthBG.Visible=false; obj.HealthBar.Visible=false
end

local function GetHpColor(pct)
    return Color3.new(math.clamp(2*(1-pct),0,1),math.clamp(2*pct,0,1),0)
end

local function RenderESP()
    if not ESPConfig.Enabled then
        for _, obj in pairs(ESPObjects) do HideESP(obj) end
        return
    end
    local camPos=Camera.CFrame.Position
    for plr, obj in pairs(ESPObjects) do
        if not plr or not plr.Parent or not plr.Character then HideESP(obj); continue end
        local char=plr.Character
        local hrp=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then HideESP(obj); continue end
        local dist=(hrp.Position-camPos).Magnitude
        if dist<0.5 or dist>ESPConfig.MaxDistance then HideESP(obj); continue end
        if Cfg.IgnoreTeam and isAlly(plr) then HideESP(obj); continue end
        local headTop=hrp.Position+Vector3.new(0,3,0)
        local feetBot=hrp.Position-Vector3.new(0,3,0)
        local topSP=Camera:WorldToViewportPoint(headTop)
        local botSP,onScreen=Camera:WorldToViewportPoint(feetBot)
        if not onScreen or topSP.Z<=0 then HideESP(obj); continue end
        local h=math.abs(topSP.Y-botSP.Y); local w=h*0.55
        if h<4 then HideESP(obj); continue end
        local bPos=Vector2.new(topSP.X-w*0.5,topSP.Y)
        local enemy2=isEnemy(plr)
        local teamC=plr.Team and plr.TeamColor.Color or espColor
        local boxCol=ESPConfig.ShowTeamColor and teamC or (enemy2 and Color3.fromRGB(255,70,70) or Color3.fromRGB(70,255,70))
        if ESPConfig.ShowBoxes then
            obj.Box.Position=bPos; obj.Box.Size=Vector2.new(w,h)
            obj.Box.Color=boxCol; obj.Box.Visible=true
        end
        if ESPConfig.ShowNames then
            obj.Text.Text=plr.Name; obj.Text.Color=boxCol
            obj.Text.Size=ESPConfig.TextSize
            obj.Text.Position=Vector2.new(topSP.X,topSP.Y-17)
            obj.Text.Visible=true
        end
        if ESPConfig.ShowHealthBar then
            local hpPct=math.clamp(hum.Health/math.max(1,hum.MaxHealth),0,1)
            local bw=3; local bx=bPos.X-bw-2
            obj.HealthBG.Position=Vector2.new(bx,topSP.Y); obj.HealthBG.Size=Vector2.new(bw,h); obj.HealthBG.Visible=true
            obj.HealthBar.Position=Vector2.new(bx,topSP.Y+h*(1-hpPct))
            obj.HealthBar.Size=Vector2.new(bw,h*hpPct)
            obj.HealthBar.Color=GetHpColor(hpPct); obj.HealthBar.Visible=true
        end
    end
end

local doorKW={"Door","Gate","door","gate","DOOR","GATE"}
local function containsKW(name)
    for _, kw in ipairs(doorKW) do
        if string.find(name,kw,1,true) then return true end
    end
    return false
end
local function deleteAll(parent)
    local n=0
    for _, obj in ipairs(parent:GetChildren()) do
        if containsKW(obj.Name) then obj:Destroy(); n=n+1
        else n=n+deleteAll(obj) end
    end
    return n
end
local function isGrille(obj)
    if not obj then return false end
    local n=obj.Name:lower()
    return n:find("grille") or n:find("vent") or n:find("lattice")
end

local function randomString()
    local length=math.random(10,20); local array={}
    for i=1,length do array[i]=string.char(math.random(32,126)) end
    return table.concat(array)
end

local function getRoot(char)
    if char and char:FindFirstChildOfClass("Humanoid") then
        return char:FindFirstChildOfClass("Humanoid").RootPart
    end
    return nil
end

local function enableNoclip()
    Clip=false
    if Noclipping then Noclipping:Disconnect() end
    Noclipping=RS.Stepped:Connect(function()
        if Clip==false and Player.Character then
            for _, child in pairs(Player.Character:GetDescendants()) do
                if child:IsA("BasePart") then child.CanCollide=false end
            end
        else
            if Noclipping then Noclipping:Disconnect() end
        end
    end)
end

local function disableNoclip()
    if Noclipping then Noclipping:Disconnect(); Noclipping=nil end
    Clip=true
end

local function NOFLY()
    FLYING=false
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp   then flyKeyUp:Disconnect()   end
    local char=Player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").PlatformStand=false
    end
    pcall(function() workspace.CurrentCamera.CameraType=Enum.CameraType.Custom end)
end

local function sFLY(vfly)
    local char=Player.Character or Player.CharacterAdded:Wait()
    local humanoid=char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
        humanoid=char:FindFirstChildOfClass("Humanoid")
    end
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect(); flyKeyUp:Disconnect() end
    local T=getRoot(char)
    local CONTROL={F=0,B=0,L=0,R=0,Q=0,E=0}
    local lCONTROL={F=0,B=0,L=0,R=0,Q=0,E=0}
    local SPEED=0
    local function FLY()
        FLYING=true
        local BG=Instance.new("BodyGyro"); local BV=Instance.new("BodyVelocity")
        BG.P=9e4; BG.Parent=T; BV.Parent=T
        BG.MaxTorque=Vector3.new(9e9,9e9,9e9); BG.CFrame=T.CFrame
        BV.Velocity=Vector3.new(0,0,0); BV.MaxForce=Vector3.new(9e9,9e9,9e9)
        task.spawn(function()
            repeat task.wait()
                local camera=workspace.CurrentCamera
                if not vfly and humanoid then humanoid.PlatformStand=true end
                if CONTROL.L+CONTROL.R~=0 or CONTROL.F+CONTROL.B~=0 or CONTROL.Q+CONTROL.E~=0 then
                    SPEED=50
                elseif SPEED~=0 then SPEED=0 end
                if (CONTROL.L+CONTROL.R)~=0 or (CONTROL.F+CONTROL.B)~=0 or (CONTROL.Q+CONTROL.E)~=0 then
                    BV.Velocity=((camera.CFrame.LookVector*(CONTROL.F+CONTROL.B))+((camera.CFrame*CFrame.new(CONTROL.L+CONTROL.R,(CONTROL.F+CONTROL.B+CONTROL.Q+CONTROL.E)*0.2,0).p)-camera.CFrame.p))*SPEED
                    lCONTROL={F=CONTROL.F,B=CONTROL.B,L=CONTROL.L,R=CONTROL.R}
                elseif (CONTROL.L+CONTROL.R)==0 and (CONTROL.F+CONTROL.B)==0 and (CONTROL.Q+CONTROL.E)==0 and SPEED~=0 then
                    BV.Velocity=((camera.CFrame.LookVector*(lCONTROL.F+lCONTROL.B))+((camera.CFrame*CFrame.new(lCONTROL.L+lCONTROL.R,(lCONTROL.F+lCONTROL.B+CONTROL.Q+CONTROL.E)*0.2,0).p)-camera.CFrame.p))*SPEED
                else BV.Velocity=Vector3.new(0,0,0) end
                BG.CFrame=camera.CFrame
            until not FLYING
            CONTROL={F=0,B=0,L=0,R=0,Q=0,E=0}; lCONTROL={F=0,B=0,L=0,R=0,Q=0,E=0}; SPEED=0
            BG:Destroy(); BV:Destroy()
            if humanoid then humanoid.PlatformStand=false end
        end)
    end
    flyKeyDown=UIS.InputBegan:Connect(function(input,processed)
        if processed then return end
        local spd=iyflyspeed
        if     input.KeyCode==Enum.KeyCode.W then CONTROL.F=spd
        elseif input.KeyCode==Enum.KeyCode.S then CONTROL.B=-spd
        elseif input.KeyCode==Enum.KeyCode.A then CONTROL.L=-spd
        elseif input.KeyCode==Enum.KeyCode.D then CONTROL.R=spd
        elseif input.KeyCode==Enum.KeyCode.E and QEfly then CONTROL.Q=spd*2
        elseif input.KeyCode==Enum.KeyCode.Q and QEfly then CONTROL.E=-spd*2 end
        pcall(function() workspace.CurrentCamera.CameraType=Enum.CameraType.Track end)
    end)
    flyKeyUp=UIS.InputEnded:Connect(function(input,processed)
        if processed then return end
        if     input.KeyCode==Enum.KeyCode.W then CONTROL.F=0
        elseif input.KeyCode==Enum.KeyCode.S then CONTROL.B=0
        elseif input.KeyCode==Enum.KeyCode.A then CONTROL.L=0
        elseif input.KeyCode==Enum.KeyCode.D then CONTROL.R=0
        elseif input.KeyCode==Enum.KeyCode.E then CONTROL.Q=0
        elseif input.KeyCode==Enum.KeyCode.Q then CONTROL.E=0 end
    end)
    FLY()
end

local function unfling()
    disableNoclip(); NOFLY()
    if flingDied then flingDied:Disconnect() end
    flinging=false
    local char=Player.Character
    if not char or not getRoot(char) then return end
    for _, v in pairs(getRoot(char):GetChildren()) do
        if v:IsA("AngularVelocity") or v:IsA("BodyAngularVelocity") or v.Name=="FlingAttachment" then
            v:Destroy()
        end
    end
    for _, child in pairs(char:GetDescendants()) do
        if child:IsA("BasePart") then child.CustomPhysicalProperties=nil end
    end
end

local function fling()
    unfling()
    local char=Player.Character; if not char then return end
    local root=getRoot(char);    if not root then return end
    flinging=true
    for _, child in pairs(char:GetDescendants()) do
        if child:IsA("BasePart") then
            child.CustomPhysicalProperties=PhysicalProperties.new(100,0.3,0.5)
            child.CanCollide=false; child.Massless=true; child.Velocity=Vector3.new(0,0,0)
        end
    end
    enableNoclip(); task.wait(0.1)
    local bambam=Instance.new("BodyAngularVelocity")
    bambam.Name=randomString(); bambam.Parent=root
    bambam.AngularVelocity=Vector3.new(0,99999,0)
    bambam.MaxTorque=Vector3.new(0,math.huge,0); bambam.P=math.huge
    local humanoid=char:FindFirstChildOfClass("Humanoid")
    if humanoid then flingDied=humanoid.Died:Connect(unfling) end
    task.spawn(sFLY)
    task.spawn(function()
        while flinging and char and root and bambam do
            bambam.AngularVelocity=Vector3.new(0,99999,0); task.wait(0.2)
            if not flinging then break end
            bambam.AngularVelocity=Vector3.new(0,0,0); task.wait(0.1)
        end
    end)
end

local Window = Rayfield:CreateWindow({
    Name            = "bulo hub",
    LoadingTitle    = "Loading...",
    LoadingSubtitle = "https://discord.gg/WZp4DZ9QZs",
    ConfigurationSaving = {Enabled=false},
    Discord   = {Enabled=false},
    KeySystem = false,
    Theme     = "Amethyst"
})

local InfoTab    = Window:CreateTab("Info",     4483362458)
local ClownsTab  = Window:CreateTab("Clowns",   4483362458)
local AimTab     = Window:CreateTab("Aim",      4483345998)
local CombatTab  = Window:CreateTab("Combat",   4483345998)
local VisualsTab = Window:CreateTab("Visuals",  4483345998)
local MoveTab    = Window:CreateTab("Movement", 4483345998)
local MiscTab    = Window:CreateTab("Misc",     4483345998)

InfoTab:CreateSection("")
InfoTab:CreateLabel("User: "     .. Player.DisplayName .. " (@" .. Player.Name .. ")")
InfoTab:CreateLabel("ID: "       .. tostring(Player.UserId))
InfoTab:CreateLabel("Executor: " .. executorName)
InfoTab:CreateLabel("Device: "   .. getDeviceInfo())

ClownsTab:CreateSection("The Most Braindead Game Moderators in Discord")
ClownsTab:CreateLabel("1. electroblade_")
ClownsTab:CreateLabel("2. exot1cdev")
ClownsTab:CreateLabel("3. buulhork")
ClownsTab:CreateLabel("4. kosokidbytheway")
ClownsTab:CreateLabel("5. crusaderthatgames")
ClownsTab:CreateLabel("6. originallysilly")
ClownsTab:CreateLabel("7. treyzie1")
ClownsTab:CreateLabel("8. abd0050")
ClownsTab:CreateLabel("9. apollyxnryxmen")
ClownsTab:CreateLabel("10. bamboo_cult")

AimTab:CreateSection("Silent Aim (Advanced)")
AimTab:CreateToggle({
    Name="Silent Aim", CurrentValue=false, Flag="SilentAimAdv",
    Callback=function(v)
        silentAimEnabled=v
        if DrawingAvailable then pcall(function() silentFOVring.Visible=v end) end
        pcall(function()
            game.StarterGui:SetCore("SendNotification",{Title="Silent Aim",Text=v and "ON" or "OFF",Duration=2})
        end)
    end
})
AimTab:CreateSlider({
    Name="Silent Aim FOV", Range={30,400}, Increment=1,
    Suffix="px", CurrentValue=100, Flag="SilentAimFOV",
    Callback=function(v)
        silentAimFOV=v
        if DrawingAvailable then pcall(function() silentFOVring.Radius=v end) end
    end
})

AimTab:CreateSection("Hitbox Silent Aim")
AimTab:CreateToggle({
    Name="Hitbox Silent Aim", CurrentValue=false, Flag="SilentAimOn",
    Callback=function(v)
        Cfg.SilentAim=v
        if not v then
            for id, head in pairs(Cfg.HiddenHeads) do
                if head and head.Parent then
                    pcall(function() head.Transparency=0 end)
                    for _, ch in pairs(head:GetChildren()) do
                        if ch:IsA("Decal") or ch:IsA("Texture") then pcall(function() ch.Transparency=0 end) end
                    end
                end
            end
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local head=p.Character:FindFirstChild("Head"); local id=GetID(p)
                    if head and Cfg.OrigSizes[id] then pcall(function() head.Size=Cfg.OrigSizes[id] end) end
                end
            end
            table.clear(Cfg.OrigSizes); Cfg.HiddenHeads={}; bestTarget=nil
        end
    end
})

local WallbangToggle
WallbangToggle = AimTab:CreateToggle({
    Name="Wallbang (Hitbox Expander)", CurrentValue=false, Flag="WallbangToggle",
    Callback=function(v)
        Cfg.Wallbang=v
        if not v then RestoreAllHitboxes() end
        pcall(function()
            game.StarterGui:SetCore("SendNotification",{Title="Wallbang",Text=v and "ENABLED" or "DISABLED",Duration=2})
        end)
    end
})
AimTab:CreateSlider({
    Name="Hitbox Size", Range={10,200}, Increment=1,
    Suffix=" units", CurrentValue=50, Flag="HitboxSlider",
    Callback=function(v) Cfg.WallbangRadius=v end
})
AimTab:CreateToggle({
    Name="Ignore Teammates", CurrentValue=true, Flag="IgnoreTeam",
    Callback=function(v) Cfg.IgnoreTeam=v end
})
AimTab:CreateToggle({
    Name="Ignore Unarmed Class D", CurrentValue=true, Flag="IgnoreClassD",
    Callback=function(v) Cfg.IgnoreUnarmedClassD=v end
})

CombatTab:CreateSection("Fling")
CombatTab:CreateToggle({
    Name="Enable Fling", CurrentValue=false, Flag="FlingToggle",
    Callback=function(v) if v then fling() else unfling() end end
})

CombatTab:CreateSection("Team Check")
CombatTab:CreateToggle({
    Name="Team Check (Sphere)", CurrentValue=false, Flag="TeamCheckToggle",
    Callback=function(v)
        teamCheckEnabled=v
        if not v then
            for _, pl in ipairs(Players:GetPlayers()) do
                local char=pl.Character
                local root=char and char:FindFirstChild("HumanoidRootPart")
                if root and root:FindFirstChild("ESP_Sphere") then root.ESP_Sphere:Destroy() end
            end
        end
        pcall(function()
            game.StarterGui:SetCore("SendNotification",{Title="Team Check",Text=v and "ON" or "OFF",Duration=2})
        end)
    end
})

CombatTab:CreateSection("Gun Mods")
CombatTab:CreateToggle({
    Name="Super Fast Fire Rate", CurrentValue=false, Flag="FastFire",
    Callback=function(v)
        Cfg.FastFireEnabled=v
        if v then
            startFastFire()
            pcall(function()
                game.StarterGui:SetCore("SendNotification",{
                    Title="Fast Fire ON",
                    Text="Pistol / M4 / Minigun / Freeze Gun / XM250",
                    Duration=3,
                })
            end)
        else
            stopFastFire()
            pcall(function()
                game.StarterGui:SetCore("SendNotification",{Title="Fast Fire OFF",Text="Disabled",Duration=2})
            end)
        end
    end
})
CombatTab:CreateToggle({
    Name="Remote Kill Aura", CurrentValue=false, Flag="KillAura",
    Callback=function(v) Cfg.MinigunSpam=v end
})

CombatTab:CreateSection("Misc")
CombatTab:CreateToggle({
    Name="Spinbot", CurrentValue=false, Flag="Spinbot",
    Callback=function(v) Cfg.Spinbot=v end
})

CombatTab:CreateSection("World")
CombatTab:CreateButton({Name="Delete All Doors", Callback=function() deleteAll(workspace) end})
CombatTab:CreateToggle({
    Name="Ghost Doors", CurrentValue=false, Flag="GhostDoorsToggle",
    Callback=function(v)
        if v then startGhostDoors() else stopGhostDoors() end
        pcall(function()
            game.StarterGui:SetCore("SendNotification",{Title="Ghost Doors",Text=v and "ON" or "OFF",Duration=2})
        end)
    end
})
CombatTab:CreateToggle({
    Name="Ghost Map", CurrentValue=false, Flag="GhostMapToggle",
    Callback=function(v)
        if v then task.spawn(applyGhostMap) else task.spawn(restoreGhostMap) end
        pcall(function()
            game.StarterGui:SetCore("SendNotification",{Title="Ghost Map",Text=v and "ON" or "OFF",Duration=2})
        end)
    end
})

CombatTab:CreateSection("No Team Limit")
CombatTab:CreateButton({
    Name="Bypass Team Limit",
    Callback=function()
        applyNoTeamLimit()
        pcall(function()
            game.StarterGui:SetCore("SendNotification",{Title="No Team Limit",Text="Applied!",Duration=3})
        end)
    end
})

VisualsTab:CreateSection("Player ESP")
VisualsTab:CreateToggle({
    Name="Enable ESP", CurrentValue=false, Flag="EspToggle",
    Callback=function(v) ESPConfig.Enabled=v end
})
VisualsTab:CreateToggle({
    Name="Show Boxes", CurrentValue=true, Flag="ShowBoxes",
    Callback=function(v) ESPConfig.ShowBoxes=v end
})
VisualsTab:CreateToggle({
    Name="Show Names", CurrentValue=true, Flag="ShowNames",
    Callback=function(v) ESPConfig.ShowNames=v end
})
VisualsTab:CreateToggle({
    Name="Show Health Bar", CurrentValue=true, Flag="ShowHp",
    Callback=function(v) ESPConfig.ShowHealthBar=v end
})
VisualsTab:CreateToggle({
    Name="Team Colors", CurrentValue=true, Flag="TeamColor",
    Callback=function(v) ESPConfig.ShowTeamColor=v end
})
VisualsTab:CreateSlider({
    Name="Max Distance", Range={100,10000}, Increment=100,
    Suffix="m", CurrentValue=5000, Flag="EspMaxDist",
    Callback=function(v) ESPConfig.MaxDistance=v end
})

VisualsTab:CreateSection("SCP ESP")
VisualsTab:CreateToggle({
    Name="SCP ESP (Blue)", CurrentValue=false, Flag="ScpEspToggle",
    Callback=function(v)
        scpEspEnabled=v
        if not v then clearSCPHighlights() end
        pcall(function()
            game.StarterGui:SetCore("SendNotification",{Title="SCP ESP",Text=v and "ON" or "OFF",Duration=2})
        end)
    end
})

VisualsTab:CreateSection("World")
VisualsTab:CreateToggle({
    Name="Full Bright", CurrentValue=false, Flag="FullBright",
    Callback=function(v) setFullbright(v) end
})
VisualsTab:CreateSlider({
    Name="Camera FOV", Range={70,120}, Increment=1,
    Suffix="deg", CurrentValue=70, Flag="WorldFovSlider",
    Callback=function(v)
        Cfg.WorldFOV=v
        pcall(function()
            Camera.FieldOfView=v
            Camera.FieldOfViewMode=Enum.FieldOfViewMode.Vertical
        end)
    end
})

MoveTab:CreateSection("Speed")
MoveTab:CreateToggle({
    Name="Speedhack", CurrentValue=false, Flag="Speedhack",
    Callback=function(v) Cfg.SpeedhackEnabled=v end
})
MoveTab:CreateSlider({
    Name="Speed Multiplier", Range={10,20}, Increment=1,
    Suffix="x0.1", CurrentValue=15, Flag="SpeedMult",
    Callback=function(v) Cfg.SpeedMultiplier=v end
})
MoveTab:CreateToggle({
    Name="Anti-Slowdown", CurrentValue=false, Flag="AntiSlow",
    Callback=function(v) Cfg.AntiSlowdown=v end
})
MoveTab:CreateToggle({
    Name="NoClip", CurrentValue=false, Flag="Noclip",
    Callback=function(v) Cfg.NoclipEnabled=v end
})

MoveTab:CreateSection("Jump")
MoveTab:CreateToggle({
    Name="Infinity Jump", CurrentValue=false, Flag="InfJump",
    Callback=function(v) Cfg.InfJumpEnabled=v end
})
MoveTab:CreateSlider({
    Name="Jump Force", Range={20,150}, Increment=1,
    CurrentValue=50, Flag="JumpForce",
    Callback=function(v) Cfg.InfJumpForce=v end
})

MoveTab:CreateSection("Fly")
MoveTab:CreateToggle({
    Name="Enable Fly", CurrentValue=false, Flag="FlyToggle",
    Callback=function(v)
        if v then
            enableFly()
            if UIS.TouchEnabled then createFlyMobileControls() end
        else
            disableFly()
            pcall(function()
                local g=Player.PlayerGui:FindFirstChild("FlyMobileControls")
                if g then g:Destroy() end
            end)
        end
    end
})
MoveTab:CreateSlider({
    Name="Fly Speed", Range={5,100}, Increment=1,
    CurrentValue=35, Flag="FlySpeedSlider",
    Callback=function(v) Cfg.FlySpeed=v end
})

MoveTab:CreateSection("Teleport (Locations)")
MoveTab:CreateButton({Name="Class D Cell",      Callback=function() advancedTeleport(218,   2,   -58) end})
MoveTab:CreateButton({Name="Sector 1",          Callback=function() advancedTeleport(-71,   2,    96) end})
MoveTab:CreateButton({Name="Sector 2",          Callback=function() advancedTeleport(-113,  2,  -531) end})
MoveTab:CreateButton({Name="Sector 3",          Callback=function() advancedTeleport(-42,   2,  -973) end})
MoveTab:CreateButton({Name="Biohazard Sector",  Callback=function() advancedTeleport(113,   2,  -966) end})
MoveTab:CreateButton({Name="Bunker",            Callback=function() advancedTeleport(-496, -10,  -262) end})
MoveTab:CreateButton({Name="Helipad",           Callback=function() advancedTeleport(-80,  -9,   963) end})
MoveTab:CreateButton({Name="MTF Spawn",         Callback=function() advancedTeleport(-66,   2,  -866) end})
MoveTab:CreateButton({Name="CI Spawn",          Callback=function() advancedTeleport(-136, 116, -192) end})
MoveTab:CreateButton({Name="Outside MTF Base",  Callback=function() advancedTeleport(-477,  0,   708) end})
MoveTab:CreateButton({Name="Transformers",      Callback=function() advancedTeleport(-255, -10,  -141) end})
MoveTab:CreateButton({Name="Administration",    Callback=function() advancedTeleport(-144,  24,   498) end})
MoveTab:CreateButton({Name="Medical Center",    Callback=function() advancedTeleport(24,    2,    16) end})
MoveTab:CreateButton({Name="Control Room",      Callback=function() advancedTeleport(-75,  24,   449) end})

MoveTab:CreateSection("Teleport (SCP Chambers)")
MoveTab:CreateButton({Name="SCP-008",  Callback=function() advancedTeleport(208,   2, -1083) end})
MoveTab:CreateButton({Name="SCP-002",  Callback=function() advancedTeleport(-164,  2, -1140) end})
MoveTab:CreateButton({Name="SCP-016",  Callback=function() advancedTeleport(411,   2, -1038) end})
MoveTab:CreateButton({Name="SCP-023",  Callback=function() advancedTeleport(-288,  2,  -684) end})
MoveTab:CreateButton({Name="SCP-049",  Callback=function() advancedTeleport(44,    2,  -587) end})
MoveTab:CreateButton({Name="SCP-066",  Callback=function() advancedTeleport(-204,  2,  -498) end})
MoveTab:CreateButton({Name="SCP-076",  Callback=function() advancedTeleport(-26,   2, -1331) end})
MoveTab:CreateButton({Name="SCP-087",  Callback=function() advancedTeleport(-58,   2,  -726) end})
MoveTab:CreateButton({Name="SCP-093",  Callback=function() advancedTeleport(92,    2,  -372) end})
MoveTab:CreateButton({Name="SCP-106",  Callback=function() advancedTeleport(-303,  2, -1057) end})
MoveTab:CreateButton({Name="SCP-131",  Callback=function() advancedTeleport(40,    2,  -384) end})
MoveTab:CreateButton({Name="SCP-173",  Callback=function() advancedTeleport(23,   16,  -535) end})
MoveTab:CreateButton({Name="SCP-299",  Callback=function() advancedTeleport(335,  -40, -1097) end})
MoveTab:CreateButton({Name="SCP-316",  Callback=function() advancedTeleport(-146,  2,  -201) end})
MoveTab:CreateButton({Name="SCP-409",  Callback=function() advancedTeleport(258,   2,  -938) end})
MoveTab:CreateButton({Name="SCP-457",  Callback=function() advancedTeleport(-353,  2,  -870) end})
MoveTab:CreateButton({Name="SCP-682",  Callback=function() advancedTeleport(-618, -70,  898) end})
MoveTab:CreateButton({Name="SCP-939",  Callback=function() advancedTeleport(-154, -81, -963) end})
MoveTab:CreateButton({Name="SCP-966",  Callback=function() advancedTeleport(11,    2,  -933) end})
MoveTab:CreateButton({Name="SCP-999",  Callback=function() advancedTeleport(103,   2,   -98) end})
MoveTab:CreateButton({Name="SCP-1025", Callback=function() advancedTeleport(-137,  2,  -387) end})
MoveTab:CreateButton({Name="SCP-1299", Callback=function() advancedTeleport(-163,  2,  -117) end})
MoveTab:CreateButton({Name="SCP-2950", Callback=function() advancedTeleport(-160,  2,   -29) end})
MoveTab:CreateButton({Name="SCP-079",  Callback=function() advancedTeleport(176,   2,  -674) end})
MoveTab:CreateButton({Name="SCP-096",  Callback=function() advancedTeleport(324,   2,  -848) end})

MiscTab:CreateSection("FPS Boost")
MiscTab:CreateToggle({
    Name="FPS Boost", CurrentValue=false, Flag="FPSBoost",
    Callback=function(v)
        toggleFPSBoost(v)
    end
})

MiscTab:CreateSection("Auto Grille")
MiscTab:CreateToggle({
    Name="Auto Click on Grilles", CurrentValue=false, Flag="AutoGrille",
    Callback=function(v) Cfg.AutoGrilleEnabled=v end
})
MiscTab:CreateSlider({
    Name="Click Delay (ms)", Range={10,500}, Increment=10,
    Suffix="ms", CurrentValue=100, Flag="ClickDelay",
    Callback=function(v) Cfg.ClickDelay=v end
})

MiscTab:CreateSection("Anti Name Tag")
MiscTab:CreateToggle({
    Name="Hide Own Name Tag", CurrentValue=false, Flag="AntiNameTag",
    Callback=function(v)
        if v then enableAntiNameTag() else disableAntiNameTag() end
        pcall(function()
            game.StarterGui:SetCore("SendNotification",{
                Title   = "Anti Name Tag",
                Text    = v and "ON" or "OFF",
                Duration= 3,
            })
        end)
    end
})

MiscTab:CreateSection("Fall Damage Reducer")
MiscTab:CreateToggle({
    Name="Fall Damage Reducer", CurrentValue=false, Flag="FallReducer",
    Callback=function(v)
        fallReducerEnabled=v
        pcall(function()
            game.StarterGui:SetCore("SendNotification",{
                Title   = "Fall Damage Reducer",
                Text    = v and "ON" or "OFF",
                Duration= 2,
            })
        end)
    end
})

pcall(function()
    if UIS.TouchEnabled then
        local mobileGui=Instance.new("ScreenGui")
        mobileGui.Name="MobileAimButton"; mobileGui.ResetOnSpawn=false
        mobileGui.Parent=Player:WaitForChild("PlayerGui")
        local aimButton=Instance.new("TextButton")
        aimButton.Size=UDim2.new(0,80,0,80)
        aimButton.Position=UDim2.new(0.8,-40,0.7,-40)
        aimButton.BackgroundColor3=Color3.fromRGB(0,160,255)
        aimButton.Text="AIM"; aimButton.TextColor3=Color3.new(1,1,1)
        aimButton.Font=Enum.Font.GothamBold; aimButton.TextSize=16
        aimButton.Parent=mobileGui
        Instance.new("UICorner",aimButton).CornerRadius=UDim.new(1,0)
        aimButton.Active=true
        aimButton.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch then MobileAimActive=true end
        end)
        aimButton.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch then MobileAimActive=false end
        end)
    end
end)

table.insert(connections, RS.RenderStepped:Connect(function()
    pcall(function()
        Camera.FieldOfView=Cfg.WorldFOV
        Camera.FieldOfViewMode=Enum.FieldOfViewMode.Vertical
    end)
    for id, head in pairs(Cfg.HiddenHeads) do
        if head and head.Parent then
            pcall(function()
                head.Transparency=1
                for _, ch in pairs(head:GetChildren()) do
                    if ch:IsA("Decal") or ch:IsA("Texture") then ch.Transparency=1 end
                end
            end)
        else
            Cfg.HiddenHeads[id]=nil
        end
    end
    pcall(RenderESP)
    if Cfg.AutoGrilleEnabled then
        pcall(function()
            if Mouse.Target and isGrille(Mouse.Target) then
                local now=tick()*1000
                if now-lastClick>=Cfg.ClickDelay then SafeClick(); lastClick=now end
            end
        end)
    end
end))

table.insert(connections, RS.Heartbeat:Connect(function(dt)
    pcall(function()
        if Cfg.SilentAim then
            UpdateSilentAimHitboxes()
        else
            if not Cfg.Wallbang then RestoreAllHitboxes() end
        end
        if not Cfg.SilentAim then
            if Cfg.Wallbang then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr~=Player and isEnemy(plr) then
                        local char=plr.Character
                        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health>0 then
                            local part=char:FindFirstChild(Cfg.TargetPart)
                            if part and part:IsA("BasePart") then
                                if not OriginalStates[plr] then
                                    OriginalStates[plr]={
                                        Size=part.Size, Transparency=part.Transparency,
                                        CanCollide=part.CanCollide, Massless=part.Massless,
                                    }
                                end
                                part.Size=Vector3.new(Cfg.WallbangRadius,Cfg.WallbangRadius,Cfg.WallbangRadius)
                                part.Transparency=1; part.CanCollide=false; part.Massless=true
                            end
                        end
                    end
                end
            else
                RestoreAllHitboxes()
            end
        end
    end)
    pcall(function()
        if Player.Character then
            local root=Player.Character:FindFirstChild("HumanoidRootPart")
            local hum=Player.Character:FindFirstChildOfClass("Humanoid")
            if hum and Cfg.AntiSlowdown then
                if hum.WalkSpeed<16 then hum.WalkSpeed=16 end
            end
            if not isFlying and not flyActive and Cfg.SpeedhackEnabled and root and hum and hum.MoveDirection.Magnitude>0 then
                local baseSpeed=hum.WalkSpeed
                if Cfg.AntiSlowdown and baseSpeed<16 then baseSpeed=16 end
                root.CFrame=root.CFrame+(hum.MoveDirection.Unit*baseSpeed*((Cfg.SpeedMultiplier/10)-1)*dt)
            end
        end
    end)
    pcall(function()
        if Cfg.Spinbot and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Cfg.SpinAngle=(Cfg.SpinAngle+20)%360
            Player.Character.HumanoidRootPart.CFrame=Player.Character.HumanoidRootPart.CFrame*CFrame.Angles(0,math.rad(Cfg.SpinAngle),0)
        end
    end)
    pcall(function()
        if isFlying and flyTarget then
            local char=Player.Character; if not char then stopFly(); return end
            local root=char:FindFirstChild("HumanoidRootPart"); if not root then stopFly(); return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide=false end) end
            end
            local dir=flyTarget-root.Position; local dist=dir.Magnitude
            if dist<=5 then
                root.CFrame=CFrame.new(flyTarget)
                pcall(function() root.Velocity=Vector3.new(0,0,0) end)
                stopFly(); return
            end
            local step=dir.Unit*math.min(Cfg.FlySpeed,dist)*dt
            pcall(function() root.Velocity=Vector3.new(0,0,0) end)
            pcall(function() root.AssemblyLinearVelocity=Vector3.new(0,0,0) end)
            local ld=Vector3.new(dir.X,0,dir.Z)
            if ld.Magnitude>0.1 then
                root.CFrame=CFrame.lookAt(root.Position+step,root.Position+step+ld.Unit)
            else
                root.CFrame=root.CFrame+step
            end
        end
    end)
end))

table.insert(connections, RS.Stepped:Connect(function()
    pcall(function()
        if (Cfg.NoclipEnabled or isFlying or flyActive) and Player.Character then
            for _, part in ipairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide=false end
            end
        end
    end)
end))

table.insert(connections, UIS.JumpRequest:Connect(function()
    if not Cfg.InfJumpEnabled then return end
    pcall(function()
        local char=Player.Character; if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if root and hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            root.Velocity=Vector3.new(root.Velocity.X,Cfg.InfJumpForce,root.Velocity.Z)
        end
    end)
end))

table.insert(connections, UIS.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.KeyCode==Cfg.WallbangKey then
        local newState=not Cfg.Wallbang
        pcall(function() WallbangToggle:Set(newState) end)
    end
end))

Player.CharacterAdded:Connect(function(newChar)
    task.wait(0.3)
    if isFlying then stopFly() end
    if flyActive then
        flyActive=false; flyCurrentVel=Vector3.zero
        if flyHeartbeatConn then flyHeartbeatConn:Disconnect(); flyHeartbeatConn=nil end
    end
    fetchFlyCharParts(newChar)
    RestoreAllHitboxes()
    currentWeaponObj=nil; currentWeaponName=""; isReloadingFF=false
    pcall(function()
        Camera.FieldOfView=Cfg.WorldFOV
        Camera.FieldOfViewMode=Enum.FieldOfViewMode.Vertical
    end)
    if antiNameTagEnabled then
        task.wait(0.5)
        setupAntiNameTag(newChar)
    end
end)

pcall(function()
    local VirtualUser=game:GetService("VirtualUser")
    Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

for _, p in ipairs(Players:GetPlayers()) do pcall(function() CreateESPForPlayer(p) end) end
Players.PlayerAdded:Connect(function(p) pcall(function() CreateESPForPlayer(p) end) end)
Players.PlayerRemoving:Connect(function(p)
    pcall(function()
        if ESPObjects[p] then
            for _, d in pairs(ESPObjects[p]) do pcall(function() d:Remove() end) end
            ESPObjects[p]=nil
        end
    end)
end)

fetchFlyCharParts(Player.Character or Player.CharacterAdded:Wait())

pcall(function()
    Rayfield:Notify({
        Title   = "fail hub ["..executorName.."]",
        Content = "All functions loaded!",
        Duration= 5,
        Image   = 4483362458,
    })
end)
