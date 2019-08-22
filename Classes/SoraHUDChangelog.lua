SoraHUDChangelog = SoraHUDChangelog or class()

local small_text_changelog = 15
local color_header = Color(0.35, 0.65, 1)
local color_changelog = Color(0.7, 0.7, 0.7)

function SoraHUDChangelog:DrawVersion232(notebook)
    local holder = notebook:Holder({offset = 0})

    self:ImageHeader("NepgearsyHUDReborn/Menu/Versions/232", holder)
    self:Title("2.3.2 - Acceleration - Content Update", holder)
    self:Change("Teammate Skins", "Added new skins! These were made by Syphist, and gabsF. Thanks to them!", holder)
    self:Change("Localization Updated", "The portuguese localization has been updated.", holder)
    return holder
end


function SoraHUDChangelog:DrawVersion231(notebook)
    local holder = notebook:Holder({offset = 0})

    self:ImageHeader("NepgearsyHUDReborn/Menu/Versions/231", holder)
    self:Title("2.3.1 - Acceleration - Bugfix", holder)
    self:Change("Bugfixes", "Fixed an issue where, under exceptionnal circumstances, the game would freeze forever when opening the menu.", holder)
    self:Change("New stuff", "2 new teammate panel skins added in the community category.", holder)

    return holder
end

function SoraHUDChangelog:DrawVersion230(notebook)
    local holder = notebook:Holder({offset = 0})

    self:ImageHeader("NepgearsyHUDReborn/Menu/Versions/230", holder)
    self:Title("2.3.0 - Acceleration", holder)
    self:Change("Stamina Bar", "A new stamina bar has been added. You can toggle it on, or off in the HUD options. You can also personalize the colors!", holder)
    self:Change("Integrated Money In HUD", "You can now enjoy a brand new Money in HUD, directly included, adapted to the HUD style. Toggle it on and off in the options.", holder)
    self:Change("Teammate Panel Skins are now loading instantly", "A problem that was getting bigger and bigger the more I added skins. This is now definitely fixed. In addition to that, kruiserdb created 10 new teammate panel skins. Check them in the Community category!", holder)
    self:Change("Bugfixes", "- Fixed an issue when switching loadouts in a pre-game: the fire mode was not displaying properly. This is now fixed", holder)

    return holder
end

function SoraHUDChangelog:DrawVersion220(notebook)
    local holder = notebook:Holder({offset = 0})

    self:ImageHeader("NepgearsyHUDReborn/Menu/Versions/220", holder)
    self:Title("2.2.0 - The Colorful Update", holder)
    self:Change("New Colors", "A lot of options now supports ALL colors. Check them out, as the options are reset. Also added missing color options, and additional ways to customize the HUD.", holder)
    self:Change("And also a new Changelog!", "The Changelog part of the menu wasn't touched since the version 1.0.0... Today, it got updated, and it looks nicer than ever. If you missed a previous update, you can now easily check it out by clicking the arrows on the top right.", holder)
    self:Change("PDTH Font available for use!", "You can now select the Payday the Heist Font in addition of the two previous choices you had!\nLittle note: Special icons are not supported.", holder, "fonts/font_pdth")
    self:Change("Reset to Default Values", "I think that was something asked by a lot of people, and it's now reality. Clicking the button will directly reset all options to their default values.", holder)
    self:Change("Difficulty, and Party Size added to the Discord Rich Presence", "A little thing I forgot. Now, the difficulty played on is displayed next to the heist's name, and the party size is displayed when you're in a Multiplayer Lobby.", holder)
    self:Change("Current Fire Mode, now displayed", "As well asked for a long time, here's the current firemode of the weapon, now displayed near the ammo counter.", holder)
    self:Change("Blackscreen Transition, no more so black..", "It looks nice to have the level loading screen in the blackscreen transition. This change won't be there if you disable the option 'Starring Screen'.", holder)
    self:Change("Localizations Updated", "gabsF updated the Portuguese Localization. Thanks to him!", holder)
    self:Change("Bugfixes", "An issue with the teammate panel skins ingame were making them more wide than intended. This is now fixed.\nFixed a crash when trying to retrieve the steam avatar.", holder)

    return holder
end

function SoraHUDChangelog:DrawVersion210(notebook)
    local holder = notebook:Holder({offset = 0})

    self:ImageHeader("NepgearsyHUDReborn/Menu/Versions/210", holder)
    self:Title("2.1.0 - Discord Rich Presence", holder)
    self:Change("CUSTOM DISCORD RICH PRESENCE, NOW AVAILABLE", "Added a new feature : Custom Discord Rich Presence. You can personalize what your friends see when you're playing.", holder)
    self:Change("TEAMMATE PANEL SKINS MORE ORGANIZED", "Added a lot of new Teammate Panel Skins! The menu got quite laggy since we added so many of them (close to 100), so it was a better plan to separate the render in their own categories. That way, it's now easier to find the ones you like!", holder)
    self:Change("VARIOUS ADDITIONS", "Bots now have a name background, like players.\nAdded a new option: \"Show the player's color with a Teammate Panel Skin\". This is disabled by default.", holder)
    self:Change("BUGFIXES", "- Fixed an issue where collaborator avatars wouldn't load properly sometimes.\n- Fixed an issue with the assault banner, where clients couldn't see \"Prepare for the next assault\".\n- Menu initialization changed.", holder)

    return holder
end

function SoraHUDChangelog:DrawVersion200(notebook)
    local holder = notebook:Holder({offset = 0})

    self:ImageHeader("NepgearsyHUDReborn/Menu/Versions/200", holder)
    self:Title("2.0.0 - Passage to Sora's HUD Reborn", holder)
    self:Change("NEW IDENTITY", "The HUD goes from Nepgearsy HUD to Sora's HUD. Nothing much else change but the identity of the HUD itself, which hasn't changed despite me changing my name. Now this is done.", holder)
    self:Change("BUGFIX 2.0.1", "The mod initialization changed, in order to make other BeardLib mods compatible with this one..", holder)

    return holder
end

function SoraHUDChangelog:ImageHeader(texture_path, holder)
    holder:Image({
        texture = texture_path,
        w = holder:W(),
        h = 70
    })
end

function SoraHUDChangelog:Title(title, holder, custom_font)
    holder:Divider({
        text = title,
        font = not custom_font and "fonts/font_eurostile_ext" or custom_font,
        size = 24,
        text_align = "center",
        background_color = Color(0.7, 0, 0, 0)
    })
end

function SoraHUDChangelog:Change(title, desc, holder, custom_font)
    holder:Divider({ size = 10 })
    holder:QuickText(utf8.to_upper(title), { foreground = color_header, size = 20, font = custom_font or nil })
    holder:Divider({
        font = custom_font or nil,
        text = desc,
        size = 15,
        foreground = color_changelog
    })
end