# dexter-afkfishing

## Dependencies

* [Qbox](https://github.com/Qbox-project/qbx_core)
* [ox_inventory](https://github.com/overextended/ox_inventory)
* [ox_target](https://github.com/communityox/ox_target)
* [PolyZone](https://github.com/mkafrin/PolyZone)
* [MZ-Skills](https://github.com/MrZainRP/mz-skills)

## How To Install

### 1: Items

* Copy the entries from `fish_items.lua` into your `ox_inventory/data/items.lua` return table.
* Make sure your rod and bait items also exist in `ox_inventory`. This resource checks for:
* Rods: `homemadefishingrod`, `cheapfishingrod`, `midtierfishingrod`, `hightierfishingrod`, `masterrod`
* Legal bait: `worms`, `minnows`, `cricket`, `grasshopper`, `leech`
* Illegal bait: `squid`, `cowcarcass`, `pigcarcass`, `seaweed`, `octopus`

### 2: Images

* Add the images from `Images` into `ox_inventory/web/images`.
* This rewrite expects `humpbackwhale.png` and `minnows.png` to exist alongside the original files.

### 3: Config

* Set `Config.DiscordWebhook` if you want fish-sale Discord logs.
* If you do not want Discord logs, leave `Config.DiscordLogs = false`.
