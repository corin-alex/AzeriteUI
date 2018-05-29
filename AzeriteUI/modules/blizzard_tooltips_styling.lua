local ADDON = ...
local AzeriteUI = CogWheel("CogModule"):GetModule("AzeriteUI")
if (not AzeriteUI) then 
	return 
end

local BlizzardTooltipStyling = AzeriteUI:NewModule("BlizzardTooltipStyling", "CogEvent", "CogDB", "CogTooltip")
local Colors = CogWheel("CogDB"):GetDatabase("AzeriteUI: Colors")

-- Lua API
local _G = _G

-- Current player level
local LEVEL = UnitLevel("player") 



-- Utility Functions
-----------------------------------------------------------------

-- Returns the correct difficulty color compared to the player
local getDifficultyColorByLevel = function(level)
	level = level - LEVEL
	if (level > 4) then
		return Colors.quest.red.colorCode
	elseif (level > 2) then
		return Colors.quest.orange.colorCode
	elseif (level >= -2) then
		return Colors.quest.yellow.colorCode
	elseif (level >= -GetQuestGreenRange()) then
		return Colors.quest.green.colorCode
	else
		return Colors.quest.gray.colorCode
	end
end

-- Proxy function to get media from our local media folder
local getPath = function(fileName)
	return ([[Interface\AddOns\%s\media\%s.tga]]):format(ADDON, fileName)
end 


-- Blizzard and other tooltips we'll style
local blizzardTips = {
	"GameTooltip", -- raise a hand if you hate this one
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ShoppingTooltip3",
	"ItemRefTooltip",
	"ItemRefShoppingTooltip1",
	"ItemRefShoppingTooltip2",
	"ItemRefShoppingTooltip3",
	"WorldMapTooltip",
	"WorldMapCompareTooltip1",
	"WorldMapCompareTooltip2",
	"WorldMapCompareTooltip3",
	"DatatextTooltip",
	"VengeanceTooltip",
	"hbGameTooltip",
	"EventTraceTooltip",
	"FrameStackTooltip",
	"FloatingGarrisonFollowerTooltip",
	"PetBattlePrimaryUnitTooltip",
	"PetBattlePrimaryAbilityTooltip",
	"QueueStatusFrame"
} 

-- Blizzard dropdowns we'll style
local blizzardDrops = {
	"ChatMenu",
	"EmoteMenu",
	"FriendsTooltip",
	"LanguageMenu",
	"VoiceMacroMenu"
}

BlizzardTooltipStyling.OnEnable = function(self)
end 

BlizzardTooltipStyling.OnInit = function(self)
end 