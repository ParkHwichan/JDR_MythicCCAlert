local E = select(2, ...):unpack()

E.Config.enemySpellCooldowns = {

    -- 어불동 --
    -- 3넴
    [426145] = { cooldown = 10.5, start = 10.5 }, -- Paranoid Mind
    -- Rank Overseer
    [423501] = { cooldown = 21.9 }, -- Wild Wallop
    [428066] = { cooldown = 23.1 }, -- Overpowering Roar
    -- Lowly Moleherd
    [425536] = { cooldown = 24.7 }, -- Mole Frenzy
    -- Royal Wicklighter
    [428019] = { cooldown = 15.0 }, -- Flashpoint
    -- Kobold Taskworker
    [426883] = { cooldown = 15.0 }, -- Bonk!
    -- Wandering Candle
    [430171] = { cooldown = 18.2 }, -- Quenching Blast
    [440652] = { cooldown = 26.7 }, -- Surging Flame
    [428650] = { cooldown = 0 }, -- Burning Backlash (디스펠용, 직접 쿨바 없음)
    -- Blazing Fiend
    [424322] = { cooldown = 22.3 }, -- Explosive Flame
    -- Sootsnout
    [426295] = { cooldown = 36.4 }, -- Flaming Tether
    [1218131] = { cooldown = 12.2 }, -- Burning Candles
    [426261] = { cooldown = 0 }, -- Ceaseless Flame (순간 효과)
    -- Torchsnarl
    [426619] = { cooldown = 36.4 }, -- One-Hand Headlock
    [1218117] = { cooldown = 18.2 }, -- Massive Stomp
    [426260] = { cooldown = 0 }, -- Pyro-pummel (순간 효과)
    -- Shuffling Horror
    [422541] = { cooldown = 16.7 }, -- Drain Light
    -- Corridor Creeper
    [469620] = { cooldown = 0 }, -- Creeping Shadow (스택 효과)
    -- 필요하다면 나머지 스펠도 여기에 추가…

    -- 수문 --
    -- Shreddinator 3000
    [474337] = { cooldown = 13.4 }, -- Shreddation
    [465754] = { cooldown = 26.7 }, -- Flamethrower

    -- Mechadrone Sniper
    [1214468] = { cooldown = 12.3 }, -- Trickshot

    -- Loaderbot
    [465120] = { cooldown = 17.4 }, -- Wind Up

    -- Darkfuse Hyena
    [463058] = { cooldown = 15.7 }, -- Bloodthirsty Cackle

    -- Darkfuse Demolitionist
    [1216039] = { cooldown = 0    }, -- R.P.G.G. (리로드 조건)

    -- Darkfuse Inspector
    [465682] = { cooldown = 10.9 }, -- Surprise Inspection

    -- Darkfuse Bloodwarper
    [465827] = { cooldown = 19.4 }, -- Warp Blood

    -- Undercrawler
    [465813] = { cooldown = 10.1 }, -- Lethargic Venom

    -- Venture Co. Surveyor
    [462771] = { cooldown = 22.3 }, -- Surveying Beam

    -- Venture Co. Architect
    [465408] = { cooldown = 21.4 }, -- Rapid Construction (AuraRemoved 트리거)

    -- Venture Co. Diver
    [468631] = { cooldown = 15.7 }, -- Harpoon
    [468726] = { cooldown = 20.7 }, -- Plant Seaforium Charge

    -- Disturbed Kelp
    [471736] = { cooldown = 15.8 }, -- Jettison Kelp
    [471733] = { cooldown = 16.2 }, -- Restorative Algae

    -- Bomb Pile
    [1214337] = { cooldown = 0    }, -- Plant Bombs (단발)

    -- Bubbles
    [469818] = { cooldown = 21.9 }, -- Bubble Burp
    [1217496] = { cooldown = 21.9 }, -- Splish Splash
    [469721] = { cooldown = 21.9 }, -- Backwash

    -- Venture Co. Electrician
    [469799] = { cooldown = 10.0 }, -- Overcharge

    -- Darkfuse Jumpstarter
    [465666] = { cooldown = 11.7 }, -- Sparkslam


    -- 신불수 --
    -- Guard Captain Suleyman
    [448485] = { cooldown = 10.9 },  -- Shield Slam
    [448492] = { cooldown = 15.8 },  -- Thunderclap

    -- Forge Master Damian
    [427897] = { cooldown = 18.2 },  -- Heat Wave
    [427950] = { cooldown = 21.9 },  -- Seal of Flame

    -- High Priest Aemya
    [428150] = { cooldown = 20.1 },  -- Reflective Shield

    -- Sergeant Shaynemail
    [424423] = { cooldown = 12.1 },  -- Lunging Strike
    [424621] = { cooldown = 29.1 },  -- Brutal Smash

    -- Elaena Emberlanz
    [424431] = { cooldown = 36.4 },  -- Holy Radiance
    [448515] = { cooldown = 14.5 },  -- Divine Judgment

    -- Taener Duelmal
    [424420] = { cooldown = 15.0 },  -- Cinderblast
    [424462] = { cooldown = 34.0 },  -- Ember Storm

    -- Arathi Knight
    [427609] = { cooldown = 21.8 },  -- Disrupting Shout
    [444296] = { cooldown = 17.0 },  -- Impale

    -- Arathi Footman
    [427342] = { cooldown = 60.7 },  -- Defend

    -- Fervent Sharpshooter
    [453458] = { cooldown = 27.9 },  -- Caltrops
    [462859] = { cooldown = 10.2 },  -- Pot Shot

    -- War Lynx
    [446776] = { cooldown = 16.6 },  -- Pounce

    -- Devout Priest
    [427356] = { cooldown = 25.5 },  -- Greater Heal

    -- Fanatical Conjuror
    [427484] = { cooldown = 23.1 },  -- Flamestrike

    -- Lightspawn
    [448787] = { cooldown = 16.2 },  -- Purification

    -- Ardent Paladin
    [424429] = { cooldown = 23.0 },  -- Consecration
    [448791] = { cooldown = 23.1 },  -- Sacred Toll

    -- Zealous Templar
    [444728] = { cooldown = 23.1 },  -- Templar's Wrath
    [427596] = { cooldown = 12.1 },  -- Seal of Light's Fury

    -- Risen Mage
    [444743] = { cooldown = 22.2 },  -- Fireball Volley

    -- Sir Braunpyke
    [435165] = { cooldown = 13.3 },  -- Blazing Strike

    -- 부화장 --
    -- Thunderhead
    [430109] = { cooldown = 0 , start = 2.5 },

    -- Quartermaster Koratite
    [426893]  = { cooldown = 18.2, start =  5.2 },  -- Bounding Void
    [450628]  = { cooldown = 26.7, start =  8.8 },  -- Entropy Shield

    -- Voidrider
    [474018]  = { cooldown = 20.7, start =  9.2 },  -- Wild Lightning
    [427404]  = { cooldown = 23.1, start = 15.7 },  -- Localized Storm

    -- Cursed Rooktender
    [427260]  = { cooldown = 18.6, start =  8.3 },  -- Lightning Surge

    -- Void-Cursed Crusher
    [474031]  = { cooldown = 18.6, start =  8.3 },  -- Void Crush

    -- Corrupted Oracle
    [430179]  = { cooldown = 23.1, start = 16.5 },  -- Seeping Corruption
    [430238] = { cooldown = 0, start =  5 },  -- Void Bolt

    -- Coalescing Void Diffuser
    [430812]  = { cooldown = 21.8, start =  5.7 },  -- Attracting Shadows
    [430805]  = { cooldown = 14.0, start =  8.3 },  -- Arcing Void

    -- Void Ascendant
    [1214546] = { cooldown = 21.8, start = 15.2 },  -- Umbral Wave
    [1214523] = { cooldown = 22.3, start = 11.9 },  -- Feasting Void

    -- Consuming Voidstone
    [472764]  = { cooldown = 18.2, start =  5.6 },  -- Void Extraction


    -- 양조장 --
    -- Venture Co. Pyromaniac
    [437721] = { cooldown = 24.2, start = 15.6 },  -- Boiling Flames
    [437956] = { cooldown = 17.0, start =  9.1 },  -- Erupting Inferno

    -- Venture Co. Patron
    [434773] = { cooldown = 14.8, start =  8.3 },  -- Mean Mug

    -- Hired Muscle
    [463218] = { cooldown = 24.2, start =  8.0 },  -- Volatile Keg
    [434756] = { cooldown = 15.7, start = 12.0 },  -- Throw Chair

    -- Tasting Room Attendant
    [434706] = { cooldown = 12.1, start = 13.2 },  -- Cinderbrew Toss

    -- Chef Chewie
    [463206] = { cooldown = 18.2, start =  8.0 },  -- Tenderize
    [434998] = { cooldown = 21.8, start = 11.9 },  -- High Steaks

    -- Flavor Scientist
    [441627] = { cooldown = 24.4, start = 12.1 },  -- Rejuvenating Honey
    [441434] = { cooldown = 23.0, start =  8.1 },  -- Failed Batch

    -- Careless Hopgoblin
    [448619] = { cooldown = 30.3, start =  8.8 },  -- Reckless Delivery

    -- Taste Tester
    [441214] = { cooldown = 23.1, start = 11.4 },  -- Spill Drink
    [441242] = { cooldown = 16.9, start =  9.2 },  -- Free Samples

    -- Bee Wrangler
    [441119] = { cooldown = 15.3, start =  4.1 },  -- Bee-Zooka
    [441351] = { cooldown = 18.8, start =  9.4 },  -- Bee-stial Wrath

    -- Venture Co. Honey Harvester
    [442589] = { cooldown = 25.1, start = 16.7 },  -- Beeswax
    [442995] = { cooldown = 23.1, start =  8.1 },  -- Swarming Surprise

    -- Royal Jelly Purveyor
    [440687] = { cooldown = 25.0, start =  8.9 },  -- Honey Volley
    [440876] = { cooldown = 17.0, start = 15.0 },  -- Rain of Honey

    -- Yes Man
    [439467] = { cooldown = 13.4, start =  6.9 },  -- Downward Trend

    -- 분쇄독침
    [438971] = { cooldown =  6.1, start =  8.1 },  -- 분쇄독침

    -- Workshop
    [301088] = { cooldown = 0    },  -- Detonate
    [294103] = { cooldown = 17.0 },  -- Rocket Barrage
    [1215409] = { cooldown = 25.1 }, -- Mega Drill
    [1215411] = { cooldown = 22.7 }, -- Puncture
    [1215412] = { cooldown = 26.0 }, -- Corrosive Gunk
    [1217819] = { cooldown = 19.4 }, -- Fiery Jaws
    [293827] = { cooldown = 0    },  -- Giga-Wallop
    [293854] = { cooldown = 14.5 },  -- Activate Anti-Personnel Squirrel
    [293861] = { cooldown = 0    },  -- Anti-Personnel Squirrel
    [294195] = { cooldown = 21.6 },  -- Arcing Zap
    [297128] = { cooldown = 27.9 },  -- Short Out
    [293986] = { cooldown = 6.0 },   -- Sonic Pulse
    [295169] = { cooldown = 27.4 },  -- Capacitor Discharge
    [293729] = { cooldown = 20.6 },  -- Tune Up
    [293930] = { cooldown = 20.6 },  -- Overclock
    [293683] = { cooldown = 21.8 },  -- Shield Generator

    -- 왕 노 --
    [280604]  = { cooldown = 24.9, start =  8.3 },  -- Iced Spritzer
    [263628]  = { cooldown = 18.2, start =  2.2 },  -- Charged Shield (Normal)
    [472041]  = { cooldown = 19.4, start =  9.2 },  -- Tear Gas
    [262092]  = { cooldown = 21.9, start =  9.0 },  -- Inhale Vapors
    [1217279] = { cooldown = 15.7, start = 15.7 },  -- Uppercut
    [269302]  = { cooldown = 24.2, start =  8.1 },  -- Toxic Blades
    [267354]  = { cooldown = 20.3, start = 13.0 },  -- Fan of Knives
    [473168]  = { cooldown = 26.7, start = 14.8 },  -- Rapid Extraction
    [1215411] = { cooldown = 22.6, start =  9.1 },  -- Puncture
    [263202]  = { cooldown = 0, start =  8.3 },  -- Rock Lance (Normal)
    [268362]  = { cooldown = 15.4, start =  3.8 },  -- Mining Charge
    [268702]  = { cooldown = 17.7, start =  5.2 },  -- Furious Quake (Normal)
    [263215]  = { cooldown = 20.5, start =  4.7 },  -- Tectonic Barrier
    [1214754] = { cooldown = 18.2, start = 11.5 },  -- Massive Slam
    [1213139] = { cooldown = 14.6, start =  7.8 },  -- Overtime!
    [1214751] = { cooldown = 18.2, start = 10.7 },  -- Brutal Charge
    [268846]  = { cooldown = 16.5, start =  4.6 },  -- Echo Blade
    [473304]  = { cooldown = 16.6, start = 11.2 },  -- Brainstorm
    [268797]  = { cooldown = 24.2, start =  7.0 },  -- Transmute: Enemy to Goo
    [269429]  = { cooldown = 17.0, start =  6.8 },  -- Charged Shot
    [262383]  = { cooldown = 35.3, start = 17.8 },  -- Deploy Crawler Mine
    [262377]  = { cooldown = 60.0, start =  0.0 },  -- Seek and Destroy (Fixate)  ※초기엔 적용 안 됨
    [269090]  = { cooldown = 12.1, start =  0.7 },  -- Artillery Barrage

    -- 고투 --
    [341902]  = { cooldown = 24.4 },  -- Unholy Fervor
    [333241]  = { cooldown = 18.2 },  -- Raging Tantrum
    [341977]  = { cooldown = 15.8 },  -- Meat Shield
    [330697]  = { cooldown = 22.1 },  -- Decaying Strike
    [341969]  = { cooldown = 24.0 },  -- Withering Discharge
    [330586]  = { cooldown = 24.2 },  -- Devour Flesh
    [330614]  = { cooldown = 15.7 },  -- Vile Eruption
    [330532]  = { cooldown = 22.0 },  -- Jagged Quarrel
    [1215850] = { cooldown = 13.3 },  -- Earthcrusher
    [331316]  = { cooldown = 13.3 },  -- Savage Flurry
    [317605]  = { cooldown = 26.7 },  -- Whirlwind
    [342135]  = { cooldown = 17.8 },  -- Interrupting Roar
    [336995]  = { cooldown = 13.3 },  -- Whirling Blade
    [331288]  = { cooldown = 14.5 },  -- Colossus Smash (Nekthara)
    [333861]  = { cooldown = 12.1 },  -- Ricocheting Blade
    [333845]  = { cooldown = 15.3 },  -- Unbalancing Blow
    [334023]  = { cooldown = 18.2 },  -- Bloodthirsty Charge
    [330562]  = { cooldown = 17.0 },  -- Demoralizing Shout
    [330565]  = { cooldown =  9.7 },  -- Shield Bash
    [333827]  = { cooldown =  9.3 },  -- Seismic Stomp
    [330716]  = { cooldown = 26.7 },  -- Soulstorm
    [330725]  = { cooldown = 17.0 },  -- Shadow Vulnerability
    [330868]  = { cooldown = 21.7 },  -- Necrotic Bolt Volley
    [333294]  = { cooldown =  5.9 },  -- Death Winds
    [333299]  = { cooldown = 13.3 },  -- Curse of Desolation
    [331237]  = { cooldown = 32.7 },  -- Bone Spikes
    [331223]  = { cooldown = 33.9 },  -- Bonestorm

}
