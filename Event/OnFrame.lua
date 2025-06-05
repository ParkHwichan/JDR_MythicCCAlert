local E = select(2, ...):unpack()

-- create a frame (or reuse your existing one)
local f = CreateFrame("Frame")

-- cumulative time if you want to throttle
local accumulator = 0

-- 1) 두 스펠(테이블)을 완전 비교하는 헬퍼
local function compareSpells(s1, s2)
    -- 기본 id, unitName 비교
    if s1.id ~= s2.id or s1.unitName ~= s2.unitName then
        return false
    end

    -- combinedSpells 유무 비교
    local cs1, cs2 = s1.combinedSpells, s2.combinedSpells
    if (cs1 and not cs2) or (cs2 and not cs1) then
        return false
    end

    -- 둘 다 nil 이면 여긴 OK
    if not cs1 then
        return true
    end

    -- 길이 비교
    if #cs1 ~= #cs2 then
        return false
    end

    -- 각 combinedSpells 내부의 id 비교
    for i = 1, #cs1 do
        if cs1[i].id ~= cs2[i].id then
            return false
        end
    end

    return true
end


-- 1) id와 unitName만 비교하도록 sameList 수정
local function sameList(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do
        -- a[i], b[i] 는 { id=..., unitName=..., ... } 구조의 테이블
        if not compareSpells(a[i], b[i]) then
            return false
        end
    end
    return true
end


-- set up your per-frame callback
f:SetScript("OnUpdate", function(self, elapsed)
    -- elapsed is time (in seconds) since the last OnUpdate

    if not E.CooldownFrame then
        -- 쿨타임 프레임이 없으면 종료
        return
    end

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


    if E.CombatSitu == "NO_COMBAT" and not E.showingConfig then
        -- iconPool 테이블 비우기 (기존 참조 유지)
        if next(E.CooldownFrame.iconPool) then

            E:SetIconPool({  })
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

        if not list or #list == 0 then
            return
        end

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

    local nextcast = E:GetLeastEnemyNextCast()

    -- 1) 준비된(onlyReady=true) 메인 스펠
    if spellTypes.main == "interrupt" and spellTypes.interruptCombineNum and spellTypes.interruptCombineNum > 1 then
        addSpells( E:GetCombinedSpells("interrupt",spellTypes.interruptCombineNum , true,nextcast) )
    else
        addSpells(E:GetSortedGroupSpellsByType(spellTypes.main, maxIcon, true ,  nextcast))
    end

    local skip = 0
    -- 2) 그래도 모자라면 준비된 서브 스펠
    if #spellsToDisplay < maxIcon then
        local getNum = 0
        if #spellsToDisplay > 0 then
            getNum = 1
        else
            getNum = 2
        end
        local readySub = E:GetSortedGroupSpellsByType(spellTypes.sub, maxIcon, true, nextcast)
        if readySub and #readySub > 0 then
            -- 서브 스펠이 준비된 경우
            addSpells(readySub)
            skip = 1
        end
    end

    if #spellsToDisplay < maxIcon then
        -- 3) 쿨타임 중인 메인 스펠
        if spellTypes.main == "interrupt" and spellTypes.interruptCombineNum and spellTypes.interruptCombineNum > 1 then
            addSpells( E:GetCombinedSpells("interrupt",spellTypes.interruptCombineNum , false,nextcast) )
        else
            addSpells(E:GetSortedGroupSpellsByType(spellTypes.main, maxIcon, false, nextcast))
        end
    end

    -- 3) 그래도 모자라면 준비된 서브 스펠
    if #spellsToDisplay < maxIcon then
        local readySub = E:GetSortedGroupSpellsByType(spellTypes.sub, maxIcon, true,nextcast)
        if skip and skip == 1 then
            if readySub and #readySub > 1 then
                -- 2번째 스킬 부터 추가
                for i = 2, #readySub do
                    addSpells({ readySub[i] } )
                end
            end
        else
            -- 서브 스펠이 준비된 경우
            addSpells(readySub)
        end
    end

    -- 4) 그래도 모자라면 쿨타임 중인 서브 스펠
    if #spellsToDisplay < maxIcon then
        local notReadySub = E:GetSortedGroupSpellsByType(spellTypes.sub, maxIcon, false,nextcast)
        addSpells(notReadySub)
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
