local _ = ...

local SOULSTONE_SPELL_ID = 20707
local LFR_DIFFICULTY_ID = 17
local WHISPER_MESSAGE = "Don't forget to soulstone a healer before pull"
local SELF_MESSAGE = "Soulstone a healer!"

local function isPlayerWarlock()
    local _, class = UnitClass("player")
    return class == "WARLOCK"
end

local function alertSelf()
    RaidNotice_AddMessage(RaidWarningFrame, SELF_MESSAGE, ChatTypeInfo["RAID_WARNING"])
    PlaySound(SOUNDKIT.RAID_WARNING)
    print(SELF_MESSAGE)
end

local function isLFR()
    local _, _, difficultyID = GetInstanceInfo()
    return difficultyID == LFR_DIFFICULTY_ID
end

local function hasSoulstone(unit)
    local i = 1
    while true do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
        if not aura then break end
        if aura.spellId == SOULSTONE_SPELL_ID then return true end
        i = i + 1
    end
    return false
end

local function groupHasSoulstone()
    for i = 1, GetNumGroupMembers() do
        if hasSoulstone("raid" .. i) then return true end
    end
    return false
end

local function getGroupWarlocks()
    local warlocks = {}

    local function checkUnit(unit)
        local _, class = UnitClass(unit)
        if class == "WARLOCK" and UnitIsConnected(unit) then
            table.insert(warlocks, GetUnitName(unit, true))
        end
    end

    for i = 1, GetNumGroupMembers() do
        checkUnit("raid" .. i)
    end

    return warlocks
end

local function onReadyCheck()
    if not IsInRaid() then return end

    if isLFR() then return end

    if groupHasSoulstone() then return end

    -- Don't bother other warlocks if we can soulstone a healer ourselves
    if isPlayerWarlock() then
        alertSelf()
        return
    end

    local warlocks = getGroupWarlocks()
    for _, name in ipairs(warlocks) do
        C_ChatInfo.SendChatMessage(WHISPER_MESSAGE, "WHISPER", nil, name)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("READY_CHECK")
frame:SetScript("OnEvent", function()
    onReadyCheck()
end)
