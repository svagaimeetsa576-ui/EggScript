-- Break and Steal an Egg | Delta Executor
-- GUI + best-effort ProximityPrompt collection.
-- NOTE: Actual egg/crystal collection depends on the game's object names
-- and server-side interaction mechanics; this script cannot guarantee it.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local running = true
local eggsOn = false
local crystalsOn = false

pcall(function()
    local old = CoreGui:FindFirstChild("EggCrystalFarm")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "EggCrystalFarm"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(250, 190)
frame.Position = UDim2.new(0.5, -125, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.fromOffset(10, 5)
title.BackgroundTransparency = 1
title.Text = "Egg / Crystal Helper"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local function makeButton(y, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -24, 0, 38)
    b.Position = UDim2.fromOffset(12, y)
    b.BackgroundColor3 = Color3.fromRGB(65, 70, 90)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.Text = text
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(callback)
    return b
end

local eggButton, crystalButton

eggButton = makeButton(45, "Auto Eggs: OFF", function()
    eggsOn = not eggsOn
    eggButton.Text = "Auto Eggs: " .. (eggsOn and "ON" or "OFF")
end)

crystalButton = makeButton(89, "Auto Crystals: OFF", function()
    crystalsOn = not crystalsOn
    crystalButton.Text = "Auto Crystals: " .. (crystalsOn and "ON" or "OFF")
end)

makeButton(133, "STOP ALL / CLOSE", function()
    running = false
    eggsOn = false
    crystalsOn = false
    gui:Destroy()
end)

local function tryPrompts(words)
    for _, item in ipairs(Workspace:GetDescendants()) do
        if not running then return end
        if item:IsA("ProximityPrompt") and item.Enabled then
            local promptName = item.Name:lower()
            local parentName = item.Parent and item.Parent.Name:lower() or ""
            local grandName = item.Parent and item.Parent.Parent
                and item.Parent.Parent.Name:lower() or ""
            local haystack = promptName .. " " .. parentName .. " " .. grandName

            for _, word in ipairs(words) do
                if haystack:find(word, 1, true) then
                    if typeof(fireproximityprompt) == "function" then
                        pcall(fireproximityprompt, item)
                    end
                    break
                end
            end
        end
    end
end

task.spawn(function()
    while running do
        if eggsOn then
            tryPrompts({"egg"})
        end
        task.wait(1.5)
    end
end)

task.spawn(function()
    while running do
        if crystalsOn then
            tryPrompts({"crystal", "gem"})
        end
        task.wait(1.5)
    end
end)
