local LibPlayerData = CogWheel:Set("LibPlayerData", 7)
if (not LibPlayerData) then	
	return
end

-- Lua API
local _G = _G
local assert = assert
local date = date
local debugstack = debugstack
local error = error
local pairs = pairs
local select = select
local string_join = string.join
local string_match = string.match
local tonumber = tonumber
local type = type

-- WoW API
local FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local GetAccountExpansionLevel = _G.GetAccountExpansionLevel
local GetExpansionLevel = _G.GetExpansionLevel
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local IsAzeriteItemLocationBankBag = AzeriteUtil.IsAzeriteItemLocationBankBag
local IsXPUserDisabled = _G.IsXPUserDisabled
local UnitClass = _G.UnitClass
local UnitLevel = _G.UnitLevel

-- Library registries
LibPlayerData.embeds = LibPlayerData.embeds or {}
LibPlayerData.frame = LibPlayerData.frame or CreateFrame("Frame")

-- Constant to track current player role
local CURRENT_ROLE

-- Specific per class buffs we wish to see
local _,playerClass = UnitClass("player")

-- List of damage-only classes
local classIsDamage = { 
	HUNTER = true, 
	MAGE = true, 
	ROGUE = true, 
	WARLOCK = true 
}

-- List of classes that can tank
local classCanTank = { 
	DEATHKNIGHT = true, 
	DRUID = true, 
	MONK = true, 
	PALADIN = true, 
	WARRIOR = true 
}

-- Setup our frame for tracking role events
if classIsDamage[playerClass] then
	CURRENT_ROLE = "DAMAGER"
	LibPlayerData.frame:SetScript("OnEvent", nil)
	LibPlayerData.frame:UnregisterAllEvents()
else
	LibPlayerData.frame:SetScript("OnEvent", function(self, event, ...) 
		if (event == "PLAYER_LOGIN") then
			self:UnregisterEvent(event)
			self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
		end
		-- Role name is 7th stat, wowpedia has it wrong. 
		local _, _, _, _, _, _, role = GetSpecializationInfo(GetSpecialization() or 0)
		CURRENT_ROLE = role or "DAMAGER"
	end)
	if IsLoggedIn() then 
		LibPlayerData.frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
		LibPlayerData.frame:GetScript("OnEvent")(LibPlayerData.frame)
	else 
		LibPlayerData.frame:RegisterEvent("PLAYER_LOGIN")
	end 
end 

-- Syntax check 
local check = function(value, num, ...)
	assert(type(num) == "number", ("Bad argument #%.0f to '%s': %s expected, got %s"):format(2, "Check", "number", type(num)))
	for i = 1,select("#", ...) do
		if type(value) == select(i, ...) then 
			return 
		end
	end
	local types = string_join(", ", ...)
	local name = string_match(debugstack(2, 2, 0), ": in function [`<](.-)['>]")
	error(("Bad argument #%.0f to '%s': %s expected, got %s"):format(num, name, types, type(value)), 3)
end

-- Returns the maximum level the account has access to 
LibPlayerData.GetEffectivePlayerMaxLevel = function()
	return MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]
end

-- Returns the maximum level in the current expansion 
LibPlayerData.GetEffectiveExpansionMaxLevel = function()
	return MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
end

-- Is the provided level at the account's maximum level?
LibPlayerData.IsUnitLevelAtEffectiveMaxLevel = function(level)
	return (level >= LibPlayerData.GetEffectivePlayerMaxLevel())
end

-- Is the provided level at the expansions's maximum level?
LibPlayerData.IsUnitLevelAtEffectiveExpansionMaxLevel = function(level)
	return (level >= LibPlayerData.GetEffectiveExpansionMaxLevel())
end 

-- Is the player at the account's maximum level?
LibPlayerData.IsPlayerAtEffectiveMaxLevel = function()
	return LibPlayerData.IsUnitLevelAtEffectiveMaxLevel(UnitLevel("player"))
end

-- Is the player at the expansions's maximum level?
LibPlayerData.IsPlayerAtEffectiveExpansionMaxLevel = function()
	return LibPlayerData.IsUnitLevelAtEffectiveExpansionMaxLevel(UnitLevel("player"))
end

LibPlayerData.PlayerHasAP = function()
	local azeriteItemLocation = FindActiveAzeriteItem()
	if (azeriteItemLocation) and (not IsAzeriteItemLocationBankBag(azeriteItemLocation)) then
		return azeriteItemLocation
	end
end

-- Return whether the player currently can gain XP
LibPlayerData.PlayerHasXP = function(useExpansionMax)
	if IsXPUserDisabled() then 
		return false 
	elseif useExpansionMax then 
		return (not LibPlayerData.IsPlayerAtEffectiveExpansionMaxLevel())
	else
		return (not LibPlayerData.IsPlayerAtEffectiveMaxLevel())
	end 
end

-- Returns whether the player is  tracking a reputation
LibPlayerData.PlayerHasRep = function()
	local name, reaction, min, max, current, factionID = GetWatchedFactionInfo()
	if name then 
		local numFactions = GetNumFactions()
		for i = 1, numFactions do
			local factionName, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(i)
			local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
			if (factionName == name) then
				if standingID then 
					return true
				else 
					return false
				end 
			end
		end
	end 
end

LibPlayerData.PlayerCanTank = function()
	return classCanTank[playerClass]
end

LibPlayerData.PlayerIsDamageOnly = function()
	return classIsDamage[playerClass]
end

LibPlayerData.GetPlayerRole = function()
	return CURRENT_ROLE
end

local embedMethods = {
	GetPlayerRole = true, 
	GetEffectivePlayerMaxLevel = true, 
	GetEffectiveExpansionMaxLevel = true, 
	IsPlayerAtEffectiveMaxLevel = true, 
	IsPlayerAtEffectiveExpansionMaxLevel = true, 
	IsUnitLevelAtEffectiveMaxLevel = true, 
	IsUnitLevelAtEffectiveExpansionMaxLevel = true, 
	PlayerHasAP = true, 
	PlayerHasXP = true, 
	PlayerHasRep = true, 
	PlayerCanTank = true, 
	PlayerIsDamageOnly = true
}

LibPlayerData.Embed = function(self, target)
	for method in pairs(embedMethods) do
		target[method] = self[method]
	end
	LibPlayerData.embeds[target] = true
	return target
end

-- Upgrade existing embeds, if any
for target in pairs(LibPlayerData.embeds) do
	LibPlayerData:Embed(target)
end
