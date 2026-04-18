-- ╔══════════════════════════════════════════════════════════════════╗
-- ║                  PuppyUI  ·  Example.lua                       ║
-- ║      Copy this file and build your script from it              ║
-- ╚══════════════════════════════════════════════════════════════════╝

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/coldfundss/Librarys/refs/heads/main/Library.lua"))()

-- ─────────────────────────────────────────────────────────────────
-- WINDOW
-- ─────────────────────────────────────────────────────────────────
local UI = Library.new("example ui", "v1.0")

-- INSERT key toggles the window
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        UI:Toggle()
    end
end)

-- ─────────────────────────────────────────────────────────────────
-- TABS
-- ─────────────────────────────────────────────────────────────────
local tabMain     = UI:AddTab("main")
local tabVisuals  = UI:AddTab("visuals")
local tabMisc     = UI:AddTab("misc")
local tabSettings = UI:AddTab("settings")

-- ─────────────────────────────────────────────────────────────────
-- MAIN
-- ─────────────────────────────────────────────────────────────────
local sGeneral = UI:AddSection(tabMain, "general")

sGeneral:AddToggle("example toggle", false, function(v)
    -- your code here
end)

sGeneral:AddToggle("another toggle", true, function(v)
    -- your code here
end)

sGeneral:AddSeparator()

local speedSlider = sGeneral:AddSlider("speed", 0, 100, 50, function(v)
    -- your code here
end)

local intensitySlider = sGeneral:AddSlider("intensity", 0, 100, 30, function(v)
    -- your code here
end)

sGeneral:AddSeparator()

local modeDropdown = sGeneral:AddDropdown("mode", {
    "option one", "option two", "option three"
}, "option one", function(v)
    -- your code here
end)

-- ──────────────────────────────────────────
local sActions = UI:AddSection(tabMain, "actions")

sActions:AddButton("button one", function()
    UI:Notify("action", "button one was clicked", 2.5)
end)

sActions:AddButton("button two", function()
    UI:Notify("action", "button two was clicked", 2.5)
end)

sActions:AddSeparator()

local mainKeybind = sActions:AddKeybind("keybind", Enum.KeyCode.F, function(k)
    -- your code here
end)

local mainColor = sActions:AddColorpicker("color", Color3.fromHex("7c5cbf"), function(c)
    -- your code here
end)

-- ─────────────────────────────────────────────────────────────────
-- VISUALS
-- ─────────────────────────────────────────────────────────────────
local sDisplay = UI:AddSection(tabVisuals, "display")

local espEnabled  = sDisplay:AddToggle("esp enabled",  false, function(v) end)
local showNames   = sDisplay:AddToggle("show names",   true,  function(v) end)
local showBoxes   = sDisplay:AddToggle("show boxes",   false, function(v) end)
local showBones   = sDisplay:AddToggle("show bones",   false, function(v) end)
local showHealth  = sDisplay:AddToggle("show health",  true,  function(v) end)

sDisplay:AddSeparator()

local espDistance = sDisplay:AddSlider("esp distance", 0, 500, 200, function(v) end)
local espColor    = sDisplay:AddColorpicker("esp color", Color3.fromHex("9b7de0"), function(c) end)

-- ──────────────────────────────────────────
local sRendering = UI:AddSection(tabVisuals, "rendering")

local fullbright = sRendering:AddToggle("fullbright", false, function(v)
    if v then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime  = 14
    end
end)

local noFog = sRendering:AddToggle("no fog", false, function(v)
    game:GetService("Lighting").FogEnd = v and 1e6 or 100000
end)

sRendering:AddSeparator()

local renderStyle  = sRendering:AddDropdown("render style", {"default","wireframe","outlined"}, "default", function(v) end)
local transparency = sRendering:AddSlider("transparency", 0, 9, 5, function(v) end)

-- ─────────────────────────────────────────────────────────────────
-- MISC
-- ─────────────────────────────────────────────────────────────────
local sMovement = UI:AddSection(tabMisc, "movement")

local speedEnabled = sMovement:AddToggle("speed enabled", false, function(v) end)
local speedValue   = sMovement:AddSlider("speed value", 0, 1000, 100, function(v) end)
local speedKey     = sMovement:AddKeybind("speed keybind", Enum.KeyCode.V, function(k) end)

sMovement:AddSeparator()

local bhop        = sMovement:AddToggle("bhop",        false, function(v) end)
local strafeJump  = sMovement:AddToggle("strafe jump", false, function(v) end)

-- ──────────────────────────────────────────
local sUtilities = UI:AddSection(tabMisc, "utilities")

local autoClicker    = sUtilities:AddToggle("auto clicker",     false, function(v) end)
local autoClickerKey = sUtilities:AddKeybind("auto clicker key", Enum.KeyCode.B, function(k) end)

sUtilities:AddSeparator()

sUtilities:AddButton("example action", function()
    UI:Notify("misc", "action triggered", 2.5)
end)

sUtilities:AddButton("another action", function()
    UI:Notify("misc", "another action triggered", 2.5)
end)

-- ─────────────────────────────────────────────────────────────────
-- SETTINGS
-- ─────────────────────────────────────────────────────────────────
local sConfig = UI:AddSection(tabSettings, "config")

sConfig:AddButton("save config", function()
    UI:Notify("config", "config saved", 2)
end)

sConfig:AddButton("load config", function()
    UI:Notify("config", "config loaded", 2)
end)

sConfig:AddButton("reset config", function()
    UI:Notify("config", "config reset to defaults", 2)
    speedSlider.SetValue(50)
    intensitySlider.SetValue(30)
    speedValue.SetValue(100)
    transparency.SetValue(5)
    espDistance.SetValue(200)
    espEnabled.SetState(false)
    showNames.SetState(true)
    showBoxes.SetState(false)
    showBones.SetState(false)
    showHealth.SetState(true)
    fullbright.SetState(false)
    noFog.SetState(false)
    bhop.SetState(false)
    strafeJump.SetState(false)
    autoClicker.SetState(false)
    speedEnabled.SetState(false)
end)

sConfig:AddSeparator()

local configSlot = sConfig:AddDropdown("config slot", {"slot 1","slot 2","slot 3"}, "slot 1", function(v) end)

-- ──────────────────────────────────────────
local sUiSettings = UI:AddSection(tabSettings, "ui settings")

local notifications = sUiSettings:AddToggle("notifications", true, function(v) end)
local uiToggleKey   = sUiSettings:AddKeybind("ui toggle key", Enum.KeyCode.Insert, function(k) end)

sUiSettings:AddSeparator()

local accentPicker = sUiSettings:AddColorpicker("accent color", Color3.fromHex("7c5cbf"), function(c)
    UI.Theme.accent  = c
    UI.Theme.accent2 = c
end)

local uiScale = sUiSettings:AddSlider("ui scale", 80, 120, 100, function(v)
    local s = v / 100
    UI.Window.Size     = UDim2.new(0, math.round(640*s), 0, math.round(420*s))
    UI.Window.Position = UDim2.new(0.5, -math.round(320*s), 0.5, -math.round(210*s))
end)

-- ─────────────────────────────────────────────────────────────────
task.wait(0.6)
UI:Notify("puppy ui", "loaded successfully", 3)
