local E = select(2, ...):unpack()
local ADDON_NAME  =  ...

local characterNames = {
    ["제탓은아닌데요"] = "player_jetat",
    ["제탓아님"] = "player_jetat",
    ["힐탓이아닙니다"] = "player_jetat",
    ["카르꽁스"] = "player_jmy",
    ["카르꽁순"] = "player_jmy",
    ["꽁스"] = "player_jmy",
    ["Worrisome"] = "player_zzang",
    ["Maratang"] = "player_pa"
}

local className = {
    ["DEATHKNIGHT"] = "class_dk",
    ["DEMONHUNTER"] = "class_dh",
    ["DRUID"] = "class_dr",
    ["HUNTER"] = "class_hunter",
    ["MAGE"] = "class_mage",
    ["MONK"] = "class_monk",
    ["PALADIN"] = "class_knight",
    ["PRIEST"] = "class_priest",
    ["ROGUE"] = "class_rouge",
    ["SHAMAN"] = "class_shaman",
    ["WARLOCK"] = "class_warlock",
    ["WARRIOR"] = "class_warrior",
    ["EVOKER"] = "class_evoker",
}

---플레이어 이름·클래스에 맞는 .ogg 풀패스 반환
---@param classToken string  -- "MAGE", "ROGUE" ...
---@param playerName string  -- "제탓은아닌데요" ...
---@return string|nil        -- eg. "Interface\\AddOns\\JDR\\sounds\\제탓.ogg"
function E:GetSpellSound( soundPath)
    local fileName = soundPath
    -- ③ 매핑이 없다면 nil 반환
    if not fileName then return nil end

    -- ④ 풀 패스 구성 (백슬래시 2개는 Lua 문자열 이스케이프)
    return string.format("Interface\\AddOns\\%s\\sounds\\%s.ogg",
            ADDON_NAME, fileName)
end

function E:GetCharacterSound(playerName, classToken)
    -- ① 이름별 전용 사운드 우선
    local fileName = characterNames[playerName]

    -- ② 없으면 클래스 기본
    if not fileName then
        fileName = className[classToken]
    end

    -- ③ 매핑이 없다면 nil 반환
    if not fileName then return nil end

    -- ④ 풀 패스 구성 (백슬래시 2개는 Lua 문자열 이스케이프)
    return string.format("Interface\\AddOns\\%s\\sounds\\%s.ogg",
            ADDON_NAME, fileName)
end

function E:GetNextSound()
    return string.format("Interface\\AddOns\\%s\\sounds\\%s.ogg",
            ADDON_NAME, "next")
end

function E:GetNextInterruptSound()
    return string.format("Interface\\AddOns\\%s\\sounds\\%s.ogg",
            ADDON_NAME, "next_interrupt")
end

--- 플레이어 이름·클래스에 맞는 .ogg 풀패스 반환
--- @param next boolean -- true 이면 다음 사운드, false 이면 현재 사운드
--- @param classToken string  -- "MAGE", "ROGUE" ...
--- @param playerName string  -- "제탓은아닌데요" ...
--- @param soundPath string  -- "제탓", "법사" ...
---
function E:PlaySound(next, playerName, classToken, spellSoundOverride)
    local interval = 0.5   -- 각 사운드 사이 간격
    local delay    = 0

    -- 1) “다음” 사운드도 interval 후에
    if next then
        local nextPath = self:GetNextSound()
        if nextPath then
            delay = delay
            C_Timer.After(delay, function()
                PlaySoundFile(nextPath, "Dialog")
            end)
        end
    end

    -- 2) 플레이어별 사운드
    local charPath = self:GetCharacterSound(playerName, classToken)
    if charPath then
        delay = delay + interval
        C_Timer.After(delay, function()
            PlaySoundFile(charPath, "Dialog")
        end)
    end

    -- 3) 스펠·클래스 사운드
    local spellPath = self:GetSpellSound( spellSoundOverride)
    if spellPath then
        delay = delay + interval
        C_Timer.After(delay, function()
            PlaySoundFile(spellPath, "Dialog")
        end)
    end
end