local E = select(2, ...):unpack()

-- 전투 중인 몹 풀
E.InCombatMobs = {}

E.InCombatNameplate = {}

-- 현재 전투 상태
-- "NO_COMBAT" = 전투 중 아님
-- "COMBAT_NO_CASTER" = 전투 중이고 캐스터 없음
-- "COMBAT_SINGLE_CASTER" = 전투 중이고 캐스터 1명
-- "COMBAT_MULTI_CASTER" = 전투 중이고 캐스터 2명 이상
--
E.CombatSitu = "NO_COMBAT"

E.CombatSpellTypes = {
    ["NO_COMBAT"] = {},
    ["COMBAT_NO_CASTER"] = {  main = "aoeCC" , },
    ["COMBAT_SINGLE_CASTER"] = {  main = "interrupt", sub = "aoeInterrupt" },
    ["COMBAT_DUAL_CASTER"] = { main = "interrupt", sub = {
        "aoeCC", "aoeInterrupt"
    }, interruptCombineNum = 2
    },
    ["COMBAT_MULTI_CASTER"] = { main = {"aoeInterrupt", "aoeCC"} },
    ["SINGLE_CC"] = { main = {"cc", "aoeCC"} },
    ["MULTI_CC"] = { main = { "aoeCC"} },
}

function E:GetCombatSpellTypes()
    return E.CombatSpellTypes[E.CombatSitu]
end

function E:GetLeastEnemyNextCast()
    local leastTime = math.huge
    local now       = GetTime()

    for guid, mob in pairs(E.InCombatMobs) do
        -- 1) 이 몹의 가장 이른 스킬 쿨다운
        local nextCastMin = math.huge
        if mob.cooldowns then
            for _, cd in pairs(mob.cooldowns) do
                nextCastMin = math.min(nextCastMin, cd.nextCast)
            end
        end

        -- 2) 이 몹의 가장 늦은 CC 만료 시간
        local ccExpMax = 0
        if mob.cc then
            for _, cc in pairs(mob.cc) do
                ccExpMax = math.max(ccExpMax, cc.expirationTime)
            end
        end

        -- 3) CC가 쿨다운보다 길면 CC 만료시간, 아니면 쿨다운 시간
        local effectiveTime = (ccExpMax > nextCastMin) and ccExpMax or nextCastMin

        -- 4) 전체 중 가장 빠른 시간으로 갱신
        leastTime = math.min(leastTime, effectiveTime)
    end

    -- 아무 이벤트가 없다면, 또는 이미 지난 시간이면 '지금'으로 세팅
    if leastTime == math.huge or leastTime < now then
        leastTime = now
    end

    return leastTime
end
function E:SetCombatSitu()
    local casterCount = 0
    local ccCount = 0
    local casters = {}

    for guid, mob in pairs(E.InCombatMobs) do
        if mob.type == "caster" then
            if mob.shareCooldown then
                -- shareCooldown 공유 대상이면, 같은 이름이 없을 때만 추가 및 카운트
                if not casters[mob.name] then
                    casters[mob.name] = true
                    casterCount = casterCount + 1
                end
            else
                -- shareCooldown 공유 대상이 아니면 항상 개별 카운트
                casterCount = casterCount + 1
                -- (원한다면 casters[mob.name] = true 도 추가할 수 있습니다)
            end
        end

        if mob.type == "onlyCC" then
            ccCount = ccCount + 1
        end
    end

    if casterCount == 0 then
        if ccCount == 1 then
            E.CombatSitu = "SINGLE_CC"
        elseif ccCount > 1 then
            E.CombatSitu = "MULTI_CC"
        else
            E.CombatSitu = "NO_COMBAT"
        end
    elseif casterCount == 1 then
        E.CombatSitu = "COMBAT_SINGLE_CASTER"
    elseif casterCount == 2 then
        E.CombatSitu = "COMBAT_DUAL_CASTER"
    elseif casterCount > 2 then
        E.CombatSitu = "COMBAT_MULTI_CASTER"
    end
end

-- API: 현재 전투 중인 몹 GUID→이름 목록 배열로 반환
function E:GetInCombatMobList()
    local out = {}
    for guid, name in pairs(E.InCombatMobs) do
        out[#out+1] = { guid = guid, name = name }
    end
    return out
end

function E:GetNPCIDFromGUID(guid)
    if type(guid) ~= "string" then return nil end
    local _, _, _, _, _, npcID = strsplit("-", guid)

    return tonumber(npcID)
end
