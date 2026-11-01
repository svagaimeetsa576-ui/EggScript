-- BREAK & STEAL AN EGG | Personal Helper V5
-- Delta / Roblox client helper. No remote calls, no server bypass.
-- Working client-side features:
--   1) Auto Swing: repeatedly activates your equipped Tool (server cooldown still applies).
--   2) Auto Pickup: holds nearby enabled ProximityPrompts whose text suggests pickup.
-- Not implemented: rarity targeting, crystal collection, or teleport-to-base.
-- Those require the game's actual client/server object flow; guessing RemoteEvent names
-- would make the script unreliable and could risk your account.

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "PersonalEggHelperV5"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(260, 235)
panel.Position = UDim2.new(0.5, -130, 0.55, -117)
panel.BackgroundColor3 = Color3.fromRGB(35, 19, 58)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(174, 105, 255)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -42, 0, 38)
title.Position = UDim2.fromOffset(12, 4)
title.BackgroundTransparency = 1
title.Text = "EGG HELPER  •  V5"
title.TextColor3 = Color3.fromRGB(238, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local hide = Instance.new("TextButton")
hide.Size = UDim2.fromOffset(28, 28)
hide.Position = UDim2.new(1, -34, 0, 7)
hide.Text = "—"
hide.TextSize = 18
hide.Font = Enum.Font.GothamBold
hide.TextColor3 = Color3.new(1,1,1)
hide.BackgroundColor3 = Color3.fromRGB(104, 55, 155)
hide.Parent = panel
Instance.new("UICorner", hide).CornerRadius = UDim.new(0, 8)

local function makeToggle(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -24, 0, 40)
    b.Position = UDim2.fromOffset(12, y)
    b.BackgroundColor3 = Color3.fromRGB(73, 47, 100)
    b.TextColor3 = Color3.fromRGB(245, 235, 255)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.Text = text .. ": OFF"
    b.Parent = panel
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
    return b
end

local swingButton = makeToggle("Auto Swing", 54)
local pickupButton = makeToggle("Auto Pick Up", 102)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 58)
status.Position = UDim2.fromOffset(12, 154)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(205, 180, 230)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.Text = "Ready. Equip your pickaxe and stand near an egg."
status.Parent = panel

local minimized = false
local mini = Instance.new("TextButton")
mini.Size = UDim2.fromOffset(44, 44)
mini.Position = UDim2.new(0.86, 0, 0.35, 0)
mini.BackgroundColor3 = Color3.fromRGB(105, 54, 160)
mini.Text = "E"
mini.TextColor3 = Color3.new(1,1,1)
mini.Font = Enum.Font.GothamBold
mini.TextSize = 20
mini.Visible = false
mini.Parent = gui
Instance.new("UICorner", mini).CornerRadius = UDim.new(1, 0)

hide.MouseButton1Click:Connect(function()
    minimized = true
    panel.Visible = false
    mini.Visible = true
end)
mini.MouseButton1Click:Connect(function()
    minimized = false
    panel.Visible = true
    mini.Visible = false
end)

local autoSwing = false
local autoPickup = false
local swingThread = 0
local pickupThread = 0

local function setButton(button, label, enabled)
    button.Text = label .. (enabled and ": ON" or ": OFF")
    button.BackgroundColor3 = enabled and Color3.fromRGB(111, 57, 166) or Color3.fromRGB(73, 47, 100)
end

swingButton.MouseButton1Click:Connect(function()
    autoSwing = not autoSwing
    swingThread += 1
    local thisThread = swingThread
    setButton(swingButton, "Auto Swing", autoSwing)
    if autoSwing then
        task.spawn(function()
            while autoSwing and thisThread == swingThread do
                local character = player.Character
                local tool = character and character:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() tool:Activate() end)
                    status.Text = "Auto Swing active • equipped tool is being activated."
                else
                    status.Text = "Equip your pickaxe to start Auto Swing."
                end
                task.wait(0.22)
            end
        end)
    end
end)

local function isPickupPrompt(prompt)
    local text = string.lower((prompt.ActionText or "") .. " " .. (prompt.ObjectText or "") .. " " .. prompt.Name)
    return string.find(text, "pick") or string.find(text, "collect") or string.find(text, "take")
end

pickupButton.MouseButton1Click:Connect(function()
    autoPickup = not autoPickup
    pickupThread += 1
    local thisThread = pickupThread
    setButton(pickupButton, "Auto Pick Up", autoPickup)
    if autoPickup then
        task.spawn(function()
            while autoPickup and thisThread == pickupThread do
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, prompt in ipairs(workspace:GetDescendants()) do
                        if not (autoPickup and thisThread == pickupThread) then break end
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled and isPickupPrompt(prompt) then
                            local part = prompt.Parent
                            if part and part:IsA("BasePart") and (part.Position - root.Position).Magnitude <= (prompt.MaxActivationDistance + 1) then
                                pcall(function()
                                    prompt:InputHoldBegin()
                                    task.wait(math.max(prompt.HoldDuration, 0.25))
                                    prompt:InputHoldEnd()
                                end)
                            end
                        end
                    end
                end
                task.wait(0.35)
            end
        end)
    end
end)

gui.Destroying:Connect(function()
    autoSwing = false
    autoPickup = false
end)
