
local characterNames = {
    ["제탓은아닌데요"] = "제탓",
    ["제탓아님"] = "제탓",
    ["힐탓이아닙니다"] = "제탓",
    ["카르꽁스"] = "카르꽁스",
    ["카르꽁순"] = "카르꽁스",
    ["Worrisome"] = "짱크",
    ["Maratang"] = "마라탕"
}

local className = {
    ["DEATHKNIGHT"] = "죽기",
    ["DEMONHUNTER"] = "악사",
    ["DRUID"] = "드루",
    ["HUNTER"] = "냥꾼",
    ["MAGE"] = "법사",
    ["MONK"] = "수도사",
    ["PALADIN"] = "기사",
    ["PRIEST"] = "사제",
    ["ROGUE"] = "도적",
    ["SHAMAN"] = "술사",
    ["WARLOCK"] = "흑마",
    ["WARRIOR"] = "전사",
    ["EVOKER"] = "기원사",
}

-- 애드온(폴더) 이름 -- 필요하면 바꿔 주세요
local ADDON_NAME = "JDR"

---플레이어 이름·클래스에 맞는 .ogg 풀패스 반환
---@param classToken string  -- "MAGE", "ROGUE" ...
---@param playerName string  -- "제탓은아닌데요" ...
---@return string|nil        -- eg. "Interface\\AddOns\\JDR\\sounds\\제탓.ogg"
function GetSpecSound(classToken, playerName)
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

function GetNextInterruptSound()
    return string.format("Interface\\AddOns\\%s\\sounds\\%s.ogg",
            ADDON_NAME, "다음짤")
end