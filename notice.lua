notice = {
    time = 0,
    text = "",
    secondLine = "",
    color = { r = 1, g = 1, b = 1 },
    fadeOutTime = 0,
}

-- 원하는 폰트 경로 • 기본 폰트 사용 시 STANDARD_TEXT_FONT
local FONT_PATH   = STANDARD_TEXT_FONT        -- 또는 "Interface\\AddOns\\JDR\\media\\MyFont.ttf"
local SIZE_BIG    = 18                        -- 1행(제목) 크기
local SIZE_SMALL  = 24                        -- 2행 크기
local OUTLINE     = "THICKOUTLINE"            -- 굵은 외곽선
local CENTER_Y =  80


-----------------------------------------------------------------
--  처음 한 번만 만들기
-----------------------------------------------------------------
local CentralNotice = CreateFrame("Frame", "JDRCentralNotice", UIParent)
CentralNotice:SetPoint("CENTER")
CentralNotice:SetSize(1, 1)
CentralNotice:SetFrameStrata("FULLSCREEN_DIALOG")
CentralNotice:Hide()

-- 1행
CentralNotice.msg1 = CentralNotice:CreateFontString(nil, "OVERLAY")
CentralNotice.msg1:SetFont(FONT_PATH, SIZE_BIG, OUTLINE)
CentralNotice.msg1:SetPoint("CENTER", 0, CENTER_Y + SIZE_SMALL)
-- 2행
CentralNotice.msg2 = CentralNotice:CreateFontString(nil, "OVERLAY")
CentralNotice.msg2:SetFont(FONT_PATH, SIZE_SMALL, OUTLINE)
CentralNotice.msg2:SetPoint("CENTER", 0, CENTER_Y)
-- 페이드 애니메이션
CentralNotice.fadeGroup = CentralNotice:CreateAnimationGroup()
local fade = CentralNotice.fadeGroup:CreateAnimation("Alpha")
fade:SetFromAlpha(1)  fade:SetToAlpha(0)
fade:SetSmoothing("OUT")
CentralNotice.fadeGroup:SetScript("OnFinished", function() CentralNotice:Hide() end)


-----------------------------------------------------------------
-- 2. API : ShowCentralNotice
-----------------------------------------------------------------
---@param text     string
---@param color    table|nil  {r,g,b}  -- 생략 시 흰색
---@param duration number|nil          -- 사라지는 데 걸릴 시간, 기본 2초
---
function ShowCentralNotice(text1, color1, hold, secondLine)
    color1   = color1   or { r = 1, g = 1, b = 1 }
    local color2   = (secondLine and secondLine.color)   or { r = 1, g = 1, b = 1 }
    hold     = tonumber(hold)    or 3   -- 3초 유지
    local fadeDur  =  2   -- 2초 페이드

    if CentralNotice.fadeGroup:IsPlaying() then
        CentralNotice.fadeGroup:Stop()
    end

    -- 1행
    CentralNotice.msg1:SetText(text1 or "")
    CentralNotice.msg1:SetTextColor(color1.r, color1.g, color1.b)

    -- 2행
    if secondLine then
        CentralNotice.msg2:SetText(secondLine.text or "")
        CentralNotice.msg2:SetTextColor(color2.r, color2.g, color2.b)
        CentralNotice.msg2:Show()
    else
        CentralNotice.msg2:Hide()
    end

    -- 알파 애니메이션 설정 (시작 지연 + 페이드 시간)
    fade:SetStartDelay(hold)
    fade:SetDuration(fadeDur)

    CentralNotice:SetAlpha(1)
    CentralNotice:Show()
    CentralNotice.fadeGroup:Play()
end
-----------------------------------------------------------------
-- 3. 예시: 특정 이벤트에서 호출
-----------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("GARRISON_MISSION_FINISHED")  -- 임의 이벤트
f:SetScript("OnEvent", function()
    ShowCentralNotice("주둔지 임무 완료!", { r = 0.2, g = 0.9, b = 0.2 }, 3 , nil ) -- 3초 후 사라짐
end)