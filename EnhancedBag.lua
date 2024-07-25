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
        if (not msg) then
            break
        end
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
                local containerItemInfo = C_Container.GetContainerItemInfo(i, slotIndex);
                local containerPos = GetItemContainerLocation(i, slotIndex)
                local currentFrame = _G["ContainerFrame" .. containerPos.bagIndex .. "Item" .. containerPos.itemIndex];
                Debug(_G["ContainerFrame" .. containerPos.bagIndex]:GetChildren()[1])
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

                    if (not containerItemInfo.isBound and
                        (itemInfo.itemType == Enum.ItemClass.Armor or itemInfo.itemType == Enum.ItemClass.Weapon)) then
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

local function CalculateSellPrice()
    local total = 0;
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot);
            if itemInfo then
                if (itemInfo.quality == Enum.ItemQuality.Poor and not itemInfo.noValue) then
                    local sellPrice = select(11, GetItemInfo(itemInfo.itemID));
                    total = total + (sellPrice * itemInfo.stackCount);
                end
            end
        end
    end
    return total;
end

local function HandleSellTrash()
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot);
            if itemInfo then
                if (itemInfo.quality == Enum.ItemQuality.Poor and not itemInfo.noValue) then
                    C_Container.UseContainerItem(bag, slot)
                end
            end
        end
    end
end

local function HandleAutoSellTrashButton()
    local merchantFrame = _G["MerchantFrame"];
    local repairButton = _G["MerchantGuildBankRepairButton"];
    local sellButton = merchantFrame.EHUDAutoSellTrashButton or
                           CreateFrame("Button", "EHUDAutoSellTrashButton", MerchantFrame, "SecureActionButtonTemplate");
    merchantFrame.EHUDAutoSellTrashButton = sellButton;
    sellButton:SetSize(repairButton:GetSize());
    sellButton:SetPoint("TOPLEFT", repairButton, "TOPRIGHT", 10, 0);
    sellButton.background = sellButton.background or sellButton:CreateTexture(nil, "BACKGROUND");
    sellButton.background:SetSize(64, 64)
    sellButton.background:SetTexture("Interface\\Buttons\\UI-EmptySlot");
    sellButton.background:SetPoint("CENTER", sellButton, "CENTER", 0, 0);

    sellButton.texture = sellButton.texture or sellButton:CreateTexture(nil, "BORDER");
    sellButton.texture:SetAtlas("SpellIcon-256x256-SellJunk");
    sellButton.texture:SetAllPoints(sellButton);
    sellButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
    sellButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
    sellButton:SetScript("OnEnter", function(self)
        -- local totalSellPrice = CalculateSellPrice();
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(SELL_ALL_JUNK_ITEMS);
        -- GameTooltip:AddLine(SELL_PRICE .. ": " .. GetCoinTextureString(totalSellPrice));
        GameTooltip:Show();
    end);
    sellButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide();
    end);
    sellButton:SetScript("OnClick", function()
        HandleSellTrash();
    end)

    merchantFrame:HookScript("OnUpdate", function(self)
        if (self.EHUDAutoSellTrashButton) then
            if (self.selectedTab == 1) then
                local hasJunkItems = C_MerchantFrame.GetNumJunkItems() > 0;
                self.EHUDAutoSellTrashButton:Show();

                self.EHUDAutoSellTrashButton.texture:SetDesaturated(not hasJunkItems);
                self.EHUDAutoSellTrashButton:SetEnabled(hasJunkItems);
            else
                self.EHUDAutoSellTrashButton:Hide();
            end
        end
    end)
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

EHUD:RegisterEvent("MERCHANT_SHOW", function(event)
    HandleAutoSellTrashButton();
end);
