local E = select(2, ...):unpack()

-- 이름표 감시용 프레임
local NPWatcher = CreateFrame("Frame")

-- 트래킹 및 전투 상태 저장 테이블
E.Nameplate = {}
E.Nameplate.tracked      = {}                   -- [unit] = true

local tracked = E.Nameplate.tracked

function E.Nameplate:GetNameplateInfo()
    return {
        tracked      = tracked,
        inCombatMobs = E.Nameplate.inCombatMobs,
    }
end

-- 이벤트 등록
NPWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
NPWatcher:RegisterEvent("NAME_PLATE_UNIT_ADDED")
NPWatcher:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
NPWatcher:RegisterEvent("UNIT_THREAT_LIST_UPDATE")

-- 위협 유무 단순 체크 함수
local function hasThreat(target)
    -- 플레이어 위협 체크
    if UnitThreatSituation("player", target) then
        return true
    end
    -- 파티/레이드 위협 체크
    if IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            local u =  ("party"..i)
            if UnitThreatSituation(u, target) then
                return true
            end
        end
    end
    return false
end


NPWatcher:SetScript("OnEvent", function(self, event, unit, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        wipe(tracked)
        return
    end

    if event == "NAME_PLATE_UNIT_ADDED" then
        if UnitCanAttack("player", unit) then
            tracked[unit] = true
        end
        return
    end

    if event == "NAME_PLATE_UNIT_REMOVED" then
        if tracked[unit] then
            local guid = UnitGUID(unit)
            tracked[unit] = nil
        end
        return
    end

    if event == "UNIT_THREAT_LIST_UPDATE" then
        if not tracked[unit] then return end

        local guid = UnitGUID(unit)
        if not guid then return end

        -- 이미 전투 등록된 적은 스킵
        if E.InCombatMobs[guid] then return end

        -- 해당 NPC에 대한 설정이 있어야만
        local npcID = E:GetNPCIDFromGUID(guid)
        local npcInfo = npcID and E.Config.monsters[npcID]
        if not npcInfo then return end

        if hasThreat(unit) then
            -- NPC 정보 기반 전투 초기화
            local cooldowns = {}
            if npcInfo.spells then
                for _, spellID in ipairs(npcInfo.spells) do
                    local startCD = (E.Config.enemySpellCooldowns[spellID] or {}).start or 0
                    cooldowns[spellID] = { id = spellID, nextCast = GetTime() + startCD }
                end
            end

            E.InCombatMobs[guid] = {
                name          = UnitName(unit),
                npcID         = npcID,
                type          = npcInfo.type,
                lastInterrupt = 0,
                castTime      = npcInfo.castTime,
                cooldown      = npcInfo.cooldown,
                shareCooldown = npcInfo.shareCooldown,
                onlyInterrupt = npcInfo.onlyInterrupt,
                spellID       = npcInfo.spellID,
                raidFlag      = -1,
                cooldowns     = cooldowns,
            }

            E.CooldownFrame:SetSafeEndTime(E:GetLeastEnemyNextCast())

            if E.SetCombatSitu then E:SetCombatSitu() end
        end
    end
end)
