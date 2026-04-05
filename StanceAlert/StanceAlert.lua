-- StanceAlert
-- Shows a red X warning when a Warrior is in the wrong stance for their spec.
--   DPS (Arms/Fury): warns when in Defensive Stance
--   Prot:            warns when NOT in Defensive Stance

local PROT_SPEC_ID = 73
-- Defensive Stance spell ID (retail, The War Within / Dragonflight+)
local DEFENSIVE_STANCE_SPELL_ID = 386208

-- ============================================================
-- Build the indicator frame (300x300 red X, 25% alpha, centered)
-- ============================================================
local indicator = CreateFrame("Frame", "StanceAlertIndicator", UIParent)
indicator:SetSize(300, 300)
indicator:SetPoint("CENTER")
indicator:SetAlpha(0.25)
indicator:SetFrameStrata("HIGH")

-- Two diagonal lines forming an X
local line1 = indicator:CreateLine(nil, "OVERLAY")
line1:SetColorTexture(1, 0, 0, 1)
line1:SetThickness(30)
line1:SetStartPoint("TOPLEFT", indicator, 0, 0)
line1:SetEndPoint("BOTTOMRIGHT", indicator, 0, 0)

local line2 = indicator:CreateLine(nil, "OVERLAY")
line2:SetColorTexture(1, 0, 0, 1)
line2:SetThickness(30)
line2:SetStartPoint("TOPRIGHT", indicator, 0, 0)
line2:SetEndPoint("BOTTOMLEFT", indicator, 0, 0)

indicator:Hide()

-- ============================================================
-- Logic helpers
-- ============================================================
local function IsWarrior()
    return select(2, UnitClass("player")) == "WARRIOR"
end

local function GetCurrentSpecID()
    local specIndex = GetSpecialization()
    if not specIndex then return nil end
    return (GetSpecializationInfo(specIndex)) -- first return value is the spec ID
end

local function IsInDefensiveStance()
    local currentForm = GetShapeshiftForm()
    if currentForm == 0 then return false end
    local _, _, _, spellID = GetShapeshiftFormInfo(currentForm)
    return spellID == DEFENSIVE_STANCE_SPELL_ID
end

local function ShouldShowAlert()
    if not IsWarrior() then return false end

    local specID = GetCurrentSpecID()
    if not specID then return false end

    local inDefStance = IsInDefensiveStance()

    if specID == PROT_SPEC_ID then
        -- Prot should always be in Defensive Stance
        return not inDefStance
    else
        -- Arms / Fury should NOT be in Defensive Stance
        return inDefStance
    end
end

local function UpdateDisplay()
    if ShouldShowAlert() then
        indicator:Show()
    else
        indicator:Hide()
    end
end

-- ============================================================
-- Event registration
-- ============================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

eventFrame:SetScript("OnEvent", function()
    UpdateDisplay()
end)
