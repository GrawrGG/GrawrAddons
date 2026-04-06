local _ = ...

local SOULSTONE_SPELL_ID = 20707
local WHISPER_MESSAGE = "Hey, no soulstone is out — can you soulstone a healer before the pull? Thanks!"

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
    if groupHasSoulstone() then return end

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
