local L = LibStub("AceLocale-3.0"):GetLocale("EHUD")


local _, core = ...; -- Namespace
local UF = {
    frames = {}
};
core.UF = UF;

function core:CreateUnitFrame(dimension, unit)
    local unitFrame = CreateFrame("Button", unit .. "Frame", UIParent, "SecureUnitButtonTemplate")
    UF.frames[unit .. "Frame"] = unitFrame;
    unitFrame.unit = unit;
    unitFrame:SetAttribute("unit", unit)
    unitFrame:SetSize(dimension.width, dimension.height)
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetScript("OnEnter", UnitFrame_OnEnter)
    unitFrame:SetScript("OnLeave", UnitFrame_OnLeave)
    unitFrame:SetAttribute("type1", "target")
    unitFrame:SetAttribute("type2", "togglemenu")
    unitFrame:SetScript("OnDragStart", unitFrame.StartMoving)
    unitFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing();
        SaveFramePoints(self,
            "unitFrame",
            self:GetName()
        );
    end)
    unitFrame:SetScript("OnUpdate",
        function(_, elapsed) core:OnUpdateHandler(elapsed, UF:OnUpdateHandler(unitFrame, unit)) end)
    unitFrame.AddUpdateHandler = function(_, handler)
        unitFrame:HookScript("OnUpdate", function(_, elapsed) core:OnUpdateHandler(elapsed, handler) end)
    end
    local unitFrameBackground = unitFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
    unitFrameBackground:SetAllPoints(unitFrame)
    unitFrameBackground:SetColorTexture(0, 0, 0, 0.8)


    -- Get class color
    local _, class = UnitClass(unit)
    local color = RAID_CLASS_COLORS[class] or { r = 0, g = 1, b = 0 }

    -- Create health bar
    local healthBar = CreateFrame("StatusBar", "PlayerHealth", unitFrame)
    unitFrame.healthBar = healthBar
    unitFrame.healthBar.currentHealth = 0;
    healthBar:SetSize(dimension.healthBar.width, dimension.healthBar.height)
    healthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 0, 0)
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetFrameLevel(3)

    healthBar.texture = healthBar:CreateTexture(nil, "BACKGROUND", nil, 0)
    healthBar.texture:SetAllPoints(healthBar)
    healthBar.texture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health", true)
    healthBar:SetStatusBarTexture(healthBar.texture)


    local healthBarBorder = CreateFrame("Frame", nil, healthBar, "BackdropTemplate")
    healthBarBorder:SetPoint("TOPLEFT", healthBar, 0, 0)
    healthBarBorder:SetPoint("BOTTOMRIGHT", healthBar, 0, 0)
    healthBarBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    healthBarBorder:SetBackdropBorderColor(0, 0, 0)
    -- healthBarBorder:SetFrameLevel(3)

    -- Create resource bar
    local resourceBar = CreateFrame("StatusBar", nil, healthBar)
    unitFrame.resourceBar = resourceBar
    resourceBar:SetHeight(10)
    resourceBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, 1)
    resourceBar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)
    resourceBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    resourceBar:SetStatusBarColor(0, 0, 0, 1)
    resourceBar:SetMinMaxValues(0, 100)
    -- resourceBar:SetFrameLevel(2)

    local resourceBarBackground = resourceBar:CreateTexture(nil, "BACKGROUND")
    resourceBarBackground:SetAllPoints(resourceBar)
    resourceBarBackground:SetColorTexture(0, 0, 0, 0.8)
    resourceBarBackground:SetDrawLayer("BACKGROUND", 1)

    local resourceBarBorder = CreateFrame("Frame", nil, resourceBar, "BackdropTemplate")
    resourceBarBorder:SetPoint("TOPLEFT", resourceBar, 0, 0)
    resourceBarBorder:SetPoint("BOTTOMRIGHT", resourceBar, 0, 0)
    resourceBarBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    resourceBarBorder:SetBackdropBorderColor(0, 0, 0)
    resourceBarBorder:SetFrameLevel(3)

    resourceBar.texture = resourceBar:CreateTexture(nil, "OVERLAY")
    resourceBar.texture:SetAllPoints(resourceBar)
    resourceBar.texture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana", true)
    resourceBar:SetStatusBarTexture(resourceBar.texture)


    -- Create player health percentage text
    healthBar.percentageText = healthBar:CreateFontString(nil, "OVERLAY")
    healthBar.percentageText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    healthBar.percentageText:SetPoint("LEFT", healthBar, "LEFT", 5, 0)
    healthBar.percentageText:SetTextColor(1, 1, 1, 1)
    healthBar.percentageText:SetJustifyH("LEFT")
    healthBar.percentageText:SetJustifyV("MIDDLE")
    healthBar.percentageText:SetText("100%")

    -- Create player health text
    healthBar.healthText = healthBar:CreateFontString(nil, "OVERLAY")
    healthBar.healthText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    healthBar.healthText:SetPoint("RIGHT", healthBar, "RIGHT", -5, 0)
    healthBar.healthText:SetTextColor(1, 1, 1, 1)
    healthBar.healthText:SetJustifyH("RIGHT")
    healthBar.healthText:SetJustifyV("MIDDLE")
    healthBar.healthText:SetText("100")

    -- Create unit receiving healing bar
    local healingBar = CreateFrame("StatusBar", nil, healthBar)
    unitFrame.healingBar = healingBar
    healingBar:SetMinMaxValues(0, 100)
    healingBar:SetAllPoints(healthBar)
    healingBar:SetFrameLevel(healthBar:GetFrameLevel() - 1)
    healingBar.texture = healingBar:CreateTexture(nil, "BACKGROUND", "MyHealPredictionBarTemplate", 1)
    healingBar:SetStatusBarTexture(healingBar.texture)

    -- Craete unit absorb bar
    local absorbBar = CreateFrame("StatusBar", nil, healthBar)
    unitFrame.absorbBar = absorbBar
    absorbBar:SetMinMaxValues(0, 100)
    absorbBar:SetAllPoints(healthBar)
    absorbBar:SetFrameLevel(healthBar:GetFrameLevel() - 2)
    absorbBar.texture = absorbBar:CreateTexture(nil, "BACKGROUND", "TotalAbsorbBarTemplate", 1)
    -- absorbBar.texture:SetAllPoints(absorbBar)
    absorbBar:SetStatusBarTexture(absorbBar.texture)
    -- Health bar absorb over glow
    healthBar.overGlowFrame = CreateFrame("Frame", nil, healthBar)
    healthBar.overGlowFrame:SetFrameLevel(healthBar:GetFrameLevel() + 1)
    healthBar.overGlowFrame:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 7, 0)
    healthBar.overGlowFrame:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 7, 0)
    healthBar.overGlowFrame:SetWidth(15)
    healthBar.overGlow = healthBar.overGlowFrame:CreateTexture(nil, "OVERLAY", "OverAbsorbGlowTemplate")
    healthBar.overGlow:SetBlendMode("ADD")
    healthBar.overGlow:SetAllPoints(healthBar.overGlowFrame)
    healthBar.overGlowFrame:Hide()


    -- Health loss animation frame
    local healthLossFrame = CreateFrame("StatusBar", nil, healthBar)
    healthLossFrame:SetMinMaxValues(0, 100);
    healthLossFrame:SetAllPoints(healthBar)
    healthLossFrame:SetFrameLevel(healthBar:GetFrameLevel() + 1)

    healthLossFrame.texture = healthLossFrame:CreateTexture(nil, "OVERLAY")
    healthLossFrame.texture:SetColorTexture(1, 0, 0, 0.5)
    healthLossFrame.texture:SetBlendMode("ADD")
    healthLossFrame:SetStatusBarTexture(healthLossFrame.texture);
    healthLossFrame:SetAlpha(0);
    healthBar.healthLossFrame = healthLossFrame

    -- Health loss animation
    local healthLossAnimation = healthLossFrame:CreateAnimationGroup()
    healthLossAnimation:SetLooping("NONE")
    healthLossAnimation:HookScript("OnFinished", function(self)
        healthLossFrame:SetAlpha(0)
    end)
    local healthLossAnimation1 = healthLossAnimation:CreateAnimation("Alpha")
    healthLossAnimation1:SetDuration(0.5)
    healthLossAnimation1:SetFromAlpha(0)
    healthLossAnimation1:SetToAlpha(1)
    healthLossAnimation1:SetOrder(1)
    healthLossAnimation1:HookScript("OnFinished", function(self)
        healthLossFrame:SetValue(healthBar:GetValue());
    end)
    local healthLossAnimation2 = healthLossAnimation:CreateAnimation("Alpha")
    healthLossAnimation2:SetDuration(0.5)
    healthLossAnimation2:SetFromAlpha(1)
    healthLossAnimation2:SetToAlpha(0)
    healthLossAnimation2:SetOrder(2)
    healthLossAnimation2:SetEndDelay(0.2)


    healthBar.healthLossAnimation = healthLossAnimation




    -- Create edit mode frame mask
    local editModeFrameMask = CreateFrame("Frame", nil, unitFrame)
    unitFrame.editModeFrameMask = editModeFrameMask
    editModeFrameMask:SetAllPoints(unitFrame)
    editModeFrameMask:SetFrameLevel(100)
    local editModeFrameMaskTexture = editModeFrameMask:CreateTexture(nil, "OVERLAY")
    editModeFrameMaskTexture:SetAllPoints(editModeFrameMask)
    editModeFrameMaskTexture:SetColorTexture(0, 0, 0, 0.8)
    editModeFrameMaskTexture:SetBlendMode("BLEND")
    local editModeFrameMaskText = editModeFrameMask:CreateFontString(nil, "OVERLAY")
    editModeFrameMaskText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    editModeFrameMaskText:SetPoint("CENTER", editModeFrameMask, "CENTER", 0, 0)
    editModeFrameMaskText:SetTextColor(1, 1, 1, 1)
    editModeFrameMaskText:SetJustifyH("CENTER")
    editModeFrameMaskText:SetJustifyV("MIDDLE")
    editModeFrameMaskText:SetText(L[unit .. "Frame"])
    editModeFrameMask:Hide()



    return unitFrame, healthBar, resourceBar
end

function core:GetUnitInfo(unit)
    if not UnitExists(unit) then
        return nil
    end
    local _, unitClass, _ = UnitClass(unit)
    local unitHealthMax = UnitHealthMax(unit)
    local unitHealth = UnitHealth(unit)
    local unitHealthPercent = math.floor(unitHealth / unitHealthMax * 100)
    local unitPowerMax = UnitPowerMax(unit)
    local unitPower = UnitPower(unit)
    local unitPowerPercent = unitPowerMax == 0 and 0 or math.floor(unitPower / unitPowerMax * 100)
    local secondaryPowerType = core:GetUnitSecondaryPowerType()
    local secondaryPower = nil
    local secondaryPowerMax = nil

    if secondaryPowerType then
        secondaryPower = UnitPower(unit, secondaryPowerType)
        secondaryPowerMax = UnitPowerMax(unit, secondaryPowerType)
    end


    return {
        unitClass = unitClass,
        unitHealthMax = unitHealthMax,
        unitHealth = unitHealth,
        unitHealthPercent = unitHealthPercent,
        unitPowerMax = unitPowerMax,
        unitPower = unitPower,
        unitPowerPercent = unitPowerPercent,
        secondaryPower = secondaryPower,
        secondaryPowerMax = secondaryPowerMax,
    }
end

function UF:OnUpdateHandler(frame, unit)
    if not UnitExists(unit) then
        if not core.isEditMode then
            frame:EnableMouse(false)
            frame:SetAlpha(0)
        end
    else
        frame:SetAlpha(1)
        frame:EnableMouse(true)
    end
    local unitInfo = core:GetUnitInfo(unit)


    if unitInfo then
        local _, powerToken, altR, altG, altB = UnitPowerType(unit)
        local powerColor = PowerBarColor[powerToken]
        local heal = UnitGetIncomingHeals(unit) or 0
        local absorb = UnitGetTotalAbsorbs(unit) or 0
        if (unitInfo.unitHealth + heal) > unitInfo.unitHealthMax then
            heal = unitInfo.unitHealthMax - unitInfo.unitHealth
        end

        if (unitInfo.unitHealth + absorb + heal) > unitInfo.unitHealthMax then
            absorb = unitInfo.unitHealthMax - unitInfo.unitHealth + heal
            frame.healthBar.overGlowFrame:Show()
        else
            absorb = absorb + heal
            frame.healthBar.overGlowFrame:Hide()
        end

        frame.absorbBar:SetValue(math.floor((unitInfo.unitHealth + absorb) / unitInfo.unitHealthMax * 100))
        frame.healingBar:SetValue(math.floor((unitInfo.unitHealth + heal) / unitInfo.unitHealthMax * 100))
        frame.resourceBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b, 1)
        frame.healthBar:SetValue(unitInfo.unitHealthPercent)
        frame.resourceBar:SetValue(unitInfo.unitPowerPercent)
        frame.healthBar.healthText:SetText(unitInfo.unitHealth)
        frame.healthBar.percentageText:SetText(unitInfo.unitHealthPercent .. "%")
        if unitInfo.unitHealth < frame.healthBar.currentHealth then
            frame.healthBar.healthLossAnimation:Play()
        end
        if not frame.healthBar.healthLossAnimation:IsPlaying() then
            frame.healthBar.healthLossFrame:SetValue(frame.healthBar:GetValue())
        end
        frame.healthBar.currentHealth = unitInfo.unitHealth;
    end
end

function UF:ToggleEditMode(value)
    if value then
        for _, unitFrame in pairs(UF.frames) do
            unitFrame:SetAlpha(1);
            unitFrame.editModeFrameMask:Show()
            unitFrame:EnableMouse(true)
            unitFrame:SetMovable(true)
            unitFrame:RegisterForDrag("LeftButton")
        end
    else
        for _, unitFrame in pairs(UF.frames) do
            unitFrame:SetMovable(false)
            unitFrame.editModeFrameMask:Hide()
            unitFrame:SetScript("OnDragStart", nil)
            unitFrame:SetScript("OnDragStop", nil)
        end
    end
end
