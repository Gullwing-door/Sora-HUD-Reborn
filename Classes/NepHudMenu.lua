local BaseLayer = 1500
local HighlightColor = Color(0.5, 0.25, 0.25, 0.32)
local Font = "fonts/font_eurostile_ext"
local MenuBgs = Color(0.75, 0, 0, 0)

local function make_fine_text( text )
	local x,y,w,h = text:text_rect()
	text:set_size( w, h )
	text:set_position( math.round( text:x() ), math.round( text:y() ) )
end

NepHudMenu = NepHudMenu or class()
-- Based on BeardLib Editor & HoloUI's menu.
function NepHudMenu:init()
    self._menu = MenuUI:new({
        name = "NepgearsyHUDMenu",
		layer = BaseLayer,
		use_default_close_key = true,
		background_color = Color.transparent,
		inherit_values = {
			background_color = MenuBgs,
			scroll_color = Color.white:with_alpha(0.1),
			highlight_color = HighlightColor
		},
        animate_toggle = true,
        animate_colors = true
    })
    self._menu_panel = self._menu._panel
    self.BackgroundStatus = true
    self.BorderColor = NepgearsyHUDReborn:GetOption("SoraCPBorderColor")
    self.CurrentTeammateSkinCategory = "default"

    self:InitTopBar()
    self:InitBackground()
    self:InitMenu()
    self:InitCollab()
    self:InitChangelog()
    self:InitBack()
end

function NepHudMenu:InitTopBar()
    self.TopBar = self._menu:Menu({
        name = "TopBar",
        background_color = Color(0.05, 0.05, 0.05),
		h = 30,
		text_offset = 0,
		align_method = "grid",
        w = self._menu_panel:w(),
        scrollbar = false,
        position = "Top"
    })

    self.HUDName = self.TopBar:Divider({
		text = managers.localization:text("NepgearsyHUDReborn"),
        font = NepgearsyHUDReborn:SetFont(Font),
		size = 25,
		border_left = false,
		size_by_text = true,
        color = Color(0.8, 0.8, 0.8),
        layer = BaseLayer,
    })

    local BackgroundEnabler = self.TopBar:ImageButton({
        name = "BackgroundEnabler",
        texture = "NepgearsyHUDReborn/Menu/DisableBackground",
        w = 26,
        h = 26,
        offset_x = 20,
        help = "Enable or disable the background, and optional parts of the menu.",
        on_callback = ClassClbk(self, "background_enable_switch")
    })
    self.BackgroundEnabler = BackgroundEnabler

    local MWSProfile = self.TopBar:ImageButton({
        name = "MWSProfile",
        texture = "NepgearsyHUDReborn/Menu/MWSProfile",
        w = 26,
        h = 26,
        offset_x = 5,
        help = "Go to the mod's page.",
        on_callback = ClassClbk(self, "open_url", "https://modworkshop.net/mydownloads.php?action=view_down&did=22152")
    })
    self.MWSProfile = MWSProfile

    local HUDVersion = self.TopBar:Button({
        name = "HUDVersion",
        text = managers.localization:to_upper_text("NepgearsyHUDReborn/Version", { version = NepgearsyHUDReborn.Version }),
        background_color = Color.transparent,
        highlight_color = Color.transparent,
        foreground = Color(0.4, 0.4, 0.4),
        foreground_highlight = self.BorderColor,
        position = "RightOffset-x",
		offset_x = 5,
        localized = false,
        size_by_text = true,
        text_align = "right",
        text_vertical = "center",
        font_size = 25,
        font = NepgearsyHUDReborn:SetFont(Font),
        on_callback = ClassClbk(self, "open_url", "https://github.com/Nepgearsy/Nepgearsy-HUD-Reborn/commits/master")
    })

    local PostIssue = self.TopBar:Button({
        name = "PostIssue",
        text = managers.localization:to_upper_text("NepgearsyHUDReborn/PostIssue"),
        background_color = Color.transparent,
        highlight_color = Color.transparent,
        foreground = Color(1, 1, 1),
        foreground_highlight = self.BorderColor,
        position = function(item)
            item:Panel():set_right(HUDVersion:Panel():left() - 120)
            item:Panel():set_world_center_y(self.TopBar:Panel():world_center_y())
        end,
        localized = false,
        size_by_text = true,
        text_align = "right",
        text_vertical = "center",
        font_size = 15,
        font = NepgearsyHUDReborn:SetFont(Font),
        on_callback = ClassClbk(self, "open_url", "https://github.com/Nepgearsy/Nepgearsy-HUD-Reborn/issues")
    })
end


function NepHudMenu:InitBackground()
    local Background = self._menu_panel:bitmap({
        name = "Background",
        w = self._menu_panel:w(),
        h = self._menu_panel:h() - self.TopBar:Panel():h(),
        texture = "NepgearsyHUDReborn/Menu/MenuBackgrounds/SoraHudReborn",
        alpha = 1
    })
    Background:set_top(self.TopBar:Panel():bottom())

    local ColorBG = self._menu_panel:bitmap({
        name = "ColorBG",
        w = self._menu_panel:w(),
        h = self._menu_panel:h() - self.TopBar:Panel():h(),
        texture = "NepgearsyHUDReborn/Menu/BGColor",
        color = NepgearsyHUDReborn.Options:GetValue("SoraCPColor"),
        layer = -2
    })
    ColorBG:set_top(self.TopBar:Panel():bottom())

    self.ColorBG = ColorBG
end

function NepHudMenu:SetBackgroundVis(vis)
    local Background = self._menu_panel:child("Background")
    Background:set_visible(vis)
    self.ColorBG:set_visible(vis)
end

function NepHudMenu:SetEnabled(state)
    if not self._menu then
        self:init()
    end

    self._menu:SetEnabled(state)
end

function NepHudMenu:InitMenu()
    self.MainMenu = self._menu:Menu({
        name = "MainMenu",
        h = self._menu_panel:h() - self.TopBar:Panel():h(),
		w = self._menu_panel:w() / 4,
		size = 15,
		border_color = self.BorderColor,
		offset = 8,
		text_align = "left",
		text_vertical = "center",
		localized = true,
        position = function(item)
            item:Panel():set_top(self.TopBar:Panel():bottom())
            item:Panel():set_right(self._menu_panel:right())
        end
    })

    self.TeammateSkins = self._menu:Menu({
        name = "TeammateSkins",
        background_color = MenuBgs,
        h = 600,
        scrollbar = true,
        w = self._menu_panel:w() / 2.1,
        align_method = "grid",
        position = function(item)
            item:Panel():set_top(self.TopBar:Panel():bottom() + 15)
            item:Panel():set_right(self.MainMenu:Panel():left() - 10)
        end,
        visible = false
    })

    self:InitMainMenu()
end

function NepHudMenu:InitMainMenu()
    self:ClearMenu()
    self:VisOptionalMenuParts(true)

    if self.TeammateSkins then
        self.TeammateSkins:SetVisible(false)
    end

    self.ForcedLocalization = self.MainMenu:ComboBox({
        name = "ForcedLocalization",
        border_left = true,
        items = NepgearsyHUDReborn.LocalizationTable,
        value = NepgearsyHUDReborn.Options:GetValue("ForcedLocalization"),
        text = "NepgearsyHUDRebornMenu/ForcedLocalization",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.MainMenuOptionsCat = self.MainMenu:Divider({
        name = "MainMenuOptionsCat",
		text = "NepgearsyHUDRebornMenu/Buttons/MainMenuOptionsCat",
		offset_y = 20,
        background_color = Color(0, 0, 0),
        highlight_color = Color.black,
        text_align = "center",
        font_size = 20,
        font = NepgearsyHUDReborn:SetFont(Font)
    })

    self.MainMenuOptions = {}
    self.MainMenuOptions.HUDOptionsButton = self.MainMenu:Button({
        name = "HUDOptionsButton",
        border_color = self.BorderColor,
        border_left = true,
        text = "NepgearsyHUDRebornMenu/Buttons/HUDOptionsButton",
        localized = true,
        on_callback = ClassClbk(self, "InitHUDOptions")
    })

    self.MainMenuOptions.MenuOptionsButton = self.MainMenu:Button({
        name = "MenuOptionsButton",
        border_color = self.BorderColor,
        border_left = true,
        text = "NepgearsyHUDRebornMenu/Buttons/MenuOptionsButton",
        localized = true,
        on_callback = ClassClbk(self, "InitMenuOptions")
    })

    self.MainMenuOptions.ColorOptionsButton = self.MainMenu:Button({
        name = "ColorOptionsButton",
        border_color = self.BorderColor,
        border_left = true,
        text = "NepgearsyHUDRebornMenu/Buttons/ColorOptionsButton",
        localized = true,
        on_callback = ClassClbk(self, "InitColorOptions")
    })

    self.MainMenuOptions.TeammatePanelSkinButton = self.MainMenu:Button({
        name = "TeammatePanelSkinButton",
        border_color = self.BorderColor,
        border_left = true,
        text = "NepgearsyHUDRebornMenu/Buttons/TeammatePanelSkinButton",
        localized = true,
        on_callback = ClassClbk(self, "InitTeammateSkins")
    })

    self.MainMenuOptions.DiscordRichPresenceButton = self.MainMenu:Button({
        name = "DiscordRichPresenceButton",
        border_color = self.BorderColor,
        border_left = true,
        text = "NepgearsyHUDRebornMenu/Buttons/DiscordRichPresenceButton",
        localized = true,
        on_callback = ClassClbk(self, "InitDiscordRichPresence")
    })
end

function NepHudMenu:InitHUDOptions()
    self:ClearMenu()

    self.HUDOptionsCat = self.MainMenu:Divider({
        name = "HUDOptionsCat",
		text = "NepgearsyHUDRebornMenu/Buttons/HUDOptionsCat",
		offset_y = 20,
        background_color = Color(0, 0, 0),
        highlight_color = Color.black,
        text_align = "center",
        font_size = 20,
        font = NepgearsyHUDReborn:SetFont(Font)
    })

    self.HUDOptions = {}
    self.HUDOptions.AssaultBar = self.MainMenu:ComboBox({
        name = "AssaultBarFont",
        border_left = true,
        items = NepgearsyHUDReborn.AssaultBarFonts,
        value = NepgearsyHUDReborn.Options:GetValue("AssaultBarFont"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/AssaultBarFont",
        on_callback = ClassClbk(self, "MainClbk")
    })

	self.HUDOptions.PlayerNameFont = self.MainMenu:ComboBox({
        name = "PlayerNameFont",
        border_left = true,
        items = NepgearsyHUDReborn.PlayerNameFonts,
        value = NepgearsyHUDReborn.Options:GetValue("PlayerNameFont"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/PlayerNameFont",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.InteractionFont = self.MainMenu:ComboBox({
        name = "InteractionFont",
        border_left = true,
        items = NepgearsyHUDReborn.InteractionFonts,
        value = NepgearsyHUDReborn.Options:GetValue("InteractionFont"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/InteractionFont",
        on_callback = ClassClbk(self, "MainClbk")
    })
    --[[
    self.HUDOptions.TeammatePanelStyle = self.MainMenu:ComboBox({
        name = "TeammatePanelStyle",
		border_left = true,
        offset_y = 20,
        items = NepgearsyHUDReborn.TeammatePanelStyles,
        value = NepgearsyHUDReborn.Options:GetValue("TeammatePanelStyle"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/TeammatePanelStyle",
        on_callback = ClassClbk(self, "MainClbk")
    })--]]

    self.HUDOptions.Minimap = self.MainMenu:Toggle({
        name = "EnableMinimap",
		border_left = true,
		offset_y = 20,
        value = NepgearsyHUDReborn.Options:GetValue("EnableMinimap"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/Minimap",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.MinimapForce = self.MainMenu:Toggle({
        name = "MinimapForce",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("MinimapForce"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/MinimapForce",
        help = "Force the minimap anytime, even if the current map doesn't have a texture for it.",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.MinimapSize = self.MainMenu:Slider({
        name = "MinimapSize",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("MinimapSize"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/MinimapSize",
        min = 150,
        max = 200,
        step = 1,
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.MinimapZoom = self.MainMenu:Slider({
        name = "MinimapZoom",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("MinimapZoom"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/MinimapZoom",
        min = 0.25,
        max = 1,
        step = 0.01,
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.Trackers = self.MainMenu:Toggle({
        name = "EnableTrackers",
		border_left = true,
		offset_y = 20,
        value = NepgearsyHUDReborn.Options:GetValue("EnableTrackers"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/Trackers",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.CopTracker = self.MainMenu:Toggle({
        name = "EnableCopTracker",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("EnableCopTracker"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/CopTracker",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.TrueAmmo = self.MainMenu:Toggle({
        name = "EnableTrueAmmo",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("EnableTrueAmmo"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/TrueAmmo",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.HealthStyle = self.MainMenu:ComboBox({
        name = "HealthStyle",
        items = NepgearsyHUDReborn.HealthStyle,
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("HealthStyle"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/HealthStyle",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.StatusNumberType = self.MainMenu:ComboBox({
        name = "StatusNumberType",
        items = NepgearsyHUDReborn.StatusNumberType,
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("StatusNumberType"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/StatusNumberType",
        on_callback = ClassClbk(self, "MainClbk")
    })

	self.HUDOptions.EnablePlayerLevel = self.MainMenu:Toggle({
        name = "EnablePlayerLevel",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("EnablePlayerLevel"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/EnablePlayerLevel",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.EnableSteamAvatars = self.MainMenu:Toggle({
        name = "EnableSteamAvatars",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("EnableSteamAvatars"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/EnableSteamAvatars",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.EnableSteamAvatarsInChat = self.MainMenu:Toggle({
        name = "EnableSteamAvatarsInChat",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("EnableSteamAvatarsInChat"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/EnableSteamAvatarsInChat",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.EnableDownCounter = self.MainMenu:Toggle({
        name = "EnableDownCounter",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("EnableDownCounter"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/EnableDownCounter",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.ColorWithSkinPanels = self.MainMenu:Toggle({
        name = "ColorWithSkinPanels",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("ColorWithSkinPanels"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/ColorWithSkinPanels",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.EnableInteraction = self.MainMenu:Toggle({
        name = "EnableInteraction",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("EnableInteraction"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/EnableInteraction",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.ActivateStaminaBar = self.MainMenu:Toggle({
        name = "ActivateStaminaBar",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("ActivateStaminaBar"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/ActivateStaminaBar",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.HUDOptions.ActivateMoneyHUD = self.MainMenu:Toggle({
        name = "ActivateMoneyHUD",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("ActivateMoneyHUD"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/ActivateMoneyHUD",
        on_callback = ClassClbk(self, "MainClbk")
    })
    
    self.HUDOptions.Scale = self.MainMenu:Slider({
        name = "Scale",
		border_left = true,
		offset_y = 20,
        value = NepgearsyHUDReborn.Options:GetValue("Scale"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/Scale",
        help = "If in-game, restart the map to take effect",
        min = 0.1,
        max = 1.5,
        step = 0.01,
        on_callback = ClassClbk(self, "SetHudScaleSpacing")
    })

    self.HUDOptions.Spacing = self.MainMenu:Slider({
        name = "Spacing",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("Spacing"),
        text = "NepgearsyHUDRebornMenu/Buttons/HUD/Spacing",
        help = "If in-game, restart the map to take effect",
        min = 0.1,
        max = 1,
        step = 0.01,
        on_callback = ClassClbk(self, "SetHudScaleSpacing")
    })

    self.MainMenu:Divider({ size = 10 })

    self.MainMenu:Button({
        name = "ResetHUDOptions",
        border_color = self.BorderColor,
        border_left = true,
        localized = true,
        text = "NepgearsyHUDRebornMenu/Buttons/ResetOption",
        on_callback = ClassClbk(self, "ResetHUD")
    })

    self:CreateSharedBackButton()
end

function NepHudMenu:InitMenuOptions()
    self:ClearMenu()

    self.MenuLobbyOptionsCat = self.MainMenu:Divider({
        name = "MenuLobbyOptionsCat",
		text = "NepgearsyHUDRebornMenu/Buttons/MenuLobbyOptionsCat",
		offset_y = 20,
        background_color = Color(0, 0, 0),
        highlight_color = Color.black,
        text_align = "center",
        text_vertical = "center",
        font_size = 20,
        font = NepgearsyHUDReborn:SetFont(Font)
    })

    self.MenuLobbyOptions = {}
    self.MenuLobbyOptions.StarringScreen = self.MainMenu:Toggle({
        name = "EnableStarring",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("EnableStarring"),
        text = "NepgearsyHUDRebornMenu/Buttons/LobbyMenu/StarringScreen",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.MenuLobbyOptions.StarringColor = self.MainMenu:ComboBox({
        name = "StarringColor",
        items = NepgearsyHUDReborn.StarringColors,
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("StarringColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/LobbyMenu/StarringColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.MenuLobbyOptions.StarringText = self.MainMenu:TextBox({
        name = "StarringText",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("StarringText"),
        text = "NepgearsyHUDRebornMenu/Buttons/LobbyMenu/StarringText",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.MenuLobbyOptions.HorizontalLoadout = self.MainMenu:Toggle({
        name = "EnableHorizontalLoadout",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("EnableHorizontalLoadout"),
        text = "NepgearsyHUDRebornMenu/Buttons/LobbyMenu/HorizontalLoadout",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.MenuLobbyOptions.ShowMapStarring = self.MainMenu:Toggle({
        name = "ShowMapStarring",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("ShowMapStarring"),
        text = "NepgearsyHUDRebornMenu/Buttons/LobbyMenu/ShowMapStarring",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self:CreateSharedBackButton()
end

function NepHudMenu:InitColorOptions()
    self:ClearMenu()

    self.ColorsCat = self.MainMenu:Divider({
        name = "ColorsCat",
        text = "NepgearsyHUDRebornMenu/Buttons/ColorsCat",
        background_color = Color(0, 0, 0),
        highlight_color = Color.black,
        text_align = "center",
		text_vertical = "center",
		offset_y = 20,
        font_size = 20,
        font = NepgearsyHUDReborn:SetFont(Font)
    })

    self.MainMenu:QuickText("NepgearsyHUDRebornMenu/Help/NewColors", { localized = true, size = 16 })

    self.Colors = {}
    self.Colors.SoraCPColor = self.MainMenu:ColorTextBox({
        name = "SoraCPColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraCPColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/CPColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.SoraCPBorderColor = self.MainMenu:ColorTextBox({
        name = "SoraCPBorderColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraCPBorderColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/CPBorderColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.MainMenu:Divider({ size = 5 })

    self.Colors.HealthColor = self.MainMenu:ComboBox({
        name = "HealthColor",
        border_left = true,
        items = NepgearsyHUDReborn.HealthColor,
        value = NepgearsyHUDReborn.Options:GetValue("HealthColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/HealthColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.ShieldColor = self.MainMenu:ComboBox({
        name = "ShieldColor",
        border_left = true,
        items = NepgearsyHUDReborn.ArmorColor,
        value = NepgearsyHUDReborn.Options:GetValue("ShieldColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/ShieldColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.MainMenu:Divider({ size = 5 })

    self.Colors.SoraObjectiveColor = self.MainMenu:ColorTextBox({
        name = "SoraObjectiveColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraObjectiveColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/ObjectiveColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.SoraInteractionColor = self.MainMenu:ColorTextBox({
        name = "SoraInteractionColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraInteractionColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/InteractionColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.MainMenu:Divider({ size = 5 })

    self.Colors.SoraAssaultBarColor = self.MainMenu:ColorTextBox({
        name = "SoraAssaultBarColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraAssaultBarColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/AssaultBar",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.SoraSurvivedBarColor = self.MainMenu:ColorTextBox({
        name = "SoraSurvivedBarColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraSurvivedBarColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/AssaultBarSurvived",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.SoraStealthBarColor = self.MainMenu:ColorTextBox({
        name = "SoraStealthBarColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraStealthBarColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/AssaultBarStealth",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.SoraPONRBarColor = self.MainMenu:ColorTextBox({
        name = "SoraPONRBarColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraPONRBarColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/AssaultBarPONR",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.SoraWintersBarColor = self.MainMenu:ColorTextBox({
        name = "SoraWintersBarColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraWintersBarColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/AssaultBarWinters",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.MainMenu:Divider({ size = 5 })

    self.Colors.SoraPeerOneColor = self.MainMenu:ColorTextBox({
        name = "SoraPeerOneColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraPeerOneColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/PeerOneColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.SoraPeerTwoColor = self.MainMenu:ColorTextBox({
        name = "SoraPeerTwoColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraPeerTwoColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/PeerTwoColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.SoraPeerThreeColor = self.MainMenu:ColorTextBox({
        name = "SoraPeerThreeColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraPeerThreeColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/PeerThreeColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.SoraPeerFourColor = self.MainMenu:ColorTextBox({
        name = "SoraPeerFourColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraPeerFourColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/PeerFourColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.SoraAIColor = self.MainMenu:ColorTextBox({
        name = "SoraAIColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("SoraAIColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/AIColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.MainMenu:Divider({ size = 5 })

    self.Colors.StaminaBarColor = self.MainMenu:ColorTextBox({
        name = "StaminaBarColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("StaminaBarColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/StaminaBarColor",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.Colors.LowStaminaBarColor = self.MainMenu:ColorTextBox({
        name = "LowStaminaBarColor",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("LowStaminaBarColor"),
        text = "NepgearsyHUDRebornMenu/Buttons/Colors/LowStaminaBarColor",
        on_callback = ClassClbk(self, "MainClbk")
    })


    self.MainMenu:Divider({ size = 10 })

    self.MainMenu:Button({
        name = "ResetColors",
        border_color = self.BorderColor,
        border_left = true,
        localized = true,
        text = "NepgearsyHUDRebornMenu/Buttons/ResetOption",
        on_callback = ClassClbk(self, "ResetColors")
    })

    self:CreateSharedBackButton()
end

function NepHudMenu:InitTeammateSkins()
    self:ClearMenu()
    self:ClearSkinMenu()
    self:VisOptionalMenuParts(false)

    local TeammateSkinsHeader = self.MainMenu:Divider({
        name = "TeammateSkinsHeader",
        text = "NepgearsyHUDRebornMenu/Buttons/TeammateSkinsHeader",
        background_color = Color(0, 0, 0),
        text_align = "center",
		text_vertical = "center",
		offset_y = 20,
        font_size = 20,
        font = NepgearsyHUDReborn:SetFont(Font)
    })

    self.MainMenu:Divider({
        name = "SkinExplaination",
        text = "NepgearsyHUDRebornMenu/Help/TeammateSkinsExplaination",
        localized = true
    })

    self.MainMenu:Divider({
        name = "SkinEquippedHeader",
        text = "NepgearsyHUDRebornMenu/Help/SkinEquipped",
        background_color = Color(0, 0, 0),
        text_align = "center",
		text_vertical = "center",
		offset_y = 20,
        font_size = 20,
        font = NepgearsyHUDReborn:SetFont(Font)
    })

    local skin_w = NepgearsyHUDReborn:IsTeammatePanelWide() and 168 or 154
    local skin_h = NepgearsyHUDReborn:IsTeammatePanelWide() and 68 or 45

    self.EquippedSkin = self.MainMenu:Image({
        name = "EquippedSkin",
        texture = NepgearsyHUDReborn:GetTeammateSkinBySave(),
        w = skin_w,
        h = skin_h,
        offset_x = 82,
        offset_y = 10
    })

    self:CreateSharedBackButton()

    self.TeammateSkins:SetVisible(true)

    self.TeammateSkinsCategory = self.TeammateSkins:Holder({
        background_color = Color(0.5, 0, 0, 0),
        w = self.TeammateSkins:W(),
        align_method = "grid"
    })

    for _, category_id in ipairs(NepgearsyHUDReborn.TeammateSkinsCollectionLegacy) do
        self.TeammateSkinsCategory:ImageButton({
            texture = "NepgearsyHUDReborn/HUD/TeammateSkinsCategories/" .. category_id,
            w = 48,
            h = 48,
            on_callback = ClassClbk(self, "ClbkSkinChangeCat", category_id),
            border_bottom = true
        })
    end

    if self.CurrentTeammateSkinCategory == "community" then
        self.TeammateSkins:Divider({
            text = "NepgearsyHUDRebornMenu/Help/CommunityHelpText",
            localized = true,
            text_align = "center",
            background_color = Color(0.5, 0, 0, 0)
        })
    end

    for category_id, category_title in pairs(NepgearsyHUDReborn.TeammateSkinsCollection) do
        if category_id == self.CurrentTeammateSkinCategory then
            self.TeammateSkins:Divider({
                name = "DefaultHeader",
                text = tostring(category_title),
                background_color = Color(0, 0, 0),
                text_align = "center",
                localized = true,
                text_vertical = "center",
                font_size = 20,
                font = NepgearsyHUDReborn:SetFont(Font)
            })

            self:GenerateSkinButtonsByCat(category_id)

            break
        end
    end
end

function NepHudMenu:GenerateSkinButtonsByCat(category)
    for skin_id, skin_data in pairs(NepgearsyHUDReborn.TeammateSkins) do
        if category == skin_data.collection then
            if not skin_data.dev then
                local author = skin_data.author
                local name = skin_data.name
                local texture = skin_data.texture

                local skin_button_panel = self.TeammateSkins:Button({
                    name = "skin_button_panel_".. author .. name,
                    text = "",
                    w = 154 * 1.22,
                    h = 65,
                    border_left = true,
                    border_color = self.BorderColor,
                    offset_x = 5,
                    offset_y = 15,
                    background_color = Color(0.35, 0, 0, 0),
                    on_callback = ClassClbk(self, "SkinSetClbk", skin_id),
                    enabled = not NepgearsyHUDReborn:IsTeammatePanelWide() or NepgearsyHUDReborn:IsTeammatePanelWide() and NepgearsyHUDReborn.TeammateSkins[skin_id].wide_counterpart and true or false
                })

                local skin_button = skin_button_panel:Image({
                    name = "skin_button_" .. author .. name,
                    texture = texture,
                    w = 154,
                    h = 45,
                    offset_y = 5,
                    position = "CenterTop"
                })

                local skin_title = skin_button_panel:Divider({
                    text = name .. " by " .. author,
                    font = "fonts/font_large_mf",
                    background_color = Color.transparent,
                    font_size = 14,
                    offset_y = -5,
                    position = "CenterBottom",
                    text_align = "center"
                })

                --[[
                local skin_panel = self.TeammateSkins:Panel()
                local skin_button_panel = skin_button:Panel()

                local skin_title = skin_panel:text({
                    text = name,
                    font = Font,
                    color = Color.white,
                    font_size = 16
                })
                skin_title:set_top(skin_button_panel:bottom() - 3)
                skin_title:set_left(skin_button_panel:left())--]]
            end
        end
    end
end

function NepHudMenu:ClbkSkinChangeCat(category)
    self.CurrentTeammateSkinCategory = category
    self:InitTeammateSkins()
end

function NepHudMenu:InitDiscordRichPresence()
    self:ClearMenu()

    local DiscordRichPresenceHeader = self.MainMenu:Divider({
        name = "DiscordRichPresenceHeader",
        text = "NepgearsyHUDRebornMenu/Header/DiscordRichPresenceHeader",
        background_color = Color(0, 0, 0),
        text_align = "center",
		text_vertical = "center",
		offset_y = 5,
        font_size = 20,
        font = NepgearsyHUDReborn:SetFont(Font)
    })

    local status = {
        text = "NepgearsyHUDRebornMenu/Status/DiscordRichPresenceInactive",
        color = Color(1, 0.5, 0)
    }

    local has_presence_active = false

    if NepgearsyHUDReborn:GetOption("UseDiscordRichPresence") then
        status.text = "NepgearsyHUDRebornMenu/Status/DiscordRichPresenceActive"
        status.color = Color.green
        has_presence_active = true
    end

    local PresenceVersionCheck = self.MainMenu:Divider({
        name = "PresenceVersionCheck",
        text = status.text,
        foreground = status.color,
        background_color = Color(0.25, 0, 0, 0),
        text_align = "center",
		text_vertical = "center",
		offset_y = 5,
        font_size = 14,
        font = "fonts/font_large_mf"
    })

    local DiscordRichPresenceHelp = self.MainMenu:Divider({
        name = "DiscordRichPresenceHelp",
        text = "NepgearsyHUDRebornMenu/Help/DiscordRichPresenceHelp",
        background_color = Color(0.25, 0, 0, 0),
		text_vertical = "center",
		offset_y = 20,
        font_size = 14,
        font = "fonts/font_large_mf"
    })

    local DiscordRichPresencePicHelp = self.MainMenu:Image({
        name = "DiscordRichPresencePicHelp",
        texture = "NepgearsyHUDReborn/Menu/DiscordRichPresence",
        h = 386 / 1.25,
        w = 368 / 1.25
    })

    self.DiscordOptions = {}

    self.DiscordOptions.UseDiscordRichPresence = self.MainMenu:Toggle({
        name = "UseDiscordRichPresence",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("UseDiscordRichPresence"),
        text = "NepgearsyHUDRebornMenu/Buttons/Menu/UseDiscordRichPresence",
        on_callback = ClassClbk(self, "MainClbk")
    })

    self.DiscordOptions.DiscordRichPresenceType = self.MainMenu:ComboBox({
        name = "DiscordRichPresenceType",
        border_left = true,
        items = NepgearsyHUDReborn.DiscordRichPresenceTypes,
        value = NepgearsyHUDReborn.Options:GetValue("DiscordRichPresenceType"),
        text = "NepgearsyHUDRebornMenu/Buttons/Menu/DiscordRichPresenceType",
        on_callback = ClassClbk(self, "MainClbk"),
        enabled = has_presence_active
    })

    local DiscordRichPresenceCustomLimitation = self.MainMenu:Divider({
        name = "DiscordRichPresenceCustomLimitation",
        text = "NepgearsyHUDRebornMenu/Help/DiscordCustomPresenceLimitation",
        background_color = Color(0.25, 0, 0, 0),
		text_vertical = "center",
        font_size = 14,
        font = "fonts/font_large_mf"
    })

    self.DiscordOptions.DiscordRichPresenceCustom = self.MainMenu:TextBox({
        name = "DiscordRichPresenceCustom",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("DiscordRichPresenceCustom"),
        text = "NepgearsyHUDRebornMenu/Buttons/Menu/DiscordRichPresenceCustom",
        on_callback = ClassClbk(self, "MainClbk"),
        enabled = has_presence_active
    })

    self.DiscordOptions.DRPAllowTimeElapsed = self.MainMenu:Toggle({
        name = "DRPAllowTimeElapsed",
        border_left = true,
        value = NepgearsyHUDReborn.Options:GetValue("DRPAllowTimeElapsed"),
        text = "NepgearsyHUDRebornMenu/Buttons/Menu/DRPAllowTimeElapsed",
        on_callback = ClassClbk(self, "MainClbk"),
        enabled = has_presence_active
    })

    self:CreateSharedBackButton()
end

function NepHudMenu:CreateSharedBackButton()
    self.SharedBackButtonMenu = self.MainMenu:Button({
        name = "HUDOptionsButton",
        border_color = self.BorderColor,
        border_left = true,
        text = "NepgearsyHUDRebornMenu/Buttons/Back",
        offset_y = 30,
        localized = true,
        on_callback = ClassClbk(self, "InitMainMenu")
    })
end

function NepHudMenu:ClearMenu()
    self.MainMenu:ClearItems()
end

function NepHudMenu:ClearSkinMenu()
    self.TeammateSkins:ClearItems()
end

function NepHudMenu:InitCollab()
    self.CollabMenu = self._menu:Menu({
        name = "CollabMenu",
        background_color = MenuBgs,
        h = 270,
        w = self._menu_panel:w() / 2.1,
		scrollbar = true,
		offset = 8,
        position = function(item)
            item:Panel():set_top(self.TopBar:Panel():bottom() + 15)
            item:Panel():set_right(self.MainMenu:Panel():left() - 10)
        end
    })

    self.CollabMenuHeader = self.CollabMenu:Divider({
        name = "CollabMenuHeader",
        text = "NepgearsyHUDRebornMenu/Collaborators/Header",
        localized = true,
        font = NepgearsyHUDReborn:SetFont(Font),
        size = 20,
        background_color = Color(0.75, 0, 0, 0),
        highlight_color = Color(0.75, 0, 0, 0),
        text_vertical = "center",
        text_align = "center"
    })

    self.Collaborator = {}
    self.CollabAvatarLoaded = {}
    self.CollabPanel = {}
    self.CollabAvatar = {}
    self.CollabName = {}
    self.CollabAction = {}

    for i, collab_data in ipairs(NepgearsyHUDReborn.Creators) do
        local built_steam_url = nil
        local cbk = nil

        if collab_data.steam_id then
            built_steam_url = "http://steamcommunity.com/profiles/" .. collab_data.steam_id
            cbk = callback(self, self, "open_url", built_steam_url)
        end

        self.Collaborator[i] = self.CollabMenu:Button({
            name = "Collaborator_" .. i,
            h = 24,
            text = "",
            border_left = false,
            background_color = MenuBgs,
            highlight_color = HighlightColor,
            on_callback = cbk
        })

        self.CollabPanel[i] = self.Collaborator[i]:Panel()
        self.CollabAvatar[i] = self.CollabPanel[i]:bitmap({
            texture = "guis/textures/pd2/none_icon",
            h = self.Collaborator[i]:Panel():h(),
            w = self.Collaborator[i]:Panel():h(),
            x = 5,
            layer = BaseLayer
        })

        if collab_data.steam_id then
            Steam:friend_avatar(1, collab_data.steam_id, function (texture)
                local avatar = texture or nil
                local retrieving_tries = 0
                local max_tries = 10

                while not avatar do
                    if retrieving_tries >= max_tries then
                        log("Max tries reached, pass")
                        break
                    end

                    if self.CollabAvatarLoaded[i] then
                        break
                    end

                    Steam:friend_avatar(1, collab_data.steam_id, function (texture)
                        local avatar = texture or nil

                        if avatar then 
                            self.CollabAvatar[i]:set_image(avatar)
                            self.CollabAvatarLoaded[i] = true
                        end
                    end)

                    retrieving_tries = retrieving_tries + 1
                end

                if avatar then
                    self.CollabAvatar[i]:set_image(avatar)
                    self.CollabAvatarLoaded[i] = true
                end
            end)
        end

        self.CollabName[i] = self.CollabPanel[i]:text({
            text = collab_data.name,
            font = NepgearsyHUDReborn:SetFont(Font),
            font_size = 18,
            color = i == 1 and Color(0.63, 0.58, 0.95) or Color.white,
            layer = BaseLayer,
            vertical = "center"
        })
        self.CollabName[i]:set_left(self.CollabAvatar[i]:right() + 5)

        self.CollabAction[i] = self.CollabPanel[i]:text({
            text = collab_data.action,
            font = "fonts/font_large_mf",
            font_size = 18,
            color = Color(0.5, 0.5, 0.5),
            layer = BaseLayer,
            vertical = "center",
            align = "right",
            x = -5
        })
    end
end

function NepHudMenu:InitChangelog()
    self.ChangelogMenu = self._menu:Holder({
        name = "ChangelogMenu",
        background_color = MenuBgs,
		h = 320,
		offset = 8,
        w = self._menu_panel:w() / 2.1,
        position = function(item)
            item:Panel():set_top(self.CollabMenu:Panel():bottom() + 10)
            item:Panel():set_right(self.MainMenu:Panel():left() - 10)
        end
    })
--[[
    self.ChangelogMenuHeader = self.ChangelogMenu:Divider({
        name = "ChangelogMenuHeader",
        text = managers.localization:text("NepgearsyHUDRebornMenu/Changelog/Header", { version = NepgearsyHUDReborn.Version }),
        localized = false,
        font = Font,
        font_size = 20,
        background_color = Color(0.75, 0, 0, 0),
        highlight_color = Color(0.75, 0, 0, 0),
        text_vertical = "center",
        text_align = "center"
    })

    self.Changelog = self.ChangelogMenu:Divider({
        text = NepgearsyHUDReborn.Changelog,
        font = "fonts/font_large_mf",
        font_size = 16,
        border_color = self.BorderColor,
        highlight_color = Color.transparent,
        border_left = true,
        localized = false,
        on_callback = ClassClbk(self, "open_url", "https://github.com/Nepgearsy/Nepgearsy-HUD-Reborn/commits/master")
    })
--]]

    local notebook = self.ChangelogMenu:NoteBook({
        name = "Changelog",
        auto_height = false,
        h = self.ChangelogMenu:H() - 15
    })

    notebook:AddItemPage("Update 2.7.0 - 24.08.2023, 16:51", SoraHUDChangelog:DrawVersion270(notebook))
    notebook:AddItemPage("Update 2.6.1 - 23.12.2022, 14:38", SoraHUDChangelog:DrawVersion261(notebook))
    notebook:AddItemPage("Update 2.6.0 - 21.12.2022, 17:55", SoraHUDChangelog:DrawVersion260(notebook))
    notebook:AddItemPage("Update 2.5.0 - 04.10.2019, 16:17", SoraHUDChangelog:DrawVersion250(notebook))
    notebook:AddItemPage("Update 2.4.0 - 06.09.2019, 14:08", SoraHUDChangelog:DrawVersion240(notebook))
    notebook:AddItemPage("Update 2.3.2 - 22.08.2019, 19:11", SoraHUDChangelog:DrawVersion232(notebook))
    notebook:AddItemPage("Update 2.3.1 - 06.08.2019, 19:46", SoraHUDChangelog:DrawVersion231(notebook))
    notebook:AddItemPage("Update 2.3.0 - 29.07.2019, 18:52", SoraHUDChangelog:DrawVersion230(notebook))
    notebook:AddItemPage("Update 2.2.0 - 15.07.2019, 21:22", SoraHUDChangelog:DrawVersion220(notebook))
    notebook:AddItemPage("Update 2.1.0 - 09.07.2019, 18:37", SoraHUDChangelog:DrawVersion210(notebook))
    notebook:AddItemPage("Update 2.0.0", SoraHUDChangelog:DrawVersion200(notebook))
end

function NepHudMenu:InitBack()
    self.BackMenu = self._menu:Holder({
        name = "BackMenu",
        background_color = MenuBgs,
		h = 50,
        w = self._menu_panel:w() / 2.1,
        position = function(item)
            item:Panel():set_top(self.ChangelogMenu:Panel():bottom() + 10)
            item:Panel():set_right(self.MainMenu:Panel():left() - 10)
        end
    })

    self.BackButton = self.BackMenu:Button({
        name = "BackButton",
        border_color = self.BorderColor,
        border_left = true,
        text = "NepgearsyHUDRebornMenu/Buttons/Close",
        background_color = MenuBgs,
        highlight_color = HighlightColor,
        position = "Center",
        localized = true,
        text_align = "center",
        text_vertical = "center",
        font_size = 20,
        on_callback = ClassClbk(self._menu, "SetEnabled", false)
    })
end

function NepHudMenu:open_url(url)
    Steam:overlay_activate("url", url)
end

function NepHudMenu:ResetHUD()
    for option_name, _ in pairs(self.HUDOptions) do
        local option = NepgearsyHUDReborn.Options:GetOption(option_name)

        if option then
            self.HUDOptions[option_name]:SetValue(option.default_value)
            self:SetOption(option_name, option.default_value)
        end
    end
end

function NepHudMenu:ResetColors()
    for option_name, _ in pairs(self.Colors) do
        local option = NepgearsyHUDReborn.Options:GetOption(option_name)

        if option then
            self.Colors[option_name]:SetValue(option.default_value)
            self:SetOption(option_name, option.default_value)
        end

        if option_name == "SoraCPColor" then
            self.ColorBG:set_color(option.default_value)
        end
    end
end

function NepHudMenu:background_enable_switch()
    if self.BackgroundStatus == true then
        self:SetBackgroundVis(false)
        self:VisOptionalMenuParts(false)
        self.BackgroundEnabler:SetImage("NepgearsyHUDReborn/Menu/EnableBackground")
        self.BackgroundStatus = false
    else
        self:SetBackgroundVis(true)
        self:VisOptionalMenuParts(true)
        self.BackgroundEnabler:SetImage("NepgearsyHUDReborn/Menu/DisableBackground")
        self.BackgroundStatus = true
    end
end

function NepHudMenu:VisOptionalMenuParts(state)
    if self.CollabMenu and self.ChangelogMenu then
        self.CollabMenu:SetVisible(state)
        self.ChangelogMenu:SetVisible(state)
    end
end

function NepHudMenu:SetOption(option_name, option_value)
    NepgearsyHUDReborn:DebugLog("NAME ; VALUE", tostring(option_name), tostring(option_value))
    NepgearsyHUDReborn.Options:SetValue(option_name, option_value)
    NepgearsyHUDReborn.Options:Save()
end

function NepHudMenu:MainClbk(item)
    if item then
        self:SetOption(item.name, item:Value())

        if item.name == "SoraCPColor" then
            --local new_color = NepgearsyHUDReborn:StringToColor("cpcolor", NepgearsyHUDReborn.Options:GetValue("CPColor"))
            self.ColorBG:set_color(item:Value())
        end

        if item.name == "ForcedLocalization" then
            if NepgearsyHUDReborn:IsLanguageFontLimited(item:Value()) then
                local menu_title = "Warning"
                local menu_message = "This localization may not support fonts beyond font_large_mf."
                local menu_options = {
                    [1] = {
                        text = "OK",
                        is_cancel_button = true,
                    }
                }

                local menu = QuickMenu:new( menu_title, menu_message, menu_options )
                menu:Show()
                self:SetBackgroundVis(false)
                self:VisOptionalMenuParts(false)
            end
        end

        if item.name == "UseDiscordRichPresence" then
            local menu_title = "Restart Required"
            local menu_message = "The game need to close to apply the change."
            local menu_options = {
                [1] = {
                    text = "Close now",
                    callback = ClassClbk(self, "GameClose"),
                },
                [2] = {
                    text = "Close later",
                    is_cancel_button = true,
                },
            }

            local menu = QuickMenu:new( menu_title, menu_message, menu_options )
            menu:Show()
            self:SetBackgroundVis(false)
            self:VisOptionalMenuParts(false)
        end
    end
end

function NepHudMenu:GameClose()
    setup:quit()
end

function NepHudMenu:SkinSetClbk(skin_id)
    if skin_id then
        NepgearsyHUDReborn:DebugLog("Teammate skin id set to: ", skin_id)
        self:SetOption("TeammateSkin", skin_id)
        self.EquippedSkin:SetImage(NepgearsyHUDReborn:GetTeammateSkinById(skin_id))
    end
end

function NepHudMenu:SetHudScaleSpacing(item)
	NepgearsyHUDReborn.Options:SetValue(item:Name(), item:Value())
    if managers.hud and managers.hud.recreate_player_info_hud_pd2 then
        if NepgearsyHUDReborn:IsTeammatePanelWide() then
            managers.gui_data:layout_scaled_fullscreen_workspace(managers.hud._saferect, 0.95, 1)
		    managers.hud:recreate_player_info_hud_pd2()
            return
        end

		managers.gui_data:layout_scaled_fullscreen_workspace(managers.hud._saferect, NepgearsyHUDReborn.Options:GetValue("Scale"), NepgearsyHUDReborn.Options:GetValue("Spacing"))
		managers.hud:recreate_player_info_hud_pd2()
	end
end
