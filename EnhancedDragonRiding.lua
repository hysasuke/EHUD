local _, core = ...; -- Namespace

local EDR = {};

core.EDR = EDR;
local powerBarContainer = _G["UIWidgetPowerBarContainerFrame"];


local COLOR_PALETTES = {
    [0] = CreateColor(0, 1, 0),
    [1] = CreateColor(1, 1, 0),
    [2] = CreateColor(1, 0.5, 0),
    [3] = CreateColor(1, 0, 0)
}
local MAX_SPEED = 1428;
local function CreateGlidingSpeedProgressBar()
    local bar = CreateFrame("StatusBar", nil, powerBarContainer);
    bar:SetPoint("CENTER", UIParent, "CENTER", -150, 0);
    bar:SetSize(80, 180);
    bar:SetOrientation("VERTICAL");
    bar:SetMinMaxValues(0, 100);
    bar:SetValue(0);
    bar:Hide();
    bar:SetStatusBarTexture("Interface\\AddOns\\EHUD\\assets\\speedometer_red")
    -- Background
    bar.background = bar:CreateTexture(nil, "OVERLAY");
    bar.background:SetAllPoints();
    bar.background:SetTexture("Interface\\AddOns\\EHUD\\assets\\speedometer_background_red")

    return bar;
end

local function CreateMovementSpeedProgressBar()
    local bar = CreateFrame("StatusBar", nil, powerBarContainer);
    local relativeFrame = powerBarContainer.GlidingSpeedBar or powerBarContainer;
    bar:SetPoint("CENTER", UIParent, "CENTER", 150, 0);
    bar:SetSize(80, 180);
    bar:SetOrientation("VERTICAL");
    bar:SetMinMaxValues(100, MAX_SPEED);
    bar:SetValue(0);
    bar:Hide();
    bar:SetStatusBarTexture("Interface\\AddOns\\EHUD\\assets\\speedometer_blue")
    -- Background
    bar.background = bar:CreateTexture(nil, "OVERLAY");
    bar.background:SetAllPoints();
    bar.background:SetTexture("Interface\\AddOns\\EHUD\\assets\\speedometer_background_blue")

    return bar;
end


function EDR:Initialize()
    powerBarContainer.GlidingSpeedBar = powerBarContainer.GlidingSpeedBar or CreateGlidingSpeedProgressBar();
    powerBarContainer.MovementSpeedBar = powerBarContainer.MovementSpeedBar or CreateMovementSpeedProgressBar();

    powerBarContainer.GlidingSpeedBar.StartAnimation = function(self, value)
        powerBarContainer.GlidingSpeedBar.targetValue = value;
        powerBarContainer.GlidingSpeedBar.startTime = GetTime();
        powerBarContainer.GlidingSpeedBar:SetScript("OnUpdate", function(self, elapsed)
            local duration = 1;
            local valueDifference = self.targetValue - self:GetValue();
            local progress = (GetTime() - self.startTime) / duration;
            if progress > 1 then
                progress = 1;
                self:SetScript("OnUpdate", nil);
            end
            self:SetValue(self:GetValue() + valueDifference * progress);
        end);
    end

    powerBarContainer.MovementSpeedBar.StartAnimation = function(self, value)
        powerBarContainer.MovementSpeedBar.targetValue = value;
        powerBarContainer.MovementSpeedBar.startTime = GetTime();
        powerBarContainer.MovementSpeedBar:SetScript("OnUpdate", function(self, elapsed)
            local duration = 1;
            local valueDifference = self.targetValue - self:GetValue();
            local progress = (GetTime() - self.startTime) / duration;
            if progress > 1 then
                progress = 1;
                self:SetScript("OnUpdate", nil);
            end
            self:SetValue(self:GetValue() + valueDifference * progress);
        end);
    end

    C_Timer.NewTicker(.1, function()
        local enabled = EHUD.db.profile.enhancedDragonRiding.enable
        local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
        local base = isGliding and forwardSpeed or GetUnitSpeed("player")
        local movespeed = Round(base / BASE_MOVEMENT_SPEED * 100)
        movespeed = movespeed < 0 and -movespeed or movespeed
        if powerBarContainer.GlidingSpeedBar then
            powerBarContainer.GlidingSpeedBar:StartAnimation(forwardSpeed);
            powerBarContainer.GlidingSpeedBar:SetShown(enabled and canGlide);
        end

        if powerBarContainer.MovementSpeedBar then
            powerBarContainer.MovementSpeedBar:StartAnimation(movespeed);
            powerBarContainer.MovementSpeedBar:SetShown(enabled and canGlide);
        end
    end)
end
