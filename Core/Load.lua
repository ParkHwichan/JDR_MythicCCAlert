local E, L, C = select(2, ...):unpack()


local DB_VERSION = 1

local function JDR_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then

    elseif event == "PLAYER_LOGIN" then

    elseif event == "PLAYER_ENTERING_WORLD" then
            self:OnInitialize()
            self:InitCooldownFrame()
    end
end


E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("PLAYER_ENTERING_WORLD")
E:SetScript("OnEvent", JDR_OnEvent)

function E:OnInitialize()
    if not JDR_MythicCCAlertDB or not JDR_MythicCCAlertDB.version then
        JDR_MythicCCAlertDB = { version = DB_VERSION }
    else

    end

    -- 2) AceDB 생성
    local AceDB = LibStub("AceDB-3.0")
    local db = AceDB:New("JDR_MythicCCAlertDB", self.defaults, true)
    -- 세 번째 인자(true)는 기본 프로파일 이름을 사용하겠다는 뜻

    -- 3) 편의용 참조
    E.DB = db.profile
    -- print("|cff00ff00바보 쐐기 전용 애드온 로드 완료|r")

    self.global = self.DB.global
    self.profile = self.DB.profile

end


