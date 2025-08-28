-- تحميل Orion UI
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "HM HUB | KINGDOM",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "HMHUB",
    IntroEnabled = true,
    IntroText = "HM HUB | KINGDOM",
    IntroIcon = "http://www.roblox.com/asset/?id=82795327169782"
})

-- === تبويب الرئيسي (Main) ===
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- === 1. Places ESP (أبيض) ===
MainTab:AddSection({ Name = "Places ESP" })

local places = {
    "\217\136\217\130\216\170 \216\167\217\132\217\132\217\138\216\167\217\130\216\169 / Fitness time",
    "\217\135\216\167\217\138\216\168\216\177\216\168\217\134\216\175\216\169 / hyperpanda",
    "\217\135\216\167\217\129 \217\133\217\132\217\138\217\136\217\134 / half million",
    "\217\133\217\136\217\130\217\129 \216\168\216\167\216\181 \216\185\217\134\216\175 \216\167\217\132\216\167\216\180\216\167\216\177\216\167\216\170 / Bus Stop traffic lights ",
    "\217\133\217\134\216\183\217\130\216\169 \216\167\217\132\216\167\216\179\216\170\216\177\216\167\216\173\216\169 / Houses Park",
    "\217\133\217\136\217\130\217\129 \216\167\217\132\216\168\216\167\216\181\216\167\216\170 \217\133\217\130\216\167\216\168\217\132 \216\179\216\167\217\138\217\134 / Bus stops infront of Sign",
    "\217\133\216\173\217\132 \216\167\217\132\216\167\216\170\216\181\217\132\216\167\216\170 / STC",
    "\217\133\216\173\216\183\216\169 \216\167\217\132\217\133\217\138\216\170\216\177\217\136 / Metro Station",
    "\217\133\216\170\216\172\216\177 \216\167\217\132\217\132\217\136\216\173\216\167\216\170 | plates shop",
    "\217\131\217\138\216\167\217\134 / kyan",
    "\216\181\217\138\216\175\217\132\217\138\216\169 / Pharmacy",
    "\216\180\216\167\216\177\216\185 \216\167\217\132\216\168\217\138\217\136\216\170 2 / Houses Street 2",
    "\216\180\217\134\216\175\216\167\216\161 \217\136\216\168\217\138\216\185 \216\179\217\132\216\185\216\169 / Shop",
    "\216\168\217\134\217\131 \216\167\217\132\216\177\217\138\216\167\216\182 / Riyadh Bank",
    "\216\167\217\132\217\136\216\177\216\180\216\169 / workshop",
    "\216\167\217\132\217\133\216\185\216\177\216\182 | Dealership",
    "\216\167\217\132\217\133\216\173\216\183\216\169 \216\167\217\132\216\167\216\179\216\167\216\179\217\138\216\169 / Main gas station"
}

local placeEspObjects = {}
local espEnabledPlaces = false
local placeESPColor = Color3.fromRGB(255, 255, 255) -- أبيض

local function createPlaceESP(placeName)
    local place = game:GetService("Workspace").TaxiNPCSystem.Places:FindFirstChild(placeName)
    if not place then return end

    if placeEspObjects[placeName] then
        placeEspObjects[placeName]:Remove()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlaceESP"
    billboard.Parent = place
    billboard.Adornee = place
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = placeName
    textLabel.TextColor3 = placeESPColor
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    placeEspObjects[placeName] = billboard
end

local function removePlaceESP(placeName)
    if placeEspObjects[placeName] then
        placeEspObjects[placeName]:Remove()
        placeEspObjects[placeName] = nil
    end
end

spawn(function()
    while wait(0.2) do
        if not espEnabledPlaces then continue end
        for _, placeName in pairs(places) do
            createPlaceESP(placeName)
        end
    end
end)

MainTab:AddToggle({
    Name = "تفعيل Places ESP",
    Default = false,
    Callback = function(state)
        espEnabledPlaces = state
        if state then
            for _, placeName in pairs(places) do
                createPlaceESP(placeName)
            end
        else
            for name in pairs(placeEspObjects) do
                removePlaceESP(name)
            end
        end
    end
})

-- === 2. التنقل إلى الأماكن (مع ضمان التنقل فوق الأرض) ===
MainTab:AddSection({ Name = "التنقل إلى الأماكن" })

local function getSafeTeleportPosition(position)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    raycastParams.IgnoreWater = true

    local raycastResult = workspace:Raycast(position + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), raycastParams)
    if raycastResult then
        return raycastResult.Position + Vector3.new(0, 10, 0)
    else
        return position + Vector3.new(0, 10, 0)
    end
end

for _, placeName in pairs(places) do
    MainTab:AddButton({
        Name = "الذهاب إلى: " .. placeName,
        Callback = function()
            local place = game:GetService("Workspace").TaxiNPCSystem.Places:FindFirstChild(placeName)
            if place then
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local safePosition = getSafeTeleportPosition(place.Position)
                    hrp.CFrame = CFrame.new(safePosition)
                    OrionLib:MakeNotification({
                        Name = "تنقل",
                        Content = "تم التنقل إلى: " .. placeName,
                        Time = 3
                    })
                else
                    OrionLib:MakeNotification({
                        Name = "خطأ",
                        Content = "تعذر العثور على اللاعب!",
                        Time = 5
                    })
                end
            else
                OrionLib:MakeNotification({
                    Name = "خطأ",
                    Content = "تعذر العثور على الموقع: " .. placeName,
                    Time = 5
                })
            end
        end
    })
end

MainTab:AddButton({
    Name = "تنقل عشوائي",
    Callback = function()
        local placeName = places[math.random(1, #places)]
        local place = game:GetService("Workspace").TaxiNPCSystem.Places:FindFirstChild(placeName)
        if place then
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local safePosition = getSafeTeleportPosition(place.Position)
                hrp.CFrame = CFrame.new(safePosition)
                OrionLib:MakeNotification({
                    Name = "تنقل",
                    Content = "تم التنقل إلى: " .. placeName,
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "خطأ",
                    Content = "تعذر العثور على اللاعب!",
                    Time = 5
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "خطأ",
                Content = "تعذر العثور على الموقع: " .. placeName,
                Time = 5
            })
        end
    end
})

-- === 3. Auto Real (ريال سعودي) - مع انتقال فوق سيارة محددة ===
MainTab:AddSection({ Name = "Auto Real (ريال سعودي)" })

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SpawnTriggered = ReplicatedStorage:FindFirstChild("Server_Events") and ReplicatedStorage.Server_Events:FindFirstChild("SpawnTriggered")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local CarSpawnHandler = PlayerGui.CarSpawnUI:FindFirstChild("CarSpawnHandler")

local carNames = {
    "\216\167\217\133\216\172\217\138\216\167 \216\168\217\134\217\136\216\172\217\136\216\177",
    "\216\167\217\133\216\172\217\136\216\177\216\175 \216\170\217\138\217\136\216\177\217\138\217\136\216\179 2023",
    "\216\167\217\133\216\172\217\138\217\136\216\170\216\167 \217\131\216\167\217\133\217\138\216\177\217\138\216\167 2011",
    "\216\167\217\133\216\172\217\138\217\136\217\134\216\175\216\167\217\138 \216\167\217\131\216\180\217\134\216\170 2012",
    "\216\167\217\133\216\172\217\138\217\136\217\132\217\138\217\135 \217\131\216\177\216\178 \216\179\216\170\216\167\217\134\216\175\216\177 2016"
}

MainTab:AddButton({
    Name = "🚗 تشغيل Auto Real (انتقال فوق سيارة)",
    Callback = function()
        if not SpawnTriggered or not CarSpawnHandler then
            OrionLib:MakeNotification({
                Name = "خطأ",
                Content = "تعذر العثور على SpawnTriggered أو CarSpawnHandler",
                Time = 5
            })
            return
        end

        pcall(function()
            SpawnTriggered:FireServer(
                {
                    "\216\167\217\133\216\172\217\138\217\136\217\134\216\175\216\167\217\138 \216\172\216\177\216\167\217\134\216\175 \216\167\216\179 \216\170\217\134 2023"
                },
                CarSpawnHandler,
                PlayerGui.CarSpawnUI
            )
            OrionLib:MakeNotification({
                Name = "Auto Real",
                Content = "تم إرسال طلب الريال...",
                Time = 5
            })
        end)

        spawn(function()
            wait(1)

            local spawnedCars = Workspace:FindFirstChild("SpawnedCars")
            if not spawnedCars then return end

            local targetCar = nil
            for _, name in pairs(carNames) do
                local car = spawnedCars:FindFirstChild(name)
                if car and car:FindFirstChild("PrimaryPart") then
                    targetCar = car
                    break
                end
            end

            if not targetCar and #spawnedCars:GetChildren() >= 9 then
                targetCar = spawnedCars:GetChildren()[9]
            end

            local character = Players.LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp and targetCar and targetCar:FindFirstChild("PrimaryPart") then
                hrp.CFrame = targetCar.PrimaryPart.CFrame + Vector3.new(0, 10, 0)
                OrionLib:MakeNotification({
                    Name = "Auto Real",
                    Content = "تم الانتقال فوق السيارة!",
                    Time = 5
                })
            end
        end)
    end
})

-- === تبويب LocalPlayer (مُحدّث) ===
local LocalPlayerTab = Window:MakeTab({
    Name = "LocalPlayer",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

LocalPlayerTab:AddSection({ Name = "تعديل خصائص اللاعب" })

-- السلايدر الأصلي للسرعة
LocalPlayerTab:AddSlider({
    Name = "سرعة المشي",
    Min = 0,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    Callback = function(value)
        local character = game.Players.LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

-- السلايدر الأصلي للقفزة
LocalPlayerTab:AddSlider({
    Name = "قوة القفزة",
    Min = 0,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 1,
    Callback = function(value)
        local character = game.Players.LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if humanoid.UseJumpPower then
                humanoid.JumpPower = value
            else
                humanoid.JumpHeight = value / 7.2
            end
        end
    end
})

-- ✅ زر جديد: إدخال سرعة وقفزة يدويًا
LocalPlayerTab:AddButton({
    Name = "🔧 إدخال سرعة وقفزة يدويًا",
    Callback = function()
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 150)
        frame.Position = UDim2.new(0.5, -150, 0.5, -75)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.BorderSizePixel = 0
        frame.Visible = true
        frame.ZIndex = 10

        local textLabel = Instance.new("TextLabel")
        textLabel.Text = "أدخل القيم:"
        textLabel.Size = UDim2.new(1, 0, 0, 30)
        textLabel.Position = UDim2.new(0, 0, 0, 10)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 18
        textLabel.Parent = frame

        local speedBox = Instance.new("TextBox")
        speedBox.PlaceholderText = "سرعة المشي (مثل: 100)"
        speedBox.Size = UDim2.new(0.8, 0, 0, 30)
        speedBox.Position = UDim2.new(0.1, 0, 0, 50)
        speedBox.BackgroundTransparency = 0.8
        speedBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        speedBox.TextColor3 = Color3.fromRGB(0, 0, 0)
        speedBox.Font = Enum.Font.SourceSans
        speedBox.TextSize = 16
        speedBox.Parent = frame

        local jumpBox = Instance.new("TextBox")
        jumpBox.PlaceholderText = "قوة القفزة (مثل: 100)"
        jumpBox.Size = UDim2.new(0.8, 0, 0, 30)
        jumpBox.Position = UDim2.new(0.1, 0, 0, 90)
        jumpBox.BackgroundTransparency = 0.8
        jumpBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        jumpBox.TextColor3 = Color3.fromRGB(0, 0, 0)
        jumpBox.Font = Enum.Font.SourceSans
        jumpBox.TextSize = 16
        jumpBox.Parent = frame

        local applyButton = Instance.new("TextButton")
        applyButton.Text = "تطبيق"
        applyButton.Size = UDim2.new(0.8, 0, 0, 30)
        applyButton.Position = UDim2.new(0.1, 0, 0, 130)
        applyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        applyButton.Font = Enum.Font.SourceSansBold
        applyButton.Parent = frame

        applyButton.MouseButton1Click:Connect(function()
            local speed = tonumber(speedBox.Text)
            local jump = tonumber(jumpBox.Text)

            if not speed or not jump then
                OrionLib:MakeNotification({
                    Name = "خطأ",
                    Content = "يرجى إدخال أرقام صالحة!",
                    Time = 5
                })
                return
            end

            local character = game.Players.LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speed
                if humanoid.UseJumpPower then
                    humanoid.JumpPower = jump
                else
                    humanoid.JumpHeight = jump / 7.2
                end
                OrionLib:MakeNotification({
                    Name = "تم التحديث",
                    Content = "السرعة: " .. speed .. " | القفزة: " .. jump,
                    Time = 4
                })
                frame.Visible = false
            else
                OrionLib:MakeNotification({
                    Name = "خطأ",
                    Content = "تعذر العثور على Humanoid!",
                    Time = 5
                })
            end
        end)

        -- إضافة النافذة إلى الشاشة
        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        frame.Parent = playerGui
    end
})

-- === تبويب Combat ===
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CombatTab:AddSection({ Name = "ميزات الهروب" })

local SafeEscapeLocation = Vector3.new(0, 5, 0)

CombatTab:AddButton({
    Name = "🚨 الهروب من الشرطة",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local safePosition = getSafeTeleportPosition(SafeEscapeLocation)
            hrp.CFrame = CFrame.new(safePosition)
            OrionLib:MakeNotification({
                Name = "هروب ناجح",
                Content = "تم الانتقال إلى المكان الآمن!",
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "خطأ",
                Content = "لم يتم العثور على اللاعب.",
                Time = 5
            })
        end
    end
})

CombatTab:AddSection({ Name = "Team ESP (كل فريق بلون)" })

local TeamColors = {
    ["\216\167\217\132\216\167\217\133\217\134 \216\167\217\132\216\185\216\167\217\133 - \216\167\217\132\216\180\216\177\216\183\216\169 | Public Security - Police"] = Color3.fromRGB(0, 0, 255),
    ["\216\167\217\132\216\167\217\133\217\134 \216\167\217\132\216\185\216\167\217\133 - \216\167\217\132\217\133\216\177\217\136\216\177 | Public Security - Traffic"] = Color3.fromRGB(30, 144, 255),
    ["\216\167\217\132\216\173\216\177\216\179 \216\167\217\132\217\133\217\132\217\131\217\138 | Royal Guard"] = Color3.fromRGB(139, 0, 255),
    ["\216\170\217\136\216\181\217\138\217\132 / \216\167\216\172\216\177\216\169 | Taxi Transportation"] = Color3.fromRGB(0, 255, 255),
    ["\216\185\216\181\216\167\216\168\216\167\216\170 | Criminals"] = Color3.fromRGB(255, 0, 0),
    ["\217\129\216\177\217\138\217\130 \216\167\217\132\216\185\217\133\217\132 | Mj Studios Team"] = Color3.fromRGB(255, 255, 0),
    ["\217\133\216\179\216\172\217\136\217\134 | Imprisoned"] = Color3.fromRGB(128, 128, 128),
    ["\217\133\217\136\216\167\216\183\217\134 | Citizen"] = Color3.fromRGB(0, 255, 0)
}

local playerEsp = {}
local espEnabledTeam = false

local function createPlayerESP(player)
    if player == game.Players.LocalPlayer or playerEsp[player] then return end

    local function setup()
        local character = player.Character
        if not character then return end

        local head = character:FindFirstChild("Head")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not head or not hrp then return end

        local team = player.Team
        if not team or not TeamColors[team.Name] then return end

        local color = TeamColors[team.Name]

        local billboard = Instance.new("BillboardGui")
        billboard.Parent = character
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = billboard
        nameLabel.Size = UDim2.new(1, 0, 0.5, -2)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = color
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

        local teamLabel = Instance.new("TextLabel")
        teamLabel.Parent = nameLabel.Parent
        teamLabel.Size = UDim2.new(1, 0, 0.5, -2)
        teamLabel.Position = UDim2.new(0, 0, 0.5, 2)
        teamLabel.BackgroundTransparency = 1
        teamLabel.Text = team.Name
        teamLabel.TextColor3 = color
        teamLabel.TextScaled = true
        teamLabel.Font = Enum.Font.SourceSans
        teamLabel.TextStrokeTransparency = 0.5
        teamLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

        playerEsp[player] = {
            Billboard = billboard,
            Color = color,
            Character = character,
            HRP = hrp
        }
    end

    if player.Character then
        setup()
    end
    player.CharacterAdded:Connect(setup)
end

local function removePlayerESP(player)
    if playerEsp[player] then
        playerEsp[player].Billboard:Remove()
        playerEsp[player] = nil
    end
end

CombatTab:AddToggle({
    Name = "تفعيل Team ESP",
    Default = false,
    Callback = function(state)
        espEnabledTeam = state
        if state then
            for _, player in pairs(game.Players:GetPlayers()) do
                createPlayerESP(player)
            end
            game.Players.PlayerAdded:Connect(createPlayerESP)
        else
            for player in pairs(playerEsp) do
                removePlayerESP(player)
            end
        end
    end
})

CombatTab:AddSection({ Name = "التنقل إلى المجرمين" })

local lastTeleportedPlayer = nil

CombatTab:AddButton({
    Name = "🚨 التنقل إلى مجرم عشوائي",
    Callback = function()
        local criminals = {}
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Team and player.Team.Name == "\216\185\216\181\216\167\216\168\216\167\216\170 | Criminals" then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if player ~= lastTeleportedPlayer then
                        table.insert(criminals, player)
                    end
                end
            end
        end

        if #criminals == 0 then
            OrionLib:MakeNotification({
                Name = "خطأ",
                Content = "لم يتم العثور على مجرمين متاحين!",
                Time = 5
            })
            return
        end

        local targetPlayer = criminals[math.random(1, #criminals)]
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")

        if hrp and targetHRP then
            local safePosition = getSafeTeleportPosition(targetHRP.Position)
            hrp.CFrame = CFrame.new(safePosition)
            lastTeleportedPlayer = targetPlayer
            OrionLib:MakeNotification({
                Name = "تنقل",
                Content = "تم التنقل إلى المجرم: " .. targetPlayer.Name,
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "خطأ",
                Content = "تعذر التنقل إلى المجرم!",
                Time = 5
            })
        end
    end
})

-- === تبويب Creators (جديد) ===
local CreatorsTab = Window:MakeTab({
    Name = "Creators",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CreatorsTab:AddSection({ Name = "فريق HM HUB" })

CreatorsTab:AddLabel("تم التطوير من قبل: HM HUB")
CreatorsTab:AddLabel("شكراً على دعمنا!")

CreatorsTab:AddButton({
    Name = "تابع قناتنا على يوتيوب",
    Callback = function()
        local youtubeLink = "https://youtube.com/@hazarobloxscripts?si=8x3msH4LOr1NLGi-"
        setclipboard(youtubeLink)
        OrionLib:MakeNotification({
            Name = "تم النسخ",
            Content = "تم نسخ رابط قناة اليوتيوب!\nتابعنا: @hazarobloxscripts",
            Time = 5
        })
    end
})

-- === تنظيف عند الإغلاق ===
game.Players.LocalPlayer:WaitForChild("PlayerGui").ChildRemoved:Connect(function(child)
    if child.Name == "Orion" then
        for name in pairs(placeEspObjects) do
            removePlaceESP(name)
        end
        for player in pairs(playerEsp) do
            removePlayerESP(player)
        end
    end
end)

-- === إشعار التحميل ===
OrionLib:MakeNotification({
    Name = "HM HUB | KINGDOM",
    Content = "تم التحديث! تابع قناتنا على يوتيوب لمزيد من الأدوات: hazarobloxscripts",
    Time = 7
})

print("HM HUB | KINGDOM - تم التحميل بنجاح!")