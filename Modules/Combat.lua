local E = select(2, ...):unpack()

-- 전투 중인 몹 풀
E.InCombatMobs = {}

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

    for guid, mob in pairs(E.InCombatMobs) do
        if mob.cooldowns then
            for spellID, cooldown in pairs(mob.cooldowns) do
                local nextCast = cooldown.nextCast
                if leastTime > nextCast then
                    leastTime = nextCast
                end
            end
        end
    end

    if leastTime == math.huge then
        leastTime = GetTime()
    end

    if leastTime < GetTime() then
        leastTime = GetTime()
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
