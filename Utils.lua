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
