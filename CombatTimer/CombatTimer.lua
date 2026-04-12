-- CombatTimer
-- Shows mm:ss time-in-combat in instances. Continues running if the player
-- dies during a boss encounter (until ENCOUNTER_END). When combat ends the
-- timer freezes and dims to indicate the final time. Hides on instance exit.

local AddonName, ns = ...

-- ============================================================
-- Configuration
-- ============================================================
local STOPPED_COLOR_R, STOPPED_COLOR_G, STOPPED_COLOR_B = 1, 1, 0  -- #FFFF00
local STOPPED_ALPHA = 0.6
local RUNNING_ALPHA = 1.0
local TICK_INTERVAL = 0.25
local FLASH_LOW_ALPHA = 0.15
local FLASH_DOWN_DELAY = 0.1
local FLASH_UP_DELAY = 0.2

-- ============================================================
-- State
-- ============================================================
local state = "idle"  -- "idle" | "running" | "stopped"
local startTime = nil
local stoppedElapsed = nil
local inEncounter = false
local ticker = nil
local flashGen = 0

-- ============================================================
-- Frame
-- ============================================================
local frame = CreateFrame("Frame", "CombatTimerFrame", UIParent)
frame:SetSize(120, 24)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
frame:Hide()

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetAllPoints(frame)
text:SetText("0:00")

-- ============================================================
-- Display helpers
-- ============================================================
local function FormatTime(seconds)
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%d:%02d", m, s)
end

local function ApplyRunningStyle()
    text:SetFontObject("GameFontNormalLarge")
    -- Force the default normal font color in case a previous SetTextColor stuck
    local c = NORMAL_FONT_COLOR
    text:SetTextColor(c.r, c.g, c.b)
    text:SetAlpha(RUNNING_ALPHA)
end

local function ApplyStoppedStyle()
    text:SetTextColor(STOPPED_COLOR_R, STOPPED_COLOR_G, STOPPED_COLOR_B)
    -- Brief flash: full alpha -> near-zero -> settled dim
    flashGen = flashGen + 1
    local gen = flashGen
    text:SetAlpha(1.0)
    C_Timer.After(FLASH_DOWN_DELAY, function()
        if flashGen == gen and state == "stopped" then
            text:SetAlpha(FLASH_LOW_ALPHA)
        end
    end)
    C_Timer.After(FLASH_UP_DELAY, function()
        if flashGen == gen and state == "stopped" then
            text:SetAlpha(STOPPED_ALPHA)
        end
    end)
end

local function UpdateText()
    local elapsed
    if state == "running" then
        elapsed = GetTime() - startTime
    elseif state == "stopped" then
        elapsed = stoppedElapsed
    else
        return
    end
    text:SetText(FormatTime(elapsed))
end

-- ============================================================
-- Ticker
-- ============================================================
local function StartTicker()
    if ticker then ticker:Cancel() end
    ticker = C_Timer.NewTicker(TICK_INTERVAL, UpdateText)
end

local function StopTicker()
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
end

-- ============================================================
-- Instance / visibility
-- ============================================================
local function IsInValidInstance()
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return false end
    return instanceType == "party" or instanceType == "raid"
        or instanceType == "pvp" or instanceType == "arena"
        or instanceType == "scenario"
end

local function UpdateFrameVisibility()
    if not IsInValidInstance() then
        frame:Hide()
        return
    end
    if state == "idle" then
        frame:Hide()
    else
        frame:Show()
    end
end

-- ============================================================
-- State transitions
-- ============================================================
local function StartTimer()
    state = "running"
    startTime = GetTime()
    stoppedElapsed = nil
    ApplyRunningStyle()
    text:SetText("0:00")
    StartTicker()
end

local function StopTimer()
    if state ~= "running" then return end
    stoppedElapsed = GetTime() - startTime
    state = "stopped"
    StopTicker()
    UpdateText()
    ApplyStoppedStyle()
end

local function ResetTimer()
    state = "idle"
    startTime = nil
    stoppedElapsed = nil
    inEncounter = false
    StopTicker()
end

-- ============================================================
-- Edit mode integration
-- ============================================================
-- The library calls EditModeStartMock/EditModeStopMock on the registered
-- frame when entering/leaving edit mode. We use them to force the frame
-- visible with a sample value so it can be selected and dragged even when
-- the player is out of combat (or out of an instance entirely).
function frame:EditModeStartMock()
    self.editModeWasShown = self:IsShown()
    ApplyRunningStyle()
    text:SetText("0:00")
    self:Show()
end

function frame:EditModeStopMock()
    -- Restore the real display based on current state
    if state == "running" then
        ApplyRunningStyle()
        UpdateText()
    elseif state == "stopped" then
        text:SetTextColor(STOPPED_COLOR_R, STOPPED_COLOR_G, STOPPED_COLOR_B)
        text:SetAlpha(STOPPED_ALPHA)
        UpdateText()
    end
    UpdateFrameVisibility()
end

local function RegisterEditMode()
    local lib = LibStub and LibStub("FerrozEditModeLib-1.0", true)
    if lib and lib.Register then
        if not CombatTimerDB then CombatTimerDB = {} end
        lib:Register(frame, CombatTimerDB, { width = 120, height = 24 })
    end
end

-- ============================================================
-- Events
-- ============================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("ENCOUNTER_START")
eventFrame:RegisterEvent("ENCOUNTER_END")

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == AddonName then
            RegisterEditMode()
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        if not IsInValidInstance() then
            ResetTimer()
        end
        UpdateFrameVisibility()
    elseif event == "PLAYER_REGEN_DISABLED" then
        if IsInValidInstance() then
            StartTimer()
            UpdateFrameVisibility()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if not inEncounter then
            StopTimer()
        end
    elseif event == "ENCOUNTER_START" then
        inEncounter = true
        if state ~= "running" and IsInValidInstance() then
            StartTimer()
            UpdateFrameVisibility()
        end
    elseif event == "ENCOUNTER_END" then
        inEncounter = false
        StopTimer()
    end
end)
