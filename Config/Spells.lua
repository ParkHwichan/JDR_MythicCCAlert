local E = select(2, ...):unpack()

E.Config.spells = {
    -- 개인 차단 --
    [183752] = { name = "Disrupt", type = "interrupt", class = "DEMONHUNTER", cooldown = 15, priority = 12, silence = 3 },
    [47528] = { name = "Mind Freeze", type = "interrupt", class = "DEATHKNIGHT", cooldown = 15, priority = 11, silence = 3 },
    [1766] = { name = "Kick", type = "interrupt", class = "ROGUE", cooldown = 15, priority = 10 },
    [57994] = { name = "Wind Shear", type = "interrupt", class = "SHAMAN", cooldown = 12, priority = 9 },
    [6552] = { name = "Pummel", type = "interrupt", class = "WARRIOR", cooldown = 15, priority = 8 },
    [116705] = { name = "Spear Hand Strike", type = "interrupt", class = "MONK", cooldown = 15, priority = 7 },
    [96231] = { name = "Rebuke", type = "interrupt", class = "PALADIN", cooldown = 15, priority = 6 },
    [2139] = { name = "Counterspell", type = "interrupt", class = "MAGE", cooldown = 24, priority = 5, silence = 5 },
    [147362] = { name = "Counter Shot", type = "interrupt", class = "HUNTER", cooldown = 24, priority = 4 },
    [106839] = { name = "Skull Bash", type = "interrupt", class = "DRUID", cooldown = 15, priority = 3, specRequired = { 103, 104 } },
    [351338] = { name = "Quell", type = "interrupt", class = "EVOKER", cooldown = 40, priority = 2, specRequired = { 1467, 1468 } },
    [15487] = { name = "Silence", type = "interrupt", class = "PRIEST", cooldown = 45, priority = 1, specRequired = { 258 } },

    -- 광역 CC --
    [202138] = { name = "사슬", soundPath = "chain",  type = "aoeCC", class = "DEMONHUNTER", cooldown = 60, priority = 13 }, -- 혼돈의 회오리
    [78675] = { name = "빔", soundPath = "beam", ccDuration= 8, type = "aoeInterrupt", class = "DRUID", cooldown = 60, priority = 12, silence = 8 },
    [179057] = { name = "혼회", soundPath = "chaos", ccDuration = 2, type = "aoeCC", class = "DEMONHUNTER", cooldown = 45, priority = 11 }, -- 혼돈의 회오리
    [202137] = { name = "침묵", soundPath = "silence",  ccDuration = 4,  type = "aoeInterrupt",       class = "DEMONHUNTER", cooldown = 120, priority = 10 },  -- 혼돈의 회오리
    [207167] = { name = "진눈", soundPath = "dk_aoe", type = "aoeCC", class = "DEATHKNIGHT", cooldown = 60, priority = 9 },
    [157980] = {name = "초신성",  soundPath = "mage_aoe_1", type = "aoeCC", class = "MAGE", cooldown = 45, priority = 8 },
    [157981] = { name = "화폭", soundPath = "mage_aoe_2", type = "aoeCC", class = "MAGE", cooldown = 45, priority = 7 },
    [99] = { name = "행불포",soundPath = "druid_aoe_1", type = "aoeCC", class = "DRUID", cooldown = 30, priority = 6 },
    ["interrupt_combine"]  = { name = "개인짤" , soundPath = "짤" , type = "interruptCombine" , class="UNKNOWN", priority = 5 },
    [61392] = { name = "태풍", soundPath = "druid_aoe_2", type = "aoeCC", class = "DRUID", cooldown = 30, priority = 4 },
    [132469] = { name = "태풍", soundPath = "druid_aoe_1", type = "aoeCC", class = "DRUID", cooldown = 30, priority = 3 },
    [207684] = { name = "공포", soundPath = "fear", type = "aoeCC", class = "DEMONHUNTER", cooldown = 120, priority = 2 }, -- 혼돈의 회오리
    [8122] = { name = "영절", soundPath = "priest_aoe", type = "aoeCC", class = "PRIEST", cooldown = 60, priority = 1 },

}

E.Config.sigils = {
    [202138] = { name = "사슬", soundPath = "사슬",  type = "aoeCC", class = "DEMONHUNTER", cooldown = 60, priority = 121 }, -- 혼돈의 회오리
    [202137] = { name = "침묵", soundPath = "침묵",  ccDuration = 4,  type = "aoeInterrupt",       class = "DEMONHUNTER", cooldown = 120, priority = 118 },  -- 혼돈의 회오리
    [207684] = { name = "공포", soundPath = "공포", type = "aoeCC", class = "DEMONHUNTER", cooldown = 120, priority = 112 }, -- 혼돈의
}