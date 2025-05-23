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
    -- 1) DB 만들기
    local db = LibStub("AceDB-3.0"):New("JDR_MythicCCAlertDB", E.defaults, true)
    self.DB      = db.profile
    local profile = self.DB

    -- 3) 실제 SV 테이블 병합
    if not profile.spells then
        profile.spells = {}
    end

    -- profiles 테이블이 없으면 생성
    if not profile.spells.profiles then
        profile.spells.profiles = {}
    end

    -- default 프로필이 비어 있으면 E.Config.spells 복사
    if not profile.spells.profiles.default
            or next(profile.spells.profiles.default) == nil
    then
        profile.spells.profiles.default = CopyTable(E.Config.spells)
    end

    -- current 키가 없으면 default 로 설정
    if not profile.spells.current then
        profile.spells.current = "default"
    end

    local defaultCF ={
        enabled     = true,
        big_size    = 40,
        small_size  = 30,
        margin      = 5,
        pos_x       = 5,
        pos_y       = 5,
        max_icon    = 3,
        show_glow   = true,
        lock        = false,
        sound_alert = true,
        show_name = true,
    }

    -- profile.cooldownFrame 이 nil 이면 새 테이블 생성
    if not profile.cooldownFrame then
        profile.cooldownFrame = {}
    end


    -- 기본값에 있는 키만 검사해서, profile 쪽에 값이 없으면 defaults 값을 복사
    for key, val in pairs(defaultCF) do
        if profile.cooldownFrame[key] == nil then
            profile.cooldownFrame[key] = val
        end
    end



end

