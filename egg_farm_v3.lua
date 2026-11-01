-- EGG FARM V3 - draggable GUI and settings scaffold
-- The actual game's pickaxe-hit and crystal-pickup methods are unverified.
-- This file implements the interface; it does not claim to automate game actions.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local old = CoreGui:FindFirstChild("EggFarmV3")
if old then old:Destroy() end

local settings = {
    autoEggs = false, autoCrystals = false, speed = 100,
    rarities = {
        Common=true, Uncommon=true, Rare=true, Epic=true, Legendary=true,
        Mythic=true, Divine=true, Cosmic=true, Secret=true, Inferno=true
    }
}
_G.EggFarmV3Settings = settings

local gui = Instance.new("ScreenGui")
gui.Name = "EggFarmV3"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local function round(o, n)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,n or 10); c.Parent=o
end
local function outline(o)
    local s=Instance.new("UIStroke"); s.Color=Color3.fromRGB(155,110,255); s.Transparency=.15; s.Parent=o
end
local function drag(handle, target)
    local active, start, origin
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            active=true; start=i.Position; origin=target.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then active=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if active and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            target.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,origin.Y.Scale,origin.Y.Offset+d.Y)
        end
    end)
end

local main=Instance.new("Frame")
main.Size=UDim2.fromOffset(310,500); main.Position=UDim2.new(.5,-155,.5,-250)
main.BackgroundColor3=Color3.fromRGB(23,22,35); main.BorderSizePixel=0; main.Parent=gui
round(main,16); outline(main)

local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,52); header.BackgroundColor3=Color3.fromRGB(58,39,91)
header.BorderSizePixel=0; header.Parent=main; round(header,16); drag(header,main)

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-55,1,0); title.Position=UDim2.fromOffset(14,0)
title.BackgroundTransparency=1; title.Text="✦  EGG FARM V3"; title.TextColor3=Color3.new(1,1,1)
title.Font=Enum.Font.GothamBold; title.TextSize=18; title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=header

local mini=Instance.new("TextButton")
mini.Size=UDim2.fromOffset(34,34); mini.Position=UDim2.new(1,-43,0,9)
mini.Text="—"; mini.TextSize=20; mini.TextColor3=Color3.new(1,1,1)
mini.BackgroundColor3=Color3.fromRGB(112,77,170); mini.Parent=header; round(mini,9)

local function label(txt,y)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-24,0,20); l.Position=UDim2.fromOffset(12,y)
    l.BackgroundTransparency=1; l.Text=txt; l.TextColor3=Color3.fromRGB(196,178,231)
    l.Font=Enum.Font.GothamBold; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=main
end
local function btn(txt,x,y,w,h)
    local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(w,h); b.Position=UDim2.fromOffset(x,y)
    b.BackgroundColor3=Color3.fromRGB(65,53,91); b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.GothamSemibold; b.TextSize=12; b.Text=txt; b.Parent=main; round(b,8); return b
end

label("AUTOMATION",62)
local egg=btn("Auto Break Eggs  [OFF]",12,85,286,35)
local crystal=btn("Auto Collect Crystals  [OFF]",12,126,286,35)
local function toggle(b,key,name)
    settings[key]=not settings[key]
    b.Text=name.."  ["..(settings[key] and "ON" or "OFF").."]"
    b.BackgroundColor3=settings[key] and Color3.fromRGB(105,70,160) or Color3.fromRGB(65,53,91)
end
egg.MouseButton1Click:Connect(function() toggle(egg,"autoEggs","Auto Break Eggs") end)
crystal.MouseButton1Click:Connect(function() toggle(crystal,"autoCrystals","Auto Collect Crystals") end)

label("EGG RARITY • MULTI SELECT",170)
local names={"Common","Uncommon","Rare","Epic","Legendary","Mythic","Divine","Cosmic","Secret","Inferno"}
local rarityButtons={}
for i,name in ipairs(names) do
    local col=(i-1)%2; local row=math.floor((i-1)/2)
    local b=btn("✓ "..name,12+col*145,194+row*32,141,28)
    rarityButtons[name]=b
    b.MouseButton1Click:Connect(function()
        settings.rarities[name]=not settings.rarities[name]
        b.Text=(settings.rarities[name] and "✓ " or "○ ")..name
        b.BackgroundColor3=settings.rarities[name] and Color3.fromRGB(105,70,160) or Color3.fromRGB(43,42,55)
    end)
end

label("FARM SPEED  (1–1000)",360)
local value=Instance.new("TextLabel"); value.Size=UDim2.fromOffset(55,22); value.Position=UDim2.fromOffset(242,357)
value.BackgroundTransparency=1; value.Text=tostring(settings.speed); value.TextColor3=Color3.fromRGB(220,196,255)
value.Font=Enum.Font.GothamBold; value.TextSize=16; value.Parent=main
local bar=Instance.new("Frame"); bar.Size=UDim2.fromOffset(286,8); bar.Position=UDim2.fromOffset(12,386)
bar.BackgroundColor3=Color3.fromRGB(62,53,82); bar.BorderSizePixel=0; bar.Parent=main; round(bar,5)
local fill=Instance.new("Frame"); fill.Size=UDim2.new((settings.speed-1)/999,0,1,0)
fill.BackgroundColor3=Color3.fromRGB(174,130,255); fill.BorderSizePixel=0; fill.Parent=bar; round(fill,5)
local knob=Instance.new("TextButton"); knob.Size=UDim2.fromOffset(18,18); knob.AnchorPoint=Vector2.new(.5,.5)
knob.Position=UDim2.new((settings.speed-1)/999,0,.5,0); knob.Text=""; knob.BackgroundColor3=Color3.new(1,1,1); knob.Parent=bar; round(knob,9)
local sliding=false
local function setSpeed(x)
    local r=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
    settings.speed=math.clamp(math.floor(1+r*999+.5),1,1000)
    value.Text=tostring(settings.speed); fill.Size=UDim2.new(r,0,1,0); knob.Position=UDim2.new(r,0,.5,0)
end
knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true end end)
bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true; setSpeed(i.Position.X) end end)
UIS.InputChanged:Connect(function(i) if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setSpeed(i.Position.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end end)

local all=btn("SELECT ALL",12,416,139,30)
local none=btn("DESELECT ALL",159,416,139,30)
all.MouseButton1Click:Connect(function()
    for n,b in pairs(rarityButtons) do settings.rarities[n]=true; b.Text="✓ "..n; b.BackgroundColor3=Color3.fromRGB(105,70,160) end
end)
none.MouseButton1Click:Connect(function()
    for n,b in pairs(rarityButtons) do settings.rarities[n]=false; b.Text="○ "..n; b.BackgroundColor3=Color3.fromRGB(43,42,55) end
end)

local note=Instance.new("TextLabel"); note.Size=UDim2.new(1,-20,0,36); note.Position=UDim2.fromOffset(10,455)
note.BackgroundTransparency=1; note.Text="GUI + settings ready. Game-specific farm actions are not connected."
note.TextWrapped=true; note.TextColor3=Color3.fromRGB(255,205,130); note.Font=Enum.Font.Gotham; note.TextSize=9; note.Parent=main

local floater=Instance.new("TextButton"); floater.Size=UDim2.fromOffset(48,48)
floater.Position=UDim2.new(1,-70,.5,-24); floater.Text="✦"; floater.TextSize=23
floater.TextColor3=Color3.new(1,1,1); floater.BackgroundColor3=Color3.fromRGB(112,77,170)
floater.Visible=false; floater.Parent=gui; round(floater,12); outline(floater); drag(floater,floater)

mini.MouseButton1Click:Connect(function()
    main.Visible=false; floater.Visible=true
end)
floater.MouseButton1Click:Connect(function()
    floater.Visible=false; main.Visible=true
end)
