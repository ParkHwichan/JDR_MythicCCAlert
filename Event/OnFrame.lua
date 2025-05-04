local E = select(2, ...):unpack()

-- create a frame (or reuse your existing one)
local f = CreateFrame("Frame")

-- cumulative time if you want to throttle
local accumulator = 0

-- 1) id와 unitName만 비교하도록 sameList 수정
local function sameList(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do
        -- a[i], b[i] 는 { id=..., unitName=..., ... } 구조의 테이블
        if a[i].id ~= b[i].id or a[i].unitName ~= b[i].unitName then
            return false
        end
    end
    return true
end


-- set up your per-frame callback
f:SetScript("OnUpdate", function(self, elapsed)
    -- elapsed is time (in seconds) since the last OnUpdate
    accumulator = accumulator + elapsed

    -- if you want to run your logic every frame, just put it here:
    --    <your per-frame code>

    -- if you want to run logic e.g. only every 0.1s:
    if accumulator >= 0.2 then
        accumulator = 0
        -- <your throttled code>
        -- e.g. scan spells table, update UI, etc.
    end

    if E.showingConfig  then
        -- config 창이 열려있으면 업데이트 안함
        return
    end


    if E.CombatSitu == "NO_COMBAT" then
        -- iconPool 테이블 비우기 (기존 참조 유지)
        if next(E.CooldownFrame.iconPool) then
            E:SetIconPool({  })
            E.CooldownFrame.enemyCast = {}
        end
        return
    end

    local DB = E.DB

    -- a) 스펠 타입 불러오기
    local spellTypes      = E:GetCombatSpellTypes()
    local maxIcon         = DB.cooldownFrame.max_icon
    local spellsToDisplay = {}


    -- b) 리스트를 spellsToDisplay 에 중복 없이 최대 maxIcon 개수만큼 채워넣는 헬퍼
    local function addSpells(list)
        for _, spell in ipairs(list) do
            if #spellsToDisplay >= maxIcon then break end

            local exists = false
            for _, s in ipairs(spellsToDisplay) do
                if s.id == spell.id and s.unitName == spell.unitName then
                    exists = true
                    break
                end
            end

            if not exists then
                tinsert(spellsToDisplay, spell)
            end
        end
    end

    -- 1) 준비된(onlyReady=true) 메인 스펠
    addSpells(E:GetSortedGroupSpellsByType(spellTypes.main, maxIcon, true))
    -- 2) 그래도 모자라면 준비된 서브 스펠
    if #spellsToDisplay < maxIcon then
        addSpells(E:GetSortedGroupSpellsByType(spellTypes.sub, maxIcon, true))
    end

    -- 3) 모자라면 준비 안 된(onlyReady=false) 메인 스펠
    if #spellsToDisplay < maxIcon then
        addSpells(E:GetSortedGroupSpellsByType(spellTypes.main, maxIcon, false))
    end




    -- b) 스펠 ID만 뽑아서 비교 → 변경됐으면 풀 재생성
    local lastSpells = {}
    for i, icon in ipairs(E.CooldownFrame.iconPool) do
        lastSpells[i] = icon.spell
    end


    if  not sameList(spellsToDisplay, lastSpells) then
        -- SetIconPool 안에서 CreateFrame/SetTexture 등 수행
        E:SetIconPool(spellsToDisplay)
    end

   E:UpdateIconPool(spellsToDisplay)


end)
