local _, core = ...; -- Namespace
local AceGUI = LibStub("AceGUI-3.0")
EHUD = LibStub("AceAddon-3.0"):NewAddon("EHUD", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EHUD")
core.UF = {}
core.BT = {}
core.IDD = {}
core.PF = {}
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
        }
    }
}


local defaultConfigs = {
    profile = {
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
        }
    },
    class = {
        buffTracker = {
            trackers = {}
        },
    }
}


function SaveFramePoints(frame, type, name)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()

    if type == "unitFrame" then
        EHUD.db.profile[name] = {
            point = point,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs,
            containerWidth = frame:GetWidth(),
            containerHeight = frame:GetHeight(),
        }
    elseif type == "buffTracker" then
        EHUD.db.class.buffTracker.trackers[name] = {
            point = point,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs,
            containerWidth = frame:GetWidth(),
            containerHeight = frame:GetHeight(),
        }
    end
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
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("EHUD", "EHUD")
    handleFramePoints();
    core.BT:Initialize()
    _G["PlayerFrame"].feedbackFontHeight = EHUD.db.profile.playerFrame.hitIndicatorFontSize
    MoveBuiltInFramesMovable();
    core.FineTune:Initialize();
    core.PF:ToggleHealthBarColor(EHUD.db.profile.playerFrame.healthBarColor.enabled)
    -- -- Copy buffTracker Data from profile to class
    -- if self.db.profile.buffTracker then
    --     self.db.class.buffTracker = self.db.profile.buffTracker
    -- end
end

SLASH_EHUDOPTIONS1 = '/ehud';
function SlashCmdList.EHUDOPTIONS(msg, editBox)
    InterfaceOptionsFrame_OpenToCategory("EHUD");
    InterfaceOptionsFrame_OpenToCategory("EHUD");
end

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
end

function EHUD:isDurabilityDisplayEnabled()
    return EHUD.db.profile.durabilityDisplay.enable
end

function EHUD:setDurabilityDisplayEnabled(info, value)
    EHUD.db.profile.durabilityDisplay.enable = value
    core.IDD:ToggleDurabilityFrame(value)
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
