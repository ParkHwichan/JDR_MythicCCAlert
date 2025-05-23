local E = unpack(select(2, ...))
local AceGUI = E.Libs.AceGUI -- AceGUI-3.0

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


function E.Options:buildInterfaceTab(parent)
    parent:ReleaseChildren()
    parent:SetLayout("Fill")

    -- 1) ScrollFrame 으로 래핑
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    parent:AddChild(scroll)

    -- 2) 슬라이더 헬퍼 (scroll 에 붙입니다)
    local function makeSlider(name, min, max, step, cur, onChanged)
        local slider = AceGUI:Create("Slider")
        slider:SetLabel(name)
        slider:SetSliderValues(min, max, step)

        -- 1) coerce current value to a number, default to min
        local numeric = tonumber(cur) or min
        slider:SetValue(numeric)

        slider:SetFullWidth(true)
        slider:SetCallback("OnValueChanged", function(widget, _, value)
            -- 2) round and coerce
            local v = math.floor(value + 0.5)
            -- 3) call your handler first
            onChanged(v)
            -- 4) only now push that back into the slider itself
            widget:SetValue(v)
        end)

        scroll:AddChild(slider)
    end
    local DB = E.DB

    -- 3) 아이콘 관련 슬라이더
    makeSlider("표시 스킬 갯수", 1, 5, 1, DB.cooldownFrame.max_icon, function(v)
        DB.cooldownFrame.max_icon = v
        E:SetIconPool(testSpells)  -- 실제 로직에 맞게 조정
    end)
    makeSlider("큰 아이콘 크기", 20, 80, 1, DB.cooldownFrame.big_size, function(v)
        DB.cooldownFrame.big_size = v
        E:RefreshCooldownFrame()
    end)
    makeSlider("작은 아이콘 크기", 16, 64, 1, DB.cooldownFrame.small_size, function(v)
        DB.cooldownFrame.small_size = v
        E:RefreshCooldownFrame()
    end)
    makeSlider("아이콘 간격", 0, 20, 1, DB.cooldownFrame.margin, function(v)
        DB.cooldownFrame.margin = v
        E:RefreshCooldownFrame()
    end)

    -- 4) 체크박스들도 가로폭 꽉 채우기
    local function makeCheck(label, valueGetter, valueSetter)
        local cb = AceGUI:Create("CheckBox")
        cb:SetLabel(label)
        cb:SetValue(valueGetter())
        cb:SetFullWidth(true)
        cb:SetCallback("OnValueChanged", function(_,_,v)
            valueSetter(v)
        end)
        scroll:AddChild(cb)
    end

    makeCheck("아이콘 사용자 이름 보이기",
            function() return DB.cooldownFrame.show_name end,
            function(v) DB.cooldownFrame.show_name = v end
    )
    makeCheck("내 사용 순서에 반짝임",
            function() return DB.cooldownFrame.show_glow end,
            function(v) DB.cooldownFrame.show_glow = v end
    )
    makeCheck("내 사용 순서에 음성 알림",
            function() return DB.cooldownFrame.sound_alert end,
            function(v) DB.cooldownFrame.sound_alert = v end
    )
    makeCheck("프레임 이동 잠금",
            function() return DB.cooldownFrame.lock end,
            function(v)
                DB.cooldownFrame.lock = v
                E.CooldownFrame:EnableMouse(not v)
            end
    )

    -- 5) 위치 슬라이더도 추가
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
