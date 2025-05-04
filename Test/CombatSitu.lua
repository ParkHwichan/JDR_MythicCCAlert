-- 모드 네임스페이스 로드
local E = select(2, ...):unpack()

E.Test = {}

-- --------------------------------------------------
-- 2) 드래그 가능한 프레임 생성 (크기 유동화 제거)
-- --------------------------------------------------
local FRAME_WIDTH = 400

local MobGUIDFrame = CreateFrame("Frame", "CombatMobGUIDFrame", UIParent, "BackdropTemplate")
MobGUIDFrame:SetWidth(FRAME_WIDTH)
MobGUIDFrame:SetPoint("CENTER")
MobGUIDFrame:SetMovable(true)
MobGUIDFrame:EnableMouse(true)
MobGUIDFrame:RegisterForDrag("LeftButton")
MobGUIDFrame:SetScript("OnDragStart", MobGUIDFrame.StartMoving)
MobGUIDFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
MobGUIDFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile     = true, tileSize = 32, edgeSize = 16,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 },
})

-- 제목 글씨
MobGUIDFrame.title = MobGUIDFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
MobGUIDFrame.title:SetPoint("TOP", 0, -8)
MobGUIDFrame.title:SetText("Active Mob List")

-- 가변 높이 안내용 텍스트
MobGUIDFrame.text = MobGUIDFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
MobGUIDFrame.text:SetPoint("TOPLEFT", 10, -30)
MobGUIDFrame.text:SetJustifyH("LEFT")
MobGUIDFrame.text:SetJustifyV("TOP")
MobGUIDFrame.text:SetWidth(FRAME_WIDTH - 20)

-- --------------------------------------------------
-- 1) 목록 갱신 함수 (GUID, 이름, 타입, spellID 순)
-- --------------------------------------------------
function E.Test:UpdateMobList()
    local lines = {}
    lines[#lines+1] = E.CombatSitu
    lines[#lines+1] = "GUID  | 이름  | 타입  | 스펠ID"

    for guid, info in pairs(E.InCombatMobs) do
        -- 한 줄 포맷: GUID | 이름 | 타입 | 스펠ID
        lines[#lines+1] = string.format(
                "%s  |cff00ff00%s|r  |cffff8800%s|r  |cff88ff88%d|r",
                guid, info.name, info.type, info.spellID
        )
    end

    -- 텍스트 갱신
    local textString = table.concat(lines, "\n")
    MobGUIDFrame.text:SetText(textString)

    -- 프레임 높이 유동 조절
    local _, fontSize = MobGUIDFrame.text:GetFont()
    local lineHeight  = fontSize + 4       -- 폰트 크기 + 여유
    local paddingTop  = 40                 -- 제목 + 여백
    local paddingBottom = 10
    local totalHeight = paddingTop + (#lines * lineHeight) + paddingBottom
    MobGUIDFrame:SetHeight(totalHeight)
end
