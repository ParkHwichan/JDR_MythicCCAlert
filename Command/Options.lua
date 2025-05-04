-- Modules/ConfigAceGUI.lua
local E = unpack(select(2, ...))

-- 라이브러리 로드
local AceGUI = LibStub("AceGUI-3.0")

local testSpells = {
    [1] = {
        guid      = 1,
        class     = "DEATHKNIGHT",
        isDeadOrOffline = false,
        unitName  = "테스트",
        duration  = "2",
        enabled   = "true",
        priority = "999",
        id        = 192058,
        name      = "천폭",
        soundPath = nil,
        type      = "aoeCC",
        baseCD    = 40,
        remaining = 0,
        ready     = true,
    },
    [2] = {
        guid      = 1,
        class     = "DEATHKNIGHT",
        isDeadOrOffline = false,
        unitName  = "테스트",
        duration  = "2",
        enabled   = "true",
        priority = "999",
        id        = 51490,
        name      = "천폭",
        soundPath = nil,
        type      = "aoeCC",
        baseCD    = 40,
        remaining = 0,
        ready     = true,
    },
    [3] = {
        guid      = 1,
        class     = "DEATHKNIGHT",
        isDeadOrOffline = false,
        unitName  = "테스트",
        duration  = "2",
        enabled   = "true",
        priority = "999",
        id        = 57994,
        name      = "천폭",
        soundPath = nil,
        type      = "aoeCC",
        baseCD    = 40,
        remaining = 0,
        ready     = true,
    },
    [4] = {
        guid      = 1,
        class     = "DEATHKNIGHT",
        isDeadOrOffline = false,
        unitName  = "테스트",
        duration  = "2",
        enabled   = "true",
        priority = "999",
        id        = 370,
        name      = "천폭",
        soundPath = nil,
        type      = "aoeCC",
        baseCD    = 40,
        remaining = 0,
        ready     = true,
    },
    [5] = {
        guid      = 1,
        class     = "DEATHKNIGHT",
        isDeadOrOffline = false,
        unitName  = "테스트",
        duration  = "2",
        enabled   = "true",
        priority = "999",
        id        = 114050,
        name      = "천폭",
        soundPath = nil,
        type      = "aoeCC",
        baseCD    = 40,
        remaining = 0,
        ready     = true,
    },

}


-- 설정 창 객체 저장용
local cfgFrame
-- 실제 위젯을 생성하는 함수
local function buildConfigWidgets(frame)
    local DB = E.DB


    -- 1) 애드온 전체 사용 토글
    local cbEnable = AceGUI:Create("CheckBox")
    cbEnable:SetLabel("애드온 사용")
    cbEnable:SetValue(DB.enabled)
    cbEnable:SetCallback("OnValueChanged", function(_,_,v)
        DB.enabled = v
        if v then E:Enable() else E:Disable() end
    end)
    frame:AddChild(cbEnable)

    -- 2) 쿨다운 프레임 표시 토글
    local cbShow = AceGUI:Create("CheckBox")
    cbShow:SetLabel("쿨다운 프레임 표시")
    cbShow:SetValue(DB.cooldownFrame.enabled)
    cbShow:SetCallback("OnValueChanged", function(_,_,v)
        DB.cooldownFrame.enabled = v
        if v then E.CooldownFrame:ShowFrame() else E.CooldownFrame:HideFrame() end
    end)
    frame:AddChild(cbShow)

    -- 3) 슬라이더 생성 헬퍼
    local function makeSlider(name, min, max, step, cur, onChanged)
        local slider = AceGUI:Create("Slider")
        slider:SetLabel(name)
        slider:SetSliderValues(min, max, step)
        slider:SetValue(cur)
        slider:SetFullWidth(true)
        slider:SetCallback("OnValueChanged", function(_,_,v)
            v = math.floor(v + 0.5)
            slider:SetValue(v)
            onChanged(v)
        end)
        frame:AddChild(slider)
    end

    -- 3-1) 아이콘 크기 & 간격
    makeSlider("표시 스킬 갯수", 1, 5, 1, DB.cooldownFrame.max_icon, function(v)
        DB.cooldownFrame.max_icon = v
        local tmp = testSpells
        local num = E.DB.cooldownFrame.max_icon
        -- 3) num 개수만큼 잘라내기
        if num and num >= 1 then
            local tmp2 = {}
            for i = 1, math.min(num, #tmp) do
                tinsert(tmp2, tmp[i])
            end
            tmp = tmp2
        end
        E:SetIconPool(tmp)
    end)

    makeSlider("큰 아이콘 크기", 20, 80, 1, DB.cooldownFrame.big_size, function(v)
        DB.cooldownFrame.big_size = v
        E:RefreshCooldownFrame()
    end)
    makeSlider("작은 아이콘 크기", 16, 64, 1, DB.cooldownFrame.small_size, function(v)
        DB.cooldownFrame.small_size = v
        E:RefreshCooldownFrame()
    end)
    makeSlider("아이콘 간격",         0,  20, 1, DB.cooldownFrame.margin, function(v)
        DB.cooldownFrame.margin = v
        E:RefreshCooldownFrame()
    end)

    -- 4) 글로우 토글
    local cbGlow = AceGUI:Create("CheckBox")
    cbGlow:SetLabel("내 사용 순서에 반짝임")
    cbGlow:SetValue(DB.cooldownFrame.show_glow)
    cbGlow:SetCallback("OnValueChanged", function(_,_,v)
        DB.cooldownFrame.show_glow = v
    end)
    frame:AddChild(cbGlow)

    -- 5) 음성 알림 토글
    local cbSound = AceGUI:Create("CheckBox")
    cbSound:SetLabel("내 사용 순서에 음성 알림")
    cbSound:SetValue(DB.cooldownFrame.sound_alert)
    cbSound:SetCallback("OnValueChanged", function(_,_,v)
        DB.cooldownFrame.sound_alert = v
    end)
    frame:AddChild(cbSound)

    -- 6) 이동 잠금 토글
    local cbLock = AceGUI:Create("CheckBox")
    cbLock:SetLabel("프레임 이동 잠금")
    cbLock:SetValue(DB.cooldownFrame.lock)
    cbLock:SetCallback("OnValueChanged", function(_,_,v)
        DB.cooldownFrame.lock = v
        E.CooldownFrame:EnableMouse(not v)
    end)
    frame:AddChild(cbLock)

    -- 7) X/Y 위치 슬라이더
    makeSlider("프레임 X 위치", -500, 500, 1, DB.cooldownFrame.pos_x, function(v)
        DB.cooldownFrame.pos_x = v
        E.CooldownFrame:ClearAllPoints()
        E.CooldownFrame:SetPoint("CENTER", UIParent, "CENTER", v, DB.cooldownFrame.pos_y)
    end)
    makeSlider("프레임 Y 위치", -500, 500, 1, DB.cooldownFrame.pos_y, function(v)
        DB.cooldownFrame.pos_y = v
        E.CooldownFrame:ClearAllPoints()
        E.CooldownFrame:SetPoint("CENTER", UIParent, "CENTER", DB.cooldownFrame.pos_x, v)
    end)
end

-- 슬래시 커맨드 핸들러
SLASH_JDR1 = "/jdr"
SlashCmdList["JDR"] = function(msg)
    msg = msg:lower():trim()
    if msg == "config" then
        if not cfgFrame then
            -- 첫 생성
            cfgFrame = AceGUI:Create("Frame")
            cfgFrame:SetTitle("JDR MythicCCAlert 설정")
            cfgFrame:SetStatusText("Slash '/jdrcf config' to toggle")
            cfgFrame:SetLayout("Flow")
            cfgFrame:SetWidth(350)
            cfgFrame:SetHeight(500)
            cfgFrame:EnableResize(false)
            -- 닫을 때 아직 위젯은 유지하되, 프레임만 숨김
            cfgFrame:SetCallback("OnClose", function(widget)
                E:SetIconPool({})
                E.showingConfig = false
                widget:Hide() end)
        else
            -- 이미 만들었던 프레임이면 자식 위젯들 전부 해제
            cfgFrame:ReleaseChildren()
        end

        -- 항상 최신 DB 값으로 위젯 재생성
        buildConfigWidgets(cfgFrame)
        local tmp =  testSpells
        local num = E.DB.cooldownFrame.max_icon
        -- 3) num 개수만큼 잘라내기
        if num and num >= 1 then
            local tmp2 = {}
            for i = 1, math.min(num, #tmp) do
                tinsert(tmp2, tmp[i])
            end
            tmp = tmp2
        end
        E:SetIconPool(tmp)
        E.showingConfig = true
        cfgFrame:Show()

    else
        print("|cff00ff00[JDR]|r 사용법: /jdrcf config")
    end
end