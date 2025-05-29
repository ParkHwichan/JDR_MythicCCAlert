local E = unpack(select(2, ...))

-- flatten all your CC tables into one lookup for easy checking
local ccLookup = {}
for cat, t in pairs(E.Config.CCAuras) do
    for spellID, info in pairs(t) do
        ccLookup[spellID] = info.name
    end
end

-- 1) nameplate 단위 unit token ↔ GUID 매핑
local guidToUnit = {}
local plateWatcher = CreateFrame("Frame")
plateWatcher:RegisterEvent("NAME_PLATE_UNIT_ADDED")
plateWatcher:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
plateWatcher:SetScript("OnEvent", function(self, event, unit)
    local guid = UnitGUID(unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        guidToUnit[guid] = unit
    else -- NAME_PLATE_UNIT_REMOVED
        guidToUnit[guid] = nil
    end
end)

-- create the frame
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        -- now UnitAura is guaranteed to exist
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        -- pull combat-log data
        self:SetScript("OnEvent", function(_, _, ...)
            local timestamp, subevent,
            hideCaster,
            srcGUID, srcName, srcFlags, srcRaidFlags,
            dstGUID, dstName, dstFlags, dstRaidFlags,
            spellID, spellName = CombatLogGetCurrentEventInfo()


            if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REMOVED" then

                local ccInfo = ccLookup[spellID]
                if not ccInfo then return end

                local mob = E.InCombatMobs[dstGUID]
                if not mob then return end

                -- GUID ↔ unit token 매핑에서 unit 가져오기
                local unit = guidToUnit[dstGUID]
                -- (만약 nameplate 말고 party/raid/unitTarget 매핑을 추가했다면 여기서도 확인)


                local ccName = ccLookup[spellID]
                if ccName then
                    if subevent == "SPELL_AURA_APPLIED" then
                        local cfg = ccLookup[spellID]
                        if not cfg then return end

                        local duration, expirationTime
                        local defaultDur = cfg.duration or 0.2

                        if unit and UnitExists(unit) then

                            local aura = C_UnitAuras.GetAuraDataBySpellName(unit, spellName, "HARMFUL")

                            if aura then
                                duration       = aura.duration or 0
                                expirationTime = aura.expirationTime or 0
                            else
                                -- fallback to your config if the aura isn't found yet
                                duration       = defaultDur
                                expirationTime = (defaultDur > 0) and (GetTime() + defaultDur) or 0
                            end
                        else
                            -- unit 토큰이 없으면 config.duration 사용
                            duration       = defaultDur
                            expirationTime = (defaultDur > 0) and (GetTime() + defaultDur) or 0
                        end

                        -- 무한 지속 오라 처리
                        if duration == 0 and expirationTime == 0 then
                            duration       = math.huge
                            expirationTime = math.huge
                        end

                        -- 기록
                        mob.cc = mob.cc or {}
                        mob.cc[spellID] = {
                            name           = spellName,
                            startTime      = GetTime(),
                            duration       = duration,
                            expirationTime = expirationTime,
                        }
                        E.CooldownFrame:SetSafeEndTime(E:GetLeastEnemyNextCast())
                    else
                        if mob.cc then
                            mob.cc[spellID] = nil
                        end
                    end
                end
            end
        end)
    end
end)