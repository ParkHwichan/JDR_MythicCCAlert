local E  = select(2, ...):unpack()

-- test.lua  ─  /ocdump : OmniCD 전역 테이블 시각화
----------------------------------------------------
local function Serialize(tbl, indent, visited, lines)
    indent  = indent  or ""
    visited = visited or {}
    lines   = lines   or {}

    if type(tbl) ~= "table" then
        lines[#lines+1] = indent .. tostring(tbl)
        return lines
    end
    if visited[tbl] then
        lines[#lines+1] = indent .. "<cycle>"
        return lines
    end
    visited[tbl] = true

    lines[#lines+1] = indent .. "{"
    local nextI = indent .. "    "
    for k,v in pairs(tbl) do
        local key = "["..tostring(k).."] = "
        if type(v) == "table" then
            lines[#lines+1] = nextI .. key
            Serialize(v, nextI .. "    ", visited, lines)
        else
            lines[#lines+1] = nextI .. key .. tostring(v)
        end
    end
    lines[#lines+1] = indent .. "}"
    return lines
end

----------------------------------------------------
-- ① 덤프 결과를 보여 줄 인터페이스 창
----------------------------------------------------
local viewer = CreateFrame("Frame", "OCDumpViewer", UIParent, "BackdropTemplate")
viewer:SetSize(600, 500)
viewer:SetPoint("CENTER")
viewer:SetBackdrop({ bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
                     edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
                     tile=true, tileSize=32, edgeSize=32, insets={left=6, right=6, top=6, bottom=6}})
viewer:Hide()
viewer:SetMovable(true); viewer:EnableMouse(true)
viewer:RegisterForDrag("LeftButton")
viewer:SetScript("OnDragStart", viewer.StartMoving)
viewer:SetScript("OnDragStop", viewer.StopMovingOrSizing)

-- 닫기 버튼
local close = CreateFrame("Button", nil, viewer, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -4, -4)

-- 스크롤 프레임 + EditBox
local scroll = CreateFrame("ScrollFrame", "OCDumpScroll", viewer, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 10, -28)
scroll:SetPoint("BOTTOMRIGHT", -28, 10)

local editBox = CreateFrame("EditBox", nil, scroll)
editBox:SetMultiLine(true)
editBox:SetFontObject("GameFontHighlightSmall")
editBox:SetAutoFocus(false)
scroll:SetScrollChild(editBox)
editBox:SetWidth(540)
editBox:SetScript("OnEscapePressed", editBox.ClearFocus)

----------------------------------------------------
-- ② Slash 명령: 덤프 + 창 열기
----------------------------------------------------
SLASH_OCDUMP1 = "/ocdump"
SlashCmdList.OCDUMP = function()
    local omni = _G.OmniCD
    if not omni then
        print("|cffff0000[OCDump]|r OmniCD 가 로드되어 있지 않습니다.")
        return
    end

    -- 직렬화
    local text = table.concat(Serialize(  omni[1].Party), "\n")

    -- EditBox 갱신
    editBox:SetText(text)
    editBox:HighlightText(0,0)           -- 커서 맨 위
    C_Timer.After(0, function() scroll:SetVerticalScroll(0) end)

    -- 창 토글
    if viewer:IsShown() then
        viewer:Hide()
    else
        viewer:Show()
    end
end


SLASH_SNAP1 = "/cdsnap"
SlashCmdList.SNAP = function()
    local OmniCD   = _G.OmniCD
    local partyMod = OmniCD and OmniCD[1].Party


    if not partyMod then
        print("|cffff0000[OCDump]|r OmniCD 가 로드되어 있지 않습니다.")
        return
    end

    local now = GetTime()

    local text = table.concat(    Serialize(E:GetSortedGroupSpellsByType("aoeCC" , nil , true)))

    editBox:SetText(text)
    editBox:HighlightText(0,0)           -- 커서 맨 위
    C_Timer.After(0, function() scroll:SetVerticalScroll(0) end)
    if viewer:IsShown() then
        viewer:Hide()
    else
        viewer:Show()
    end

end