local frame, scroll, content
local dragIndex = nil


GetSpellInfo = C_Spell.GetSpellInfo


-- 우선순위 리스트 표시
function ShowPriorityOptions()
    if frame and frame:IsShown() then
        frame:Hide()
        return
    end

    frame = CreateFrame("Frame", "InterruptPriorityOptions", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 400)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMoving)

    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -10)
    frame.title:SetText("Interrupt Priority")

    scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -35)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)

    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(250, 800)
    scroll:SetScrollChild(content)

    RefreshPriorityList()
end

local function CreateSpellButton(parent, spellID, index, y)
    local config = GetConfig()
    local data = config.interrupts[spellID]
    local spellInfo = GetSpellInfo(spellID)
    local name = spellInfo.name or "Unknown"
    local icon = spellInfo.iconID or 136243

    local btn = CreateFrame("Frame", nil, parent)
    btn:SetSize(220, 32)
    btn:SetPoint("TOPLEFT", 10, y)

    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetSize(28, 28)
    tex:SetPoint("LEFT", btn, "LEFT", 0, 0)
    tex:SetTexture(icon)

    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(spellID)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", tex, "RIGHT", 8, 0)
    label:SetText(name .. " (" .. data.class .. ")")

    btn:EnableMouse(true)
    btn:SetScript("OnMouseDown", function()
        dragIndex = index
    end)
    btn:SetScript("OnMouseUp", function()
        if dragIndex and dragIndex ~= index then
            table.insert(config.priority, index, table.remove(config.priority, dragIndex))
            RefreshPriorityList()
        end
        dragIndex = nil
    end)

    return btn
end

-- 우선순위 UI 다시 그리기
function RefreshPriorityList()
    for _, child in ipairs({ content:GetChildren() }) do
        child:Hide()
    end

    local config = GetConfig()
    local y = -10

    for i, spellID in ipairs(config.priority) do
        CreateSpellButton(content, spellID, i, y)
        y = y - 36
    end
end

local function OnPlayerLogin()
    SLASH_INTERRUPTPRIORITY1 = "/iap"
    SlashCmdList["INTERRUPTPRIORITY"] = function()
        if not GetSpellInfo then
            print("WoW API 아직 초기화되지 않음 (GetSpellInfo nil)")
            return
        end
        ShowPriorityOptions()
    end
end



-- 안전하게 이벤트로 연기
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnPlayerLogin)