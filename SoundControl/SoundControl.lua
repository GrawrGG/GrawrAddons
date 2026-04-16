local AddonName = ...

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local ICON = "Interface\\COMMON\\VoiceChat-Speaker"
local VOLUME_STEPS = { 0.1, 0.25, 0.5, 0.75, 1.0 }

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
    local isEnabled = SoundControlDB.enabled[name]
    if isEnabled == nil then return true end
    return isEnabled
end

local function GetEnabledDevices()
    local enabled = {}
    for _, device in ipairs(GetDevices()) do
        if IsEnabled(device.name) then
            enabled[#enabled + 1] = device
        end
    end
    return enabled
end

local function Notify(msg)
    print("|cff88ccffSoundControl|r: " .. msg)
end

local function GetMasterVolume()
    return tonumber(GetCVar("Sound_MasterVolume")) or 1.0
end

local function CycleVolume()
    local current = GetMasterVolume()
    local next = VOLUME_STEPS[1]
    for _, step in ipairs(VOLUME_STEPS) do
        if step > current + 0.0001 then
            next = step
            break
        end
    end
    SetCVar("Sound_MasterVolume", next)
    Notify(string.format("volume set to %d%%", math.floor(next * 100 + 0.5)))
end

local function CycleDevice()
    local enabledDevices = GetEnabledDevices()
    if #enabledDevices < 2 then
        Notify("need at least 2 enabled devices to cycle (right-click to configure).")
        return
    end
    local current = GetCurrentIndex()
    local pos = 1
    for i, device in ipairs(enabledDevices) do
        if device.index == current then pos = i; break end
    end
    local next = enabledDevices[(pos % #enabledDevices) + 1]
    ApplyDevice(next.index)
    Notify("switched to " .. next.name)
end

local function BuildContextMenu(_, root)
    root:CreateTitle("Sound Output Devices")
    for _, device in ipairs(GetDevices()) do
        local name = device.name
        root:CreateCheckbox(
            name,
            function() return IsEnabled(name) end,
            function() SoundControlDB.enabled[name] = not IsEnabled(name) end
        )
    end
end

local dataObj = LDB:NewDataObject(AddonName, {
    type = "launcher",
    icon = ICON,
    OnClick = function(self, button)
        if button == "LeftButton" then
            if IsControlKeyDown() then
                CycleDevice()
            else
                CycleVolume()
            end
        elseif button == "RightButton" then
            MenuUtil.CreateContextMenu(self, BuildContextMenu)
        end
    end,
    OnTooltipShow = function(tt)
        local current = GetCurrentIndex()
        local name = Sound_GameSystem_GetOutputDriverNameByIndex(current) or "Unknown"
        local vol = math.floor(GetMasterVolume() * 100 + 0.5)
        tt:AddLine("SoundControl")
        tt:AddLine("Device: " .. name, 1, 1, 1)
        tt:AddLine("Volume: " .. vol .. "%", 1, 1, 1)
        tt:AddLine(" ")
        tt:AddLine("Left-click: cycle master volume", 0, 1, 0)
        tt:AddLine("Ctrl+Left-click: cycle enabled devices", 0, 1, 0)
        tt:AddLine("Right-click: enable/disable devices", 0, 1, 0)
    end,
})

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" and ... == AddonName then
        SoundControlDB = SoundControlDB or {}
        SoundControlDB.enabled = SoundControlDB.enabled or {}
        SoundControlDB.minimap = SoundControlDB.minimap or { hide = false }
        LDBIcon:Register(AddonName, dataObj, SoundControlDB.minimap)
    end
end)
