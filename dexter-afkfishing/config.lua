Config = {}

Config.Debug = false

Config.DiscordLogs = false
Config.DiscordWebhook = ''

Config.Delay = 5 -- (s) Delay between fishing attempts

Config.Skill = {
    name = 'Fishing',
    xp = 250
}

Config.RequiredLevels = {
    Pier = 0,
    Fresh = 20,
    River = 40,
    Swamp = 60,
    Ocean = 80,
    Illegal = 60
}

Config.RodItems = {
    'fishingrod'
}

Config.BaitItems = {
    Legal = {'worms'},
    Illegal = {'rareworms'}
}

Config.CatchPools = {
    Legal = {
        pier = {'rockfish', 'californiahalibut', 'jacksmelt', 'surfperch', 'halibut', 'californiacorbina', 'calicobass'},
        fresh = {'salmon', 'bass', 'perch'},
        river = {'trout', 'lingcod', 'pike'},
        swamp = {'mackeral', 'barracuda', 'watersnake'},
        ocean = {'whiteseabass', 'sheephead', 'yellowtail'}
    },
    Illegal = {
        ocean = {'greenturtle', 'leatherbackturtle', 'oliveridleyturtle', 'schoolshark', 'hornshark', 'greatwhiteshark', 'graywhale', 'bluewhale', 'humpbackwhale'}
    }
}

Config.Selling = {
    ped = `ig_old_man2`,
    coords = vector3(-517.5355, -2741.7134, 5.0359),
    heading = 24.14,
    scenario = 'WORLD_HUMAN_STAND_FISHING',
    chair = nil,
    targetIcon = 'fish',
    targetLabel = 'Sell Fish',
    blip = {
        enabled = true,
        sprite = 356,
        colour = 3,
        scale = 0.8,
        shortRange = true,
        label = 'Fish Buyer'
    }
}

Config.SellMoneyType = 'cash'

Config.FishPrices = {
    ['rockfish'] = {
        name = 'rockfish',
        price = 100
    },
    ['californiahalibut'] = {
        name = 'californiahalibut',
        price = 125
    },
    ['jacksmelt'] = {
        name = 'jacksmelt',
        price = 165
    },
    ['surfperch'] = {
        name = 'surfperch',
        price = 205
    },
    ['halibut'] = {
        name = 'halibut',
        price = 225
    },
    ['californiacorbina'] = {
        name = 'californiacorbina',
        price = 245
    },
    ['calicobass'] = {
        name = 'calicobass',
        price = 285
    },
    ['mackeral'] = {
        name = 'mackeral',
        price = 300
    },
    ['whiteseabass'] = {
        name = 'whiteseabass',
        price = 345
    },
    ['pike'] = {
        name = 'pike',
        price = 365
    },
    ['sheephead'] = {
        name = 'sheephead',
        price = 385
    },
    ['perch'] = {
        name = 'perch',
        price = 405
    },
    ['yellowtail'] = {
        name = 'yellowtail',
        price = 435
    },
    ['salmon'] = {
        name = 'salmon',
        price = 465
    },
    ['trout'] = {
        name = 'trout',
        price = 495
    },
    ['bass'] = {
        name = 'bass',
        price = 505
    },
    ['barracuda'] = {
        name = 'barracuda',
        price = 535
    },
    ['lingcod'] = {
        name = 'lingcod',
        price = 565
    },
    ['graywhale'] = {
        name = 'graywhale',
        price = 595
    },
    ['bluewhale'] = {
        name = 'bluewhale',
        price = 600
    },
    ['humpbackwhale'] = {
        name = 'humpbackwhale',
        price = 630
    },
    ['schoolshark'] = {
        name = 'schoolshark',
        price = 670
    },
    ['hornshark'] = {
        name = 'hornshark',
        price = 700
    },
    ['greatwhiteshark'] = {
        name = 'greatwhiteshark',
        price = 745
    },
    ['greenturtle'] = {
        name = 'greenturtle',
        price = 780
    },
    ['leatherbackturtle'] = {
        name = 'leatherbackturtle',
        price = 835
    },
    ['oliveridleyturtle'] = {
        name = 'oliveridleyturtle',
        price = 875
    },
    ['watersnake'] = {
        name = 'watersnake',
        price = 65
    }
}

Config.Zones = {
    ['Pier'] = {
        {
            coords = vector3(-1801.88, -1187.31, 13.02),
            radius = 150.0
        }
    },
    ['Fresh'] = {
        {
            coords = vector3(1930.82, 103.3, 161.21),
            radius = 70.0
        }
    },
    ['River'] = {
        {
            coords = vector3(-961.85, 4374.01, 9.17),
            radius = 10.0
        }
    },
    ['Swamp'] = {
        {
            coords = vector3(-2310.22, 2600.02, -0.47),
            radius = 40.0
        }
    },
    ['Illegal'] = {
        {
            coords = vector3(4325.29, -5144.88, 9.55),
            radius = 500.0
        }
    },
    ['Ocean'] = {
        {
            coords = vector3(-3259.34, 7341.74, 1.11),
            radius = 500.0
        }
    }
}
