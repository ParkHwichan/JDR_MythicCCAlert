local E = select(2, ...):unpack()
local spells = E.Config.spells

local START_EVENTS = {
    SPELL_CAST_START         = true,
    SPELL_CAST_SUCCESS       = true,
    SWING_DAMAGE             = true,
    RANGE_DAMAGE             = true,
    SPELL_DAMAGE             = true,
    SPELL_PERIODIC_DAMAGE    = true,
    -- ← add aura application so that debuffs like taunt/silence count
    SPELL_AURA_APPLIED       = false,
    SPELL_AURA_APPLIED_DOSE  = false,
}


local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")


local TYPE_NPC          = COMBATLOG_OBJECT_TYPE_NPC
local REACTION_MASK     = COMBATLOG_OBJECT_REACTION_MASK
local REACTION_HOSTILE  = COMBATLOG_OBJECT_REACTION_HOSTILE



f:SetScript("OnEvent", function()
    local timestamp, subevent,
    hideCaster,
    srcGUID, srcName, srcFlags, srcRaidFlags,
    dstGUID, dstName, dstFlags, dstRaidFlags,
    spellID, spellName,
    _, extraSpellID = CombatLogGetCurrentEventInfo()


    -- 1) 공격 행동 계열로 “전투 개시” 판단
    if START_EVENTS[subevent] then
        if not dstFlags then
            return
        end

        if spellID == 217832 then
            return
        end

        local npcID = E:GetNPCIDFromGUID(dstGUID)
        if not npcID then
            return
        end

        local npcInfo = E.Config.monsters[npcID]

        if(not npcInfo) then
            return
        end

        if E.InCombatMobs[dstGUID] then
            return
        end
        local cooldowns = {}
        if npcInfo.spells then
            for _, spellID in ipairs(npcInfo.spells) do
                local start = E.Config.enemySpellCooldowns[spellID] and E.Config.enemySpellCooldowns[spellID].start or 0

                cooldowns[spellID] = {
                    id = spellID,
                    nextCast = GetTime() + start,
                }
            end
        end

        E.InCombatMobs[dstGUID] = {
            name = dstName,
            npcID = npcID,
            type = npcInfo.type,
            lastInterrupt = 0,
            castTime = npcInfo.castTime,
            cooldown = npcInfo.cooldown,
            shareCooldown = npcInfo.shareCooldown,
            onlyInterrupt = npcInfo.onlyInterrupt,
            spellID = npcInfo.spellID,
            raidFlag = dstRaidFlags,
            cooldowns = cooldowns,
        }



        E:SetCombatSitu()




        -- 2) 몹 사망 시 테이블에서 제거
    elseif subevent == "UNIT_DIED" then
        E.InCombatMobs[dstGUID] = nil
        if next(E.InCombatMobs) == nil then
            E.CombatSitu = "NO_COMBAT"
        else
            E:SetCombatSitu()
        end
    end
end)

-- 전투 종료 시 클리어
local combatWatcher = CreateFrame("Frame")
combatWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
combatWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
combatWatcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")

combatWatcher:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" or event ==  "ZONE_CHANGED_NEW_AREA" then
        -- 기존: 전투 종료 시 클리어
        wipe(E.InCombatMobs)
        E:SetCombatSitu()
        E.CombatSitu = "NO_COMBAT"
        if not E.refreshCooldownFrame == nil then
            E:refreshCooldownFrame()
        end
    end
end)
