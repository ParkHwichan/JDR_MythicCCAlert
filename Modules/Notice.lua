local E = select(2, ...):unpack()

-- 큐를 저장할 테이블과 상태 플래그
E._noticeQueue  = {}
E._noticeActive = false


-- 원하는 폰트 경로 • 기본 폰트 사용 시 STANDARD_TEXT_FONT
local FONT_PATH   = STANDARD_TEXT_FONT        -- 또는 "Interface\\AddOns\\JDR\\media\\MyFont.ttf"
local SIZE_BIG    = 24                        -- 1행(제목) 크기
local SIZE_SMALL  = 18                       -- 2행 크기
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

-- 1) 색상 파라미터를 없애고, text1/text2 그대로 SetText
function E:QueueCentralNotice(entry)
    -- entry = {
    --   text1 = "|cffff8800악사|r 차단기 준비됨",
    --   hold1 = 2, fade1 = 1,
    --   text2 = "|cff00ff00다음: 도적 Kick|r", hold2=3, fade2=1.5,
    -- }
    entry.hold1 = tonumber(entry.hold1) or 2
    entry.fade1 = tonumber(entry.fade1) or 1
    if entry.size1 then
        CentralNotice.msg1:SetFont(FONT_PATH, entry.size1, OUTLINE)
    else
        CentralNotice.msg1:SetFont(FONT_PATH, SIZE_BIG, OUTLINE)
    end

    if entry.text2 then
        entry.hold2 = tonumber(entry.hold2) or entry.hold1
        entry.fade2 = tonumber(entry.fade2) or entry.fade1

        if entry.size2 then
            CentralNotice.msg2:SetFont(FONT_PATH, entry.size2, OUTLINE)
        else
            CentralNotice.msg2:SetFont(FONT_PATH, SIZE_SMALL, OUTLINE)
        end
    end


    tinsert(self._noticeQueue, entry)
    if not self._noticeActive then
        self:_ProcessNextNotice()
    end
end

function E:_ProcessNextNotice()
    local entry = tremove(self._noticeQueue, 1)
    if not entry then
        self._noticeActive = false
        return
    end
    self._noticeActive = true

    -- 1행: inline color code 포함된 text1
    CentralNotice.msg1:SetText(entry.text1 or "")
    CentralNotice.msg1:SetAlpha(1)

    -- 2행 처리
    if entry.text2 then
        CentralNotice.msg2:SetText(entry.text2)
        CentralNotice.msg2:Show()
        CentralNotice.msg2:SetAlpha(1)
    else
        CentralNotice.msg2:Hide()
    end

    CentralNotice:Show()

    -- 페이드 아웃 처리
    -- (이전과 동일하게 hold/fade 로직)
    C_Timer.After(entry.hold1, function()
        C_Timer.NewTicker(0.02, function(t)
            local a = CentralNotice.msg1:GetAlpha() - (0.02/entry.fade1)
            if a <= 0 then
                CentralNotice.msg1:SetAlpha(0)
                t:Cancel()
            else
                CentralNotice.msg1:SetAlpha(a)
            end
        end)
    end)
    if entry.text2 then
        C_Timer.After(entry.hold2, function()
            C_Timer.NewTicker(0.02, function(t)
                local a = CentralNotice.msg2:GetAlpha() - (0.02/entry.fade2)
                if a <= 0 then
                    CentralNotice.msg2:SetAlpha(0)
                    t:Cancel()
                else
                    CentralNotice.msg2:SetAlpha(a)
                end
            end)
        end)
    end

    -- 다음 알림 스케줄
    local total = entry.hold1 + entry.fade1
    if entry.text2 then
        total = math.max(total, entry.hold2 + entry.fade2)
    end
    C_Timer.After(total, function()
        CentralNotice:Hide()
        self:_ProcessNextNotice()
    end)
end