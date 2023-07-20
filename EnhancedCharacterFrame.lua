local L = LibStub("AceLocale-3.0"):GetLocale("EHUD")

local _, core = ...; -- Namespace
local characterFrame = _G["CharacterFrame"];
local ECF = {};
core.ECF = ECF;

local INVSLOT_ID_MAP = {
    [1] = "HeadSlot",
    [2] = "NeckSlot",
    [3] = "ShoulderSlot",
    [4] = "ShirtSlot",
    [5] = "ChestSlot",
    [6] = "WaistSlot",
    [7] = "LegsSlot",
    [8] = "FeetSlot",
    [9] = "WristSlot",
    [10] = "HandsSlot",
    [11] = "Finger0Slot",
    [12] = "Finger1Slot",
    [13] = "Trinket0Slot",
    [14] = "Trinket1Slot",
    [15] = "BackSlot",
    [16] = "MainHandSlot",
    [17] = "SecondaryHandSlot",
    [18] = "RangedSlot",
}

local frame = CreateFrame("Frame", nil, UIParent);
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("UPDATE_UI_WIDGET");
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
-- local durabilityText = characterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
-- durabilityText:SetPoint("BOTTOMLEFT", characterFrame, "BOTTOMLEFT", 10, 10);
-- durabilityText:SetJustifyH("LEFT");
-- durabilityText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");

local characterStatsPane = _G["CharacterStatsPane"];
function ECF:ToggleDurabilityFrame(value)
    if (value) then
        characterStatsPane:SetParent(ECF.ScrollFrame.statFrame)
        characterStatsPane.ItemLevelCategory:SetPoint("TOP", characterStatsPane.ItemDurabilityCategory.DurabilityFrame,
            "BOTTOM", 0, 0);

        characterStatsPane.ItemDurabilityCategory:Show();
    else
        characterStatsPane.ItemDurabilityCategory:Hide();
        characterStatsPane:SetParent(_G["CharacterFrame"])
        characterStatsPane.ItemLevelCategory:SetPoint("TOP", characterStatsPane, "TOP", 0, 0);
    end
end

function ECF:GetActualItemLevel(unit, slot)
    local itemLevel;
    local tooltipData = C_TooltipInfo.GetInventoryItem(unit, slot)
    for j = 2, 3 do
        local msg = tooltipData.lines[j] and tooltipData.lines[j].leftText
        if (not msg) then break end
        local match = string.match(msg, ITEM_LEVEL:gsub("%%d", "(%%d+)"))
        if (match) then
            itemLevel = tonumber(match)
            break
        end
    end
    return itemLevel
end

function ECF:GetInventoryItemsInfo(unit)
    local items = {};
    for i = 1, 18 do
        local itemID = GetInventoryItemID(unit, i);
        if itemID then
            local slotName = GetItemInfo(itemID);
            local itemLink = GetInventoryItemLink(unit, i);
            local itemDetails = HandleItemLink(itemLink);

            local itemLevel = ECF:GetActualItemLevel(unit, i);
            local current, max = GetInventoryItemDurability(i);
            items[itemID] = {
                id = itemID,
                slotPos = i,
                slotName = slotName,
                itemLevel = itemLevel,
                itemEnchant = itemDetails.itemEnchant,
                itemGem1 = itemDetails.itemGem1,
                itemGem2 = itemDetails.itemGem2,
                itemGem3 = itemDetails.itemGem3,
                itemGem4 = itemDetails.itemGem4,
            }

            if (current ~= nil and max ~= nil) then
                local percentage = math.floor(current / max * 100);
                local color = GetDurablityColor(percentage);
                items[itemID].durability = {
                    current = current,
                    max = max,
                    percentage = percentage,
                    color = color,
                }
            end
        end
    end
    return items;
end

function ECF:GetInvslotFrameName(slotID, unit)
    local slotName = INVSLOT_ID_MAP[slotID];
    return (unit == "player" and "Character" or "Inspect") .. slotName;
end

function ECF:CreateStatScrollFrame()
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
    StatScrollFrame.statFrame = StatFrame;
    -- StatFrame:SetSize(191, characterStatsPane:GetHeight())
    StatFrame:SetPoint("TOPLEFT", StatScrollFrame, "TOPLEFT", 0, 0)
    StatScrollFrame:SetScrollChild(StatFrame)

    characterStatsPane:SetParent(StatFrame);

    characterStatsPane:HookScript("OnShow", function(self)
        StatFrame:SetSize(191, characterStatsPane:GetHeight() or 355)
    end)

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
    end)

    -- Setup tooltip to display every item's durability
    itemDurabilityCategory.DurabilityFrame:HookScript("OnEnter", function()
        local itemsInfo = ECF:GetInventoryItemsInfo("player");
        GameTooltip:SetOwner(itemDurabilityCategory.DurabilityFrame, "ANCHOR_RIGHT");
        GameTooltip:SetText(L["itemDurability"]);
        GameTooltip:AddLine(" ");

        for itemID, itemInfo in pairs(itemsInfo) do
            if itemInfo.durability then
                local durability = itemInfo.durability;
                GameTooltip:AddDoubleLine(itemInfo.slotName, durability.percentage .. "%", 1, 1, 1, durability.color.r,
                    durability.color.g, durability.color.b);
            end
        end
        GameTooltip:Show();
    end)
    return StatScrollFrame;
end

function ECF:InitializeSlotFrames(unit)
    for i = 1, 18 do
        local slotFrame = _G[ECF:GetInvslotFrameName(i, unit)];
        if slotFrame and slotFrame.itemLevelFontString then
            slotFrame.itemLevelFontString:SetText("");
        end
    end
end

function ECF:HandleItemFrames(itemsInfo, unit)
    ECF:InitializeSlotFrames();
    for itemID, itemInfo in pairs(itemsInfo) do
        local slotFrame = _G[ECF:GetInvslotFrameName(itemInfo.slotPos, unit)];
        ECF:CreateExtraInfoFrames(slotFrame);
        local itemLevelFontString = slotFrame.itemLevelFontString or
            slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        slotFrame.itemLevelFontString = itemLevelFontString;
        itemLevelFontString:SetPoint("BOTTOMRIGHT", slotFrame, "BOTTOMRIGHT", 0, 0);
        itemLevelFontString:SetText(itemInfo.itemLevel);
        -- Add shadow to the font string
        itemLevelFontString:SetShadowColor(0, 0, 0, 1);
        itemLevelFontString:SetShadowOffset(1, -1);
        -- Set font size
        itemLevelFontString:SetFont(itemLevelFontString:GetFont(), 12, "OUTLINE");
        -- Add texture to extra info frames
        for i = 1, 3 do
            local gemKey = "itemGem" .. i
            if (itemInfo[gemKey]) then
                local extraInfoFrame = ECF:FindNextAvailableExtraInfoFrame(slotFrame);
                if extraInfoFrame then
                    extraInfoFrame.occupied = true;
                    extraInfoFrame.texture:SetTexture(itemInfo[gemKey].icon);
                end
                extraInfoFrame:HookScript("OnEnter", function()
                    GameTooltip:SetOwner(extraInfoFrame, "ANCHOR_RIGHT");
                    GameTooltip:SetItemByID(itemInfo[gemKey].id);
                    GameTooltip:Show();
                end)
                extraInfoFrame:HookScript("OnLeave", function()
                    GameTooltip:Hide();
                end)
            end
        end

        if (itemInfo.itemEnchant) then
            local extraInfoFrame = ECF:FindNextAvailableExtraInfoFrame(slotFrame);
            extraInfoFrame.occupied = true;
            if (itemInfo.itemEnchant.id) then
                extraInfoFrame.texture:SetTexture(itemInfo.itemEnchant.icon);
            else
                extraInfoFrame.texture:SetTexture("Interface\\FriendsFrame\\InformationIcon");
            end
            extraInfoFrame:HookScript("OnEnter", function()
                GameTooltip:SetOwner(extraInfoFrame, "ANCHOR_RIGHT");
                if itemInfo.itemEnchant.id then
                    GameTooltip:SetItemByID(itemInfo.itemEnchant.id);
                    GameTooltip:Show();
                else
                    extraInfoFrame.texture:SetTexture("Interface\\FriendsFrame\\InformationIcon-Highlight");
                    GameTooltip:AddLine(L["noEnchant"], 1, 1, 0, 1);
                    GameTooltip:AddLine("ID: " .. itemInfo.itemEnchant.enchantID)
                    GameTooltip:Show();
                end
            end)
            extraInfoFrame:HookScript("OnLeave", function()
                GameTooltip:Hide();
                if itemInfo.itemEnchant.id then
                    extraInfoFrame.texture:SetTexture(itemInfo.itemEnchant.icon);
                else
                    extraInfoFrame.texture:SetTexture("Interface\\FriendsFrame\\InformationIcon");
                end
            end)
        end
    end
end

function ECF:FindNextAvailableExtraInfoFrame(slotFrame)
    for i = 1, 4 do
        local name = "extraInfoFrame" .. i;
        if (slotFrame[name]) then
            if (not slotFrame[name].occupied) then
                return slotFrame[name];
            end
        end
    end
    return nil;
end

function ECF:CreateExtraInfoFrames(slotFrame)
    local leftSlots = {
        "CharacterHeadSlot",
        "CharacterNeckSlot",
        "CharacterShoulderSlot",
        "CharacterChestSlot",
        "CharacterWristSlot",
        "CharacterBackSlot",
        "InspectHeadSlot",
        "InspectNeckSlot",
        "InspectShoulderSlot",
        "InspectChestSlot",
        "InspectWristSlot",
        "InspectBackSlot",
    }
    local rightSlots = {
        "CharacterHandsSlot",
        "CharacterWaistSlot",
        "CharacterLegsSlot",
        "CharacterFeetSlot",
        "CharacterFinger0Slot",
        "CharacterFinger1Slot",
        "CharacterTrinket0Slot",
        "CharacterTrinket1Slot",
        "InspectHandsSlot",
        "InspectWaistSlot",
        "InspectLegsSlot",
        "InspectFeetSlot",
        "InspectFinger0Slot",
        "InspectFinger1Slot",
        "InspectTrinket0Slot",
        "InspectTrinket1Slot",

    }
    local bottomSlots = {
        "CharacterMainHandSlot",
        "CharacterSecondaryHandSlot",
        "InspectMainHandSlot",
        "InspectSecondaryHandSlot",
    }
    local slotName = slotFrame:GetName();
    local slotPosition = tContains(leftSlots, slotName) and "LEFT" or tContains(rightSlots, slotName) and "RIGHT" or
        tContains(bottomSlots, slotName) and "BOTTOM";
    local slotAnchor = slotPosition == "LEFT" and "TOPRIGHT" or "TOPLEFT";
    local extraInfoFrameAnchor = slotPosition == "LEFT" and "TOPLEFT" or
        slotPosition == "RIGHT" and "TOPRIGHT" or "BOTTOMLEFT";
    local offsetX = slotPosition == "LEFT" and 10 or slotPosition == "RIGHT" and -10 or 0;
    local offsetY = slotPosition == "BOTTOM" and 10 or -5;

    -- Frame 1
    slotFrame["extraInfoFrame1"] = slotFrame["extraInfoFrame1"] or CreateFrame("Frame", nil, slotFrame)
    slotFrame["extraInfoFrame1"]:SetSize(15, 15)
    slotFrame["extraInfoFrame1"]:SetPoint(extraInfoFrameAnchor, slotFrame, slotAnchor, offsetX, offsetY)
    slotFrame["extraInfoFrame1"].texture = slotFrame["extraInfoFrame1"].texture or
        slotFrame["extraInfoFrame1"]:CreateTexture(nil, "OVERLAY")
    slotFrame["extraInfoFrame1"].texture:SetAllPoints()
    slotFrame["extraInfoFrame1"].texture:SetTexture(nil)
    slotFrame["extraInfoFrame1"].occupied = false;
    slotFrame["extraInfoFrame1"]:SetScript("OnEnter", function()
    end)

    -- Frame 2
    slotFrame["extraInfoFrame2"] = slotFrame["extraInfoFrame2"] or CreateFrame("Frame", nil, slotFrame)
    slotFrame["extraInfoFrame2"]:SetSize(15, 15)
    slotFrame["extraInfoFrame2"]:SetPoint("TOPLEFT", slotFrame["extraInfoFrame1"],
        slotPosition == "BOTTOM" and "TOPRIGHT" or "BOTTOMLEFT", 0, 0)
    slotFrame["extraInfoFrame2"].texture = slotFrame["extraInfoFrame2"].texture or
        slotFrame["extraInfoFrame2"]:CreateTexture(nil, "OVERLAY")
    slotFrame["extraInfoFrame2"].texture:SetAllPoints()
    slotFrame["extraInfoFrame2"].texture:SetTexture(nil)
    slotFrame["extraInfoFrame2"].occupied = false;
    slotFrame["extraInfoFrame2"]:SetScript("OnEnter", function()
    end)

    -- Frame 3
    local frame3Anchor = slotPosition == "LEFT" and "TOPLEFT" or
        slotPosition == "RIGHT" and "TOPRIGHT" or "BOTTOMLEFT";
    local frame3to1RelativeAnchor = slotPosition == "LEFT" and "TOPRIGHT" or "TOPLEFT";
    slotFrame["extraInfoFrame3"] = slotFrame["extraInfoFrame3"] or CreateFrame("Frame", nil, slotFrame)
    slotFrame["extraInfoFrame3"]:SetSize(15, 15)
    slotFrame["extraInfoFrame3"]:SetPoint(frame3Anchor, slotFrame["extraInfoFrame1"],
        frame3to1RelativeAnchor, 0, 0)
    slotFrame["extraInfoFrame3"].texture = slotFrame["extraInfoFrame3"].texture or
        slotFrame["extraInfoFrame3"]:CreateTexture(nil, "OVERLAY")
    slotFrame["extraInfoFrame3"].texture:SetAllPoints()
    slotFrame["extraInfoFrame3"].texture:SetTexture(nil)
    slotFrame["extraInfoFrame3"].occupied = false;
    slotFrame["extraInfoFrame3"]:SetScript("OnEnter", function()
    end)

    -- Frame 4
    local frame4to3RelativeAnchor = slotPosition == "LEFT" and "BOTTOMLEFT" or slotPosition == "RIGHT" and "BOTTOMLEFT"
        or "TOPRIGHT";
    slotFrame["extraInfoFrame4"] = slotFrame["extraInfoFrame4"] or CreateFrame("Frame", nil, slotFrame)
    slotFrame["extraInfoFrame4"]:SetSize(15, 15)
    slotFrame["extraInfoFrame4"]:SetPoint("TOPLEFT", slotFrame["extraInfoFrame3"],
        frame4to3RelativeAnchor, 0, 0)
    slotFrame["extraInfoFrame4"].texture = slotFrame["extraInfoFrame4"].texture or
        slotFrame["extraInfoFrame4"]:CreateTexture(nil, "OVERLAY")
    slotFrame["extraInfoFrame4"].texture:SetAllPoints()
    slotFrame["extraInfoFrame4"].texture:SetTexture(nil)
    slotFrame["extraInfoFrame4"].occupied = false;
    slotFrame["extraInfoFrame4"]:SetScript("OnEnter", function()
    end)
end

frame:SetScript("OnEvent", function(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        ECF.ScrollFrame = ECF:CreateStatScrollFrame();
        ECF:ToggleDurabilityFrame(EHUD.db.profile.durabilityDisplay.enable);
        -- ECF:CreateItemLevelFrame(itemsInfo);
    end

    if (event == "UPDATE_UI_WIDGET") then
        local inspectFrame = _G["InspectFrame"];
        if inspectFrame and not inspectFrame.ECFHookSetup then
            if (inspectFrame:IsShown()) then
                local itemsInfo = ECF:GetInventoryItemsInfo("target");
                ECF:HandleItemFrames(itemsInfo, "target")
            end
            inspectFrame:HookScript("OnShow", function()
                local itemsInfo = ECF:GetInventoryItemsInfo("target");
                ECF:HandleItemFrames(itemsInfo, "target")
            end)
            inspectFrame.ECFHookSetup = true;
        end
    end

    if (event == "PLAYER_EQUIPMENT_CHANGED") then
        local itemsInfo = ECF:GetInventoryItemsInfo("player");
        ECF:HandleItemFrames(itemsInfo, "player")
    end
end)

characterFrame:HookScript("OnShow", function()
    local itemsInfo = ECF:GetInventoryItemsInfo("player");
    ECF:HandleItemFrames(itemsInfo, "player")
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
