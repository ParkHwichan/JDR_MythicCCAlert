local E      = unpack(select(2, ...))
local AceGUI = E.Libs.AceGUI  -- AceGUI-3.0
local AceComm       = LibStub("AceComm-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate    = E.Libs.LibDeflate
local COMM_REQ      = "JDRREQUEST"  -- 요청 프리픽스
local COMM_DATA     = "JDRPROFILE"  -- 실제 데이터 전송 프리픽스



hooksecurefunc("SetItemRef", function(link, text, button, chatFrame, ...)
    -- 컬러코드·|H|h 제거
    local stripped = link
            :gsub("|c%x%x%x%x%x%x%x%x", "") -- |cffa335ee 제거
            :gsub("|H", "")                  -- |H 제거
            :gsub("|h", "")                  -- |h 제거
            :gsub("|r", "")
    local prefix, key = stripped:match("^(%w+):(.+)$")
    if prefix ~= COMM_REQ then return end

    -- 여기가 COMM_REQ 와 같아야 동작
    AceComm:SendCommMessage(COMM_REQ, key, "PARTY", nil, "BULK")
    print(("|cffa330c9[JDR]|r 프로필 '%s' 요청 전송"):format(key))
end)
-- 3) 요청 수신 핸들러 → 데이터 직렬화·전송
AceComm:RegisterComm(COMM_REQ, function(_, key, _, sender)
    local preset = E.DB.spells.profiles[key]
    if not preset then return end
    local ok, raw = AceSerializer:Serialize(preset)
    if not ok then return print("Serialize 실패:", raw) end
    local enc = LibDeflate:EncodeForWoWAddonChannel(
            LibDeflate:CompressDeflate(raw, {level=9})
    )
    AceComm:SendCommMessage(COMM_DATA, enc, "WHISPER", sender, "BULK")
end)

-- 4) 데이터 수신 핸들러 → 역직렬화·저장
AceComm:RegisterComm(COMM_DATA, function(_, encoded, _, sender)
    local compressed = LibDeflate:DecodeForWoWAddonChannel(encoded)
    local raw = LibDeflate:DecompressDeflate(compressed)
    local ok, tbl = AceSerializer:Deserialize(raw)
    if not ok then return print("Deserialize 실패:", tbl) end
    local id = tbl._id or ("imp_"..date("%H%M%S"))
    tbl._id = id
    E.DB.spells.profiles[id] = tbl
    E.DB.spells.current = id
    print(("|cff00ff00[JDR]|r %s 님의 프로필 '%s' 수신 완료"):format(sender,id))
    E.Options:buildSpellTab(E.Options.cfgFrame.children[1])
end)

local function displaySendingProgress(userArgs, bytesSent, bytesToSend)
    local distribution = userArgs[1]
    local presetName = userArgs[2]

    local prefix = "[JDR:"
    local name, realm = UnitFullName("player")
    name = UnitFullName(name)
    local fullName = name.."+"..realm

    --done sending
    if bytesSent == bytesToSend then
        SendChatMessage(prefix  .. fullName .. "-".. presetName .. "]", distribution)
    end
end



-- ▲/▼ 클릭 시 priority 교환
local function swapPriority(a, b)
    a.priority, b.priority = b.priority, a.priority
end

-- priority 내림차순 정렬용
local function byPriority(a, b)
    return a.priority > b.priority
end

local function byClass(a, b)
    return a.class < b.class
end

local function PrefillChat(link)
    C_Timer.After(0, function()
        -- 1) 채팅창 열기
        C_ChatEdit.OpenChat("", DEFAULT_CHAT_FRAME)
        -- 2) 에디터 객체 가져오기
        local edit = C_ChatEdit.GetActiveWindow()
        -- 3) 삽입
        edit:Insert(link)
        edit:HighlightText()
    end)
end

-- buildSpellCategory 를 살짝 바꿔서 spellsTable 을 인자로 받습니다.
local function buildSpellCategory(container, category, spellsTable)
    container:ReleaseChildren()
    container:SetLayout("List")

    -- spellsTable 에서 id→spell 구조라고 가정
    local spells = {}
    for id, spell in pairs(spellsTable) do
        if category == "INTERRUPT" and spell.type == "interrupt"
                or category == "AOE" and (spell.type=="aoeCC" or spell.type=="aoeInterrupt")
        then
            spell.id = id
            table.insert(spells, spell)
        end
    end
    table.sort(spells, byClass)

    for _, spell in ipairs(spells) do
        local row = AceGUI:Create("SimpleGroup")
        row:SetLayout("Flow")
        row:SetFullWidth(true)
        container:AddChild(row)

        local info = C_Spell.GetSpellInfo(spell.id)
        local text = E:GetSpellIconTag(spell.id,14) .. E:GetCharacterColorTag(info.name, spell.class)

        local name = AceGUI:Create("Label")
        name:SetText(text)
        name:SetRelativeWidth(0.3)
        row:AddChild(name)

        local slider = AceGUI:Create("Slider")
        slider:SetSliderValues(0,100,1)
        slider:SetLabel("우선순위")
        slider:SetValue(spell.priority)
        slider:SetRelativeWidth(0.6)
        slider:SetCallback("OnValueChanged", function(_,_,v)
            spell.priority = v
        end)
        row:AddChild(slider)
    end
end

-- “주문” 탭 자체를 구성
function E.Options:buildSpellTab(container)
    container:ReleaseChildren()
    container:SetLayout("Flow")

    -- 1) 프로필 헤더
    local header = AceGUI:Create("SimpleGroup")
    header:SetLayout("Flow")
    header:SetRelativeWidth(1)
    container:AddChild(header)

    -- 프로필 리스트 준비
    local spellsDB = E.DB.spells.profiles
    local names = {}
    for k in pairs(spellsDB) do table.insert(names, k) end
    table.sort(names)

    local list = {}
    for _, profileName in ipairs(names) do
        list[profileName] = profileName
    end


    -- 드롭다운: 현재 프로필 선택
    local dd = AceGUI:Create("Dropdown")
    dd:SetLabel("프로필")
    dd:SetList(list)
    dd:SetValue(E.DB.spells.current)
    dd:SetRelativeWidth(0.2)
    dd:SetCallback("OnValueChanged", function(_,_,val)
        E.DB.spells.current = val
        -- 다시 그리기
        self:buildSpellTab(container)
    end)
    header:AddChild(dd)

    -- 새 프로필 버튼
    local btn = AceGUI:Create("Button")
    btn:SetText("새 프로필")
    btn:SetRelativeWidth(0.15)
    btn:SetCallback("OnClick", function()
       StaticPopup_Show("JDR_CREATE_PROFILE")
    end)
    header:AddChild(btn)

    -- 삭제 버튼
    local delBtn = AceGUI:Create("Button")
    delBtn:SetText("삭제하기")
    delBtn:SetRelativeWidth(0.1)
    -- 클릭 시 팝업 띄우기
    delBtn:SetCallback("OnClick", function()
        local name = E.DB.spells.current
        StaticPopup_Show("JDR_DELETE_PROFILE", name)
    end)
    header:AddChild(delBtn)

    -- 삭제 버튼 다음에
    local renameBtn = AceGUI:Create("Button")
    renameBtn:SetText("이름변경")
    renameBtn:SetRelativeWidth(0.1)
    renameBtn:SetCallback("OnClick", function()
        StaticPopup_Show("JDR_RENAME_PROFILE", E.DB.spells.current)
    end)
    header:AddChild(renameBtn)

    -- 기존 헤더 뒤에
    local expBtn = AceGUI:Create("Button")
    expBtn:SetText("내보내기")
    expBtn:SetRelativeWidth(0.1)
    expBtn:SetCallback("OnClick", function()
        StaticPopup_Show("JDR_EXPORT_PROFILE")
    end)
    header:AddChild(expBtn)

    -- buildSpellTab 의 header 생성 뒤
    local expBtn = AceGUI:Create("Button")
    expBtn:SetText("링크 내보내기")
    expBtn:SetWidth(100)
    expBtn:SetCallback("OnClick", function()
        local export = E:TableToString(E.DB.spells.profiles[E.DB.spells.current], false, 5)
        local preset =  E.DB.spells.profiles[E.DB.spells.current]
        local current = E.DB.spells.current or "default"
        AceComm:SendCommMessage(COMM_REQ, export, "PARTY", nil, "BULK", displaySendingProgress,
                { "PARTY" , current })
    end)
    --header:AddChild(expBtn)

    local impBtn = AceGUI:Create("Button")
    impBtn:SetText("가져오기")
    impBtn:SetRelativeWidth(0.1)
    impBtn:SetCallback("OnClick", function()
        StaticPopup_Show("JDR_IMPORT_PROFILE")
    end)
    header:AddChild(impBtn)

    -- 드롭다운 값이 바뀔 때마다 삭제 버튼 활성/비활성 업데이트
    dd:SetCallback("OnValueChanged", function(_,_,val)
        E.DB.spells.current = val
        -- default면 비활성, 아니면 활성
        delBtn:SetDisabled(val == "default")
        -- UI 재생성
        self:buildSpellTab(container)
    end)
    -- 초기 상태 세팅
    delBtn:SetDisabled(E.DB.spells.current == "default")

    -- 2) TabGroup
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetFullWidth(true)
    tabs:SetFullHeight(true)
    tabs:SetLayout("Fill")
    tabs:SetTabs({
        { text = "개인 차단", value = "INTERRUPT" },
        { text = "광역 CC",   value = "AOE"       },
    })
    tabs:SetCallback("OnGroupSelected", function(_,_,group)
        tabs:ReleaseChildren()
        local scroll = AceGUI:Create("ScrollFrame")
        scroll:SetLayout("List")
        scroll:SetFullWidth(true)
        scroll:SetFullHeight(true)
        tabs:AddChild(scroll)

        -- 현재 프로필에서 spells 테이블을 꺼내서 넘겨줌
        local current = E.DB.spells.current
        local tbl = E.DB.spells.profiles[current] or {}
        buildSpellCategory(scroll, group, tbl)
    end)

    container:AddChild(tabs)
    tabs:SelectTab("INTERRUPT")
end

StaticPopupDialogs["JDR_CREATE_PROFILE"] = {
    text = "새 프로필 이름을 입력하세요:",
    button1 = "확인",
    button2 = "취소",
    hasEditBox = true,
    maxLetters = 32,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,

    -- 팝업이 뜰 때마다 입력칸 초기화
    OnShow = function(self)
        self.editBox:SetText("")
        self.editBox:SetFocus()
    end,
    -- 엔터키로도 확인
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        parent.button1:Click()
    end,
    -- 확인 버튼 클릭 시
    OnAccept = function(self)
        local name = self.editBox:GetText():trim()
        if name == "" then
            return StaticPopup_Show("JDR_CREATE_PROFILE")  -- 빈 문자열이면 다시 열기
        end
        local profile = E.DB.spells
        -- 이미 있는 이름이면 덮어쓰기 금지
        if profile.profiles[name] then
            print("|cffff0000[JDR]|r 이미 존재하는 프로필 이름입니다.")
            return
        end
        -- 새 프로필 만들기 (현재 설정 복사 or 빈 테이블)
        profile.profiles[name] = CopyTable(profile.profiles[profile.current])
        -- 방금 만든 프로필을 곧바로 현재로 지정
        profile.current = name
        print("|cff00ff00[JDR]|r 새 프로필 '"..name.."' 생성 및 선택됨")
        -- UI 갱신
        E.Options:buildSpellTab(E.Options.cfgFrame.children[1])  -- 컨테이너 참조에 맞게 조정
    end,
}

StaticPopupDialogs["JDR_DELETE_PROFILE"] = {
    text = "프로필 '%s' 을(를) 정말 삭제하시겠습니까?",
    button1 = "삭제",
    button2 = "취소",
    OnAccept = function(self, profileName, ...)
        local p = E.DB.spells
        local name = E.DB.spells.current
        -- 삭제
        p.profiles[name] = nil
        p.current = "default"
        print("|cff00ff00[JDR]|r 프로필 '"..name.."' 이(가) 삭제되었습니다.")
        -- UI 갱신
        E.Options:buildSpellTab(E.Options.cfgFrame.children[1])
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    showAlert = true,
    preferredIndex = 3,
}

StaticPopupDialogs["JDR_EXPORT_PROFILE"] = {
    text = "아래 문자열을 복사하세요:",
    button1 = "닫기",
    hasEditBox = true,
    editBoxWidth = 400,
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self)
        local p = E.DB.spells.profiles[E.DB.spells.current]
        local s = E:ExportProfileString(p)
        self.editBox:SetText(s)
        self.editBox:HighlightText()
        self.editBox:ClearFocus()
    end,
    editBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["JDR_IMPORT_PROFILE"] = {
    text = "문자열을 붙여넣고 확인하세요:",
    button1 = "확인", button2 = "취소",
    hasEditBox = true,
    editBoxWidth = 400,
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self)
        self.editBox:SetText("")
        self.editBox:SetFocus()
    end,
    EditBoxOnEnterPressed = function(self)
        self.button1:Click()
    end,
    OnAccept = function(self)
        local input = self.editBox:GetText():trim()
        local tbl, err = E:ImportProfileString(input)
        if not tbl then
            print("|cffff0000[JDR]|r 가져오기 실패:", err)
            return
        end
        -- 새 프로필 생성
        local name = "imported_"..date("%H%M%S")
        E.DB.spells.profiles[name] = tbl
        E.DB.spells.current = name
        print("|cff00ff00[JDR]|r 프로필 가져오기 성공:", name)
        E.Options:buildSpellTab(E.Options.cfgFrame.children[1])
    end,
    editBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

-- JSON 직렬화 (간단히 Lua 표현식으로)
function E:SerializeProfile(tbl)
    local AceSerializer = LibStub("AceSerializer-3.0")
    -- ① 직렬화된 문자열을 먼저 받고, ② 에러 메시지를 두 번째 받습니다
    local serialized, err = AceSerializer:Serialize(tbl)
    if not serialized then
        error("Serialize 실패: "..tostring(err))
    end
    return serialized
end

function E:DeserializeProfile(str)
    local AceSerializer = LibStub("AceSerializer-3.0")
    local ok, tbl = AceSerializer:Deserialize(str)
    if not ok then
        return nil, tbl  -- tbl 에는 에러 메시지
    end
    return tbl
end

function E:ExportProfileString(profileTable)
    local raw = self:SerializeProfile(profileTable)
    local compressed = E.Libs.LibDeflate:CompressDeflate(raw, {level = 9})
    local encoded    = E.Libs.LibDeflate:EncodeForPrint(compressed)
    return encoded
end

function E:ImportProfileString(encoded)
    local LibDeflate = E.Libs.LibDeflate

    local compressed = LibDeflate:DecodeForPrint(encoded)
    if not compressed then
        return nil, "인코딩이 올바르지 않습니다."
    end

    local raw = LibDeflate:DecompressDeflate(compressed)
    if not raw then
        return nil, "압축 해제에 실패했습니다."
    end

    -- 여기서 loadstring 대신 AceSerializer:Deserialize 를 사용
    local tbl, err = self:DeserializeProfile(raw)
    if not tbl then
        return nil, err
    end
    return tbl
end


-- Blizzard StaticPopup 대신, 채팅 링크는 SetItemRef 훅으로 처리


StaticPopupDialogs["JDR_EXPORT_PROFILE_CHAT"] = {
    text = "아래 문자열을 복사하세요:",
    button1 = "닫기",
    hasEditBox = true,
    editBoxWidth = 400,
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnShow = function(self)
        local p    = E.DB.spells.profiles[E.DB.spells.current]
        local str  = E:ExportProfileString(p)
        self.editBox:SetText(str)
        self.editBox:HighlightText()
        self.editBox:ClearFocus()
    end,
    editBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["JDR_RENAME_PROFILE"] = {
    text = "프로필 '%s' 의 새 이름을 입력하세요:",
    button1 = "확인", button2 = "취소",
    hasEditBox = true, maxLetters = 32,
    timeout = 0, whileDead = true, hideOnEscape = true,
    preferredIndex = 3,

    -- 팝업이 뜰 때마다 데이터(self.data)에 담긴 oldName을 꺼내 사용
    OnShow = function(self)
        local oldName = E.DB.spells.current
        self.editBox:SetText(oldName)
        self.editBox:SetFocus()
        self.editBox:HighlightText()
    end,

    EditBoxOnEnterPressed = function(self)
        self:GetParent().button1:Click()
    end,

    OnAccept = function(self)
        local oldName = E.DB.spells.current
        local newName = self.editBox:GetText():trim()
        if newName == "" or newName == oldName then return end

        local p = E.DB.spells
        if p.profiles[newName] then
            print("|cffff0000[JDR]|r 이미 존재하는 프로필 이름입니다.")
            return
        end

        -- 키 교체
        p.profiles[newName] = p.profiles[oldName]
        p.profiles[oldName] = nil
        p.current = newName

        print(("|cff00ff00[JDR]|r 프로필 '%s' → '%s' 으로 이름 변경됨"):format(oldName, newName))
        E.Options:buildSpellTab(E.Options.cfgFrame.children[1])
    end,
}


function E:TableToString(inTable, forChat, level)
    local serialized = AceSerializer:Serialize(inTable)
    local compressed = LibDeflate:CompressDeflate(serialized, {
        level = 9
    })
    -- prepend with "!" so that we know that it is not a legacy compression
    -- also this way, old versions will error out due to the "bad" encoding
    local encoded = "!"
    if (forChat) then
        encoded = encoded..LibDeflate:EncodeForPrint(compressed)
    else
        encoded = encoded..LibDeflate:EncodeForWoWAddonChannel(compressed)
    end
    return encoded
end



-- 1) 들어오는 파티/레이드/길드 채팅을 가로채서
--    [JDR:키] 패턴을 링크 토큰으로 바꿔줍니다.
local function ChatFilter(self, event, msg, author, ...)

    -- "[JDR: someKey]" 패턴 찾기
    local key = msg:match("%[JDR:%s*([^%]]+)%]")
    if not key then
        return false
    end

    -- ① 레이블은 들어온 msg 그대로
    local label = msg

    -- ② 보라색 에픽 색상 코드: |cffa335ee … |r
    local linkToken = string.format(
            "|cffa335ee|H%s:%s|h%s|h|r",
            COMM_REQ,    -- "JDRREQ"
            key,       -- 요청 키
            label      -- "[JDR:key]" 원본 메시지
    )

    -- ③ 필터 교체: 원본 msg → linkToken
    return false, linkToken, author, ...
end



ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", ChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", ChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", ChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", ChatFilter)
