local _, core = ...; -- Namespace

local dimension = core.config.dimensions.targetFrame
local targetFrame, healthBar, resourceBar = core:CreateUnitFrame(dimension, "target")
targetFrame:SetPoint("CENTER", UIParent, "CENTER", dimension.width, 0)
local spellBarFrame = CreateFrame("STATUSBAR", nil, targetFrame, "TargetSpellBarTemplate")
spellBarFrame:SetPoint("TOPLEFT", targetFrame, "BOTTOMLEFT", 20, -10)

spellBarFrame:SetUnit("target")
spellBarFrame.Icon:SetPoint("TOPRIGHT", spellBarFrame, "TOPLEFT", 0, 0)

targetFrame:Hide();

-- _G["TargetFrame"]:Hide();
-- _G["TargetFrame"]:SetScript("OnEvent", nil);
-- local TF = _G["TargetFrame"]
-- TF.TargetFrameContent.FrameTexture = TF.TargetFrameContent:CreateTexture(nil, "BACKGROUND")
