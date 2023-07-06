local _, core = ...; -- Namespace

local EC = {};

core.EC = EC;

local chatEventFrame = CreateFrame("Frame");
chatEventFrame:RegisterEvent("CHAT_MSG_WHISPER");
chatEventFrame:RegisterEvent("CHAT_MSG_BN_WHISPER");
chatEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
local function ChatFrame_MessageEventHandler(self, event, ...)
    local message, sender, _, _, _, _, _, _, _, _, _, guid = ...
    if (event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER") and sender ~= UnitName("player") then
        PlaySound(182875, "Master")
    end

    if event == "PLAYER_ENTERING_WORLD" then
        EC:CreateCopyButtons();
    end

    return false, message, sender, ...
end


chatEventFrame:RegisterEvent("CHAT_MSG_WHISPER")
chatEventFrame:HookScript("OnEvent", ChatFrame_MessageEventHandler)


local chatCopyFrame = CreateFrame("ScrollFrame", "EHUDChatCopyFrame", UIParent, "InputScrollFrameTemplate")
chatCopyFrame:SetPoint("CENTER")
chatCopyFrame:Hide();
chatCopyFrame.CharCount:Hide();

chatCopyFrame.closeButton = CreateFrame("Button", nil, chatCopyFrame, "UIPanelCloseButton");
chatCopyFrame.closeButton:SetPoint("BOTTOMLEFT", chatCopyFrame, "TOPRIGHT", -10, -10);
chatCopyFrame.closeButton:SetScript("OnClick", function(self, arg)
    chatCopyFrame:Hide();
end)


function EC:CreateOneCopyButton(chatFrame)
    if (chatFrame and chatFrame.copyButton) then
        return;
    end

    local button = CreateFrame("Button", nil, chatFrame)
    button.bg = button:CreateTexture(nil, "ARTWORK");
    button.bg:SetTexture("Interface\\AddOns\\EHUD\\assets\\copyChatIcon");
    button.bg:SetAllPoints(button);
    button.texture = button.bg;
    button:SetFrameLevel(7);
    button:SetWidth(18);
    button:SetHeight(18);
    button:SetAlpha(0.5);
    button:SetPoint("TOPRIGHT", -2, -3);
    button:SetScript("OnClick", function(self, arg)
        if (chatCopyFrame:IsVisible()) then
            chatCopyFrame:Hide();
        else
            EC:OpenCopyChatFrame(chatFrame);
        end
    end)



    button:HookScript("OnEnter", function(self)
        button:SetAlpha(0.8);
    end)
    button:HookScript("OnLeave", function(self)
        button:SetAlpha(0.5);
    end)
end

function EC:CreateCopyButtons()
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i];
        if (chatFrame) then
            EC:CreateOneCopyButton(chatFrame);
        end
    end
end

function EC:OpenCopyChatFrame(chatFrame)
    chatCopyFrame:SetSize(500, 300)
    chatCopyFrame.EditBox:SetText("");
    local numOfLines = chatFrame:GetNumMessages() or 0;
    for i = 1, numOfLines do
        local message, r, g, b = chatFrame:GetMessageInfo(i);
        local colorCode = "";
        if (r and g and b) then
            colorCode = RGBToColorCode(r, g, b);
            message = string.gsub(message, "|r", "|r" .. colorCode);
            message = colorCode .. message;
        end
        if (message) then
            chatCopyFrame.EditBox:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
            chatCopyFrame.EditBox:SetWidth(chatCopyFrame:GetWidth() - 30);
            chatCopyFrame.EditBox:Insert(message .. "\n");
        end
    end

    chatCopyFrame:Show();
end
