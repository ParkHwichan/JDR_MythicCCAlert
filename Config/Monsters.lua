local E = select(2, ...):unpack()

E.Config.monsters = {
    -- 몹의 이름을 키로 하고, 그에 대한 설정을 값으로 하는 테이블
    -- 예시: ["몹이름"] = { spellID = 12345, duration = 5 }
    -- spellID: 몹이 사용하는 주문의 ID
    -- duration: 주문 지속 시간
--[[     [219250] = { name = "허수아비" , type = "caster"},
     [225984] = { name = "허수아비" , type = "caster"},
     [225983] = { name = "허수아비" , type = "caster"},]]
     -- 부화장
     [207198] = { name = "천둥병" , type = "caster", spellID = 403109 },
     [214439] = { name = "예언자" , type = "caster" },
     [212793] = { name = "승천자" , type = "caster", onlyInterrupt = true },

     -- 수도원
     [206697] = { name = "성직자" , type = "caster" },
     [206698] = { name = "사제" , type = "caster" },
     [221760] = { name = "마법사", type = "caster"},
     [206705] = { name = "보병", type = "onlyCC"},
     [212827] = { name = "에이므야" , type = "caster", onlyInterrupt = true },
     [239834] = { name = "듀얼말" , type = "caster", onlyInterrupt = true },
     [207940] = { name = "머프레이" , type = "caster", onlyInterrupt = true },

     -- 양조장
     [218671] = { name = "불놀이꾼" , type = "caster" },
     [220060] = { name = "시식단" , type = "caster" },

     [210264] = { name = "조련사" , type = "caster" },
     [220141] = { name = "연발맨" , type = "caster" },

     -- 어불동
     [210812] = { name = "점화맨" , type = "caster" },
     [220815] = { name = "폭발맨" , type = "caster" },

     [213913] = { name = "한방맨" , type = "caster" },
     [208745] = { name = "3넴" , type = "caster", onlyInterrupt = true },

     -- 수문
     [229686] = { name = "조사관" , type = "caster" },
     [231496] = { name = "작살맨" , type = "caster", shareCooldown = true},
     [228424] = { name = "보스쫄" , type = "caster", shareCooldown = true},
     [229212] = { name = "폭파병" , type = "onlyCC" },
     [231223] = { name = "빙글맨" , type = "caster",  },
     [230748] = { name = "왜곡자" , type = "caster", onlyInterrupt = true },
     [231312] = { name = "번개맨" , type = "caster" },

     -- 왕노
     [134232] = { name = "암살자" , type = "caster" , spells = {269302, 267354}},
     [136470] = { name = "상인" , type = "caster", spells={280604}},
     [130661] = { name = "대지창" , type = "caster", spells={263202}},
     [130635] = { name = "분노석" , type = "caster", spells={268702}},
     [133432] = { name = "연금술사" , type = "caster", spells={268797}},

     -- 고투
     [164461] = { name = "사델" , type = "caster" },
     [164506] = { name = "대장" , type = "caster" },
     [174210] = { name = "오물맨" , type = "caster" },
     [170690] = { name = "고기방패" , type = "caster" },
     [170882] = { name = "뼈창맨" , type = "caster" },
     [160495] = { name = "연발맨" , type = "caster" },
     [169875] = { name = "구속된영혼" , type = "caster" },

     -- 작업장
     [151657] = { name = "폭탄" , type = "caster" },
     [236033] = { name = "오물맨" , type = "onlyCC" },
     [144294] = { name = "떔장이" , type = "caster" },
}

E.Config.enemySpells = {
     [403109] = { name = "번개 화살" , baseCD = 0, castTime = 1900 }

}

E.Config.ccOnlySpells = {
     [151657] = { name = "폭탄" , baseCD = 0, castTime = 0 },
     [236033] = { name = "오물맨" , baseCD = 0, castTime = 0 },
}