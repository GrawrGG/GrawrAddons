local Burder = ...

local INSTANCE_ID = 2913
local ENCOUNTER_INDEX = 1
local JOURNAL_ENCOUNTER_ID = 2739
local BOSS_NAME = "Belo'ren"
local NOT_KILLED_TEXT = "You haven't committed burder yet this week."
local KILLED_TEXT = "Belo'ren is dead. Burderer!"
local IN_PROGRESS_TEXT = "Attempted burder in progress..."


local burderFrame, healthBar, healthText, statusText
local belorenEncounterActive = false

local function IsBelorenEncounter(encounterName)
    local localizedName = EJ_GetEncounterInfo(JOURNAL_ENCOUNTER_ID)
    return localizedName ~= nil and encounterName == localizedName
end

local function GetBelorenLiveHealthPct()
    if not belorenEncounterActive then return nil end
    if not UnitExists("boss1") then return nil end
    return UnitHealthPercent("boss1", true, CurveConstants.ScaleTo100)
end

local function HasKilledBeloren()
    for i = 1, GetNumSavedInstances() do
        local _, _, reset, _, locked, _, _, _, _, _, numEncounters, _, _, instanceID = GetSavedInstanceInfo(i)
        if instanceID == INSTANCE_ID and locked and reset and reset > 0
                and numEncounters and numEncounters >= ENCOUNTER_INDEX then
            local _, _, isKilled = GetSavedInstanceEncounterInfo(i, ENCOUNTER_INDEX)
            if isKilled then
                return true
            end
        end
    end
    return false
end

local function CreateUI()
    burderFrame = CreateFrame("Frame", "BurderFrame", UIParent)
    burderFrame:SetSize(320, 44)
    burderFrame:SetPoint("TOP", UIParent, "TOP", 0, -16)

    healthBar = CreateFrame("StatusBar", nil, burderFrame)
    healthBar:SetSize(320, 22)
    healthBar:SetPoint("TOP", burderFrame, "TOP", 0, 0)
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    healthBar:SetStatusBarColor(0.1, 0.7, 0.1)
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetValue(100)

    local barBg = healthBar:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints()
    barBg:SetColorTexture(0, 0, 0, 0.6)

    healthText = healthBar:CreateFontString(nil, "OVERLAY")
    healthText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    healthText:SetText(BOSS_NAME .. " — 100%")

    statusText = burderFrame:CreateFontString(nil, "OVERLAY")
    statusText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    statusText:SetPoint("TOP", healthBar, "BOTTOM", 0, -4)
    statusText:SetText(NOT_KILLED_TEXT)
end

local function UpdateState()
    local killedThisWeek = HasKilledBeloren()
    local livePct = GetBelorenLiveHealthPct()
    if livePct then
        statusText:SetText(IN_PROGRESS_TEXT)
        healthText:SetText(string.format("%s — %.2f%%", BOSS_NAME, livePct))
        healthBar:SetValue(livePct)
        healthBar:SetStatusBarColor(0.1, 0.7, 0.1)
    elseif killedThisWeek then
        statusText:SetText(KILLED_TEXT)
        healthText:SetText(BOSS_NAME .. " — 0%")
        healthBar:SetValue(0)
        healthBar:SetStatusBarColor(0.7, 0.1, 0.1)
    else
        statusText:SetText(NOT_KILLED_TEXT)
        healthText:SetText(BOSS_NAME .. " — 100%")
        healthBar:SetValue(100)
        healthBar:SetStatusBarColor(0.1, 0.7, 0.1)
    end
    burderFrame:Show()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_INSTANCE_INFO")
frame:RegisterEvent("BOSS_KILL")
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")
frame:RegisterEvent("UNIT_HEALTH")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" and ... == "Burder" then
        CreateUI()
        RequestRaidInfo()
        UpdateState()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_INSTANCE_INFO" then
        UpdateState()
    elseif event == "ENCOUNTER_START" then
        local _, encounterName = ...
        if IsBelorenEncounter(encounterName) then
            belorenEncounterActive = true
            UpdateState()
        end
    elseif event == "UNIT_HEALTH" then
        local unit = ...
        if unit == "boss1" then
            UpdateState()
        end
    elseif event == "BOSS_KILL" or event == "ENCOUNTER_END" then
        belorenEncounterActive = false
        RequestRaidInfo()
        UpdateState()
    end
end)
