local _, core = ...; -- Namespace
local AceGUI = LibStub("AceGUI-3.0")
EHUD = LibStub("AceAddon-3.0"):NewAddon("EHUD", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EHUD")



core.UF = {}
core.BT = {}
core.ECF = {}
core.PF = {}
core.EB = {}
core.EDR = {}
core.CT = {}
core.config = {};
core.config.dimensions = {
    playerFrame = {
        width = 220,
        height = 50,
        healthBar = {
            width = 220,
            height = 40,
        },

    },
    targetFrame = {
        width = 220,
        height = 50,
        healthBar = {
            width = 220,
            height = 40,
        },
    },
    buffTracker = {
        width = 300,
        height = 30,
        icon = {
            width = 30,
            height = 30,
        },
    }
}
local timeElapsed = 0
function core:OnUpdateHandler(elapsed, handler)
    timeElapsed = timeElapsed + elapsed
    while (timeElapsed > 0.05) do
        timeElapsed = timeElapsed - 0.05
        if (handler) then
            handler()
        end
    end
end

EHUD.options = {
    name = "EHUD",
    handler = EHUD,
    type = "group",
    args = {
        editMode = {
            type = "toggle",
            name = L["editMode"],
            desc = L["editModeDesc"],
            get = "isEditMode",
            set = "setEditMode",
        },
        buffTrackerSettings = {
            type = "group",
            name = L["buffTracker"],
            childGroups = "select",
            args = {
                addButton = {
                    order = 1,
                    type = "execute",
                    name = L["add"],
                    func = function()
                        local newTrackerIndex = #EHUD.db.class.buffTracker.trackers + 1
                        core.BT:CreateTrackerFrame(newTrackerIndex, true)
                    end,
                },
            },
        },
        playerFrameSettings = {
            type = "group",
            name = L["playerFrame"],
            args = {
                playerFrameHitIndicator = {
                    type = "range",
                    name = L["playerFrameHitIndicator"],
                    min = 1,
                    max = 30,
                    step = 1,
                    get = function()
                        return _G["PlayerFrame"].feedbackFontHeight
                    end,
                    set = function(info, value)
                        EHUD.db.profile.playerFrame.hitIndicatorFontSize = value
                        _G["PlayerFrame"].feedbackFontHeight = value
                    end,
                    width = "full",
                },
                healthBarColorOptions = {
                    type = "group",
                    name = L["healthBarColor"],
                    inline = true,
                    args = {
                        enable = {
                            order = 0,
                            type = "toggle",
                            name = L["enable"],
                            get = function()
                                return EHUD.db.profile.playerFrame.healthBarColor.enabled
                            end,
                            set = function(info, value)
                                EHUD.db.profile.playerFrame.healthBarColor.enabled = value
                                core.PF:ToggleHealthBarColor(value);
                            end,
                        },
                        useClassColor = {
                            type = "toggle",
                            name = L["useClassColor"],
                            hidden = function()
                                return not EHUD.db.profile.playerFrame.healthBarColor.enabled
                            end,
                            get = function()
                                return EHUD.db.profile.playerFrame.healthBarColor.useClassColor
                            end,
                            set = function(info, value)
                                EHUD.db.profile.playerFrame.healthBarColor.useClassColor = value
                                if value then
                                    core.PF:SetHealthBarColor(core.PF:GetPlayerClassColor())
                                else
                                    core.PF:SetHealthBarColor(
                                        EHUD.db.profile.playerFrame.healthBarColor)
                                end
                            end,

                        },
                        healthBarColorPicker = {
                            type = "color",
                            name = L["healthBarColor"],
                            hidden = function()
                                return not EHUD.db.profile.playerFrame.healthBarColor.enabled or
                                    EHUD.db.profile.playerFrame.healthBarColor.useClassColor
                            end,
                            hasAlpha = true,
                            get = function()
                                local color = EHUD.db.profile.playerFrame.healthBarColor.color
                                return color.r, color.g, color.b, color.a
                            end,
                            set = "setHealthBarColor",
                        }
                    }
                }

            }
        },
        durabilityDisplay = {
            type = "group",
            name = L["durabilityDisplay"],
            args = {
                toggle = {
                    type = "toggle",
                    name = L["enable"],
                    get = "isDurabilityDisplayEnabled",
                    set = "setDurabilityDisplayEnabled",
                },
            }
        },
        enhancedMythicPlusDisplay = {
            type = "group",
            name = L["enhancedMythicPlusDisplay"],
            args = {
                toggle = {
                    type = "toggle",
                    name = L["enable"],
                    get = "isEMPEnabled",
                    set = "setEMPEnabled",
                },
            }
        },
        fineTuneHUD = {
            type = "group",
            name = L["fineTuneHUD"],
            args = {
                toggle = {
                    type = "toggle",
                    name = L["enable"],
                    get = "isFineTuneHUDEnabled",
                    set = "setFineTuneHUDEnabled",
                },
            }
        },
        enhancedDragonRiding = {
            type = "group",
            name = L["enhancedDragonRiding"],
            args = {
                dragonRidingSpeedometer = {
                    type = "group",
                    name = L["dragonRidingSpeedometer"],
                    args = {
                        toggle = {
                            type = "toggle",
                            name = L["enable"],
                            get = "isDragonRidingSpeedometerEnabled",
                            set = "setDragonRidingSpeedometerEnabled",
                        },

                    }
                }
            }
        },
        combatText = {
            type = "group",
            name = L["combatText"],
            args = {
                toggle = {
                    type = "toggle",
                    name = L["enable"],
                    get = function()
                        return EHUD.db.profile.combatText.enable
                    end,
                    set = function(info, value)
                        EHUD.db.profile.combatText.enable = value
                        core.CT:Toggle(value)
                    end,
                },
                showBackground = {
                    type = "toggle",
                    name = L["showBackground"],
                    get = function()
                        return EHUD.db.profile.combatText.showBackground
                    end,
                    set = function(info, value)
                        EHUD.db.profile.combatText.showBackground = value
                        core.CT:ToggleBackground(value)
                    end,
                }
            }
        }
    }
}


local defaultConfigs = {
    profile = {
        savedFramePoints = {

        },
        playerFrame = {
            point = "CENTER",
            relativePoint = "CENTER",
            xOfs = 0,
            yOfs = 0,
            containerWidth = core.config.dimensions.playerFrame.width,
            containerHeight = core.config.dimensions.playerFrame.height,
            healthBarColor = {
                enabled = true,
                useClassColor = true,
                color = {
                    r = 1,
                    g = 1,
                    b = 1,
                    a = 1
                }
            }
        },
        targetFrame = {
            point = "CENTER",
            relativePoint = "CENTER",
            xOfs = 0,
            yOfs = 0,
            containerWidth = core.config.dimensions.targetFrame.width,
            containerHeight = core.config.dimensions.targetFrame.height,
        },
        buffTracker = {
            trackers = {}
        },
        durabilityDisplay = {
            enable = true
        },
        enhancedMythicPlusDisplay = {
            enable = true
        },
        fineTuneHUD = {
            enable = true
        },
        enhancedDragonRiding = {
            enable = true
        },
        combatText = {
            enable = true,
            showBackground = true,
            point = "CENTER",
            relativePoint = "CENTER",
            xOfs = 0,
            yOfs = 0,
            containerWidth = core.config.dimensions.targetFrame.width,
            containerHeight = core.config.dimensions.targetFrame.height,
        },
    },
    class = {
        buffTracker = {
            trackers = {}
        },
    }
}


function SaveFramePoints(frame, type, name)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()

    if type == "buffTracker" then
        EHUD.db.class.buffTracker.trackers[name] = {
            point = point,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs,
            containerWidth = frame:GetWidth(),
            containerHeight = frame:GetHeight(),
        }
    else
        EHUD.db.profile.savedFramePoints[name] = {
            point = point,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs,
            containerWidth = frame:GetWidth(),
            containerHeight = frame:GetHeight(),
        }
    end
end

function core:GetFramePoints(name)
    return EHUD.db.profile.savedFramePoints[name]
end

local function handleFramePoints()
    if core.UF then
        for name, frame in pairs(core.UF.frames) do
            local points = EHUD.db.profile[name]
            frame:SetWidth(points.containerWidth)
            frame:SetHeight(points.containerHeight)
            frame:SetPoint(points.point, UIParent, points.relativePoint, points.xOfs, points.yOfs)
        end
    end
end

function MoveBuiltInFramesMovable()
    SetFrameMovable(_G["SettingsPanel"])
    SetFrameMovable(_G["CharacterFrame"])
end

function EHUD:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("EHUDDB", defaultConfigs, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("EHUD", EHUD.options)
    SLASH_RELOADUI1 = "/rl"; -- new slash command for reloading UI
    SlashCmdList.RELOADUI = ReloadUI;
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("EHUD", "EHUD")
    handleFramePoints();

    _G["PlayerFrame"].feedbackFontHeight = EHUD.db.profile.playerFrame.hitIndicatorFontSize
    MoveBuiltInFramesMovable();
    core.FineTune:Initialize();
    core.CT:Initialize();
    -- -- Copy buffTracker Data from profile to class
    -- if self.db.profile.buffTracker then
    --     self.db.class.buffTracker = self.db.profile.buffTracker
    -- end
end

function EHUD:PLAYER_ENTERING_WORLD()
    core.BT:Initialize();
    core.PF:ToggleHealthBarColor(EHUD.db.profile.playerFrame.healthBarColor.enabled)
    core.EDR:Initialize();
end

function EHUD:PLAYER_SPECIALIZATION_CHANGED()
    local buffTrackers = EHUD.db.class.buffTracker.trackers;
    local specs, currentSpec = GetPlayerSpecs();
    for i = 1, #buffTrackers do
        core.BT:HandleBuffTrackerVisible(i, currentSpec);
    end
end

SLASH_EHUDOPTIONS1 = '/ehud';
function SlashCmdList.EHUDOPTIONS(msg, editBox)
    InterfaceOptionsFrame_OpenToCategory("EHUD");
    InterfaceOptionsFrame_OpenToCategory("EHUD");
end

-- Setting Functions
function EHUD:isEditMode()
    return core.isEditMode
end

function EHUD:setEditMode(info, value)
    core.isEditMode = value
    if core.UF then
        core.UF:ToggleEditMode(value)
    end

    if core.BT then
        core.BT:ToggleEditMode(value)
    end

    if core.CT then
        core.CT:ToggleEditMode(value)
    end
end

function EHUD:isDurabilityDisplayEnabled()
    return EHUD.db.profile.durabilityDisplay.enable
end

function EHUD:setDurabilityDisplayEnabled(info, value)
    EHUD.db.profile.durabilityDisplay.enable = value
    core.ECF:ToggleDurabilityFrame(value)
end

function EHUD:isEMPEnabled()
    return EHUD.db.profile.enhancedMythicPlusDisplay.enable
end

function EHUD:setEMPEnabled(info, value)
    EHUD.db.profile.enhancedMythicPlusDisplay.enable = value
end

function EHUD:isFineTuneHUDEnabled()
    return EHUD.db.profile.fineTuneHUD.enable
end

function EHUD:setFineTuneHUDEnabled(info, value)
    EHUD.db.profile.fineTuneHUD.enable = value
    core.FineTune:Toggle(value)
end

function EHUD:setHealthBarColor(info, r, g, b, a)
    EHUD.db.profile.playerFrame.healthBarColor.color = { r = r, g = g, b = b, a = a }
    core.PF:SetHealthBarColor({ r = r, g = g, b = b, a = a })
end

function EHUD:isDragonRidingSpeedometerEnabled()
    return EHUD.db.profile.enhancedDragonRiding.enable
end

function EHUD:setDragonRidingSpeedometerEnabled(info, value)
    EHUD.db.profile.enhancedDragonRiding.enable = value
end

-- Events
EHUD:RegisterEvent("PLAYER_ENTERING_WORLD");
EHUD:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
