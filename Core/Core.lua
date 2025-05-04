local groupWatcher = CreateFrame("Frame")
groupWatcher:RegisterEvent("GROUP_ROSTER_UPDATE")
groupWatcher:RegisterEvent("PLAYER_ENTERING_WORLD") -- 진입 시 최초 초기화용

groupWatcher:SetScript("OnEvent", function()
    C_Timer.After(1, function()
        --buildInterruptListForParty()
        --UpdateInterruptStatusFrame()
        --UpdateCCStatusFrame()

    end)
end)

local inspectWatcher = CreateFrame("Frame")
inspectWatcher:RegisterEvent("INSPECT_READY")

local pending = {}   -- GUID→unit

local function RequestSpec(unit)
    if UnitIsUnit(unit,"player") then return end
    if CanInspect(unit) then
        NotifyInspect(unit)
        pending[UnitGUID(unit)] = true
    end
end

groupWatcher:SetScript("OnEvent", function()
    C_Timer.After(0.5, function()
        -- ① 파티 전원에게 Inspect 요청
        for i=1,4 do
            local u="party"..i
            if UnitExists(u) then RequestSpec(u) end
        end
        RequestSpec("player")  -- 자기 자신은 바로 OK
    end)
end)

inspectWatcher:SetScript("OnEvent", function(_,_, guid)
    pending[guid] = nil
    -- ② 대기열이 모두 끝나면 리스트 재생성
    if not next(pending) then
        --buildInterruptListForParty()
        --UpdateInterruptStatusFrame()
        --UpdateCCStatusFrame()
    end
end)