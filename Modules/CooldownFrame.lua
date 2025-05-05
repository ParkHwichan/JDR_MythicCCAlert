local E = select(2, ...):unpack()

function E:InitCooldownFrame()
    -- 기존 프레임 정리
    if E.CooldownFrame then
        E.CooldownFrame:UnregisterAllEvents()
        E.CooldownFrame:SetScript("OnUpdate", nil)
        E.CooldownFrame:SetScript("OnEvent",  nil)
        E.CooldownFrame:SetParent(nil)
        E.CooldownFrame:Hide()
        E.CooldownFrame = nil
    end

    -- 메인 쿨다운 프레임 생성
    local cf = CreateFrame("Frame", "JDR_CooldownFrame", UIParent)
    cf:SetSize(200, 50)
    cf:SetFrameStrata("HIGH")
    cf:SetFrameLevel(255)
    cf.iconPool    = {}
    cf.delay       = 0
    cf.nextFlash   = math.huge
    cf.enemyCast   = {}
    -- Safe Time 바 관련 값 초기화
    cf.safeEndTime  = nil
    cf.safeDuration = 0

    --▶ Safe Time Bar (쿨다운 프레임 하위에 attach)
    local sb = CreateFrame("StatusBar", nil, cf)
    -- 부모 하단에 붙이되, 좌우는 부모와 0 간격으로
    sb:SetPoint("TOPLEFT",  cf, "BOTTOMLEFT",  0, -5)
    sb:SetPoint("TOPRIGHT", cf, "BOTTOMRIGHT", 0, -5)
    sb:SetHeight(8)   -- 높이만 고정

    -- ▶ 1px 검은 테두리
    local border = sb:CreateTexture(nil, "BORDER")
    border:SetColorTexture(0, 0, 0, 1)
    border:SetPoint("TOPLEFT",     sb, "TOPLEFT",    -1,  1)
    border:SetPoint("BOTTOMRIGHT", sb, "BOTTOMRIGHT", 1,  -1)
    sb.border = border

    -- ▶ 배경 (검은색)
    local bg = sb:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(sb)
    bg:SetColorTexture(0, 0, 0, 1)
    sb.bg = bg

    -- ▶ 전경(fill, 주황색)
    local fg = sb:CreateTexture(nil, "ARTWORK")
    fg:SetPoint("TOPLEFT",     sb, "TOPLEFT",     2, -2)
    fg:SetPoint("BOTTOMRIGHT", sb, "BOTTOMRIGHT", -2, 2)
    sb:SetStatusBarTexture(fg)
    fg:SetColorTexture(1, 0.6, 0, 1)
    sb.fg = fg
    sb:SetReverseFill(true) -- 기본값: false

    -- ▶ 바 끝에 Blizzard Spark 텍스처
    local spark = sb:CreateTexture(nil, "OVERLAY")
    spark:SetBlendMode("ADD")
    spark:SetTexture("Interface\CastingBar\UI-CastingBar-Spark")  -- 기본 블리자드 spark
    spark:SetSize(16, 32)  -- spark 텍스처 원본 비율에 맞춰 높이 늘림
    spark:Hide()
    sb.spark = spark

    sb.remainingText = sb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sb.remainingText:SetPoint("TOPRIGHT", sb, "TOPRIGHT", -2, 2)

    sb:Hide()
    cf.safeBar = sb

    -- 프레임 핸들러 (예: safeTime 업데이트)
    -- 프레임 OnUpdate에서 Safe Time 비교
    -- ▶ OnUpdate: safeEndTime 비교하여 바 업데이트
    cf:SetScript("OnUpdate", function(self)
        if self.safeEndTime then
            local remaining = self.safeEndTime - GetTime()
            if remaining > 0 then
                self.safeBar:SetValue(remaining)
                -- 텍스트 업데이트
                self.safeBar.remainingText:SetText(string.format("%.1f", remaining))
                -- Spark 위치 업데이트: fill 끝에 붙이기
                local fillTex = self.safeBar:GetStatusBarTexture()
                self.safeBar.spark:ClearAllPoints()
                self.safeBar.spark:SetPoint("LEFT", fillTex, "RIGHT", 0, 0)
                self.safeBar.spark:Show()
            else
                self.safeEndTime = nil
                self.safeBar:Hide()
                self.safeBar.spark:Hide()

            end
        end
    end)

    -- Init 완료 후 Refresh 호출
    E.CooldownFrame = cf

    function E.CooldownFrame:SetSafeEndTime(timestamp)
        -- timestamp: 쿨타임 종료 시각
        -- cf.safeEndTime = timestamp
        -- cf.safeDuration = timestamp - GetTime()
        self.safeEndTime = timestamp
        self.safeDuration = timestamp - GetTime()
        self.safeBar:SetMinMaxValues(0, self.safeDuration)
        self.safeBar:SetValue(self.safeDuration)
        self.safeBar:Show()
    end

    E:RefreshCooldownFrame()
end



local function CreateSpellButton(parent, size, spellID, pointArgs)
    -- parent: 버튼을 붙일 프레임
    -- size: 버튼 크기
    -- spellID: C_Spell.GetSpellTexture 에 넘길 스펠 ID
    -- pointArgs: { point, relativeFrame, relativePoint, x, y } 형태의 테이블

    local btn = CreateFrame("Frame", nil, parent)
    btn:SetSize(size, size)
    if pointArgs then
        btn:SetPoint(unpack(pointArgs))
    end

    -- ▶ 아이콘
    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(btn)
    tex:SetTexture(C_Spell.GetSpellTexture(spellID))
    tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.icon = tex

    -- ▶ 1px 검은 테두리
    local border = btn:CreateTexture(nil, "BORDER")
    border:SetColorTexture(0, 0, 0, 1)
    border:SetPoint("TOPLEFT",     btn, "TOPLEFT",    -1,  1)
    border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 1,  -1)
    btn.border = border

    -- ▶ 쿨다운 스와이프
    local cd = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
    cd:SetAllPoints(btn)
    btn.cd = cd

    return btn
end

-- API: 스펠 아이콘 풀 생성
-- @param spells table -- 스펠 테이블
-- @return table -- 생성된 아이콘 풀
-- -- @usage
-- spells = {
--     [1] = { name = "someone", iconPath = "Interface\\Icons\\Spell_Fire_FlameBolt" , baseCD =2000, remaining = 0, ready = true },
--     [2] = { name = "james", iconPath = "Interface\\Icons\\Spell_Frost_FrostBolt" , baseCD = 3000, remaining = 0, ready = true },
--     [3] = { name = "john", iconPath = "Interface\\Icons\\Spell_Arcane_ArcaneMissiles" , baseCD = 4000, remaining = 0, ready = true },
--
-- 1) SetIconPool 에서 Cooldown 위젯 추가, spell 참조 저장
function E:SetIconPool(spells)
    local db = E.DB
    local opts    = db.cooldownFrame
    local parent  = E.CooldownFrame

    -- ◀ 1) 이전에 만든 버튼들 완전 해제
    for _, btn in ipairs(parent.iconPool) do
        -- combinedButtons 까지 전부
        if btn.combinedButtons then
            for _, cbtn in ipairs(btn.combinedButtons) do
                cbtn:Hide()
                cbtn:UnregisterAllEvents()
                cbtn:SetScript("OnUpdate", nil)
                cbtn:SetScript("OnEvent",  nil)
                cbtn:SetParent(nil)
            end
            btn.combinedButtons = nil
        end
        -- 메인 버튼
        btn:Hide()
        btn:UnregisterAllEvents()
        btn:SetScript("OnUpdate", nil)
        btn:SetScript("OnEvent",  nil)
        btn:SetParent(nil)
    end

    wipe(parent.iconPool)

    local totalW, maxH = 0, 0

    for i, spell in ipairs(spells) do
        -- i==1이면 큰 사이즈, 아니면 기본 사이즈
        local size = (i == 1) and opts.big_size or opts.small_size
        local pt   = (i == 1)
                and { "BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0 }
                or { "BOTTOMRIGHT", parent.iconPool[i-1], "BOTTOMLEFT", -opts.margin, 0 }

        -- 버튼 생성 및 크기
        local btn = CreateSpellButton(parent, size, spell.id, pt)
        btn.spell = spell
        btn.isFlashing = false
        btn.combinedButtons = {}
        parent.iconPool[i] = btn

        totalW = totalW + size + (i<#spells and opts.margin or 0)
        maxH   = math.max(maxH, size)

        -- 2) combinedSpells 처리
        if spell.combinedSpells then

            local lastAnchor = btn
            local comboSize  = math.floor(size * 0.8)

            for _, comboSpell in ipairs(spell.combinedSpells) do
                -- combo-icon 은 항상 parent 프레임(=E.CooldownFrame)에 붙이고,
                -- lastAnchor 의 TOPLEFT 에 comboBtn 의 BOTTOMLEFT 가 딱 붙도록
                local comboPt = {
                    "BOTTOM",    -- comboBtn 기준점
                    lastAnchor,      -- 붙일 대상
                    "TOP",       -- 대상 기준점
                    0,               -- x 오프셋 (0: 좌우 오차 없이)
                    0,               -- y 오프셋 (0: 딱 맞붙도록)
                }

                -- parent 는 항상 최상위 parent
                local comboBtn = CreateSpellButton(parent, comboSize, comboSpell.id, comboPt)
                comboBtn.spell = comboSpell
                table.insert(btn.combinedButtons, comboBtn)

                -- 다음 루프에 이 comboBtn 위에 붙도록
                lastAnchor = comboBtn
            end
        end

    end

    -- 부모 프레임 크기 조정
    parent:SetSize(totalW, maxH)
    return parent.iconPool
end



function E:RefreshCooldownFrame()

    local f = E.CooldownFrame
    local db = E.DB
    local options = db.cooldownFrame


    f:SetPoint("CENTER" , UIParent, "CENTER", db.cooldownFrame.pos_x, db.cooldownFrame.pos_y)
    f:Show()
    if db.cooldownFrame.lock then
        f:SetMovable(false)
    else
        f:SetMovable(true)
    end
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")

    f:SetScript("OnDragStart", function(self)
        if not db.cooldownFrame.lock then
            self:StartMoving()
        end
    end)

    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- 프레임을 다시 찍을 때 point, relativePoint, x, y 를 저장
        local point, relativeTo, relPoint, x, y = self:GetPoint()
        db.cooldownFrame.pos_x = x
        db.cooldownFrame.pos_y = y
         end)
    f:SetClampedToScreen(true)


    local spells = {}
    for i, btn in ipairs(f.iconPool) do
        spells[i] = btn.spell
    end
    E:SetIconPool(spells)
end

local function ControlCooldown(btn, remaining)
    local s = btn.spell

    s.remaining = remaining

    -- 비활성(쿨중)인 경우
    if s.remaining and s.remaining > 0 then
        local baseSec   = (s.baseCD   or 0)   -- baseCD 가 ms 로 들어오는 경우
        local remainSec = (s.remaining or 0) / 1000

        -- 자연스러운 스와이프를 위해
        local startTime = GetTime() - (baseSec - remainSec)
        btn.cd:SetCooldown(startTime, baseSec)
        btn.cd:Show()
    else
        -- 준비 완료
        btn.cd:Hide()
    end
end

-- 상태만 갱신 (매 업데이트)
function E:UpdateIconPool(spells )
    local db = E.DB
    local options = db.cooldownFrame

    local nextFlash = math.huge
    for _, info in pairs( self.CooldownFrame.enemyCast) do
        if info.nextFlash and info.nextFlash < nextFlash then
            nextFlash = info.nextFlash
        end
    end


    for i, btn in ipairs(E.CooldownFrame.iconPool) do

        ControlCooldown(btn, spells[i].remaining)
        for j, cbtn in ipairs(btn.combinedButtons) do
            local combinedSpells = spells[i].combinedSpells
            if combinedSpells and combinedSpells[j] then
                ControlCooldown(cbtn, combinedSpells[j].remaining)
            end
        end

        local s = btn.spell

        local shouldFlash = (i == 1 and s.unitName == UnitName("player")) and s.remaining == 0  and (GetTime() > nextFlash) and (GetTime() < nextFlash + 3)

        if shouldFlash and not btn.isFlashing then
            btn.isFlashing = true

            if options.sound_alert then
                local unitName = s.unitName or UNKNOWN
                local class = s.class or UNKNOWN

                local nextSpellConfig = E.Config.spells[s.id]

                local soundPath = nil
                if nextSpellConfig and nextSpellConfig.soundPath then
                    soundPath = nextSpellConfig.soundPath
                end
                if not soundPath and s.type == "interrupt" then
                    soundPath = "짤"
                end
                E:PlaySound(false, unitName, class, soundPath)
            end

            if options.show_glow then
                LibStub("LibButtonGlow-1.0").ShowOverlayGlow(btn)
            end
        elseif not shouldFlash and btn.isFlashing then
            btn.isFlashing = false
            LibStub("LibButtonGlow-1.0").HideOverlayGlow(btn)
        end
    end
end