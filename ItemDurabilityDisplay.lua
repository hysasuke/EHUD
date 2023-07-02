local L = LibStub("AceLocale-3.0"):GetLocale("EHUD")

local _, core = ...; -- Namespace
local characterFrame = _G["CharacterFrame"];

local durabilityText = characterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
durabilityText:SetPoint("BOTTOMLEFT", characterFrame, "BOTTOMLEFT", 10, 10);
durabilityText:SetJustifyH("LEFT");
characterFrame:HookScript("OnUpdate", function()
    local _, _, percentage = GetEquipmentDurability("player");
    durabilityText:SetText(L["itemDurability"] .. ": " .. percentage .. "%");
    local color = { r = 0, g = 1, b = 0, a = 1 };

    if (percentage < 25) then
        color.r = 1;
        color.g = 0;
        color.b = 0;
    end
    if (percentage < 50) then
        color.r = 1;
        color.g = 1;
        color.b = 0;
    end

    durabilityText:SetTextColor(color.r, color.g, color.b, 1);
    if characterFrame.selectedTab == 1 and EHUD.db.profile.durabilityDisplay.enable then
        durabilityText:Show();
    else
        durabilityText:Hide();
    end
end)



durabilityText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
