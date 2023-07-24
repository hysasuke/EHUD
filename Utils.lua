local LibItemEnchant = LibStub:GetLibrary("LibItemEnchant.7000")

function Debug(...)
    local debugChatFrame = nil;
    for i = 1, 10 do
        local chatName = GetChatWindowInfo(i);
        if chatName == "Debug" then
            debugChatFrame = Chat_GetChatFrame(i);
            break;
        end
    end
    if debugChatFrame then
        local args = { ... };
        local output = "";
        for _, value in pairs(args) do
            if type(value) == "table" then
                output = output .. "table: ";
                for k, v in pairs(value) do
                    output = output .. tostring(k) .. " = " .. tostring(v) .. " ";
                end
            else
                if not value then
                    value = "nil";
                end
                output = output .. tostring(value) .. " ";
            end
        end
        debugChatFrame:AddMessage(output);
    end
end

-- Get the player's equipment durability
function GetEquipmentDurability(unit)
    local durability = 0
    local max = 0
    for i = 0, 19 do
        local current, maximum = GetInventoryItemDurability(i)
        if current and maximum then
            durability = durability + current
            max = max + maximum
        end
    end

    -- To 2 digits after the decimal point
    local percentage = tonumber(string.format("%.2f", (durability / max) * 100))
    return durability, max, percentage
end

function GetSpellName(id)
    local name = GetSpellInfo(id)
    return name or "";
end

function GetMapIDByChallengeModeID(challengeModeID)
    local map = {
        [2] = 960,
        [56] = 961,
        [57] = 962,
        [58] = 959,
        [59] = 1011,
        [60] = 994,
        [76] = 1007,
        [77] = 1001,
        [78] = 1004,
        [161] = 1209,
        [163] = 1175,
        [164] = 1182,
        [165] = 1176,
        [166] = 1208,
        [167] = 1358,
        [168] = 1279,
        [169] = 1195,
        [197] = 1456,
        [198] = 1466,
        [199] = 1501,
        [200] = 1477,
        [206] = 1458,
        [207] = 1493,
        [208] = 1492,
        [209] = 1516,
        [210] = 1571,
        [227] = 1651,
        [233] = 1677,
        [234] = 1651,
        [239] = 1753,
        [244] = 1763,
        [245] = 1754,
        [246] = 1771,
        [247] = 1594,
        [248] = 1862,
        [249] = 1762,
        [250] = 1877,
        [251] = 1841,
        [252] = 1864,
        [353] = 1822,
        [369] = 2097,
        [370] = 2097,
        [375] = 2290,
        [376] = 2286,
        [377] = 2291,
        [378] = 2287,
        [379] = 2289,
        [380] = 2284,
        [381] = 2285,
        [382] = 2293,
        [391] = 2441,
        [392] = 2441,
        [399] = 2521,
        [400] = 2516,
        [401] = 2515,
        [402] = 2526,
        [403] = 2451,
        [404] = 2519,
        [405] = 2520,
        [406] = 2527,
        [438] = 657
    }
    local name, id = C_ChallengeMode.GetMapUIInfo(challengeModeID)
    return map[challengeModeID], name, id
end

-- Get player's mythic plus score details
function GetMythicPlusScoreDetails(unit)
    local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit);
    -- local currentScore = ratingSummary.currentSeasonScore;
    local runs = ratingSummary.runs;
    local output = {};
    for _, value in pairs(runs) do
        local affixScore, bestOverAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(value.challengeModeID);
        -- local mapID, name, id = GetMapIDByChallengeModeID(value.challengeModeID);
        output[value.challengeModeID] = {};
        output[value.challengeModeID] = {
            score = bestOverAllScore,
            fortified = {
                score = affixScore[1].score,
                level = affixScore[1].level,
                time = affixScore[1].durationSec,
                overtime = affixScore[1].overTime,
                name = affixScore[1].name,
            },
            tyrannical = {
                score = affixScore[2].score,
                level = affixScore[2].level,
                time = affixScore[2].durationSec,
                overtime = affixScore[2].overTime,
                name = affixScore[2].name,
            },
        }
    end
    return output;
end

function GetCurrentWeekRewardDetails()
    -- local runs = C_MythicPlus.GetRunHistory(false, true);
    local activities = C_WeeklyRewards.GetActivities(1); -- 1 for Mythic+
    local output = {};
    for k, activity in pairs(activities) do
        local rewardILvl = C_MythicPlus.GetRewardLevelFromKeystoneLevel(activity.level)
        local nextRewardKeystoneLevel = C_WeeklyRewards.GetNextMythicPlusIncrease(activity.level);
        local details = {
            rewardILvl = rewardILvl,
            progress = activity.progress >= activity.threshold and activity.threshold or activity.progress,
            threshold = activity.threshold,
            nextRewardKeystoneLevel = nextRewardKeystoneLevel,
            currentRewardKeystoneLevel = activity.level
        }
        table.insert(output, details)
    end
    return output;
end

function GetTeleportSpellIDByChallengeModeID(id)
    local map = {
        [251] = 410074,
        [406] = 393283,
        [206] = 410078,
        [245] = 410071,
        [403] = 393222,
        [438] = 410080,
        [405] = 393267,
        [404] = 393276
    }

    return map[id];
end

function SetFrameMovable(frame)
    frame:SetMovable(true);
    frame:EnableMouse(true);
    frame:RegisterForDrag("LeftButton");
    frame:SetScript("OnDragStart", frame.StartMoving);
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing);
end

function GetPlayerSpecs()
    local output = {};
    local spec = GetSpecialization();
    local currentSpec = {};
    for i = 1, GetNumSpecializations() do
        local id, name, description, icon, background, role, class = GetSpecializationInfo(i);
        table.insert(output, {
            id = id,
            name = name,
            description = description,
            icon = icon,
            background = background,
            role = role,
            class = class,
            selected = spec == i
        });

        if spec == i then
            currentSpec = {
                id = id,
                name = name,
                description = description,
                icon = icon,
                background = background,
                role = role,
                class = class,
                selected = spec == i
            }
        end
    end
    return output, currentSpec;
end

function HandleItemLink(itemLink)
    if not itemLink then return {} end
    local itemString = string.match(itemLink, "item[%-?%d:]+");
    if not itemString then return {} end
    local itemSplit = string:split(itemString, ":");

    -- dump itemSplit

    local itemID = itemSplit[2];
    local enchantItemID, enchantID = LibItemEnchant:GetEnchantItemID(itemLink);

    local itemEnchant = (enchantItemID or enchantID) and {
        id = enchantItemID,
        enchantID = enchantID,
        name = enchantItemID and select(1, GetItemInfo(enchantItemID)),
        icon = enchantItemID and select(10, GetItemInfo(enchantItemID)),
    } or nil;

    local itemGem1 = itemSplit[4] ~= "nil" and {
        id = itemSplit[4],
        name = select(1, GetItemInfo(itemSplit[4])),
        icon = select(10, GetItemInfo(itemSplit[4])),
    } or nil

    local itemGem2 = itemSplit[5] ~= "nil" and {
        id = itemSplit[5],
        name = select(1, GetItemInfo(itemSplit[5])),
        icon = select(10, GetItemInfo(itemSplit[5])),
    } or nil;
    local itemGem3 = itemSplit[6] ~= "nil" and {
        id = itemSplit[6],
        name = select(1, GetItemInfo(itemSplit[6])),
        icon = select(10, GetItemInfo(itemSplit[6])),
    } or nil;
    local itemGem4 = itemSplit[7] ~= "nil" and {
        id = itemSplit[7],
        name = select(1, GetItemInfo(itemSplit[7])),
        icon = select(10, GetItemInfo(itemSplit[7])),
    } or nil;

    local itemName = GetItemInfo(itemID);
    local itemIcon = select(10, GetItemInfo(itemID));
    local isBOE = select(14, GetItemInfo(itemID)) == 2;
    local itemType = select(12, GetItemInfo(itemID));
    local itemQuality = select(3, GetItemInfo(itemID));
    return {
        itemID = itemID,
        itemName = itemName,
        itemIcon = itemIcon,
        itemEnchant = itemEnchant,
        itemGem1 = itemGem1,
        itemGem2 = itemGem2,
        itemGem3 = itemGem3,
        itemGem4 = itemGem4,
        isBOE = isBOE,
        itemType = itemType,
        itemQuality = itemQuality
    }
end

function string:split(inputstr, sep)
    sep = sep or '%s'
    local t = {}
    for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
        if field ~= "" then
            table.insert(t, field)
        else
            table.insert(t, "nil")
        end

        if s == "" then return t end
    end
end

-- Color related

-- local gradientColor = {
--  [0] = CreateColor(0, 1, 0, 1),
--  [1] = CreateColor(1, 1, 0, 1),
--  [2] = CreateColor(1, 0, 0, 1)
-- }
function ColorGradient(perc, colors)
    local num = #colors

    if (perc >= 1) then
        return colors[num]
    elseif (perc <= 0) then
        return colors[0]
    end

    local segment, relperc = math.modf(perc * num)

    local r1, g1, b1, r2, g2, b2
    r1, g1, b1 = colors[segment]:GetRGB()
    r2, g2, b2 = colors[segment + 1]:GetRGB()

    if (not r2 or not g2 or not b2) then
        return colors[0]
    else
        local r = r1 + (r2 - r1) * relperc
        local g = g1 + (g2 - g1) * relperc
        local b = b1 + (b2 - b1) * relperc

        return CreateColor(r, g, b, 1)
    end
end

function GetSpellSchoolColor(spellSchool)
    local color = {
        [1] = CreateColorFromBytes(255, 255, 0, 1),
        [2] = CreateColorFromBytes(255, 230, 128, 1),
        [4] = CreateColorFromBytes(255, 128, 0, 1),
        [8] = CreateColorFromBytes(77, 255, 77, 1),
        [16] = CreateColorFromBytes(128, 255, 255, 1),
        [32] = CreateColorFromBytes(128, 128, 255, 1),
        [64] = CreateColorFromBytes(255, 128, 255, 1),
    }
    color[3] = color[1];
    color[5] = color[1];
    color[6] = color[2];
    color[9] = color[1];
    color[10] = color[2];
    color[12] = color[4];
    color[17] = color[1];
    color[18] = color[2];
    color[20] = color[4];
    color[24] = color[8];
    color[33] = color[1];
    color[34] = color[2];
    color[36] = color[4];
    color[40] = color[8];
    color[48] = color[16];
    color[65] = color[1];
    color[66] = color[2];
    color[68] = color[4];
    color[72] = color[8];
    color[80] = color[16];
    color[96] = color[32];
    color[28] = color[4];
    color[62] = color[2];
    color[106] = color[2];
    color[124] = color[4];
    color[126] = color[2];
    color[127] = color[1];



    return color[spellSchool];
end

-- Animation
function SetAnimation(frame)
    frame.StartAnimation = function(self, value, toValue, duration, onProgress, onComplete)
        local onUpdateCopy = self:GetScript("OnUpdate");
        frame.targetValue = value;
        frame.startTime = GetTime();
        frame.onUpdateCopy = onUpdateCopy;
        local difference = toValue - value;
        frame:HookScript("OnUpdate", function(self, elapsed)
            local progress = duration > 0 and (GetTime() - self.startTime) / duration or 1;
            local currentValue = value + (difference * progress);
            if progress > 1 then
                progress = 1;
                onProgress(toValue);
                self:SetScript("OnUpdate", onUpdateCopy);
                if onComplete then
                    onComplete();
                end
            else
                onProgress(currentValue);
            end
            -- self:SetValue(self.targetValue * progress);
            -- onProgress(self.targetValue * progress);
        end);
    end

    frame.StopAnimation = function(self)
        if self.onUpdateCopy then
            self:SetScript("OnUpdate", self.onUpdateCopy);
        else
            self:SetScript("OnUpdate", nil);
        end
    end
end
