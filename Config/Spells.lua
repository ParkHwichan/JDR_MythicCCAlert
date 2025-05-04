local E = select(2, ...):unpack()

E.Config.spells = {
    -- 개인 차단 --
    [183752] = { name = "Disrupt", type = "interrupt", class = "DEMONHUNTER", cooldown = 15, priority = 120 },
    [47528] = { name = "Mind Freeze", type = "interrupt", class = "DEATHKNIGHT", cooldown = 15, priority = 119 },
    [1766] = { name = "Kick", type = "interrupt", class = "ROGUE", cooldown = 15, priority = 118 },
    [57994] = { name = "Wind Shear", type = "interrupt", class = "SHAMAN", cooldown = 12, priority = 117 },
    [6552] = { name = "Pummel", type = "interrupt", class = "WARRIOR", cooldown = 15, priority = 116 },
    [116705] = { name = "Spear Hand Strike", type = "interrupt", class = "MONK", cooldown = 15, priority = 115 },
    [96231] = { name = "Rebuke", type = "interrupt", class = "PALADIN", cooldown = 15, priority = 114 },
    [2139] = { name = "Counterspell", type = "interrupt", class = "MAGE", cooldown = 24, priority = 113 },
    [147362] = { name = "Counter Shot", type = "interrupt", class = "HUNTER", cooldown = 24, priority = 112 },
    [106839] = { name = "Skull Bash", type = "interrupt", class = "DRUID", cooldown = 15, priority = 111, specRequired = { 103, 104 } },
    [351338] = { name = "Quell", type = "interrupt", class = "EVOKER", cooldown = 40, priority = 110, specRequired = { 1467, 1468 } },
    [15487] = { name = "Silence", type = "interrupt", class = "PRIEST", cooldown = 45, priority = 109, specRequired = { 258 } },

    -- 광역 CC --
    [202138] = { name = "사슬", soundPath = "사슬",  type = "aoeCC", class = "DEMONHUNTER", cooldown = 60, priority = 121 }, -- 혼돈의 회오리
    [78675] = { name = "빔", soundPath = "빔", ccDuration= 8, type = "aoeInterrupt", class = "DRUID", cooldown = 60, priority = 120,  },
    [179057] = { name = "혼회", soundPath = "혼회", ccDuration = 2, type = "aoeCC", class = "DEMONHUNTER", cooldown = 45, priority = 119 }, -- 혼돈의 회오리
    [202137] = { name = "침묵", soundPath = "침묵",  ccDuration = 4,  type = "aoeInterrupt",       class = "DEMONHUNTER", cooldown = 120, priority = 118 },  -- 혼돈의 회오리
    [207167] = { name = "진눈", soundPath = "진눈", type = "aoeCC", class = "DEATHKNIGHT", cooldown = 60, priority = 117 },
    [207684] = { name = "공포", soundPath = "공포", type = "aoeCC", class = "DEMONHUNTER", cooldown = 120, priority = 116 }, -- 혼돈의 회오리
    ["interrupt_combine"]  = { name = "개인짤" , soundPath = "짤" , type = "interruptCombine" , class="UNKNOWN", priority = 115 },
    [61392] = { name = "태풍", soundPath = "태풍", type = "aoeCC", class = "DRUID", cooldown = 30, priority = 114 },
    [132469] = { name = "태풍", soundPath = "태풍", type = "aoeCC", class = "DRUID", cooldown = 30, priority = 113 },
    [157980] = {name = "초신성",  soundPath = "초신성", type = "aoeCC", class = "MAGE", cooldown = 45, priority = 112 },
    [8122] = { name = "영절", soundPath = "영절", type = "aoeCC", class = "PRIEST", cooldown = 60, priority = 111 },
    [99] = { name = "행불포",soundPath = "행불포", type = "aoeCC", class = "DRUID", cooldown = 30, priority = 110 },
    [157981] = { name = "초신성", soundPath = "초신성", type = "aoeCC", class = "MAGE", cooldown = 45, priority = 109 },
}