local E = select(2, ...):unpack()

function E:InitCooldownFrame()
    -- 초기화
    E.CooldownFrame = nil
    E.CooldownFrame = CreateFrame("Frame", "JDR_CooldownFrame", UIParent)
    E.CooldownFrame:SetSize(100, 100)
    E.CooldownFrame:SetFrameStrata("HIGH")
    E.CooldownFrame:SetFrameLevel(255)
    E.CooldownFrame.iconPool = {}
    E.CooldownFrame.delay = 0
    E.CooldownFrame.nextFlash = math.huge
    E.CooldownFrame.enemyCast = {}
    E:RefreshCooldownFrame()

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
    local options = db.cooldownFrame
    local cooldownFrame = E.CooldownFrame
    E.CooldownFrame.enemyCast = {}

    -- 초기화
    for _, btn in ipairs(E.CooldownFrame.iconPool) do btn:Hide() end
    wipe(E.CooldownFrame.iconPool)

    local baseSize = options.small_size
    local bigSize = options.big_size
    local margin = options.margin

    local totalW, maxH = 0, 0

    for i, spell in ipairs(spells) do
        -- i==1이면 큰 사이즈, 아니면 기본 사이즈
        local size = (i == 1) and bigSize or baseSize

        -- 버튼 생성 및 크기
        local btn = CreateFrame("Frame", nil, cooldownFrame)
        btn:SetSize(size, size)
        btn:SetScale(1)  -- 이미 SetSize 로 키웠으니 스케일은 놔둡니다
        btn.size = size

        -- 위치 잡기: 첫 버튼은 부모의 오른쪽, 나머지는 직전 버튼의 왼쪽
        if i == 1 then
            -- 첫 버튼: 프레임 오른쪽에 정렬
            btn:SetPoint("BOTTOMRIGHT", cooldownFrame, "BOTTOMRIGHT", 0, 0)
        else
            -- 그 외: 직전 버튼 왼쪽에 margin 간격만큼 띄워서 정렬
            btn:SetPoint("BOTTOMRIGHT", E.CooldownFrame.iconPool[i-1], "BOTTOMLEFT", -margin, 0)
        end

        ----------------------------------------------------
        -- 아이콘
        ----------------------------------------------------
        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetDrawLayer("OVERLAY")
        tex:SetSize(size, size)
        tex:SetPoint("LEFT", btn, "LEFT", 0, 0)
        tex:SetTexture(C_Spell.GetSpellTexture(spell.id))

        -- ▶ 블리자드 아이콘 “확대” (테두리 잘라내기)
        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        btn.icon = tex

        -- ▶ 1px 검은 테두리 추가 (BORDER 레이어)
        local border = btn:CreateTexture(nil, "BORDER")
        border:SetColorTexture(0, 0, 0, 1)            -- 완전 검정
        border:SetPoint("TOPLEFT", btn, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 1, -1)

        -- 3) CD 애니메이션 위젯
        local cd = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
        cd:SetAllPoints(btn)
        btn.cd = cd

        -- 스펠 정보
        btn.spell = spell
        btn.isFlashing = false

        E.CooldownFrame.iconPool[i] = btn

        -- 부모 크기 누적
        totalW = totalW + size
        maxH   = math.max(maxH, size)
        if i < #spells then
            totalW = totalW + margin
        end
    end

    -- 부모 프레임 크기 조정
    E.CooldownFrame:SetSize(totalW, maxH)
    return E.CooldownFrame.iconPool
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

-- 상태만 갱신 (매 업데이트)
function E:UpdateIconPool(spells)
    local db = E.DB
    local options = db.cooldownFrame

    local nextFlash = math.huge
    for _, info in pairs( self.CooldownFrame.enemyCast) do
        if info.nextFlash and info.nextFlash < nextFlash then
            nextFlash = info.nextFlash
        end
    end


    for i, btn in ipairs(E.CooldownFrame.iconPool) do
        local s = btn.spell

        s.remaining = spells[i].remaining
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