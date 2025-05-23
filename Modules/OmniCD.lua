local E = select(2, ...):unpack()
local OmniCD = _G.OmniCD
local tinsert = table.insert



local function OverrideSpellInfo(info)
    local DB = E.DB

    local spells = DB.spells.profiles[DB.spells.current]
    if not spells then
        spells = E.Config.spells
    end

    local spell = spells[info.spellID]

    if not spell then
        return info
    end

    info.priority = spell.priority or info.priority or 0
    if spell.type == "aoeCC" or spell.type == "aoeInterrupt" then
        info.priority = info.priority + 100
    end
    if spell.type == "interrupt" then
        info.priority = info.priority + 200
    end

    info.soundPath = spell.soundPath or nil
    info.type = spell.type or info.type or "utility"

    return info
end

--- 모든 파티원의 Active 스펠(아이콘으로 띄워진) 목록을 반환
-- @return table: { [guid] = { unitName=string, spells={ {id,name,type,baseCD}, … } }, … }
function E:GetAllGroupSpells()
    local OmniCD = _G.OmniCD
    local out    = {}

    if not OmniCD or not OmniCD[1] or not OmniCD[1].Party then
        return out
    end

    local Party = OmniCD[1].Party
    local now   = GetTime()* 1000

    for guid, info in pairs(Party.groupInfo) do
        local unitName = info.name or UNKNOWN

        for spellID, icon in pairs(info.spellIcons) do
            local si = C_Spell.GetSpellInfo(spellID)
            local name = si and si.name or ("#"..spellID)
            local baseCD  = icon.baseCooldown or 0
            local remaining, ready = 0, true

            local override = OverrideSpellInfo(icon)

            local start, duration, enabled = 0, 0, 0
            local endTime = 0
            -- cooldown:GetCooldownTimes() 으로 (start, duration, enabled) 가져오기
            if icon.cooldown and icon.cooldown.GetCooldownTimes then
                start, duration, enabled = icon.cooldown:GetCooldownTimes()
                endTime = start + duration
                remaining = math.max(0, endTime - now)
            end

            local spell = {
                guid      = guid,
                class     = info.class,
                isDeadOrOffline = info.isDeadOrOffline,
                unitName  = unitName,
                duration  = duration,
                enabled   = enabled,
                priority = override.priority,
                id        = spellID,
                name      = name,
                soundPath = override.soundPath,
                type      = override.type,
                baseCD    = baseCD,
                remaining = remaining,
                ready     = ready,
            }

            tinsert(out, spell)
        end
    end

    return out
end

--- 모든 파티원의 Active 스펠(아이콘으로 띄워진) 목록을 반환
--- @param type string: "aoeCC", "interrupt", "defensive", "offensive", "utility"
---
function E:GetGroupSpellsByType(type)
    local out = {}
    local allSpells = E:GetAllGroupSpells()

    for _, spell in ipairs(allSpells) do
        if spell.type == type then
            tinsert(out, spell)
        end
    end

    return out
end

function E:GetSpellInfoFromOmniCd(spellID)

end

--- 모든 파티원의 Active 스펠(아이콘으로 띄워진) 목록을 우선순위·스펠ID·플레이어 이름 순으로 정렬해서 반환
-- @param type      string: "aoeCC", "interrupt", "defensive", "offensive", "utility"
-- @param num       number|nil: 반환할 최대 개수. nil 이거나 1 미만이면 제한없이 모두 반환.
-- @param onlyReady boolean|nil: true 이면 remaining ≤ 0 인(준비된) 스펠만 반환.
-- @return table: { { id, name, type, priority, unitName, remaining, ready, … }, … }
function E:GetSortedGroupSpellsByType(spellTypes, num, onlyReady , nextCast)
    -- normalize num: nil or <1 means “no limit”
    if type(num) ~= "number" or num < 1 then
        num = 1
    end



    local typesList = {}
    if type(spellTypes) == "string" then
        typesList = { spellTypes }
    elseif type(spellTypes) == "table" then
        typesList = spellTypes
    else
        return {}  -- 잘못된 입력
    end



    local now = GetTime()
    local nextCastRemaining = (nextCast and (nextCast - now) or 0 ) * 1000
    if not onlyReady then
        nextCastRemaining = math.huge
    end

    local result = {}
    local spellPool = {}
    for _, t in ipairs(typesList) do
        for _, spell in ipairs(self:GetGroupSpellsByType(t)) do
            tinsert(spellPool, spell)
        end
    end

    table.sort(spellPool, function(a,b)
        if a.priority ~= b.priority then
            return a.priority > b.priority
        end

        if a.id ~= b.id then
            return a.id < b.id
        end

        return a.unitName < b.unitName
    end )

    while #result and #result < num do
        nextCastRemaining = nextCastRemaining + #result * 1500

        local tmp = {}

        for _, spell in ipairs(spellPool) do
            if not spell.remaining or spell.remaining <= nextCastRemaining then
                tinsert(tmp, spell)
            end
        end

        if #tmp == 0 then
            break
        end

        for _, spell in ipairs(tmp) do
            tinsert(result, spell)
        end
        for _, spell in ipairs(tmp) do
            for i = #spellPool, 1, -1 do
                if spellPool[i] == spell then
                    tremove(spellPool, i)
                    break
                end
            end
        end
    end


    -- 4) 그 외에는 전체 반환
    return result
end

function E:GetCombinedSpells(spellType, num , onlyReady ,nextCast)

    if not num or num < 1 then
        return nil
    end

    local spells = {}
    if onlyReady then
        spells = E:GetSortedGroupSpellsByType(spellType, num , true, nextCast)
    else
        spells = E:GetSortedGroupSpellsByType(spellType, num , false,nextCast)
    end

    if #spells < num then
        return nil
    end

    local spell = spells[1]

    if num == 1 then
        return spell
    end

    spell.combined = true
    spell.combinedSpells = {}
    for i = 2, num do
        local spell2 = spells[i]
        tinsert(spell.combinedSpells, spell2)
    end

    return {
        [1] = spell
    }
end


