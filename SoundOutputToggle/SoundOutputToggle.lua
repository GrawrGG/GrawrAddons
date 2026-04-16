local AddonName, ns = ...

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local ICON = "Interface\\COMMON\\VoiceChat-Speaker"

local function GetDevices()
    local devices = {}
    local count = Sound_GameSystem_GetNumOutputDrivers()
    for i = 0, count - 1 do
        devices[#devices + 1] = {
            index = i,
            name = Sound_GameSystem_GetOutputDriverNameByIndex(i),
        }
    end
    return devices
end

local function GetCurrentIndex()
    return tonumber(GetCVar("Sound_OutputDriverIndex")) or 0
end

local function ApplyDevice(index)
    SetCVar("Sound_OutputDriverIndex", index)
    if Sound_GameSystem_RestartSoundSystem then
        Sound_GameSystem_RestartSoundSystem()
    end
end

local function IsEnabled(name)
    local v = SoundOutputToggleDB.enabled[name]
    if v == nil then return true end
    return v
end

local function GetEnabledDevices()
    local enabled = {}
    for _, d in ipairs(GetDevices()) do
        if IsEnabled(d.name) then
            enabled[#enabled + 1] = d
        end
    end
    return enabled
end

local function Notify(msg)
    print("|cff88ccffSoundOutputToggle|r: " .. msg)
end

local function CycleDevice()
    local enabled = GetEnabledDevices()
    if #enabled < 2 then
        Notify("need at least 2 enabled devices to cycle (right-click to configure).")
        return
    end
    local current = GetCurrentIndex()
    local pos = 1
    for i, d in ipairs(enabled) do
        if d.index == current then pos = i; break end
    end
    local next = enabled[(pos % #enabled) + 1]
    ApplyDevice(next.index)
    Notify("switched to " .. next.name)
end

local function BuildContextMenu(_owner, root)
    root:CreateTitle("Sound Output Devices")
    for _, d in ipairs(GetDevices()) do
        local name = d.name
        root:CreateCheckbox(
            name,
            function() return IsEnabled(name) end,
            function() SoundOutputToggleDB.enabled[name] = not IsEnabled(name) end
        )
    end
end

local dataObj = LDB:NewDataObject("SoundOutputToggle", {
    type = "launcher",
    icon = ICON,
    OnClick = function(self, button)
        if button == "LeftButton" then
            CycleDevice()
        elseif button == "RightButton" then
            MenuUtil.CreateContextMenu(self, BuildContextMenu)
        end
    end,
    OnTooltipShow = function(tt)
        local current = GetCurrentIndex()
        local name = Sound_GameSystem_GetOutputDriverNameByIndex(current) or "Unknown"
        tt:AddLine("SoundOutputToggle")
        tt:AddLine("Current: " .. name, 1, 1, 1)
        tt:AddLine(" ")
        tt:AddLine("Left-click: cycle enabled devices", 0, 1, 0)
        tt:AddLine("Right-click: enable/disable devices", 0, 1, 0)
    end,
})

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_self, event, ...)
    if event == "ADDON_LOADED" and ... == "SoundOutputToggle" then
        SoundOutputToggleDB = SoundOutputToggleDB or {}
        SoundOutputToggleDB.enabled = SoundOutputToggleDB.enabled or {}
        SoundOutputToggleDB.minimap = SoundOutputToggleDB.minimap or { hide = false }
        LDBIcon:Register("SoundOutputToggle", dataObj, SoundOutputToggleDB.minimap)
    end
end)
