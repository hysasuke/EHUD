local L = LibStub("AceLocale-3.0"):GetLocale("EHUD")

local _, core = ...; -- Namespace
local EB = {};
core.EB = EB;


local function GetItemContainerLocation(bagID, itemIndex)
    local numerOfSlots = C_Container.GetContainerNumSlots(bagID);
    return {
        bagIndex = bagID + 1,
        itemIndex = numerOfSlots - (itemIndex - 1)
    }
end

local function GetActualItemLevel(bagIndex, slotIndex)
    local itemLevel;
    local tooltipData = C_TooltipInfo.GetBagItem(bagIndex, slotIndex)
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

local function HandleBagItems(bagID)
    local endBagID = bagID or 12;
    if not bagID then
        bagID = 0 -- default to backpack
    end
    for i = bagID, endBagID do
        local numerOfSlots = C_Container.GetContainerNumSlots(i);
        if (numerOfSlots > 0) then
            for slotIndex = 1, numerOfSlots do
                local containerItemInfo =
                    C_Container.GetContainerItemInfo(i, slotIndex);
                local containerPos = GetItemContainerLocation(i, slotIndex)
                local currentFrame = _G
                    ["ContainerFrame" .. containerPos.bagIndex .. "Item" .. containerPos.itemIndex];
                if containerItemInfo then
                    local itemLink = containerItemInfo.hyperlink;
                    local itemInfo = HandleItemLink(itemLink);


                    -- Item level font string
                    currentFrame.itemLevelText = currentFrame.itemLevelText or
                        currentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    currentFrame.itemLevelText:SetFont(currentFrame.itemLevelText:GetFont(), 12, "OUTLINE");
                    currentFrame.itemLevelText:SetPoint("BOTTOMRIGHT", currentFrame, "BOTTOMRIGHT", 0, 0);
                    -- BOE Indicator
                    currentFrame.BOEIndicator = currentFrame.BOEIndicator or
                        currentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
                    currentFrame.BOEIndicator:SetFont(currentFrame.BOEIndicator:GetFont(), 12, "OUTLINE");
                    currentFrame.BOEIndicator:SetPoint("TOPLEFT", currentFrame, "TOPLEFT", 0, 0);

                    if (not containerItemInfo.isBound and (itemInfo.itemType == Enum.ItemClass.Armor or itemInfo.itemType == Enum.ItemClass.Weapon)) then
                        local r, g, b = GetItemQualityColor(itemInfo.itemQuality);
                        currentFrame.BOEIndicator:SetText("BOE");
                        currentFrame.BOEIndicator:SetTextColor(r, g, b)
                    else
                        currentFrame.BOEIndicator:SetText("");
                    end

                    if (itemInfo.itemType == Enum.ItemClass.Armor or itemInfo.itemType == Enum.ItemClass.Weapon) then
                        local itemLevel = GetActualItemLevel(i, slotIndex);
                        if itemLevel then
                            currentFrame.itemLevelText:SetText(itemLevel)
                        else
                            currentFrame.itemLevelText:SetText("")
                        end
                    else
                        currentFrame.itemLevelText:SetText("")
                    end
                else
                    if currentFrame.itemLevelText then
                        currentFrame.itemLevelText:SetText("")
                    end
                    if currentFrame.BOEIndicator then
                        currentFrame.BOEIndicator:SetText("")
                    end
                end
            end
        end
    end
end

EHUD:RegisterEvent("BAG_UPDATE", function(event, bag)
    local currentFrame = _G["ContainerFrame" .. bag];
    if currentFrame then
        HandleBagItems(bag);
    end

    local combinedBagFrame = _G["ContainerFrameCombinedBags"];
    if combinedBagFrame then
        HandleBagItems();
    end
end);
