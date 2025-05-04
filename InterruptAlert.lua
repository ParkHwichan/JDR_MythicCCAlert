
-- 특성 ID → 이름 캐시 (최소한의 사전 맵핑)
local specNames = {}
for i = 1, GetNumSpecializations() do
    local id, name = GetSpecializationInfo(i)
    if id then
        specNames[id] = name
    end
end

-- 유닛 → 특성명 반환
local function GetSpecName(unit)
    if not UnitExists(unit) then return nil end
    local specID = GetInspectSpecialization(unit)
    if specID and specID ~= 0 then
        local name = select(2, GetSpecializationInfoByID(specID))
        return name
    end
    return nil
end

local cooldowns = {}


-----------------------------------------------------------------
-- ① 보스 인식용 플래그
-----------------------------------------------------------------
local inBossFight = false

local bossWatcher = CreateFrame("Frame")
bossWatcher:RegisterEvent("ENCOUNTER_START")
bossWatcher:RegisterEvent("ENCOUNTER_END")
bossWatcher:SetScript("OnEvent", function(_, evt)
    if evt == "ENCOUNTER_START" then
        inBossFight = true          -- 전투 시작
    else                            -- ENCOUNTER_END
        inBossFight = false         -- 전투 종료
    end
end)


local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

f:SetScript("OnEvent", function()
    local _, subevent, _, playerGUID, sourceName, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()

    if subevent == "SPELL_CAST_SUCCESS" then
        for _, info in ipairs(availableInterrupts) do
            if info.spellID == spellID and info.playerGUID == playerGUID then

                info.cooldownEnds = GetTime() + info.baseCD   -- 갱신

                if inBossFight then
                    local nextAvailable = GetNextAvailableInterrupt()



                    ShowCentralNotice(
                            string.format("%s 차단기 사용!", info.player),
                            GetSpecRGB(info.class),
                            3,
                            {
                                text = string.format("다음 차단 %s", nextAvailable.player ),
                                color = GetSpecRGB(nextAvailable.class),
                            }
                    )

                    -- ④ 사운드 재생
                    local nextInterruptPath = GetNextInterruptSound()
                    local soundPath = GetSpecSound(nextAvailable.class, nextAvailable.player)
                    PlaySoundFile(nextInterruptPath, "Dialog")   -- "Dialog" 채널

                    if soundPath then
                        C_Timer.After(0.75, function()
                            PlaySoundFile(soundPath, "Dialog")              -- 같은 Dialog 채널
                        end)
                    end
                end

                break
            end
        end
    end
end)

-- 옵션 프레임 UI
local frame
function ShowInterruptStatusFrame()
    if frame and frame:IsShown() then
        frame:Hide()
        return
    end

    frame = CreateFrame("Frame", "InterruptAlertFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(260, 220)
    frame:SetPoint("CENTER")
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -10)
    frame.title:SetText("Interrupt Status")

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -35)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(220, 200)
    scroll:SetScrollChild(content)

    local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT")
    text:SetJustifyH("LEFT")

    local now = GetTime()
    local lines = {}

    for _, class in ipairs(PRIORITY) do
        local onCooldown = false
        for _, data in pairs(cooldowns) do
            if data.class == class and data.endsAt > now then
                onCooldown = true
                break
            end
        end
        if onCooldown then
            table.insert(lines, string.format("|cffff5555%s|r - 쿨다운 중", class))
        else
            table.insert(lines, string.format("|cff55ff55%s|r - 사용 가능", class))
        end
    end

    text:SetText(table.concat(lines, "\n"))
end


local statusFrame, statusText

local barPool   = {}          -- 재사용용
local BAR_H     = 24          -- 한 줄 높이
local BAR_W     = 210         -- 막대 너비
local ICON_SIZE = 24

local function AcquireBar(parent)
    local bar = tremove(barPool)
    if not bar then
        ----------------------------------------------------
        -- 최초 생성
        ----------------------------------------------------
        bar = CreateFrame("StatusBar", nil, parent)     -- BackdropTemplate X
        bar:SetSize(BAR_W, BAR_H)

        bar.bg = bar:CreateTexture(nil, "BACKGROUND")
        bar.bg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        bar.bg:SetAllPoints()
        bar.bg:SetVertexColor(0, 0, 0, 0.6)

        -- Melli 텍스처
        local TEX = LibStub("LibSharedMedia-3.0"):Fetch("statusbar", "Melli")
        if TEX then
            bar:SetStatusBarTexture(TEX)
        else
            bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
        end

        ----------------------------------------------------
        -- 1px 검은 사각 테두리 4줄
        ----------------------------------------------------
        local BORDER_TEX = "Interface\\BUTTONS\\WHITE8X8"
        local edges = {}

        -- 위·아래
        edges.top    = bar:CreateTexture(nil, "BORDER")
        edges.bottom = bar:CreateTexture(nil, "BORDER")
        edges.top   :SetTexture(BORDER_TEX)
        edges.bottom:SetTexture(BORDER_TEX)
        edges.top   :SetVertexColor(0,0,0)
        edges.bottom:SetVertexColor(0,0,0)
        edges.top   :SetPoint("TOPLEFT", bar, -1, 1)
        edges.top   :SetPoint("TOPRIGHT", bar, 1, 1)
        edges.bottom:SetPoint("BOTTOMLEFT", bar, -1, -1)
        edges.bottom:SetPoint("BOTTOMRIGHT", bar, 1, -1)
        edges.top   :SetHeight(1)
        edges.bottom:SetHeight(1)

        -- 좌·우
        edges.left  = bar:CreateTexture(nil, "BORDER")
        edges.right = bar:CreateTexture(nil, "BORDER")
        edges.left :SetTexture(BORDER_TEX)
        edges.right:SetTexture(BORDER_TEX)
        edges.left :SetVertexColor(0,0,0)
        edges.right:SetVertexColor(0,0,0)
        edges.left :SetPoint("TOPLEFT", bar, -1, 1)
        edges.left :SetPoint("BOTTOMLEFT", bar, -1, -1)
        edges.right:SetPoint("TOPRIGHT", bar, 1, 1)
        edges.right:SetPoint("BOTTOMRIGHT", bar, 1, -1)
        edges.left :SetWidth(1)
        edges.right:SetWidth(1)

        ----------------------------------------------------
        -- 아이콘
        ----------------------------------------------------
        bar.icon  = bar:CreateTexture(nil, "ARTWORK")
        bar.icon:SetDrawLayer("OVERLAY")
        bar.icon:SetSize(ICON_SIZE, ICON_SIZE)
        bar.icon:SetPoint("LEFT", bar, "LEFT", 0 , 0)
        -- ▶ 블리자드 아이콘 “확대” (테두리 잘라내기)
        bar.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        -- 라벨 ---------------------------------------------------------------
        bar.label = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        bar.label:SetPoint("LEFT", ICON_SIZE + 2, 0)
        bar.label:SetTextColor(1, 1, 1)                    -- 흰색
        bar.label:SetShadowColor(0, 0, 0, 0.8)             -- 검은 그림자
        bar.label:SetShadowOffset(1, -1)

        -- 타이머 -------------------------------------------------------------
        bar.timer = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        bar.timer:SetPoint("RIGHT", -2, 0)
        bar.timer:SetTextColor(1, 1, 1)                    -- 흰색
        bar.timer:SetShadowColor(0, 0, 0, 0.8)
        bar.timer:SetShadowOffset(1, -1)
    end
    if not bar.overlayAnchor then
        -- 바보다 4px 크게: 글로우 텍스처가 살짝 삐져나오게
        local anchor = CreateFrame("Frame", nil, bar)
        anchor:SetPoint("TOPLEFT", -2,  2)
        anchor:SetPoint("BOTTOMRIGHT", 2, -2)
        anchor:SetFrameLevel(bar:GetFrameLevel() + 10) -- 항상 위
        bar.overlayAnchor = anchor
    end

    --------------------------------------------------------
    -- ★ 초기화 ★
    --------------------------------------------------------
    bar:SetParent(parent)
    bar:ClearAllPoints()
    bar:SetReverseFill(false)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)

    HideGlow(bar)
    bar.icon:SetTexture(nil)
    bar.label:SetText("")
    bar.timer:SetText("")
    bar:Show()

    return bar
end

local function ReleaseAllBars(parent)
    for _, child in ipairs({ parent:GetChildren() }) do
        child:Hide()
        tinsert(barPool, child)
    end
end

-- 클래스 컬러 얻기 헬퍼
local function GetClassRGB(classToken)
    -- 최신 버전: C_ClassColor.GetClassColor 가 더 정확
    local c = C_ClassColor.GetClassColor(classToken)
            or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classToken])
            or RAID_CLASS_COLORS[classToken]
            or { r = 1, g = 1, b = 1 }     -- fallback: 흰색
    return c.r, c.g, c.b
end

function UpdateInterruptStatusFrame()
    if not statusFrame then return end
    local now       = GetTime()
    local myName    = UnitName("player")

    ReleaseAllBars(statusFrame)        -- 기존 바 반환

    -- 1) 가장 높은 우선순위 차단기 찾기
    local nextAvailable = GetNextAvailableInterrupt()


    -- 2) 바 그리기 – priority 필드 기준 정렬 후 단일 루프
    local y   = -30
    local now = GetTime()

    for _, info in ipairs(availableInterrupts) do
        local remain = math.max(0, info.cooldownEnds - now)
        local bar    = AcquireBar(statusFrame)

        -- 위치·값·색 -------------------------------------------------
        bar:SetPoint("TOPRIGHT", -10, y)
        bar:SetReverseFill(false)
        bar:SetMinMaxValues(0, info.baseCD)
        bar:SetValue(remain > 0 and remain or info.baseCD)   -- Ready 때 꽉 찬 막대

        local cr, cg, cb = GetClassRGB(info.class)
        bar:SetStatusBarColor(
              cr,cg,cb
        )

        -- 아이콘·텍스트 ---------------------------------------------
        bar.icon:SetTexture(info.spellIcon)
        bar.label:SetText(info.player)
        bar.timer:SetText(remain > 0 and string.format("%.0f", remain) or "Ready")

        -- 글로우 조건 -----------------------------------------------
        if nextAvailable and info.spellID == nextAvailable.spellID  and info.player == nextAvailable.player  then
            ShowGlow(bar)
        else
            HideGlow(bar)
        end

        y = y - (BAR_H + 4)
    end

    -- 3) 프레임 크기 조정
    statusFrame:SetHeight(math.abs(y) + 40)
end

function CreateInterruptStatusFrame()
    if statusFrame then return end

    local saved = InterruptAlertDB.ccFramePos or {}

    statusFrame = CreateFrame("Frame", "InterruptStatusFrame", UIParent, "BackdropTemplate")
    statusFrame:SetSize(220, 180)

    -- 저장된 위치 불러오기
    if saved.point and saved.x and saved.y then
        statusFrame:SetPoint(saved.point, UIParent, saved.relativePoint, saved.x, saved.y)
    else
        statusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -40, -40) -- 기본 위치
    end


    statusFrame:SetMovable(true)
    statusFrame:EnableMouse(true)
    statusFrame:RegisterForDrag("LeftButton")
    statusFrame:SetScript("OnDragStart", statusFrame.StartMoving)
    statusFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()

        -- 현재 위치 저장
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        InterruptAlertDB.ccFramePos = {
            point = point,
            relativePoint = relativePoint,
            x = xOfs,
            y = yOfs
        }
    end)

    statusFrame.title = statusFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statusFrame.title:SetPoint("TOP", 0, -10)
    statusFrame.title:SetText("파티 차단기 목록")
    statusFrame:SetScript("OnUpdate", function() UpdateInterruptStatusFrame() end)

    statusText = statusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("TOPLEFT", 10, -30)
    statusText:SetJustifyH("LEFT")
    statusText:SetJustifyV("TOP")
    statusText:SetWidth(200)
end

-- 애드온 로드 완료 후 자동으로 프레임 생성·갱신
local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
    CreateInterruptStatusFrame()
    buildInterruptListForParty()
    UpdateInterruptStatusFrame()
end)