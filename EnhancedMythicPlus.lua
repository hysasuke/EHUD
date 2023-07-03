local L = LibStub("AceLocale-3.0"):GetLocale("EHUD")


local pveFrame = _G["PVEFrame"];

local function generateRewardDetails(frame)
    local rewardDetails = GetCurrentWeekRewardDetails();
    local container = frame.rewardsDetailFrame or CreateFrame("Frame", nil, frame);
    container:SetSize(100, 100)
    container:Hide();
    for key, value in pairs(rewardDetails) do
        container["fontString" .. key] = container["fontString" .. key] or
            container:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        local rewardILvlText = value.rewardILvl > 0 and L["ilvl"] .. " " .. tostring(value.rewardILvl) or
            L["incompleted"];
        local displayText = string.format("%d/%d: %s (%s)", value.progress, value.threshold, rewardILvlText,
            value.currentRewardKeystoneLevel);
        container["fontString" .. key]:SetText(displayText);
        container["fontString" .. key]:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -key * 20);
    end
    return container;
end

local function generateTeleportButton(frame, challengeModeID)
    -- print("generateTeleportButton")
    local button = frame.teleportButton or CreateFrame("Button", nil, frame, "SecureActionButtonTemplate");
    local spellID = GetTeleportSpellIDByChallengeModeID(challengeModeID);
    local spellName = GetSpellInfo(spellID);
    local spellKnown = IsSpellKnown(spellID);
    if (not button.SetBackdrop) then Mixin(button, BackdropTemplateMixin) end
    button:HookScript("OnUpdate", function()
        local colors = {
            known = { r = 0, g = 1, b = 0, a = 1 },
            unkown = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
            cd = { r = 1, g = 0, b = 0, a = 1 },
        }
        local displayColor = spellKnown and colors.known or colors.unkown;
        if (spellKnown) then
            local start, duration, enabled = GetSpellCooldown(spellID);
            if (start > 0 and duration > 0) then
                displayColor = colors.cd;
            end
        end
        button.backdrop = {
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tileEdge = false,
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        }
        button:SetBackdrop(button.backdrop)
        button:SetBackdropBorderColor(displayColor.r, displayColor.g, displayColor.b, displayColor.a)
    end)



    button:SetAllPoints(frame);
    button:SetAttribute("type", "spell");
    button:SetAttribute("spell", spellName);
    button:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
    return button;
end


local function mythicPlusFrameOnShow(frame, event)
    local children = { frame:GetChildren() };
    local mythicPlusDetails = GetMythicPlusScoreDetails("player");
    for key, value in pairs(children) do
        local mapID = value.mapID;

        if mapID then
            local highestLevelFrame = value.HighestLevel;
            local fontObj = highestLevelFrame:GetFontObject();
            if not value.teleportButton then
                value.teleportButton = generateTeleportButton(value, mapID);
                value.teleportButton:HookScript("OnEnter", function()
                    value:OnEnter()
                end)
            end
            if not value.fortifiedScoreText then
                value.fortifiedScoreText = value:CreateFontString(nil, "OVERLAY",
                    "GameFontNormal");
                value.fortifiedScoreText:SetFontObject(fontObj);
                value.fortifiedScoreText:SetTextScale(0.8)
            end
            if not value.tyrannicalScoreText then
                value.tyrannicalScoreText = value:CreateFontString(nil, "OVERLAY",
                    "GameFontNormal");
                value.tyrannicalScoreText:SetFontObject(fontObj);
                value.tyrannicalScoreText:SetTextScale(0.8)
            end

            if not value.scoreText then
                value.scoreText = value:CreateFontString(nil, "OVERLAY",
                    "GameFontNormal");
                value.scoreText:SetFontObject(fontObj);
            end
            if mythicPlusDetails[mapID] then
                local fortified = mythicPlusDetails[mapID].fortified;
                local tyrannical = mythicPlusDetails[mapID].tyrannical;

                -- Grey for overtime
                local overTimeColor = { r = 0.5, g = 0.5, b = 0.5 };
                local fortifiedScoreColor = fortified.overtime and overTimeColor or
                    C_ChallengeMode.GetSpecificDungeonScoreRarityColor(fortified.score);
                local tyrannicalScoreColor = tyrannical.overtime and overTimeColor or
                    C_ChallengeMode.GetSpecificDungeonScoreRarityColor(tyrannical.score);
                highestLevelFrame:SetTextColor(1, 1, 1, 1);
                value.fortifiedScoreText:SetTextColor(fortifiedScoreColor.r, fortifiedScoreColor.g,
                    fortifiedScoreColor.b, 1);
                value.tyrannicalScoreText:SetTextColor(tyrannicalScoreColor.r, tyrannicalScoreColor.g,
                    tyrannicalScoreColor.b, 1);
                value.fortifiedScoreText:SetText(fortified.level);
                value.tyrannicalScoreText:SetText(tyrannical.level);
                value.fortifiedScoreText:SetPoint("RIGHT", highestLevelFrame, "LEFT", -0, 0);
                value.tyrannicalScoreText:SetPoint("LEFT", highestLevelFrame, "RIGHT", 0, 0);
                highestLevelFrame:SetText("/")

                local scoreColor = C_ChallengeMode.GetSpecificDungeonScoreRarityColor(mythicPlusDetails[mapID].score);
                value.scoreText:SetText(mythicPlusDetails[mapID].score);
                value.scoreText:SetTextColor(scoreColor.r, scoreColor.g, scoreColor.b, 1);
                value.scoreText:SetPoint("BOTTOM", value, "BOTTOM", 0, 0);
            end
        end
    end
end

pveFrame:HookScript("OnUpdate", function(self)
    local challengesFrame = nil
    if pveFrame.selectedTab == 3 and EHUD.db.profile.enhancedMythicPlusDisplay.enable then
        challengesFrame = _G["ChallengesFrame"];
        if not challengesFrame.scriptSetUp then
            challengesFrame:HookScript("OnUpdate", mythicPlusFrameOnShow)
            challengesFrame.scriptSetUp = true;
        end
        challengesFrame.rewardsDetailFrame = generateRewardDetails(challengesFrame);
        challengesFrame.rewardsDetailFrame:SetPoint("TOPLEFT", challengesFrame, "TOPLEFT", 20, -30);
        challengesFrame.rewardsDetailFrame:Show();
    end
end)
