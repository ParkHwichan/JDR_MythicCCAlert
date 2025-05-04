local E = select(2, ...):unpack()
local spells = E.Config.spells

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")


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
    extraSpellID, extraSpellName = CombatLogGetCurrentEventInfo()

    -- 1) 내가 적의 시전을 끊었을 때
    if subevent == "SPELL_INTERRUPT" then

        -- 2) 기존 SPELL_CAST_SUCCESS 처리 (내가 주문을 성공적으로 시전했을 때)
    elseif subevent == "SPELL_CAST_SUCCESS" then
        local spells = E.Config.spells
        local spell = spells[spellID]
        if spell and spell.ccDuration then
            E.CooldownFrame.delay = spell.ccDuration
        end
    end
end)
