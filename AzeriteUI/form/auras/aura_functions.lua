local ADDON = ...
local Auras = CogWheel("LibDB"):GetDatabase(ADDON..": Auras")
local Functions = CogWheel("LibDB"):GetDatabase(ADDON..": Functions")

-- Lua API
local _G = _G
local bit_band = bit.band
local string_match = string.match

-- WoW APi
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsLoggedIn = _G.IsLoggedIn
local UnitCanAttack = _G.UnitCanAttack
local UnitIsFriend = _G.UnitIsFriend
local UnitPlayerControlled = _G.UnitPlayerControlled

-- List of units we all count as the player
local unitIsPlayer = { player = true, 	pet = true, vehicle = true }

-- Shortcuts for convenience
local auraList = Auras.auraList
local filterFlags = Auras.filterFlags

local CURRENT_ROLE

if Functions.PlayerIsDamageOnly() then
	CURRENT_ROLE = "DAMAGER"
else
	local Updater = CreateFrame("Frame")
	Updater:SetScript("OnEvent", function(self, event, ...) 
		if (event == "PLAYER_LOGIN") then
			self:UnregisterEvent(event)
			self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
		end
		CURRENT_ROLE = Functions.GetPlayerRole()
	end)
	if IsLoggedIn() then 
		Updater:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
		Updater:GetScript("OnEvent")(Updater)
	else 
		Updater:RegisterEvent("PLAYER_LOGIN")
	end 
end 

local filters = {}

filters.default = function(element, button, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)
	local auraFlags = auraList[spellID]
	return (not auraFlags) or (bit_band(auraFlags, filterFlags.Always) ~= 0) or (bit_band(auraFlags, filterFlags.Never) == 0)
end

filters.player = function(element, button, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)

	local auraFlags = auraList[spellID]
	if auraFlags then

		-- Auras cast by the player
		if (bit_band(auraFlags, filterFlags.ByPlayer) ~= 0) then 
			return unitIsPlayer[unitCaster] 

		-- Auras visible on friendly targets (including ourself)
		elseif (bit_band(auraFlags, filterFlags.OnFriend) ~= 0) then 
			return UnitIsFriend(unit, "player") and UnitPlayerControlled(unit)

		-- Auras visible on the player frame (with the exception of the player unit in group frames)
		elseif (bit_band(auraFlags, filterFlags.OnPlayer) ~= 0) then
			return (unit == "player") and (not element._owner.unitGroup)

		-- Show remaining auras that hasn't specifically been hidden
		else 
			return (bit_band(auraFlags, filterFlags.Never) == 0)
		end 

	else
		-- Show auras from npc's
		if (not unitCaster) or (UnitCanAttack("player", unitCaster) and (not UnitPlayerControlled(unitCaster))) then 
			return ((not isBuff) and (duration < 3600))
		else 
			-- Show any auras cast by bosses or the player's vehicle
			return isBossDebuff or (unitCaster == "vehicle")
		end 
	end

end

filters.target = function(element, isBuff, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)
	local auraFlags = auraList[spellID]
	if auraFlags then

		-- Auras cast by the player
		if (bit_band(auraFlags, filterFlags.ByPlayer) ~= 0) then 
			return unitIsPlayer[unitCaster] 
		
		-- Auras visible on friendly targets (including ourself)
		elseif (bit_band(auraFlags, filterFlags.OnFriend) ~= 0) then 
			return UnitIsFriend(unit, "player") and UnitPlayerControlled(unit)
		
		-- Auras visible on the player frame (with the exception of the player unit in group frames)
		elseif (bit_band(auraFlags, filterFlags.OnPlayer) ~= 0) then
			return (unit == "player") and (not element._owner.unitGroup)
		
		-- Auras visible when the player is a tank
		elseif (bit_band(auraFlags, filterFlags.PlayerIsTank) ~= 0) then 
			return (CURRENT_ROLE == "TANK")

		-- Show remaining auras that hasn't specifically been hidden
		else 
			return (bit_band(auraFlags, filterFlags.Never) == 0)
		end 

	-- Show any auras cast by bosses or the player's vehicle
	elseif (isBossDebuff or (unitCaster == "vehicle")) then 
		return true

	-- Hide unknown debuffs from unknown sources  
	elseif (not isBuff) and (not unitCaster) then 
		return false

	-- Show unknown self-buffs on hostile targets
	elseif (UnitCanAttack("player", unit) and (not UnitPlayerControlled(unit))) then 
		return (not unitCaster or (unitCaster == unit)) or (isBuff and (duration < 3600))

	-- Show unknown auras not falling into any of the above categories
	else 
		return (not unitCaster)
	end
end

filters.focus = function(element, isBuff, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)
	return filters.target(element, button, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)
end

filters.targettarget = function(element, isBuff, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)
	return filters.target(element, button, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)
end

filters.party = function(element, isBuff, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)
	local auraFlags = auraList[spellID]
	if auraFlags then
		return (bit_band(auraFlags, filterFlags.OnFriend) ~= 0)
	else
		return isBossDebuff
	end
end

filters.boss = function(element, isBuff, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)
	local auraFlags = auraList[spellID]
	if auraFlags then
		if (bit_band(auraFlags, filterFlags.ByPlayer) ~= 0) then 
			return unitIsPlayer[unitCaster] 
		else 
			return (bit_band(auraFlags, filterFlags.OnEnemy) ~= 0)
		end 
	else
		return isBossDebuff
	end
end

filters.arena = function(element, isBuff, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)
	local auraFlags = auraList[spellID]
	if auraFlags then
		if (bit_band(auraFlags, filterFlags.ByPlayer) ~= 0) then 
			return unitIsPlayer[unitCaster] 
		else 
			return (bit_band(auraFlags, filterFlags.OnEnemy) ~= 0)
		end 
	end
end

Auras.FilterFuncs = setmetatable(filters, { __index = function(t,k) return rawget(t,k) or rawget(t, "default") end})

Auras.GetFilterFunc = function(self, unit)
	return self.FilterFuncs[unit or "default"]
end
