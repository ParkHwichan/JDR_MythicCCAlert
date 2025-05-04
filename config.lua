ADDON_NAME = "JDR"

spells = {
    -- 개인 차단 --
    [183752] = { name = "Disrupt", type = "INTERRUPT", class = "DEMONHUNTER", cooldown = 15, priority = 1 },
    [47528] = { name = "Mind Freeze", type = "INTERRUPT", class = "DEATHKNIGHT", cooldown = 15, priority = 2 },
    [1766] = { name = "Kick", type = "INTERRUPT", class = "ROGUE", cooldown = 15, priority = 3 },
    [57994] = { name = "Wind Shear", type = "INTERRUPT", class = "SHAMAN", cooldown = 12, priority = 4 },
    [6552] = { name = "Pummel", type = "INTERRUPT", class = "WARRIOR", cooldown = 15, priority = 5 },
    [116705] = { name = "Spear Hand Strike", type = "INTERRUPT", class = "MONK", cooldown = 15, priority = 6 },
    [96231] = { name = "Rebuke", type = "INTERRUPT", class = "PALADIN", cooldown = 15, priority = 7 },
    [2139] = { name = "Counterspell", type = "INTERRUPT", class = "MAGE", cooldown = 24, priority = 8 },
    [147362] = { name = "Counter Shot", type = "INTERRUPT", class = "HUNTER", cooldown = 24, priority = 9 },
    [106839] = { name = "Skull Bash", type = "INTERRUPT", class = "DRUID", cooldown = 15, priority = 10, specRequired = { 103, 104 } },
    [78675] = { name = "Solar Beam", type = "INTERRUPT", class = "DRUID", cooldown = 60, priority = 11, specRequired = { 102 } },
    [351338] = { name = "Quell", type = "INTERRUPT", class = "EVOKER", cooldown = 40, priority = 12, specRequired = { 1467, 1468 } },
    [15487] = { name = "Silence", type = "INTERRUPT", class = "PRIEST", cooldown = 45, priority = 13, specRequired = { 258 } },

    -- 광역 CC --
    [202138] = { name = "사슬", type = "CC_AOE", class = "DEMONHUNTER", cooldown = 60, priority = 120 }, -- 혼돈의 회오리
    [179057] = { name = "혼회", type = "CC_AOE", class = "DEMONHUNTER", cooldown = 45, priority = 119 }, -- 혼돈의 회오리
    --[202137] = { name = "침묵", type = "CC_AOE",       class = "DEMONHUNTER", cooldown = 120, priority = 3 },  -- 혼돈의 회오리
    [207167] = { name = "진눈", type = "CC_AOE", class = "DEATHKNIGHT", cooldown = 60, priority = 118 },
    [207684] = { name = "공포", type = "CC_AOE", class = "DEMONHUNTER", cooldown = 120, priority = 117 }, -- 혼돈의 회오리
    [132469] = { name = "태풍", type = "CC_AOE", class = "DRUID", cooldown = 30, priority = 116 },
    [157980] = { name = "초신성", type = "CC_AOE", class = "MAGE", cooldown = 45, priority = 115 },
    [8122] = { name = "영절", type = "CC_AOE", class = "PRIEST", cooldown = 60, priority = 114 },
    [99] = { name = "행불포", type = "CC_AOE", class = "DRUID", cooldown = 30, priority = 113 },
    [157981] = { name = "초신성", type = "CC_AOE", class = "MAGE", cooldown = 45, priority = 112 },
}

defaultConfig = {
    interrupts = {
        -- priority = 낮을수록 먼저(1 → 2 → 3 …)
    },
    crowdControls = {

    }
}
currentVersion = 1.1

function GetConfig()
    return defaultConfig
end