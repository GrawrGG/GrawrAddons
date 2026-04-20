local AddonName = ...

local SLOTS = {
    "HEADSLOT", "SHOULDERSLOT", "CHESTSLOT", "WAISTSLOT", "LEGSSLOT",
    "FEETSLOT", "WRISTSLOT", "HANDSSLOT", "MAINHANDSLOT", "SECONDARYHANDSLOT",
    "RANGEDSLOT",
}

local YELLOW_THRESHOLD = 0.25

local alert
local function CreateAlert()
    local alertFrame = CreateFrame("Frame", "BrokenGearAlert", UIParent)
    alertFrame:SetFrameStrata("HIGH")
    alertFrame:SetSize(600, 100)
    alertFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    alertFrame:Hide()

    local text = alertFrame:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 48, "THICKOUTLINE")
    text:SetPoint("CENTER")
    alertFrame.text = text

    local animGroup = alertFrame:CreateAnimationGroup()
    animGroup:SetLooping("REPEAT")

    local bounceUp = animGroup:CreateAnimation("Translation")
    bounceUp:SetOffset(0, 20)
    bounceUp:SetDuration(0.4)
    bounceUp:SetOrder(1)
    bounceUp:SetSmoothing("OUT")

    local bounceDown = animGroup:CreateAnimation("Translation")
    bounceDown:SetOffset(0, -20)
    bounceDown:SetDuration(0.4)
    bounceDown:SetOrder(2)
    bounceDown:SetSmoothing("IN")

    alertFrame.anim = animGroup
    return alertFrame
end

local function GetWorstDurability()
    local worst = 1
    local anyBroken = false
    for _, slotName in ipairs(SLOTS) do
        local slotId = GetInventorySlotInfo(slotName)
        local current, max = GetInventoryItemDurability(slotId)
        if current and max and max > 0 then
            if current == 0 then
                anyBroken = true
            end
            local ratio = current / max
            if ratio < worst then
                worst = ratio
            end
        end
    end
    return worst, anyBroken
end

local function UpdateAlert()
    if not alert then return end

    if InCombatLockdown() or UnitAffectingCombat("player") then
        alert.anim:Stop()
        alert:Hide()
        return
    end

    local worst, anyBroken = GetWorstDurability()

    if anyBroken then
        alert.text:SetText("Repair your gear!")
        alert.text:SetTextColor(1, 0.1, 0.1)
        alert:Show()
        if not alert.anim:IsPlaying() then alert.anim:Play() end
    elseif worst < YELLOW_THRESHOLD then
        alert.text:SetText("Your gear is broken!")
        alert.text:SetTextColor(1, 0.85, 0.1)
        alert:Show()
        if not alert.anim:IsPlaying() then alert.anim:Play() end
    else
        alert.anim:Stop()
        alert:Hide()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == AddonName then
        alert = CreateAlert()
    elseif event == "PLAYER_REGEN_DISABLED" then
        if alert then
            alert.anim:Stop()
            alert:Hide()
        end
    else
        UpdateAlert()
    end
end)
