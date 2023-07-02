local L = LibStub("AceLocale-3.0"):GetLocale("EHUD")
local _, core = ...; -- Namespace

local dimensions = core.config.dimensions.buffTracker;
local iconDimensions = dimensions.icon;
local BT = core.BT;

BT.iconFrames = {};

local buffTrackers = EHUD.db and EHUD.db.profile.buffTracker.trackers or {}

local totalNumberOfTrackers = math.floor(dimensions.width / iconDimensions.width);
local function HandleOptions(index)
    local args = {};
    local tracker = buffTrackers[index];
    for i = 1, totalNumberOfTrackers do
        if not tracker["trackingBuffs"] then
            tracker["trackingBuffs"] = {}
        end
        args["buffID" .. i] = {
            type = "group",
            name = L["buffDebuff"] .. i,
            inline = true,
            order = i,
            args = {
                buffID = {
                    type = "input",
                    name = L["buffDebuffID"],
                    width = 0.8,
                    order = 1,
                    get = function()
                        return tostring(tracker["trackingBuffs"][i] and tracker["trackingBuffs"][i]["id"] or "")
                    end,
                    set = function(_, value)
                        if tracker["trackingBuffs"][i] then
                            tracker["trackingBuffs"][i].id = tonumber(value)
                        else
                            tracker["trackingBuffs"][i] = { id = tonumber(value), unit = "player" }
                        end
                    end
                },
                buffName = {
                    type = "description",
                    name = GetSpellName(tracker["trackingBuffs"][i] and tracker["trackingBuffs"][i]["id"] or 0),
                    order = 2
                },
                unit = {
                    type = "select",
                    name = L["unit"],
                    width = 1,
                    order = 2,
                    values = {
                        target = "Target",
                        player = "Player"
                    },
                    get = function()
                        return tracker["trackingBuffs"][i] and tracker["trackingBuffs"][i]["unit"] or "player"
                    end,
                    set = function(_, value)
                        if tracker["trackingBuffs"][i] then
                            tracker["trackingBuffs"][i].unit = value
                        else
                            tracker["trackingBuffs"][i] = { unit = value }
                        end
                    end
                },
                highlight = {
                    type = "toggle",
                    name = L["highlight"],
                    width = 0.5,
                    order = 3,
                    get = function()
                        return tracker["trackingBuffs"][i] and tracker["trackingBuffs"][i]["highlight"] or false
                    end,
                    set = function(_, value)
                        if tracker["trackingBuffs"][i] then
                            tracker["trackingBuffs"][i].highlight = value
                        else
                            tracker["trackingBuffs"][i] = { highlight = value }
                        end
                    end
                }
            }
        }
    end
    EHUD.options.args.buffTrackerSettings.args["buffTracker" .. index] = {
        type = "group",
        name = "Buff Tracker " .. index,
        childGroups = "select",
        args = args
    }
    EHUD.options.args.buffTrackerSettings.args["buffTracker" .. index].args["removeButton"] = {
        type = "execute",
        name = L["remove"],
        order = -1,
        func = function()
            BT:RemoveTrackerFrame(index)
        end
    }
end

function BT:CreateTrackerFrame(trackerIndex, savingTable)
    local points = EHUD.db.profile["buffTracker"]["trackers"]["tracker" .. trackerIndex] or nil
    local containerFrame = CreateFrame("Frame", "buffTrackerFrame" .. trackerIndex, UIParent);
    containerFrame.iconFrames = {};
    containerFrame:SetSize(dimensions.width, dimensions.height);
    containerFrame:SetPoint("CENTER", UIParent, "CENTER", points and points.xOfs or 0, points and points.yOfs or 0);
    containerFrame:SetScript("OnUpdate",
        function(_, elapsed)
            core:OnUpdateHandler(elapsed, BT:OnUpdateHandler(trackerIndex))
        end);
    containerFrame:SetScript("OnDragStart", containerFrame.StartMoving)
    containerFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing();
        SaveFramePoints(self,
            "buffTracker",
            "tracker" .. trackerIndex
        );
    end)
    if savingTable then
        table.insert(buffTrackers, {
            frame = containerFrame,
            trackingBuffs = {}
        });
    else
        buffTrackers[trackerIndex].frame = containerFrame
    end

    -- Create edit mode frame mask
    local editModeFrameMask = CreateFrame("Frame", nil, containerFrame)
    containerFrame.editModeFrameMask = editModeFrameMask
    editModeFrameMask:SetAllPoints(containerFrame)
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
    editModeFrameMaskText:SetText(L["trackerFrame"] .. trackerIndex)
    editModeFrameMask:Hide()

    HandleOptions(#buffTrackers);
    -- Create icon frame
    local totalNumberOfIcons = math.floor(dimensions.width / iconDimensions.width);
    for i = 1, totalNumberOfIcons do
        containerFrame.iconFrames[i] = CreateFrame("Button", nil, containerFrame);
        containerFrame.iconFrames[i]:SetSize(iconDimensions.width, iconDimensions.height);
        containerFrame.iconFrames[i]:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", (i - 1) * iconDimensions.width, 0);
        containerFrame.iconFrames[i].iconTexture = containerFrame.iconFrames[i]:CreateTexture(nil, "BACKGROUND");
        containerFrame.iconFrames[i].iconTexture:SetAllPoints(containerFrame.iconFrames[i]);
        containerFrame.iconFrames[i]:EnableMouse(false);
        containerFrame.iconFrames[i]:Hide();
        -- containerFrame.iconFrames[i]:SetAlpha(0);
        containerFrame.iconFrames[i].animationGroup = containerFrame.iconFrames[i]:CreateAnimationGroup();
        containerFrame.iconFrames[i].animationGroup:SetLooping("BOUNCE");
        containerFrame.iconFrames[i].animation = containerFrame.iconFrames[i].animationGroup:CreateAnimation("Alpha");
        containerFrame.iconFrames[i].animation:SetFromAlpha(0);
        containerFrame.iconFrames[i].animation:SetToAlpha(1);
        containerFrame.iconFrames[i].animation:SetDuration(0.5);
        containerFrame.iconFrames[i].animation:SetSmoothing("IN_OUT");
        -- Create stack text frame
        containerFrame.iconFrames[i].stackTextFrame = CreateFrame("Frame", nil, containerFrame.iconFrames[i]);
        containerFrame.iconFrames[i].stackTextFrame:SetSize(10, 10);
        containerFrame.iconFrames[i].stackTextFrame:SetPoint("BOTTOMRIGHT", containerFrame.iconFrames[i], "BOTTOMRIGHT",
            0, 0);
        containerFrame.iconFrames[i].stackTextFrame.text = containerFrame.iconFrames[i].stackTextFrame:CreateFontString(
            nil, "OVERLAY");
        containerFrame.iconFrames[i].stackTextFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
        containerFrame.iconFrames[i].stackTextFrame.text:SetPoint("CENTER", containerFrame.iconFrames[i].stackTextFrame,
            "CENTER", 0, 3);
        containerFrame.iconFrames[i].stackTextFrame.text:SetTextColor(1, 1, 1, 1);
        containerFrame.iconFrames[i].stackTextFrame.text:SetJustifyH("CENTER");
        containerFrame.iconFrames[i].stackTextFrame.text:SetJustifyV("MIDDLE");
        containerFrame.iconFrames[i].stackTextFrame:Hide();

        containerFrame.iconFrames[i].coolDownFrame = CreateFrame("Cooldown", nil, containerFrame.iconFrames[i],
            "CooldownFrameTemplate");
        containerFrame.iconFrames[i].coolDownFrame:SetAllPoints(containerFrame.iconFrames[i]);
        containerFrame.iconFrames[i].coolDownFrame:SetDrawEdge(true);
        containerFrame.iconFrames[i].coolDownFrame:SetDrawSwipe(true);
        containerFrame.iconFrames[i].coolDownFrame:SetSwipeColor(0, 0, 0, 0.8);
        containerFrame.iconFrames[i].coolDownFrame:SetHideCountdownNumbers(false);
        containerFrame.iconFrames[i].coolDownFrame:SetReverse(true);
    end

    return containerFrame;
end

local function FindAura(unit, id)
    local unitHasAura = false;
    local icon = nil;
    local stack = 0;
    local duration = 0;
    local expirationTime = 0;
    local foundTime = 0;
    local callback = function(checkSource, ...)
        local auraId = select(10, ...);
        local source = select(7, ...);
        if auraId == id and (checkSource and source == "player" or true) then
            unitHasAura = true;
            icon = select(2, ...);
            stack = select(3, ...);
            duration = select(5, ...)
            expirationTime = select(6, ...)
            foundTime = expirationTime - duration;
            return unitHasAura, icon, stack, duration, expirationTime, foundTime;
        end
    end
    AuraUtil.ForEachAura(unit, "HELPFUL", nil, function(...) callback(false, ...) end)
    AuraUtil.ForEachAura(unit, "HARMFUL", nil, function(...) callback(true, ...) end)
    return unitHasAura, icon, stack, duration, expirationTime, foundTime;
end

local function GetUnitAuraInfo(unit, id)
    if not unit or not id then
        return false;
    end
    local unitHasAura, icon, stack, duration, expirationTime, foundTime = FindAura(unit, id);
    return unitHasAura, icon, stack, duration, expirationTime, foundTime;
end

function BT:OnUpdateHandler(trackerIndex)
    local trackingBuffs = buffTrackers[trackerIndex].trackingBuffs;
    local frame = buffTrackers[trackerIndex].frame;
    for i = 1, totalNumberOfTrackers do
        if trackingBuffs[i] then
            local id = trackingBuffs[i].id;
            local unit = trackingBuffs[i].unit;
            local unitHasAura, icon, stack, duration, expirationTime, foundTime = GetUnitAuraInfo(unit, id);
            local highlight = trackingBuffs[i].highlight;
            if unitHasAura then
                local buffTexture = frame.iconFrames[i].iconTexture;
                buffTexture:SetTexture(icon);
                frame.iconFrames[i]:Show();

                -- Show cooldown animation if cooldown > 0
                if foundTime then
                    frame.iconFrames[i].coolDownFrame:SetCooldown(foundTime, duration);
                    frame.iconFrames[i].coolDownFrame:Show();
                end

                -- Show stack text if stack > 0
                if stack > 0 then
                    frame.iconFrames[i].stackTextFrame.text:SetText(stack);
                    frame.iconFrames[i].stackTextFrame:Show();
                end

                if highlight then
                    -- Glow effect frame
                    ActionButton_ShowOverlayGlow(frame.iconFrames[i]);
                else
                    ActionButton_HideOverlayGlow(frame.iconFrames[i]);
                end
            else
                frame.iconFrames[i]:Hide();
            end
        end
    end
end

function BT:Initialize()
    buffTrackers = EHUD.db.profile.buffTracker.trackers;
    for i = 1, #buffTrackers do
        BT:CreateTrackerFrame(i, false);
    end
end

function BT:ToggleEditMode(value)
    if value then
        for i = 1, #buffTrackers do
            local frame = buffTrackers[i].frame;
            frame:SetAlpha(1);
            frame.editModeFrameMask:Show()
            frame:EnableMouse(true)
            frame:SetMovable(true)
            frame:RegisterForDrag("LeftButton")
        end
    else
        for i = 1, #buffTrackers do
            local frame = buffTrackers[i].frame;
            frame:SetMovable(false)
            frame:EnableMouse(false)
            frame.editModeFrameMask:Hide()
            frame:SetScript("OnDragStart", nil)
            frame:SetScript("OnDragStop", nil)
        end
    end
end

function BT:RemoveTrackerFrame(index)
    buffTrackers[index].frame:Hide();
    buffTrackers[index].frame = nil;
    table.remove(buffTrackers, index);
    EHUD.options.args.buffTrackerSettings.args["buffTracker" .. index] = nil
end
