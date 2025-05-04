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
    ["COMBAT_NO_CASTER"] = {  "aoeCC" },
    ["COMBAT_SINGLE_CASTER"] = {  "interrupt" },
    ["COMBAT_MULTI_CASTER"] = { "aoeInterrupt", "aoeCC" },
}

function E:GetCombatSpellTypes()
    return E.CombatSpellTypes[E.CombatSitu]
end

function E:SetCombatSitu()
    local casterCount = 0

    for guid, mob in pairs(E.InCombatMobs) do
        if mob.type == "caster" then
            casterCount = casterCount + 1
        end
    end

    if casterCount == 0 then
        E.CombatSitu = "COMBAT_NO_CASTER"
    elseif casterCount == 1 then
        E.CombatSitu = "COMBAT_SINGLE_CASTER"
    elseif casterCount > 1 then
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
