local AddOnName, NS = ...

local AddOn = CreateFrame("Frame")
NS[1] = AddOn

AddOn.defaults = {
    global = {},
    profile = {
        modules        = { Party = true },
        enabled        = true,
        cooldownFrame  = { },
        spells         = { current = "default", default = {} },   -- 빈 테이블

    },
}



NS[3] = AddOn.defaults.profile
NS[4] = AddOn.defaults.global

function NS:unpack()
    return self[1], self[2], self[3], self[4]
end

NS[1].Libs = {}
NS[1].Libs.ACD = LibStub("AceConfigDialog-3.0-OmniCDC")
NS[1].Libs.ACR = LibStub("AceConfigRegistry-3.0")
NS[1].Libs.CBH = LibStub("CallbackHandler-1.0"):New(NS[1])
NS[1].Libs.LSM = LibStub("LibSharedMedia-3.0")
NS[1].Libs.OmniCDC = LibStub("LibOmniCDC")
NS[1].Libs.AceGUI = LibStub("AceGUI-3.0")
NS[1].Libs.LibDeflate = LibStub("LibDeflate")

NS[1].Party = CreateFrame("Frame")
NS[1].Comm = CreateFrame("Frame")
NS[1].Cooldowns = CreateFrame("Frame")

NS[1].AddOn = AddOnName
NS[1].Version = C_AddOns.GetAddOnMetadata(AddOnName, "Version")
NS[1].Author = C_AddOns.GetAddOnMetadata(AddOnName, "Author")
NS[1].Notes = C_AddOns.GetAddOnMetadata(AddOnName, "Notes")
NS[1].License = C_AddOns.GetAddOnMetadata(AddOnName, "X-License")
NS[1].Localizations = C_AddOns.GetAddOnMetadata(AddOnName, "X-Localizations")

NS[1].userGUID = UnitGUID("player")
NS[1].userName = UnitName("player")
NS[1].userRealm = GetRealmName()
NS[1].userNameWithRealm = format("%s-%s", NS[1].userName, NS[1].userRealm)
NS[1].userClass = select(2, UnitClass("player"))
NS[1].userRaceID = select(3, UnitRace("player"))
NS[1].userLevel = UnitLevel("player")
NS[1].userFaction = UnitFactionGroup("player")
NS[1].userClassHexColor = "|c" .. select(4, GetClassColor(NS[1].userClass))

NS[1].TocVersion = select(4, GetBuildInfo())
NS[1].LoginMessage = format("%sJDR v%s|r - /oc", NS[1].userClassHexColor, NS[1].Version)