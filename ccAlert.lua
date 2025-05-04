local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")


f:SetScript("OnEvent", function()
    local _, subevent, _, playerGUID, sourceName, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()

    if subevent == "SPELL_CAST_SUCCESS" then
        for _, info in ipairs(availableCC) do
            if info.spellID == spellID and info.playerGUID == playerGUID then

                info.cooldownEnds = GetTime() + info.baseCD   -- 갱신

                local nextAvailable = GetNextAvailableCC()
                local nextExist = nextAvailable ~= nil

                ShowCentralNotice(
                        string.format("%s CC기 사용!", info.name),
                        GetSpecRGB(info.class),
                        3,
                        nextExist and {
                            text = string.format("다음 CC %s", nextAvailable.name ),
                            color = GetSpecRGB(nextAvailable.class),
                        } or nil
                )

                        if(nextExist == false) then
        break
                    end


            -- ④ 사운드 재생
            local nextInterruptPath = string.format("Interface\\AddOns\\%s\\sounds\\%s.ogg",
            ADDON_NAME, "다음")
            local soundPath = string.format("Interface\\AddOns\\%s\\sounds\\%s.ogg",
            ADDON_NAME, nextAvailable.name)
            PlaySoundFile(nextInterruptPath, "Dialog")   -- "Dialog" 채널

            if soundPath then
            C_Timer.After(0.75, function()
                PlaySoundFile(soundPath, "Dialog")              -- 같은 Dialog 채널
                end)
                end

                break
                end
        end
    end
end)


-- 옵션 프레임 UI
local frame
function ShowInterruptStatusFrame()
    if frame and frame:IsShown() then
        frame:Hide()
        return
    end

    frame = CreateFrame("Frame", "InterruptAlertFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(260, 220)
    frame:SetPoint("CENTER")
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -10)
    frame.title:SetText("Interrupt Status")

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -35)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(220, 200)
    scroll:SetScrollChild(content)

    local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT")
    text:SetJustifyH("LEFT")

    local now = GetTime()
    local lines = {}

    for _, class in ipairs(PRIORITY) do
        local onCooldown = false
        for _, data in pairs(cooldowns) do
            if data.class == class and data.endsAt > now then
                onCooldown = true
                break
            end
        end
        if onCooldown then
            table.insert(lines, string.format("|cffff5555%s|r - 쿨다운 중", class))
        else
            table.insert(lines, string.format("|cff55ff55%s|r - 사용 가능", class))
        end
    end

    text:SetText(table.concat(lines, "\n"))
end

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")


f:SetScript("OnEvent", function()
    local _, subevent, _, playerGUID, sourceName, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()

    if subevent == "SPELL_CAST_SUCCESS" then
        for _, info in ipairs(availableCC) do
            if info.spellID == spellID and info.playerGUID == playerGUID then

                info.cooldownEnds = GetTime() + info.baseCD   -- 갱신

                local nextAvailable = GetNextAvailableCC()
                local nextExist = nextAvailable ~= nil

                ShowCentralNotice(
                        string.format("%s CC기 사용!", info.name),
                        GetSpecRGB(info.class),
                        3,
                        nextExist and {
                            text = string.format("다음 CC %s", nextAvailable.name ),
                            color = GetSpecRGB(nextAvailable.class),
                        } or nil
                )

                if(nextExist == false) then
                    break
                end


                -- ④ 사운드 재생
                local nextInterruptPath = string.format("Interface\\AddOns\\%s\\sounds\\%s.ogg",
                        ADDON_NAME, "다음")
                local soundPath = string.format("Interface\\AddOns\\%s\\sounds\\%s.ogg",
                        ADDON_NAME, nextAvailable.name)
                PlaySoundFile(nextInterruptPath, "Dialog")   -- "Dialog" 채널

                if soundPath then
                    C_Timer.After(0.75, function()
                        PlaySoundFile(soundPath, "Dialog")              -- 같은 Dialog 채널
                    end)
                end

                break
            end
        end
    end
end)


-- 옵션 프레임 UI
local frame
function ShowInterruptStatusFrame()
    if frame and frame:IsShown() then
        frame:Hide()
        return
    end

    frame = CreateFrame("Frame", "InterruptAlertFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(260, 220)
    frame:SetPoint("CENTER")
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -10)
    frame.title:SetText("Interrupt Status")

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -35)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(220, 200)
    scroll:SetScrollChild(content)

    local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT")
    text:SetJustifyH("LEFT")

    local now = GetTime()
    local lines = {}

    for _, class in ipairs(PRIORITY) do
        local onCooldown = false
        for _, data in pairs(cooldowns) do
            if data.class == class and data.endsAt > now then
                onCooldown = true
                break
            end
        end
        if onCooldown then
            table.insert(lines, string.format("|cffff5555%s|r - 쿨다운 중", class))
        else
            table.insert(lines, string.format("|cff55ff55%s|r - 사용 가능", class))
        end
    end

    text:SetText(table.concat(lines, "\n"))
end


local statusFrame, statusText

local bigIconPool   = {}
local smallIconPool = {}
local BIG_SIZE      = 48
local SMALL_SIZE    = 24

-- 1) Acquire-/ReleaseIcon : Frame + 텍스처 + 글자 세트를 항상 함께 재사용
local function AcquireIcon(pool, parent, size)
    local fr = tremove(pool)
    if not fr then
        fr      = CreateFrame("Frame", nil, parent)
        fr.tex  = fr:CreateTexture(nil, "ARTWORK")
        fr.tex:SetAllPoints()
        fr.tex:SetTexCoord(.08,.92,.08,.92)

        fr.text = fr:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fr.text:SetPoint("CENTER")
        fr.text:SetTextColor(1,.82,0)
        fr.text:SetShadowColor(0,0,0,.8)
        fr.text:SetShadowOffset(1,-1)
    end
    fr:SetParent(parent); fr:SetSize(size, size); fr:ClearAllPoints(); fr:Show()
    fr.tex:Show(); fr.text:Hide()
    return fr
end

local function Release(pool, icon) icon:Hide(); tinsert(pool, icon) end
local function ReleaseAll()
    for _, p in ipairs{bigIconPool, smallIconPool} do
        for _, fr in ipairs(p) do fr:Hide() end             -- 이미 풀에 있음
    end
end
--------------------------------------------------------------
-- 남은 시간 글자를 아이콘 중앙에 붙여 주는 헬퍼
--------------------------------------------------------------
local function EnsureTimerText(icon, parent)
    if icon.cdText then return icon.cdText end
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("CENTER", icon, "CENTER")
    fs:SetTextColor(1, .82, 0)                  -- 노랑
    fs:SetShadowColor(0, 0, 0, .8)
    fs:SetShadowOffset(1, -1)
    icon.cdText = fs
    return fs
end

--------------------------------------------------------------
-- CC 상태 프레임 갱신
--------------------------------------------------------------
function UpdateCCStatusFrame()
    if not statusFrame then return end
    local now = GetTime()

    ----------------------------------------------------------------
    -- 매 프레임: 남은 쿨 짧은 순 + 같은 경우 priority 높은 순 재정렬
    ----------------------------------------------------------------
    table.sort(availableCC, function(a, b)
        local ra = math.max(0, a.cooldownEnds - now)
        local rb = math.max(0, b.cooldownEnds - now)
        if ra ~= rb then
            return ra < rb             -- 쿨 남은 시간 짧은 것이 먼저
        else
            return a.priority < b.priority   -- 같으면 priority 낮은 값(=높음)
        end
    end)

    ----------------------------------------------------------------
    -- ① 정렬된 리스트의 첫 번째가 ‘가장 우선 CC’
    ----------------------------------------------------------------
    local nextCC = availableCC[1]      -- 모두 쿨이면 nextCC=nil 에서 처리
    if nextCC and nextCC.cooldownEnds - now > 0 then
        nextCC = nil                   -- 첫 스킬도 아직 쿨이면 Ready 없음
    end

    -- 이하 아이콘 그리기 로직은 그대로…
    -- big 아이콘은 nextCC, 작은 아이콘은 2·3·4번째 항목을 사용
    ----------------------------------------------------------------
     ReleaseAll()
    local xOff = 4
    ---------------------- 큰 아이콘 (index 1) -----------------
    local first = availableCC[1]
    if first then
        local big = AcquireIcon(bigIconPool, statusFrame, 48)
        big:SetPoint("LEFT", statusFrame, "LEFT", xOff, 0)
        big.tex:SetTexture(first.spellIcon)

        if first.cooldownEnds > now then
            big.tex:SetDesaturated(true)
            big.text:SetText(math.ceil(first.cooldownEnds - now))
            big.text:Show()
        else
            big.tex:SetDesaturated(false)
        end
        xOff = xOff + 48 + 6
    end

    ---------------------- 작은 아이콘 (index 2-4) --------------
    for i = 2, 4 do
        local info = availableCC[i]
        if not info then break end

        local remain = math.max(0, info.cooldownEnds - now)
        local fr = AcquireIcon(smallIconPool, statusFrame, 24)
        fr:SetPoint("LEFT", statusFrame, "LEFT", xOff, 0)
        fr.tex:SetTexture(info.spellIcon)

        if remain > 0 then
            fr.tex:SetDesaturated(true)
            fr.text:SetText(math.ceil(remain))
            fr.text:Show()
        else
            fr.tex:SetDesaturated(false)
        end
        xOff = xOff + 24 + 4
    end

    ---------------------- 프레임 크기 --------------------------
    statusFrame:SetWidth(xOff + 4)
    statusFrame:SetHeight(52)
end

local function CreateCCStatusFrame()
    if statusFrame then return end

    local saved = InterruptAlertDB.framePos or {}

    statusFrame = CreateFrame("Frame", "CCStatusFrame", UIParent, "BackdropTemplate")
    statusFrame:SetSize(220, 180)

    -- 저장된 위치 불러오기
    if saved.point and saved.x and saved.y then
        statusFrame:SetPoint(saved.point, UIParent, saved.relativePoint, saved.x, saved.y)
    else
        statusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -40, -40) -- 기본 위치
    end


    statusFrame:SetMovable(true)
    statusFrame:EnableMouse(true)
    statusFrame:RegisterForDrag("LeftButton")
    statusFrame:SetScript("OnDragStart", statusFrame.StartMoving)
    statusFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()

        -- 현재 위치 저장
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        InterruptAlertDB.framePos = {
            point = point,
            relativePoint = relativePoint,
            x = xOfs,
            y = yOfs
        }
    end)

    statusFrame.title = statusFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statusFrame.title:SetPoint("TOP", 0, -10)
    statusFrame.title:SetText("파티 차단기 목록")
    --statusFrame:SetScript("OnUpdate", function() UpdateCCStatusFrame() end)

    statusText = statusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("TOPLEFT", 10, -30)
    statusText:SetJustifyH("LEFT")
    statusText:SetJustifyV("TOP")
    statusText:SetWidth(200)
end


-- 클래스 컬러 얻기 헬퍼
local function GetClassRGB(classToken)
    -- 최신 버전: C_ClassColor.GetClassColor 가 더 정확
    local c = C_ClassColor.GetClassColor(classToken)
            or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classToken])
            or RAID_CLASS_COLORS[classToken]
            or { r = 1, g = 1, b = 1 }     -- fallback: 흰색
    return c.r, c.g, c.b
end

local function CreateCCStatusFrame()
    if statusFrame then return end

    local saved = InterruptAlertDB.framePos or {}

    statusFrame = CreateFrame("Frame", "CCStatusFrame", UIParent, "BackdropTemplate")
    statusFrame:SetSize(220, 180)

    -- 저장된 위치 불러오기
    if saved.point and saved.x and saved.y then
        statusFrame:SetPoint(saved.point, UIParent, saved.relativePoint, saved.x, saved.y)
    else
        statusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -40, -40) -- 기본 위치
    end


    statusFrame:SetMovable(true)
    statusFrame:EnableMouse(true)
    statusFrame:RegisterForDrag("LeftButton")
    statusFrame:SetScript("OnDragStart", statusFrame.StartMoving)
    statusFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()

        -- 현재 위치 저장
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        InterruptAlertDB.framePos = {
            point = point,
            relativePoint = relativePoint,
            x = xOfs,
            y = yOfs
        }
    end)

    statusFrame.title = statusFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statusFrame.title:SetPoint("TOP", 0, -10)
    statusFrame.title:SetText("파티 차단기 목록")
    statusFrame:SetScript("OnUpdate", function() UpdateCCStatusFrame() end)

    statusText = statusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("TOPLEFT", 10, -30)
    statusText:SetJustifyH("LEFT")
    statusText:SetJustifyV("TOP")
    statusText:SetWidth(200)
end
