--[[--

The purpose of this file is to supply all the front-end modules 
with static layout data used during the setup phase. 

--]]--

local ADDON, Private = ...
local Layouts = {}
local L = CogWheel("LibLocale"):GetLocale(ADDON)

------------------------------------------------
-- Addon Environment
------------------------------------------------
-- Lua API
local _G = _G
local math_ceil = math.ceil
local math_cos = math.cos
local math_floor = math.floor
local math_max = math.max
local math_pi = math.pi
local math_sin = math.sin
local setmetatable = setmetatable
local tonumber = tonumber
local tostring = tostring

-- WoW API
local GetCVarDefault = _G.GetCVarDefault
local UnitCanAttack = _G.UnitCanAttack
local UnitClassification = _G.UnitClassification
local UnitExists = _G.UnitExists
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitLevel = _G.UnitLevel

-- Private Addon API
local GetAuraFilterFunc = Private.GetAuraFilterFunc
local GetFont = Private.GetFont
local GetMedia = Private.GetMedia
local Colors = Private.Colors

-- Generic single colored texture
local BLANK_TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]

-- Constant to convert degrees to radians
local _D2R = 2*math_pi/360

------------------------------------------------
-- Module Callbacks
------------------------------------------------
local NamePlates_RaidTarget_PostUpdate = function(element, unit)
	local self = element._owner
	if self:IsElementEnabled("Auras") then 
		self.Auras:ForceUpdate()
	else 
		element:ClearAllPoints()
		element:SetPoint(unpack(self.layout.RaidTargetPlace))
	end 
end

local NamePlates_Auras_PostUpdate = function(element, unit, visible)
	local self = element._owner
	if (not self) then 
		return 
	end 

	-- The aura frame misalignment continues, 
	-- so we might have to re-anchor it to the frame on post updates. 
	-- Edit: This does NOT fix it...?
	-- Do we need to hook to something else?
	-- Edit2: Trying to anchor to Health element instead, 
	-- as some blizzard sizing might be the issue(?). 
	element:ClearAllPoints()
	if element.point then 
		element:SetPoint(element.point, element.anchor, element.relPoint, element.offsetX, element.offsetY)
	else 
		element:SetPoint(unpack(self.layout.AuraFramePlace))
	end 

	local raidTarget = self.RaidTarget
	if raidTarget then 
		raidTarget:ClearAllPoints()
		if visible then
			if visible > 3 then 
				raidTarget:SetPoint(unpack(self.layout.RaidTargetPlace_AuraRows))
			elseif visible > 0 then
				raidTarget:SetPoint(unpack(self.layout.RaidTargetPlace_AuraRow))
			else 
				raidTarget:SetPoint(unpack(self.layout.RaidTargetPlace))
			end  
		else
			raidTarget:SetPoint(unpack(self.layout.RaidTargetPlace))
		end
	end 
end

local NamePlate_CastBar_PostUpdate = function(cast, unit)
	if cast.notInterruptible then

		-- Set it to the protected look 
		if (cast.currentStyle ~= "protected") then 
			cast:SetSize(68, 9)
			cast:ClearAllPoints()
			cast:SetPoint("TOP", 0, -26)
			cast:SetStatusBarTexture(GetMedia("cast_bar"))
			cast:SetTexCoord(0, 1, 0, 1)
			cast.Bg:SetSize(68, 9)
			cast.Bg:SetTexture(GetMedia("cast_bar"))
			cast.Bg:SetVertexColor(.15, .15, .15, 1)
			cast.Name:ClearAllPoints()
			cast.Name:SetPoint("TOP",0,-20)
			cast.currentStyle = "protected"
		end 

		-- Color the bar appropriately
		if UnitIsPlayer(unit) then 
			if UnitIsEnemy(unit, "player") then 
				cast:SetStatusBarColor(Colors.quest.red[1], Colors.quest.red[2], Colors.quest.red[3]) 
			else 
				cast:SetStatusBarColor(Colors.quest.green[1], Colors.quest.green[2], Colors.quest.green[3]) 
			end  
		elseif UnitCanAttack("player", unit) then 
			cast:SetStatusBarColor(Colors.quest.red[1], Colors.quest.red[2], Colors.quest.red[3]) 
		else 
			cast:SetStatusBarColor(Colors.quest.green[1], Colors.quest.green[2], Colors.quest.green[3]) 
		end 
	else 
		-- Return to standard castbar styling and position 
		if (cast.currentStyle == "protected") then 
			cast:SetSize(84, 14)
			cast:ClearAllPoints()
			cast:SetPoint("TOP", 0, -20)
			cast:SetStatusBarTexture(GetMedia("nameplate_bar"))
			cast:SetTexCoord(14/256, 242/256, 14/64, 50/64)
			cast.Bg:SetSize(84*256/228, 14*64/36)
			cast.Bg:SetTexture(GetMedia("nameplate_backdrop"))
			cast.Bg:SetVertexColor(1, 1, 1, 1)
			cast.Name:ClearAllPoints()
			cast.Name:SetPoint("TOP",0,-18)
			cast.currentStyle = nil 
		end 

		-- Standard bar coloring
		cast:SetStatusBarColor(Colors.cast[1], Colors.cast[2], Colors.cast[3]) 
	end 
end

------------------------------------------------
-- Module Layouts
------------------------------------------------
-- ActionBars
Layouts.ActionBarMain = {
	Colors = Colors,

	-- Button Tooltips
	-------------------------------------------------------
	UseTooltipSettings = true, 
		TooltipColorNameAsSpellWithUse = true, -- color item name as a spell (not by rarity) when it has a Use effect
		TooltipHideItemLevelWithUse = true, -- hide item level when it has a Use effect 
		TooltipHideBindsWithUse = true, -- hide item bind status when it has a Use effect
		TooltipHideEquipTypeWithUse = false, -- hide item equip location and item type with Use effect
		TooltipHideUniqueWithUse = true, -- hide item unique status when it has a Use effect
		TooltipHideStatsWithUse = true, -- hide item stats when it has a Use effect

	-- Bar Layout
	-------------------------------------------------------
	UseActionBarMenu = true, 

	-- Button Layout
	-------------------------------------------------------
	-- Generic
	ButtonSize = { 64, 64 },
	MaskTexture = GetMedia("actionbutton_circular_mask"),

	-- Icon
	IconSize = { 44, 44 },
	IconPlace = { "CENTER", 0, 0 },

	-- Button Pushed Icon Overlay
	PushedSize = { 44, 44 },
	PushedPlace = { "CENTER", 0, 0 },
	PushedColor = { 1, 1, 1, .15 },
	PushedDrawLayer = { "ARTWORK", 1 },
	PushedBlendMode = "ADD",

	-- Checked (abilities waiting to happen)
	CheckedSize = { 44, 44 },
	CheckedPlace = { "CENTER", 0, 0 },
	CheckedColor = { .9, .8, .1, .3 },
	CheckedDrawLayer = { "ARTWORK", 2 },
	CheckedBlendMode = "ADD",

	-- Auto-Attack Flash
	FlashSize = { 44, 44 },
	FlashPlace = { "CENTER", 0, 0 },
	FlashColor = { 1, 0, 0, .25 },
	FlashTexture = [[Interface\ChatFrame\ChatFrameBackground]],
	FlashDrawLayer = { "ARTWORK", 2 },

	-- Cooldown Count Number
	CooldownCountPlace = { "CENTER", 1, 0 },
	CooldownCountJustifyH = "CENTER",
	CooldownCountJustifyV = "MIDDLE",
	CooldownCountFont = GetFont(16, true),
	CooldownCountShadowOffset = { 0, 0 },
	CooldownCountShadowColor = { 0, 0, 0, 1 },
	CooldownCountColor = { Colors.highlight[1], Colors.highlight[2], Colors.highlight[3], .85 },

	-- Cooldown 
	CooldownSize = { 44, 44 },
	CooldownPlace = { "CENTER", 0, 0 },
	CooldownSwipeTexture = GetMedia("actionbutton_circular_mask"),
	CooldownBlingTexture = GetMedia("blank"),
	CooldownSwipeColor = { 0, 0, 0, .75 },
	CooldownBlingColor = { 0, 0, 0 , 0 },
	ShowCooldownSwipe = true,
	ShowCooldownBling = true,

	-- Charge Cooldown 
	ChargeCooldownSize = { 44, 44 },
	ChargeCooldownPlace = { "CENTER", 0, 0 },
	ChargeCooldownSwipeColor = { 0, 0, 0, .5 },
	ChargeCooldownBlingColor = { 0, 0, 0, 0 },
	ChargeCooldownSwipeTexture = GetMedia("actionbutton_circular_mask"),
	ChargeCooldownBlingTexture = GetMedia("blank"),
	ShowChargeCooldownSwipe = true,
	ShowChargeCooldownBling = false,

	-- Charge Count / Stack Size Text
	CountPlace = { "BOTTOMRIGHT", -3, 3 },
	CountJustifyH = "CENTER",
	CountJustifyV = "BOTTOM",
	CountFont = GetFont(18, true),
	CountShadowOffset = { 0, 0 },
	CountShadowColor = { 0, 0, 0, 1 },
	CountColor = { Colors.normal[1], Colors.normal[2], Colors.normal[3], .85 },
	CountMaxDisplayed = 99,
	CountPostUpdate = ActionButton_StackCount_PostUpdate, 

	-- Keybind Text
	KeybindPlace = { "TOPLEFT", 5, -5 },
	KeybindJustifyH = "CENTER",
	KeybindJustifyV = "BOTTOM",
	KeybindFont = GetFont(15, true),
	KeybindShadowOffset = { 0, 0 },
	KeybindShadowColor = { 0, 0, 0, 1 },
	KeybindColor = { Colors.quest.gray[1], Colors.quest.gray[2], Colors.quest.gray[3], .75 },

	-- Spell Highlights
	UseSpellHighlight = true, 
		SpellHighlightPlace = { "CENTER", 0, 0 },
		SpellHighlightSize = { 64/(122/256), 64/(122/256) },
		SpellHighlightTexture = GetMedia("actionbutton-spellhighlight"),
		SpellHighlightColor = { 255/255, 225/255, 125/255, .75 }, 

	-- Spell AutoCast
	UseSpellAutoCast = true, 
		SpellAutoCastPlace = { "CENTER", 0, 0 },
		SpellAutoCastSize = { 64/(122/256), 64/(122/256) },
		SpellAutoCastAntsTexture = GetMedia("actionbutton-ants-small"),
		SpellAutoCastAntsColor = { Colors.cast[1], Colors.cast[2], Colors.cast[3] },
		SpellAutoCastGlowTexture = GetMedia("actionbutton-ants-small-glow"),
		SpellAutoCastGlowColor = { Colors.cast[1], Colors.cast[2], Colors.cast[3] },

	-- Backdrop 
	UseBackdropTexture = true, 
		BackdropPlace = { "CENTER", 0, 0 },
		BackdropSize = { 64/(122/256), 64/(122/256) },
		BackdropTexture = GetMedia("actionbutton-backdrop"),
		BackdropDrawLayer = { "BACKGROUND", 1 },

	-- Border 
	UseBorderTexture = true, 
		BorderPlace = { "CENTER", 0, 0 },
		BorderSize = { 64/(122/256), 64/(122/256) },
		BorderTexture = GetMedia("actionbutton-border"),
		BorderDrawLayer = { "BORDER", 1 },
		BorderColor = { Colors.ui.stone[1], Colors.ui.stone[2], Colors.ui.stone[3], 1 },

	-- Gloss
	UseGlow = true, 
		GlowPlace = { "CENTER", 0, 0 },
		GlowSize = { 44/(122/256),44/(122/256) },
		GlowTexture = GetMedia("actionbutton-glow-white"),
		GlowDrawLayer = { "ARTWORK", 1 },
		GlowBlendMode = "ADD",
		GlowColor = { 1, 1, 1, .5 },

	-- Floaters
	-------------------------------------------------------
	UseExitButton = true, 
		--ExitButtonPlace = { "CENTER", "Minimap", "TOPLEFT", 14,-36 }, 
		ExitButtonPlace = { "CENTER", "Minimap", "CENTER", -math_cos(45*math_pi/180) * (213/2 + 10), math_sin(45*math_pi/180) * (213/2 + 10) }, 
		ExitButtonSize = { 32, 32 },
		ExitButtonTexturePlace = { "CENTER", 0, 0 }, 
		ExitButtonTextureSize = { 80, 80 }, 
		ExitButtonTexturePath = GetMedia("icon_exit_flight")

}

-- Floaters
Layouts.FloaterHUD = {
	Place = { "CENTER", "UICenter", "CENTER", 190, 0 },
}

-- NamePlates
Layouts.NamePlates = {
	Colors = Colors,

	Size = { 80, 32 }, 
	
	-- HealthBar
	HealthPlace = { "TOP", 0, -2 },
	HealthSize = { 84, 14 },
	HealthBarOrientation = "LEFT",
	HealthTexture = GetMedia("nameplate_bar"),
	HealthTexCoord = { 14/256,(256-14)/256,14/64,(64-14)/64 },
	HealthSparkMap = {
		top = {
			{ keyPercent =   0/256, offset = -16/32 }, 
			{ keyPercent =   4/256, offset = -16/32 }, 
			{ keyPercent =  19/256, offset =   0/32 }, 
			{ keyPercent = 236/256, offset =   0/32 }, 
			{ keyPercent = 256/256, offset = -16/32 }
		},
		bottom = {
			{ keyPercent =   0/256, offset = -16/32 }, 
			{ keyPercent =   4/256, offset = -16/32 }, 
			{ keyPercent =  19/256, offset =   0/32 }, 
			{ keyPercent = 236/256, offset =   0/32 }, 
			{ keyPercent = 256/256, offset = -16/32 }
		}
	},
	HealthColorTapped = true,
	HealthColorDisconnected = true,
	HealthColorClass = true,
	HealthColorCivilian = true,
	HealthColorReaction = true,
	HealthColorHealth = true,
	HealthColorThreat = true,
	HealthColorPlayer = true, 
	HealthThreatFeedbackUnit = "player",
	HealthThreatHideSolo = false,
	HealthFrequent = true,

	-- Health Backdrop
	HealthBackdropPlace = { "CENTER", 0, 0 },
	HealthBackdropSize = { 84*256/(256-28), 14*64/(64-28) },
	HealthBackdropTexture = GetMedia("nameplate_backdrop"),
	HealthBackdropDrawLayer = { "BACKGROUND", -2 },
	HealthBackdropColor = { 1, 1, 1, 1 },

	-- CastBar 
	CastPlace = { "TOP", 0, -20 },
	CastSize = { 84, 14 },
	CastOrientation = "LEFT",
	CastColor = { Colors.cast[1], Colors.cast[2], Colors.cast[3], 1 },
	CastTexture = GetMedia("nameplate_bar"),
	CastTexCoord = { 14/256,(256-14)/256,14/64,(64-14)/64 },
	CastTimeToHoldFailed = .5,
	CastSparkMap = {
		top = {
			{ keyPercent =   0/256, offset = -16/32 }, 
			{ keyPercent =   4/256, offset = -16/32 }, 
			{ keyPercent =  19/256, offset =   0/32 }, 
			{ keyPercent = 236/256, offset =   0/32 }, 
			{ keyPercent = 256/256, offset = -16/32 }
		},
		bottom = {
			{ keyPercent =   0/256, offset = -16/32 }, 
			{ keyPercent =   4/256, offset = -16/32 }, 
			{ keyPercent =  19/256, offset =   0/32 }, 
			{ keyPercent = 236/256, offset =   0/32 }, 
			{ keyPercent = 256/256, offset = -16/32 }
		}
	},
	CastPostUpdate = NamePlate_CastBar_PostUpdate,

	-- CastBar Backdrop
	CastBackdropPlace = { "CENTER", 0, 0 },
	CastBackdropSize = { 84*256/(256-28), 14*64/(64-28) },
	CastBackdropTexture = GetMedia("nameplate_backdrop"),
	CastBackdropDrawLayer = { "BACKGROUND", 0 },
	CastBackdropColor = { 1, 1, 1, 1 },

	-- CastBar Text 
	CastNamePlace = { "TOP", 0, -18 },
	CastNameFont = GetFont(12, true),
	CastNameColor = { Colors.highlight[1], Colors.highlight[2], Colors.highlight[3], .5 },
	CastNameDrawLayer = { "OVERLAY", 1 },
	CastNameJustifyH = "CENTER",
	CastNameJustifyV = "MIDDLE",

	-- CastBar Shield Texture 
	CastShieldPlace = { "CENTER", 0, -1 },
	CastShieldSize = { 124, 69 },
	CastShieldTexture = GetMedia("cast_back_spiked"),
	CastShieldDrawLayer = { "BACKGROUND", -5 },
	CastShieldColor = { Colors.ui.stone[1], Colors.ui.stone[2], Colors.ui.stone[3] },

	-- Threat Glow
	ThreatPlace = { "CENTER", 0, 0 },
	ThreatSize = { 84*256/(256-28), 14*64/(64-28) },
	ThreatTexture = GetMedia("nameplate_glow"),
	ThreatColor = { 1, 1, 1, 1 },
	ThreatDrawLayer = { "BACKGROUND", -3 },
	ThreatHideSolo = true, 

	-- Auras
	AuraFrameSize = { 30*3 + 4*2, 30*2 + 4  }, 
	--AuraFramePlace = { "TOPLEFT", (84 - (30*3 + 4*2))/2, 30*2 + 4 + 10 },
	AuraPoint = "BOTTOMLEFT", AuraAnchor = "Health", AuraRelPoint = "TOPLEFT",
	AuraOffsetX = (84 - (30*3 + 4*2))/2, AuraOffsetY = 10 + 4,
	AuraIconPlace = { "CENTER", 0, 0 },
	AuraIconSize = { 30 - 6, 30 - 6 },
	AuraIconTexCoord = { 5/64, 59/64, 5/64, 59/64 }, -- aura icon tex coords
	AuraCountPlace = { "BOTTOMRIGHT", 9, -6 },
	AuraCountFont = GetFont(12, true),
	AuraCountColor = { Colors.normal[1], Colors.normal[2], Colors.normal[3], .85 },
	AuraTimePlace = { "TOPLEFT", -6, 6 },
	AuraTimeFont = GetFont(11, true),
	AuraBorderFramePlace = { "CENTER", 0, 0 }, 
	AuraBorderFrameSize = { 30 + 10, 30 + 10 },
	AuraBorderBackdrop = { edgeFile = GetMedia("aura_border"), edgeSize = 12 },
	AuraBorderBackdropColor = { 0, 0, 0, 0 },
	AuraBorderBackdropBorderColor = { Colors.ui.stone[1] *.3, Colors.ui.stone[2] *.3, Colors.ui.stone[3] *.3 },
	PostUpdateAura = NamePlates_Auras_PostUpdate,
	AuraProperties = {
		growthX = "LEFT", 
		growthY = "UP", 
		spacingH = 4, 
		spacingV = 4, 
		auraSize = 30, auraWidth = nil, auraHeight = nil, 
		maxVisible = 6, maxBuffs = nil, maxDebuffs = nil, 
		filter = nil, filterBuffs = "PLAYER HELPFUL", filterDebuffs = "PLAYER HARMFUL", 
		func = nil, funcBuffs = GetAuraFilterFunc("nameplate"), funcDebuffs = GetAuraFilterFunc("nameplate"), 
		debuffsFirst = false, 
		disableMouse = true, 
		showSpirals = false, 
		showDurations = true, 
		showLongDurations = false,
		tooltipDefaultPosition = false, 
		tooltipPoint = "BOTTOMLEFT",
		tooltipAnchor = nil,
		tooltipRelPoint = "TOPLEFT",
		tooltipOffsetX = -8,
		tooltipOffsetY = -16
	},

	-- Raid Target Icon
	RaidTargetPlace = { "TOP", 0, 44 }, -- no auras
	RaidTargetPlace_AuraRow = { "TOP", 0, 80 }, -- auras, 1 row
	RaidTargetPlace_AuraRows = { "TOP", 0, 112 }, -- auras, 2 rows
	RaidTargetSize = { 64, 64 },
	RaidTargetTexture = GetMedia("raid_target_icons"),
	RaidTargetDrawLayer = { "ARTWORK", 0 },
	PostUpdateRaidTarget = NamePlates_RaidTarget_PostUpdate,

	-- CVars adjusted at startup
	SetConsoleVars = {
		-- Because we want friendly NPC nameplates
		-- We're toning them down a lot as it is, 
		-- but we still prefer to have them visible, 
		-- and not the fugly super sized names we get otherwise.
		--nameplateShowFriendlyNPCs = 1, -- Don't enforce this

		-- Insets at the top and bottom of the screen 
		-- which the target nameplate will be kept away from. 
		-- Used to avoid the target plate being overlapped 
		-- by the target frame or actionbars and keep it in view.
		nameplateLargeTopInset = false, -- default .1
		nameplateOtherTopInset = .1, -- default .08
		nameplateLargeBottomInset = .02, -- default .15
		nameplateOtherBottomInset = .02, -- default .1
		nameplateClassResourceTopInset = 0,
	
		-- Nameplate scale
		nameplateMinScale = false, -- .8
		nameplateMaxScale = 1, 
		nameplateLargerScale = 1, -- Scale modifier for large plates, used for important monsters
		nameplateGlobalScale = 1,
		NamePlateHorizontalScale = 1,
		NamePlateVerticalScale = 1,
	
		-- Alpha defaults (these are enforced to other values by the back-end now)
		nameplateMaxAlpha = false, 
		nameplateMinAlphaDistance = false, 
		nameplateMinAlpha = false,
		nameplateMaxAlphaDistance = false,
		nameplateOccludedAlphaMult = false, 
		nameplateSelectedAlpha = false, 
	
		-- The minimum distance from the camera plates will reach their minimum scale and alpha
		nameplateMinScaleDistance = false, 
		
		-- The maximum distance from the camera where plates will still have max scale and alpha
		nameplateMaxScaleDistance = 20, -- 10
	
		-- Show nameplates above heads or at the base (0 or 2,
		nameplateOtherAtBase = 0,
	
		-- Scale and Alpha of the selected nameplate (current target,
		nameplateSelectedScale = 1, -- default 1.2
	
		-- The max distance to show nameplates.
		nameplateMaxDistance = false, -- 20 is classic upper limit, 60 is BfA default
	
		-- The max distance to show the target nameplate when the target is behind the camera.
		nameplateTargetBehindMaxDistance = 15 -- default 15
	}

}

------------------------------------------------
-- Private Addon API
------------------------------------------------
-- Retrieve layout
Private.GetLayout = function(moduleName) return Layouts[moduleName] end 
