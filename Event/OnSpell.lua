local E = select(2, ...):unpack()
local spells = E.Config.spells

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- E:GetUnitFromGUID(guid) 구현 예시
function E:GetUnitFromGUID(guid)
    -- 1) 내 파티/레이드
    for i = 1, GetNumGroupMembers() do
        local unit = IsInRaid() and ("raid"..i) or ("party"..i)
        if UnitGUID(unit) == guid then
            return unit
        end
    end

    -- 2) 내 캐릭터 자신
    if UnitGUID("player") == guid then
        return "player"
    end

    -- 3) 네임플레이트 (15.2+)
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and UnitGUID(unit) == guid then
            return unit
        end
    end

    -- 4) 타겟 / 포커스 등
    for _, u in ipairs({ "target", "focus", "mouseover" }) do
        if UnitGUID(u) == guid then
            return u
        end
    end

    return nil
end

local function HandleAoeCC(spellID , sourceName, aoeInterrupt)
    local usedSpell = spells[spellID]

    local nextSpell
    if aoeInterrupt then
        nextSpell = E:GetSortedGroupSpellsByType({"aoeCC","aoeInterrupt"}, 1 , true)[1]
    else
        nextSpell = E:GetSortedGroupSpellsByType("aoeCC", 1 , true)[1]
    end

    if nextSpell then
        local unitName = nextSpell.unitName or UNKNOWN
        local class = nextSpell.class or UNKNOWN

        local nextSpellConfig = spells[nextSpell.id]

        local soundPath = nil
        if nextSpellConfig and nextSpellConfig.soundPath then
            soundPath = nextSpellConfig.soundPath
        end

        E:PlaySound(true, unitName, class, soundPath)

        local usedSpellIconTag = E:GetSpellIconTag(spellID , 9)
        local nextSpellIconTag = E:GetSpellIconTag(nextSpell.id , 12)
        local usedCharacterColorTag = E:GetCharacterColorTag(sourceName,usedSpell.class or UNKNOWN)
        local nextCharacterColorTag = E:GetCharacterColorTag(unitName, nextSpell.class)

        E:QueueCentralNotice {
            text1 = "다음 CC : " .. nextCharacterColorTag .. " " .. nextSpellIconTag .. nextSpellConfig.name,
            hold1 = 2,
            fade1 = 1,
            size = 24,
            text2 = usedCharacterColorTag .. " " .. usedSpellIconTag .. usedSpell.name .. " 사용",
            hold2 = 2,
            fade2 = 1,
            size2 = 18,
        }

    end

end
f:SetScript("OnEvent", function(self, ...)
    local timestamp, subevent,
    hideCaster,
    srcGUID, srcName, srcFlags, srcRaidFlags,
    dstGUID, dstName, dstFlags, dstRaidFlags,
    spellID, spellName,
    _, extraSpellID = CombatLogGetCurrentEventInfo()

    -- 1) 적의 시전을 끊었을 때
    if subevent == "SPELL_INTERRUPT" then

        if E.Config.enemySpells[extraSpellID] and E.InCombatMobs[dstGUID] then
            -- 1) 적의 시전이 끊겼을 때
            if not E.InCombatMobs[dstGUID].cooldowns then
                E.InCombatMobs[dstGUID].cooldowns = {}
            end

            if E.Config.enemySpellCooldowns[extraSpellID] and E.Config.enemySpellCooldowns[extraSpellID].cooldown then

                local silence = (E.Config.spells[extraSpellID] and E.Config.spells[extraSpellID].silence) or 3


                E.InCombatMobs[dstGUID].cooldowns[extraSpellID] = {
                    id = extraSpellID,
                    nextCast = GetTime() + math.max(E.Config.enemySpellCooldowns[extraSpellID].cooldown, silence + 0.5),
                }
                E.CooldownFrame:SetSafeEndTime(E:GetLeastEnemyNextCast())

            else
                E.InCombatMobs[dstGUID].cooldowns[extraSpellID] = {
                    id = extraSpellID,
                    nextCast = GetTime() + 2,
                }
                E.CooldownFrame:SetSafeEndTime(E:GetLeastEnemyNextCast())

            end
        end
    elseif subevent == "SPELL_CHANNEL_START" then
        -- spellID: 채널링 시작한 주문
        -- srcGUID: 시전자 GUID
        if E.Config.enemySpells[spellID] and E.InCombatMobs[srcGUID] then
                local cd = E.Config.enemySpellCooldowns[spellID] and E.Config.enemySpellCooldowns[spellID].cooldown or 0
                if cd then
                    if not E.InCombatMobs[srcGUID].cooldowns then
                        E.InCombatMobs[srcGUID].cooldowns = {}
                    end
                    E.InCombatMobs[srcGUID].cooldowns[spellID] = {
                        name     = spellName,
                        id       = spellID,
                        nextCast = GetTime() + cd,
                    }
                    E.CooldownFrame:SetSafeEndTime(E:GetLeastEnemyNextCast())

                end
            local nextFlash = GetTime()
        end

        -- 4) 채널이 중단되거나 끝났을 때 정리
    elseif subevent == "SPELL_CHANNEL_STOP" or subevent == "SPELL_INTERRUPT" then

        -- 1) 적의 시전이 끊겼을 때
        if E.Config.enemySpellCooldowns[extraSpellID].cooldown then
            if not E.InCombatMobs[dstGUID].cooldowns then
                E.InCombatMobs[dstGUID].cooldowns = {}
            end

            E.InCombatMobs[dstGUID].cooldowns[extraSpellID] = {
                id = extraSpellID,
                nextCast = GetTime() + E.Config.enemySpellCooldowns[extraSpellID].cooldown,
            }
            E.CooldownFrame:SetSafeEndTime(E:GetLeastEnemyNextCast())
        end

        -- 중단되면 enemyCast 기록 삭제
        E.CooldownFrame.enemyCast[srcGUID] = nil
    elseif subevent == "UNIT_DIED" or subevent == "UNIT_DESTROYED" then
        E.CooldownFrame.enemyCast[dstGUID] = nil
    elseif subevent == "SPELL_CAST_SUCCESS" then
        -- spellID: 성공한 스킬의 ID
        -- spellName: 성공한 스킬의 이름
        -- srcGUID: 스킬을 시전한 적의 GUID

        if E.Config.sigils[spellID] then
            E.CooldownFrame:SetSafeEndTime(math.max(E:GetLeastEnemyNextCast(), GetTime() + 1))
        end

        -- 1) 적의 스킬 성공을 기준으로
        if E.Config.enemySpells[spellID] and E.InCombatMobs[srcGUID] then
            local cd = E.Config.enemySpellCooldowns[spellID] and E.Config.enemySpellCooldowns[spellID].cooldown or 0
            if cd then
                if not E.InCombatMobs[srcGUID].cooldowns then
                    E.InCombatMobs[srcGUID].cooldowns = {}
                end
                E.InCombatMobs[srcGUID].cooldowns[spellID] = {
                    name     = spellName,
                    id       = spellID,
                    nextCast = GetTime() + cd,
                }
                E.CooldownFrame:SetSafeEndTime(E:GetLeastEnemyNextCast())

            end
        end
    elseif subevent == "SPELL_CAST_START" then
        if E.InCombatMobs[srcGUID] and E.Config.enemySpells[spellID] then
            -- 1) 일단 spellID, spellName 은 바로 가져올 수 있고
            local castSpellID   = spellID
            local castSpellName = spellName

            -- 2) UnitCastingInfo 로 진짜 캐스트 시간(ms 단위) 얻기
            --    GUID → unitToken 변환 함수가 필요합니다. (LibUnitGUID 등 활용)
            local unitToken = E:GetUnitFromGUID(srcGUID)
            local startTimeMS, endTimeMS, _, _, notInterruptible
            if unitToken then
                -- UnitCastingInfo(unit) 반환값: name, _, _, startTimeMS, endTimeMS, _, _
                _, _, _, startTimeMS, endTimeMS = UnitCastingInfo(unitToken)
            end

            local castDuration = nil
            if startTimeMS and endTimeMS then
                -- 밀리초 → 초 단위로 변환
                castDuration = (endTimeMS - startTimeMS) / 1000
            else
                -- 대안: E.Config.spells 에 미리 정의해 둔 값 사용
                local cfg = E.Config.spells[castSpellID]
                castDuration = cfg and cfg.castTime
            end
        end
    end
    end)
