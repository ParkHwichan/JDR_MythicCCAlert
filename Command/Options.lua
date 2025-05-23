-- Modules/ConfigAceGUI.lua
local E = unpack(select(2, ...))

-- 라이브러리 로드
local AceGUI = LibStub("AceGUI-3.0")



-- 설정 창 객체 저장용
local cfgFrame
-- 실제 위젯을 생성하는 함수
-- 슬래시 커맨드 핸들러
SLASH_JDR1 = "/jdr"
SlashCmdList["JDR"] = function(msg)

    msg = msg:lower():trim()
    if msg == "config" then
        E.Options:buildOptionsFrame()
    else
        E.Options:buildOptionsFrame()
    end

end