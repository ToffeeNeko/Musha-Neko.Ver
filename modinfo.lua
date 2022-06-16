-- Basic info (customized)
name = "DemoMod"
description = [[
    A demo mod for testing purposes.
]]
author = "ToffeeNeko"
version = "0.0.1"

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Compatible with Don't Starve Together
dst_compatible = true

-- Not compatible with Don't Starve
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

-- Required by all clients
all_clients_require_mod = true
client_only_mod = false

-- Icon shown in the mods list
icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = {
    "Neko",
}

-- Configuration options
configuration_options = {
	{
        name = "modLanguage",
        label = "Mod Language",
        hover = "[*]Choose mod language.\n[*]选择语言.",
        options =
        {
			{
                description="English", 
                data="english"
            },
			{
                description="中文",
                data="chinese"
            }
        },
        default = "chinese",
    },
}