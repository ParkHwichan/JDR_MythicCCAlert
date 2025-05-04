availableInterrupts = {} -- 쐐기 기준 필터링된 spellID 리스트
availableCC = {} -- 쐐기 기준 필터링된 spellID 리스트
party = {}

local function isInterruptAvailable(interrupt, unit)
    if not UnitExists(unit) then return false end

    local specID = GetInspectSpecialization(unit)
    local class  = select(2, UnitClass(unit))

    -- 직업 불일치
    if interrupt.class and interrupt.class ~= class then return false end

    -- specRequired  (모두 충족 OR 배열에 포함돼야 통과)
    if interrupt.specRequired then
        local ok
        for _, req in ipairs(interrupt.specRequired) do
            if req == specID then ok = true break end
        end
        if not ok then return false end
    end

    -- specExcluded
    if interrupt.specExcluded then
        for _, ex in ipairs(interrupt.specExcluded) do
            if ex == specID then return false end
        end
    end

    return true
end

local function isCCAvailable(cc, unit)
    if not UnitExists(unit) then return false end

    local specID = GetInspectSpecialization(unit)
    local class  = select(2, UnitClass(unit))

    -- 직업 불일치
    if cc.class and cc.class ~= class then return false end

    -- specRequired  (모두 충족 OR 배열에 포함돼야 통과)
    if cc.specRequired then
        local ok
        for _, req in ipairs(cc.specRequired) do
            if req == specID then ok = true break end
        end
        if not ok then return false end
    end

    -- specExcluded
    if cc.specExcluded then
        for _, ex in ipairs(cc.specExcluded) do
            if ex == specID then return false end
        end
    end

    return true
end



-- 파티 전원의 차단기 조사
function buildInterruptListForParty()
    availableInterrupts = {}
    availableCC = {}

    local units = {}

    local config = GetConfig()

    -- 항상 자신 포함
    table.insert(units, "player")

    -- 파티원 추가
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) then
            table.insert(units, unit)
        end
    end

    -- 파티 전체에서 사용 가능한 차단기 수집
    for _, unit in ipairs(units) do
        local playerName = UnitName(unit)
        local classToken = select(2, UnitClass(unit))    -- 예: "ROGUE", "MAGE"
        local specID     = GetInspectSpecialization(unit)

        for spellID, data in pairs(config.interrupts) do
            if isInterruptAvailable(data, unit) then
                -- 배열에 구조체 형태로 삽입

                local spellInfo = GetSpellInfo(spellID)

                table.insert(availableInterrupts, {
                    name     = data.name or "Unknown",
                    player    = playerName,
                    playerGUID = UnitGUID(unit),
                    class     = classToken,
                    priority  = data.priority,
                    specID      = specID,
                    spellID   = spellID,
                    spellIcon = spellInfo.iconID or 136243, -- 아이콘 ID
                    spellName = spellInfo.name or "Unknown",
                    baseCD    = data.cooldown,      -- 기본 쿨다운(초)
                    cooldownEnds = 0
                })
            end
        end

        for spellID, data in pairs(config.crowdControls) do
            if isCCAvailable(data, unit) then
                -- 배열에 구조체 형태로 삽입

                local spellInfo = GetSpellInfo(spellID)

                table.insert(availableCC, {
                    name     = data.name or "Unknown",
                    player    = playerName,
                    playerGUID = UnitGUID(unit),
                    class     = classToken,
                    priority  = data.priority,
                    specID      = specID,
                    spellID   = spellID,
                    spellIcon = spellInfo.iconID or 136243, -- 아이콘 ID
                    spellName = spellInfo.name or "Unknown",
                    baseCD    = data.cooldown,      -- 기본 쿨다운(초)
                    cooldownEnds = 0
                })
            end
        end
    end

    -- 3) 정렬
    table.sort(availableInterrupts, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        -- 같은 priority면 플레이어 이름으로 2차 정렬 (선택)
        return a.player < b.player
    end)

    table.sort(availableCC, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        -- 같은 priority면 플레이어 이름으로 2차 정렬 (선택)
        return a.player < b.player
    end)

end

-- 가장 높은 우선순위(=priority 숫자 최소) 중 Ready 차단기를 반환
function GetNextAvailableInterrupt()
    local now = GetTime()

    -- 배열은 priority 순으로 정렬돼 있으므로
    for _, info in ipairs(availableInterrupts) do
        if info.cooldownEnds <= now then      -- 쿨다운이 끝났다면
            return info                       -- 가장 먼저 만난 것이 최우선
        end
    end

-- 모든 차단기가 쿨 중
    -- 쿨다운이 끝나지 않은 차단기 중 가장 짧은 쿨다운을 가진 것을 찾음
    local minCooldown = math.huge
    local minCooldownInfo = nil
    for _, info in ipairs(availableInterrupts) do
        if info.cooldownEnds > now then
            local remainingCooldown = info.cooldownEnds - now
            if remainingCooldown < minCooldown then
                minCooldown = remainingCooldown
                minCooldownInfo = info
            end
        end
    end

    return minCooldownInfo                            -- 모든 차단기가 쿨 중
end

-- 가장 높은 우선순위(=priority 숫자 최소) 중 Ready CC를 반환
function GetNextAvailableCC()
    local now = GetTime()

    -- 배열은 priority 순으로 정렬돼 있으므로
    for _, info in ipairs(availableCC) do
        if info.cooldownEnds <= now then      -- 쿨다운이 끝났다면
            return info                       -- 가장 먼저 만난 것이 최우선
        end
    end

    return nil
end