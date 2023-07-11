local _, core = ...; -- Namespace

local PF = {};
core.PF = PF;

local media = LibStub("LibSharedMedia-3.0")

local playerSecondaryPowerTypes = {
    ROGUE = { 4 },
    DRUID = { 4 },
    DEATHKNIGHT = { 6 },
    WARLOCK = { 7 },
    PALADIN = { 9 },
    MONK = { 12 },
    MAGE = { 16 },
    EVOKER = { 19 }
}

-- Player frame
local playerFrame = _G["PlayerFrame"];
local healthBar = playerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.HealthBar
local defaultHealthBarColor = { r = 1, g = 1, b = 1, a = 1 }

function PF:SetHealthBarColor(color)
    healthBar:SetStatusBarDesaturated(true)
    healthBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
end

function PF:GetPlayerClassColor()
    local _, englishClass = GetPlayerInfoByGUID(UnitGUID("player"))
    local r, g, b, hex = GetClassColor(englishClass)
    return { r = r, g = g, b = b, a = 1 }
end

function PF:ToggleHealthBarColor(value)
    if value then
        if EHUD.db.profile.playerFrame.healthBarColor.useClassColor then
            PF:SetHealthBarColor(PF:GetPlayerClassColor())
        else
            PF:SetHealthBarColor(EHUD.db.profile.playerFrame.healthBarColor.color)
        end
    else
        healthBar:SetStatusBarDesaturated(false)
        healthBar:SetStatusBarColor(defaultHealthBarColor.r, defaultHealthBarColor.g, defaultHealthBarColor.b,
            defaultHealthBarColor.a)
    end
end

-- local playerSecondaryPowerType = nil
-- local playerSecondaryPowerBars = {}
-- local dimension = core.config.dimensions.playerFrame
-- local playerFrame, healthBar, resourceBar = core:CreateUnitFrame(dimension, "player")
-- playerFrame:Hide()
-- playerFrame:SetPoint("CENTER", UIParent, "CENTER", -dimension.width, 0)
-- playerFrame:HookScript("OnLoad", function(self)
--     self:RegisterEvent("PLAYER_LEVEL_CHANGED");
--     self:RegisterEvent("UNIT_FACTION");
--     self:RegisterEvent("PLAYER_ENTERING_WORLD");
--     self:RegisterEvent("PLAYER_ENTER_COMBAT");
--     self:RegisterEvent("PLAYER_LEAVE_COMBAT");
--     self:RegisterEvent("PLAYER_REGEN_DISABLED");
--     self:RegisterEvent("PLAYER_REGEN_ENABLED");
--     self:RegisterEvent("PLAYER_UPDATE_RESTING");
--     self:RegisterEvent("PARTY_LEADER_CHANGED");
--     self:RegisterEvent("GROUP_ROSTER_UPDATE");
--     self:RegisterEvent("READY_CHECK");
--     self:RegisterEvent("READY_CHECK_CONFIRM");
--     self:RegisterEvent("READY_CHECK_FINISHED");
--     self:RegisterEvent("UNIT_ENTERED_VEHICLE");
--     self:RegisterEvent("UNIT_EXITING_VEHICLE");
--     self:RegisterEvent("UNIT_EXITED_VEHICLE");
--     self:RegisterEvent("PVP_TIMER_UPDATE");
--     self:RegisterEvent("PLAYER_ROLES_ASSIGNED");
--     self:RegisterEvent("HONOR_LEVEL_UPDATE");
--     self:RegisterUnitEvent("UNIT_COMBAT", "player", "vehicle");
--     self:RegisterUnitEvent("UNIT_MAXPOWER", "player", "vehicle");
-- end)

-- function EHUD:OnEnable()
--     self:RegisterEvent("PLAYER_ENTERING_WORLD");
-- end

-- function OnUpdateHandler()
--     local playerInfo = core:GetUnitInfo("player")
--     for i = 1, #playerSecondaryPowerBars do
--         if playerInfo.secondaryPower and i <= playerInfo.secondaryPower then
--             playerSecondaryPowerBars[i]:SetValue(100)
--         else
--             playerSecondaryPowerBars[i]:SetValue(0)
--         end
--     end
-- end

-- playerFrame:AddUpdateHandler(OnUpdateHandler)

-- -- Create partial power bar
-- local partialPowerBar = CreateFrame("Frame", nil, playerFrame)
-- partialPowerBar:SetPoint("TOPLEFT", resourceBar, "BOTTOMLEFT", 0, 1)
-- partialPowerBar:SetPoint("TOPRIGHT", resourceBar, "BOTTOMRIGHT", 0, 0)
-- partialPowerBar:SetFrameLevel(1)
-- partialPowerBar:SetHeight(10)
-- partialPowerBar:Hide()

-- local onePartialPowerBackground = partialPowerBar:CreateTexture(nil, "BACKGROUND")
-- onePartialPowerBackground:SetAllPoints(partialPowerBar)
-- onePartialPowerBackground:SetColorTexture(0, 0, 0, 0.8)
-- onePartialPowerBackground:SetDrawLayer("BACKGROUND", 2)


-- -- _G["PlayerFrame"]:SetScript("OnEvent", nil);
-- -- _G["PlayerFrame"]:Hide();

-- function EHUD:PLAYER_ENTERING_WORLD()
--     local secondaryPowerMax = 1

--     local unitSecondaryPowerType = core:GetUnitSecondaryPowerType();
--     if (unitSecondaryPowerType) then
--         partialPowerBar:Show()
--         secondaryPowerMax = UnitPowerMax("player", unitSecondaryPowerType)
--     end
--     -- Create partial power bar
--     if (secondaryPowerMax > 0) then
--         for i = 1, secondaryPowerMax do
--             local onePartialPower = playerSecondaryPowerBars[i] or CreateFrame("StatusBar", nil, partialPowerBar)
--             local partialPowerColor = { r = 0.52, g = 1, b = 0.52 }
--             local relativeParent = playerSecondaryPowerBars[i - 1] or partialPowerBar
--             local relativePoint = playerSecondaryPowerBars[i - 1] and "RIGHT" or "LEFT"
--             onePartialPower:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
--             onePartialPower:SetStatusBarColor(partialPowerColor.r, partialPowerColor.g, partialPowerColor.b, 1)
--             onePartialPower:SetFrameLevel(2)
--             onePartialPower:SetHeight(10)
--             onePartialPower:SetWidth(math.ceil(core.config.dimensions.playerFrame.width / secondaryPowerMax))
--             onePartialPower:SetMinMaxValues(0, 100)
--             onePartialPower:SetValue(0)
--             onePartialPower:SetPoint("LEFT", relativeParent, relativePoint, 0, 0)
--             onePartialPower.border = CreateFrame("Frame", nil, onePartialPower, "BackdropTemplate")
--             onePartialPower.border:SetPoint("TOPLEFT", onePartialPower, 0, 0)
--             onePartialPower.border:SetPoint("BOTTOMRIGHT", onePartialPower, 0, 0)
--             onePartialPower.border:SetBackdrop({
--                 edgeFile = "Interface\\Buttons\\WHITE8x8",
--                 edgeSize = 1,
--             })
--             onePartialPower.border:SetBackdropBorderColor(0, 0, 0)
--             onePartialPower.border:SetFrameLevel(3)
--             onePartialPower.texture = onePartialPower:CreateTexture(nil, "OVERLAY")
--             onePartialPower.texture:SetAllPoints(onePartialPower)
--             onePartialPower.texture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana", true)
--             onePartialPower.texture:SetVertexColor(1, 1, 1, 1)
--             onePartialPower:SetStatusBarTexture(onePartialPower.texture)
--             table.insert(playerSecondaryPowerBars, onePartialPower)
--         end
--     end
-- end

-- function core:GetUnitSecondaryPowerType()
--     local _, unitClass, _ = UnitClass("player")
--     if playerSecondaryPowerTypes[unitClass] then
--         local powerTypes = playerSecondaryPowerTypes[unitClass]
--         for _, value in ipairs(powerTypes) do
--             local secondaryPowerMax = UnitPowerMax("player", value)
--             if secondaryPowerMax > 0 then
--                 return value;
--             end
--         end
--     end
--     return nil;
-- end
