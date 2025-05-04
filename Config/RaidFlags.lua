local E = select(2, ...):unpack()

E.RAID_TARGETS = {
    [1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t",
    [2] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t",
    [4] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:0|t",
    [8] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:0|t",
    [16] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t",
    [32] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t",
    [64] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t",
    [128] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t",
}

E.RAID_FLAG_PRIORITY = {
    ["DEATHKNIGHT"] = 99,
    ["DEMONHUNTER"] = 98,
    ["ROGUE"] = 97,
    ["MONK"] = 96,
    ["PALADIN"] = 95,
    ["SHAMAN"] = 94,
    ["MAGE"] = 93,
    ["DRUID"] = 92,
    ["HUNTER"] = 91,
    ["WARLOCK"] = 90,
    ["WARRIOR"] = 89,
    ["PRIEST"] = 88,
}