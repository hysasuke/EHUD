local L = LibStub("AceLocale-3.0"):GetLocale("EHUD")

local _, core = ...; -- Namespace
local characterFrame = _G["CharacterFrame"];
local IDD = {};
core.IDD = IDD;

local frame = CreateFrame("Frame", nil, UIParent);
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
-- local durabilityText = characterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
-- durabilityText:SetPoint("BOTTOMLEFT", characterFrame, "BOTTOMLEFT", 10, 10);
-- durabilityText:SetJustifyH("LEFT");
-- durabilityText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");

local characterStatsPane = _G["CharacterStatsPane"];

function IDD:CreateStatScrollFrame()
    -- Create scroll view
    local StatScrollFrame = CreateFrame("ScrollFrame", nil, CharacterFrameInsetRight, "UIPanelScrollFrameTemplate")
    StatScrollFrame:ClearAllPoints()
    StatScrollFrame:SetPoint("TOPLEFT", CharacterFrameInsetRight, "TOPLEFT", 5, -6)
    StatScrollFrame:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "BOTTOMRIGHT", 0, 3)

    StatScrollFrame.ScrollBar:ClearAllPoints()
    StatScrollFrame.ScrollBar:SetParent(StatScrollFrame)
    StatScrollFrame.ScrollBar:SetPoint("TOPLEFT", StatScrollFrame, "TOPRIGHT", -16, -16)
    StatScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", StatScrollFrame, "BOTTOMRIGHT", -16, 16)
    StatScrollFrame.ScrollBar:Hide()
    StatScrollFrame:HookScript("OnScrollRangeChanged", function(self, xrange, yrange)
        self.ScrollBar:Hide()
    end)

    local StatFrame = CreateFrame("Frame", nil, StatScrollFrame)
    StatFrame:SetSize(191, characterStatsPane:GetHeight())
    StatFrame:SetPoint("TOPLEFT", StatScrollFrame, "TOPLEFT", 0, 0)
    StatScrollFrame:SetScrollChild(StatFrame)

    characterStatsPane:SetParent(StatFrame);

    -- Create durablity category
    local itemLevelFrame = characterStatsPane.ItemLevelCategory;
    itemLevelFrame:ClearAllPoints();
    local itemDurabilityCategory = CreateFrame("Frame", nil, characterStatsPane,
        "CharacterStatFrameCategoryTemplate");
    itemDurabilityCategory:SetPoint("TOP", StatFrame, "TOP", 0, 0);
    characterStatsPane.ItemDurabilityCategory = itemDurabilityCategory;
    itemDurabilityCategory.Title:SetText(L["itemDurability"]);

    itemDurabilityCategory.DurabilityFrame = CreateFrame("Frame", nil, itemDurabilityCategory,
        "CharacterStatFrameTemplate");
    itemDurabilityCategory.DurabilityFrame:SetPoint("TOP", itemDurabilityCategory, "BOTTOM", 0, -2);
    itemDurabilityCategory.DurabilityFrame.Label:ClearAllPoints();
    itemDurabilityCategory.DurabilityFrame.Label:SetPoint("CENTER", itemDurabilityCategory.DurabilityFrame, "CENTER", 0,
        0);

    itemLevelFrame:SetPoint("TOP", itemDurabilityCategory.DurabilityFrame, "BOTTOM", 0, 0);


    characterFrame:HookScript("OnUpdate", function()
        local _, _, percentage = GetEquipmentDurability("player");
        -- durabilityText:SetText(L["itemDurability"] .. ": " .. percentage .. "%");
        local color = GetDurablityColor(percentage);

        itemDurabilityCategory.DurabilityFrame.Label:SetText(percentage .. "%");
        itemDurabilityCategory.DurabilityFrame.Label:SetTextColor(color.r, color.g, color.b, 1);
        -- durabilityText:SetTextColor(color.r, color.g, color.b, 1);
        -- if characterFrame.selectedTab == 1 and EHUD.db.profile.durabilityDisplay.enable then
        --     durabilityText:Show();
        -- else
        --     durabilityText:Hide();
        -- end
    end)

    -- Setup tooltip to display every item's durability
    itemDurabilityCategory.DurabilityFrame:HookScript("OnEnter", function()
        GameTooltip:SetOwner(itemDurabilityCategory.DurabilityFrame, "ANCHOR_RIGHT");
        GameTooltip:SetText(L["itemDurability"]);
        GameTooltip:AddLine(" ");
        for i = 1, 18 do
            local itemID = GetInventoryItemID("player", i);
            if itemID then
                local slotName = GetItemInfo(itemID);
                local current, max = GetInventoryItemDurability(i);
                if (current ~= nil and max ~= nil) then
                    local percentage = math.floor(current / max * 100);
                    local color = GetDurablityColor(percentage);

                    GameTooltip:AddDoubleLine(slotName, percentage .. "%", 1, 1, 1, color.r, color.g, color.b);
                end
            end
        end
        GameTooltip:Show();
    end)
end

frame:SetScript("OnEvent", function(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        IDD:CreateStatScrollFrame();
    end
end)

function GetDurablityColor(durability)
    local color = { r = 0, g = 1, b = 0, a = 1 };

    if (durability < 25) then
        color.r = 1;
        color.g = 0;
        color.b = 0;
    end
    if (durability < 50) then
        color.r = 1;
        color.g = 1;
        color.b = 0;
    end

    return color;
end
