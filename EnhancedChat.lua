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

-- Copied from ElvUI /ElvUI/Core/Modules/Chat/Chat.lua
local function removeExtraCharacters(text)
    local raidIconFunc = function(x)
        x = x ~= '' and _G['RAID_TARGET_' .. x]; return x and ('{' .. strlower(x) .. '}') or ''
    end
    local stripTextureFunc = function(w, x, y) if x == '' then return (w ~= '' and w) or (y ~= '' and y) or '' end end
    local hyperLinkFunc = function(w, x, y)
        if w ~= '' then return end
        local emoji = (x ~= '' and x) and strmatch(x, 'elvmoji:%%(.+)')
        return (emoji and E.Libs.Deflate:DecodeForPrint(emoji)) or y
    end
    local fourString = function(v, w, x, y)
        return format('%s%s%s', v, w, (v and v == '1' and x) or y)
    end
    text = gsub(text, [[|TInterface\TargetingFrame\UI%-RaidTargetingIcon_(%d+):0|t]], raidIconFunc) --converts raid icons into {star} etc, if possible.
    text = gsub(text, '(%s?)(|?)|[TA].-|[ta](%s?)', stripTextureFunc)                               --strip any other texture out but keep a single space from the side(s).
    text = gsub(text, '(|?)|H(.-)|h(.-)|h', hyperLinkFunc)                                          --strip hyperlink data only keeping the actual text.
    text = gsub(text, '(%d+)(.-)|4(.-):(.-);', fourString)                                          --stuff where it goes 'day' or 'days' like played; tech this is wrong but okayish
    return text
end

function EC:OpenCopyChatFrame(chatFrame)
    chatCopyFrame:SetSize(500, 300)
    chatCopyFrame.EditBox:SetText("");
    local numOfLines = chatFrame:GetNumMessages() or 0;
    for i = 1, numOfLines do
        local message, r, g, b = chatFrame:GetMessageInfo(i);
        local colorCode = RGBToColorCode(1, 1, 1);
        message = removeExtraCharacters(message);
        if (r and g and b) then
            colorCode = RGBToColorCode(r, g, b);
            message = format('%s%s|r', colorCode, message);
            message = colorCode .. message;
        end

        if (message) then
            chatCopyFrame.EditBox:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
            chatCopyFrame.EditBox:SetWidth(chatCopyFrame:GetWidth() - 30);
            chatCopyFrame.EditBox:Insert(message);

            if (i < numOfLines) then
                chatCopyFrame.EditBox:Insert("\n");
            end
        end
    end

    chatCopyFrame:Show();
end
