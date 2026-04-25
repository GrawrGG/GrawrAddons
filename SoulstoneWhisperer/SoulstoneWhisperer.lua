local SOULSTONE_SPELL_ID = 20707
local LFR_DIFFICULTY_ID = 17
local WHISPER_MESSAGE = "Don't forget to soulstone a healer before pull"
local SELF_MESSAGE = "Soulstone a healer!"

local function IsPlayerWarlock()
    local _, class = UnitClass("player")
    return class == "WARLOCK"
end

local function AlertSelf()
    RaidNotice_AddMessage(RaidWarningFrame, SELF_MESSAGE, ChatTypeInfo["RAID_WARNING"])
    PlaySound(SOUNDKIT.RAID_WARNING)
    print(SELF_MESSAGE)
end

local function IsLFR()
    local _, _, difficultyID = GetInstanceInfo()
    return difficultyID == LFR_DIFFICULTY_ID
end

local function IsInRaidInstance()
    local _, instanceType = IsInInstance()
    return instanceType == "raid"
end

local function HasSoulstone(unit)
    local i = 1
    while true do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
        if not aura then break end
        if aura.spellId == SOULSTONE_SPELL_ID then return true end
        i = i + 1
    end
    return false
end

local function HealerHasSoulstone()
    for i = 1, GetNumGroupMembers() do
        local unit = "raid" .. i
        if UnitGroupRolesAssigned(unit) == "HEALER" and HasSoulstone(unit) then
            return true
        end
    end
    return false
end

local function GetGroupWarlocks()
    local warlocks = {}

    local function CheckUnitIsWarlock(unit)
        local _, class = UnitClass(unit)
        if class == "WARLOCK" and UnitIsConnected(unit) then
            table.insert(warlocks, GetUnitName(unit, true))
        end
    end

    for i = 1, GetNumGroupMembers() do
        CheckUnitIsWarlock("raid" .. i)
    end

    return warlocks
end

local function OnReadyCheck()
    if not IsInRaid() then return end

    if not IsInRaidInstance() then return end

    if IsLFR() then return end

    if HealerHasSoulstone() then return end

    -- Don't bother other warlocks if we can soulstone a healer ourselves
    if IsPlayerWarlock() then
        AlertSelf()
        return
    end

    local warlocks = GetGroupWarlocks()
    for _, name in ipairs(warlocks) do
        C_ChatInfo.SendChatMessage(WHISPER_MESSAGE, "WHISPER", nil, name)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("READY_CHECK")
frame:SetScript("OnEvent", function()
    OnReadyCheck()
end)
