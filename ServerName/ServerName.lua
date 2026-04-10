-- ServerName: displays the current realm name below the minimap's top border,
-- so characters spread across many realms can tell at a glance which one they're on.

local _, ns = ...

local function CreateRealmLabel()
    local anchor = MinimapCluster.BorderTop
    local label = MinimapCluster:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOP", anchor, "BOTTOM", 0, -0.5)
    return label
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if not ns.label then
            ns.label = CreateRealmLabel()
        end
        ns.label:SetText(GetRealmName())
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
