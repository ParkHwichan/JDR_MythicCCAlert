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

    E.CooldownFrame.delay = E.CooldownFrame.delay - elapsed

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
        end
        return
    end

    local DB = E.DB


    -- a) 현재 보여줄 스펠 목록 가져오기
    local spellTypes      = E:GetCombatSpellTypes()
    local spellsToDisplay = E:GetSortedGroupSpellsByType(spellTypes, DB.cooldownFrame.max_icon, false)

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
