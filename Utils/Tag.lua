local E = select(2, ...):unpack()

function E:GetSpellIconTag (spellID ,size )
    -- spellID 로부터 아이콘 경로를 얻어서 텍스처 태그를 생성
    local texturePath = C_Spell.GetSpellTexture(spellID)

    if not texturePath then
        return ""
    end

    local iconSize    =  size or 32       -- 원하는 크기
    local iconTag     = format("|T%s:%d:%d:0:0|t ", texturePath, iconSize, iconSize)
    return iconTag
end

-- ------------------------------------------------------------------
--  클래스 색 컬러 태그 헬퍼
--  @param playerName string: 표시할 이름
--  @param classToken string: "MAGE", "ROGUE" 등의 WoW 클래스 토큰s
--  @return string: 색상이 입혀진 |c…|r 문자열
-- ------------------------------------------------------------------
function E:GetCharacterColorTag(playerName, classToken)
    if not playerName then return "" end

    -- WoW 10.0+ 에선 C_ClassColor.GetClassColor, 그 외엔 RAID_CLASS_COLORS
    local color = (C_ClassColor and C_ClassColor.GetClassColor(classToken))
            or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classToken])
            or RAID_CLASS_COLORS[classToken]
            or { r = 1, g = 1, b = 1 }

    local hex = string.format("%02x%02x%02x",
            color.r * 255,
            color.g * 255,
            color.b * 255
    )
    return ("|cff%s%s|r"):format(hex, playerName)
end