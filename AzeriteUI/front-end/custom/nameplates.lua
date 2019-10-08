local ADDON,Private = ...
local Core = CogWheel("LibModule"):GetModule(ADDON)
if (not Core) then 
	return 
end
local Module = Core:NewModule("NamePlates", "LibEvent", "LibNamePlate", "LibDB", "LibMenu", "LibFrame")
Module:SetIncompatible("Kui_Nameplates")
Module:SetIncompatible("NeatPlates")
Module:SetIncompatible("Plater")
Module:SetIncompatible("SimplePlates")
Module:SetIncompatible("TidyPlates")
Module:SetIncompatible("TidyPlates_ThreatPlates")
Module:SetIncompatible("TidyPlatesContinued")

-- Lua API
local _G = _G

-- WoW API
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance 
local SetCVar = SetCVar
local SetNamePlateEnemyClickThrough = C_NamePlate.SetNamePlateEnemyClickThrough
local SetNamePlateFriendlyClickThrough = C_NamePlate.SetNamePlateFriendlyClickThrough
local SetNamePlateSelfClickThrough = C_NamePlate.SetNamePlateSelfClickThrough

-- Private addon API
local GetConfig = Private.GetConfig
local GetDefaults = Private.GetDefaults
local GetLayout = Private.GetLayout
local GetFont = Private.GetFont
local GetMedia = Private.GetMedia
local Colors = Private.Colors

-- Local cache of the nameplates, for easy access to some methods
local Plates = {} 

-----------------------------------------------------------
-- Callbacks
-----------------------------------------------------------
local PostCreateAuraButton = function(element, button)
	local layout = element._owner.layout

	button.Icon:SetTexCoord(unpack(layout.AuraIconTexCoord))
	button.Icon:SetSize(unpack(layout.AuraIconSize))
	button.Icon:ClearAllPoints()
	button.Icon:SetPoint(unpack(layout.AuraIconPlace))

	button.Count:SetFontObject(layout.AuraCountFont)
	button.Count:SetJustifyH("CENTER")
	button.Count:SetJustifyV("MIDDLE")
	button.Count:ClearAllPoints()
	button.Count:SetPoint(unpack(layout.AuraCountPlace))
	if layout.AuraCountColor then 
		button.Count:SetTextColor(unpack(layout.AuraCountColor))
	end 

	button.Time:SetFontObject(layout.AuraTimeFont)
	button.Time:ClearAllPoints()
	button.Time:SetPoint(unpack(layout.AuraTimePlace))

	local layer, level = button.Icon:GetDrawLayer()

	button.Darken = button.Darken or button:CreateTexture()
	button.Darken:SetDrawLayer(layer, level + 1)
	button.Darken:SetSize(button.Icon:GetSize())
	button.Darken:SetPoint("CENTER", 0, 0)
	button.Darken:SetColorTexture(0, 0, 0, .25)

	button.Overlay:SetFrameLevel(button:GetFrameLevel() + 10)
	button.Overlay:ClearAllPoints()
	button.Overlay:SetPoint("CENTER", 0, 0)
	button.Overlay:SetSize(button.Icon:GetSize())

	button.Border = button.Border or button.Overlay:CreateFrame("Frame", nil, button.Overlay)
	button.Border:SetFrameLevel(button.Overlay:GetFrameLevel() - 5)
	button.Border:ClearAllPoints()
	button.Border:SetPoint(unpack(layout.AuraBorderFramePlace))
	button.Border:SetSize(unpack(layout.AuraBorderFrameSize))
	button.Border:SetBackdrop(layout.AuraBorderBackdrop)
	button.Border:SetBackdropColor(unpack(layout.AuraBorderBackdropColor))
	button.Border:SetBackdropBorderColor(unpack(layout.AuraBorderBackdropBorderColor))
end

local PostUpdateAuraButton = function(element, button)
	local colors = element._owner.colors
	local layout = element._owner.layout
	if (not button) or (not button:IsVisible()) or (not button.unit) or (not UnitExists(button.unit)) then 
		local color = layout.AuraBorderBackdropBorderColor
		if color then 
			button.Border:SetBackdropBorderColor(color[1], color[2], color[3])
		end 
		return 
	end 
	if UnitIsFriend("player", button.unit) then 
		if button.isBuff then 
			local color = layout.AuraBorderBackdropBorderColor
			if color then 
				button.Border:SetBackdropBorderColor(color[1], color[2], color[3])
			end 
		else
			local color = colors.debuff[button.debuffType or "none"] or layout.AuraBorderBackdropBorderColor
			if color then 
				button.Border:SetBackdropBorderColor(color[1], color[2], color[3])
			end 
		end
	else 
		if button.isStealable then 
			local color = colors.power.ARCANE_CHARGES or layout.AuraBorderBackdropBorderColor
			if color then 
				button.Border:SetBackdropBorderColor(color[1], color[2], color[3])
			end 
		elseif button.isBuff then 
			local color = colors.quest.green or layout.AuraBorderBackdropBorderColor
			if color then 
				button.Border:SetBackdropBorderColor(color[1], color[2], color[3])
			end 
		else
			local color = colors.debuff.none or layout.AuraBorderBackdropBorderColor
			if color then 
				button.Border:SetBackdropBorderColor(color[1], color[2], color[3])
			end 
		end
	end 
end

local PostUpdateOrientations = function(plate)
	if plate.isYou then 
		if (not plate.Health.isYou) then 
			plate.Health:SetOrientation("RIGHT")
			plate.Health.isYou = true
		end 
		if (not plate.Cast.isYou) then 
			plate.Cast:SetOrientation("RIGHT")
			plate.Cast.isYou = true
		end 
	else 
		if (plate.Health.isYou) then 
			plate.Health:SetOrientation("LEFT")
			plate.Health.isYou = nil
		end 
		if (plate.Cast.isYou) then 
			plate.Cast:SetOrientation("LEFT")
			plate.Cast.isYou = nil
		end 
	end 
end

-- Library Updates
-- *will be called by the library at certain times
-----------------------------------------------------------------
-- Called on PLAYER_ENTERING_WORLD by the library, 
-- but before the library calls its own updates.
Module.PreUpdateNamePlateOptions = function(self)

	--[[
	local _, instanceType = IsInInstance()
	if (instanceType == "none") then
		SetCVar("nameplateMaxDistance", 30)
	else
		SetCVar("nameplateMaxDistance", 45)
	end

	local _, instanceType = IsInInstance()
	if (instanceType == "none") then
		if self.layout.SetConsoleVars then 
			local value = self.layout.SetConsoleVars.nameplateMaxDistance or GetCVarDefault("nameplateMaxDistance")
			SetCVar("nameplateMaxDistance", value)
		else 
			SetCVar("nameplateMaxDistance", 30)
		end 
	else
		SetCVar("nameplateMaxDistance", 45)
	end
	]]

	-- If these are enabled the GameTooltip will become protected, 
	-- and all sort of taints and bugs will occur.
	-- This happens on specs that can dispel when hovering over nameplate auras.
	-- We create our own auras anyway, so we don't need these. 
	SetCVar("nameplateShowDebuffsOnFriendly", 0) 
		
end 

-- Called when certain bindable blizzard settings change, 
-- or when the VARIABLES_LOADED event fires. 
Module.PostUpdateNamePlateOptions = function(self, isInInstace)
	local layout = self.layout

	-- Make an extra call to the preupdate
	self:PreUpdateNamePlateOptions()

	if layout.SetConsoleVars then 
		for name,value in pairs(layout.SetConsoleVars) do 
			SetCVar(name, value or GetCVarDefault(name))
		end 
	end 

	-- Setting the base size involves changing the size of secure unit buttons, 
	-- but since we're using our out of combat wrapper, we should be safe.
	-- Default size 110, 45
	C_NamePlate.SetNamePlateFriendlySize(unpack(layout.Size))
	C_NamePlate.SetNamePlateEnemySize(unpack(layout.Size))
	C_NamePlate.SetNamePlateSelfSize(unpack(layout.Size))

	--NamePlateDriverFrame.UpdateNamePlateOptions = function() end
end

-- Called after a nameplate is created.
-- This is where we create our own custom elements.
Module.PostCreateNamePlate = function(self, plate, baseFrame)
	local db = self.db
	local layout = self.layout
	
	plate:SetSize(unpack(layout.Size))
	plate.colors = layout.Colors or plate.colors
	plate.layout = layout

	-- Health bar
	local health = plate:CreateStatusBar()
	health:Hide()
	health:SetSize(unpack(layout.HealthSize))
	health:SetPoint(unpack(layout.HealthPlace))
	health:SetStatusBarTexture(layout.HealthTexture)
	health:SetOrientation(layout.HealthBarOrientation)
	health:SetSmoothingFrequency(.1)
	health:SetSparkMap(layout.HealthSparkMap)
	health:SetTexCoord(unpack(layout.HealthTexCoord))
	health.absorbThreshold = layout.AbsorbThreshold
	health.colorTapped = layout.HealthColorTapped
	health.colorDisconnected = layout.HealthColorDisconnected
	health.colorClass = layout.HealthColorClass
	health.colorCivilian = layout.HealthColorCivilian
	health.colorReaction = layout.HealthColorReaction
	health.colorThreat = layout.HealthColorThreat
	health.colorHealth = layout.HealthColorHealth
	health.colorPlayer = layout.HealthColorPlayer
	health.frequent = layout.HealthFrequent
	health.threatFeedbackUnit = layout.HealthThreatFeedbackUnit
	health.threatHideSolo = layout.HealthThreatHideSolo
	plate.Health = health

	local healthBg = health:CreateTexture()
	healthBg:SetPoint(unpack(layout.HealthBackdropPlace))
	healthBg:SetSize(unpack(layout.HealthBackdropSize))
	healthBg:SetDrawLayer(unpack(layout.HealthBackdropDrawLayer))
	healthBg:SetTexture(layout.HealthBackdropTexture)
	healthBg:SetVertexColor(unpack(layout.HealthBackdropColor))
	plate.Health.Bg = healthBg

	local cast = (plate.Health or plate):CreateStatusBar()
	cast:SetSize(unpack(layout.CastSize))
	cast:SetPoint(unpack(layout.CastPlace))
	cast:SetStatusBarTexture(layout.CastTexture)
	cast:SetOrientation(layout.CastOrientation)
	cast:SetSmoothingFrequency(.1)
	cast:SetSparkMap(CastSparkMap)
	cast:SetTexCoord(unpack(layout.CastTexCoord))
	cast.timeToHold = layout.CastTimeToHoldFailed
	plate.Cast = cast
	plate.Cast.PostUpdate = layout.CastPostUpdate

	local castBg = cast:CreateTexture()
	castBg:SetPoint(unpack(layout.CastBackdropPlace))
	castBg:SetSize(unpack(layout.CastBackdropSize))
	castBg:SetDrawLayer(unpack(layout.CastBackdropDrawLayer))
	castBg:SetTexture(layout.CastBackdropTexture)
	castBg:SetVertexColor(unpack(layout.CastBackdropColor))
	plate.Cast.Bg = castBg

	local castName = cast:CreateFontString()
	castName:SetPoint(unpack(layout.CastNamePlace))
	castName:SetDrawLayer(unpack(layout.CastNameDrawLayer))
	castName:SetFontObject(layout.CastNameFont)
	castName:SetTextColor(unpack(layout.CastNameColor))
	castName:SetJustifyH(layout.CastNameJustifyH)
	castName:SetJustifyV(layout.CastNameJustifyV)
	plate.Cast.Name = castName

	local castShield = cast:CreateTexture()
	castShield:SetPoint(unpack(layout.CastShieldPlace))
	castShield:SetSize(unpack(layout.CastShieldSize))
	castShield:SetTexture(layout.CastShieldTexture) 
	castShield:SetDrawLayer(unpack(layout.CastShieldDrawLayer))
	castShield:SetVertexColor(unpack(layout.CastShieldColor))
	plate.Cast.Shield = castShield

	local threat = (plate.Health or plate):CreateTexture()
	threat:SetPoint(unpack(layout.ThreatPlace))
	threat:SetSize(unpack(layout.ThreatSize))
	threat:SetTexture(layout.ThreatTexture)
	threat:SetDrawLayer(unpack(layout.ThreatDrawLayer))
	threat:SetVertexColor(unpack(layout.ThreatColor))
	threat.hideSolo = layout.ThreatHideSolo
	threat.feedbackUnit = "player"
	plate.Threat = threat

	local raidTarget = baseFrame:CreateTexture()
	raidTarget:SetPoint(unpack(layout.RaidTargetPlace))
	raidTarget:SetSize(unpack(layout.RaidTargetSize))
	raidTarget:SetDrawLayer(unpack(layout.RaidTargetDrawLayer))
	raidTarget:SetTexture(layout.RaidTargetTexture)
	raidTarget:SetScale(plate:GetScale())
	hooksecurefunc(plate, "SetScale", function(plate,scale) raidTarget:SetScale(scale) end)
	plate.RaidTarget = raidTarget
	plate.RaidTarget.PostUpdate = layout.PostUpdateRaidTarget

	local auras = plate:CreateFrame("Frame")
	auras:SetSize(unpack(layout.AuraFrameSize))
	auras.point = layout.AuraPoint
	auras.anchor = plate[layout.AuraAnchor] or plate
	auras.relPoint = layout.AuraRelPoint
	auras.offsetX = layout.AuraOffsetX
	auras.offsetY = layout.AuraOffsetY
	auras:ClearAllPoints()
	auras:SetPoint(auras.point, auras.anchor, auras.relPoint, auras.offsetX, auras.offsetY)
	for property,value in pairs(layout.AuraProperties) do 
		auras[property] = value
	end
	plate.Auras = auras
	plate.Auras.PostUpdate = layout.PostUpdateAura
	plate.Auras.PostCreateButton = PostCreateAuraButton -- post creation styling
	plate.Auras.PostUpdateButton = PostUpdateAuraButton -- post updates when something changes (even timers)

	if (not db.enableAuras) then 
		plate:DisableElement("Auras")
	end 

	plate.PostUpdate = PostUpdateOrientations

	-- The library does this too, but isn't exposing it to us.
	Plates[plate] = baseFrame
end

Module.PostUpdateSettings = function(self)
	local db = self.db
	for plate, baseFrame in pairs(Plates) do 
		if db.enableAuras then 
			plate:EnableElement("Auras")
			plate.Auras:ForceUpdate()
			plate.RaidTarget:ForceUpdate()
		else 
			plate:DisableElement("Auras")
			plate.RaidTarget:ForceUpdate()
		end 
	end
end

Module.UpdateCVars = function(self, event, ...)
	if InCombatLockdown() then 
		return self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	end 
	SetNamePlateEnemyClickThrough(self.db.clickThroughEnemies)
	SetNamePlateFriendlyClickThrough(self.db.clickThroughFriends)
	SetNamePlateSelfClickThrough(self.db.clickThroughSelf)
end

Module.OnEvent = function(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then 
		self:UpdateCVars()
	elseif (event == "PLAYER_REGEN_ENABLED") then 
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		self:UpdateCVars()
	end 
end

Module.OnInit = function(self)
	self.db = GetConfig(self:GetName())
	self.layout = GetLayout(self:GetName())
	self:GetSecureUpdater()
end 

Module.OnEnable = function(self)
	self:StartNamePlateEngine()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
end 

Module.GetSecureUpdater = function(self)
	if (not self.proxyUpdater) then 
		local proxy = self:CreateFrame("Frame", nil, "UICenter", "SecureHandlerAttributeTemplate")
		proxy.PostUpdateSettings = function() self:PostUpdateSettings() end
		proxy.UpdateCVars = function() self:UpdateCVars() end
		for key,value in pairs(self.db) do 
			proxy:SetAttribute(key,value)
		end 
		proxy:SetAttribute("_onattributechanged", [=[
			if name then 
				name = string.lower(name); 
			end 
			if (name == "change-enableauras") then 
				self:SetAttribute("enableAuras", value); 
				self:CallMethod("PostUpdateSettings"); 
	
			elseif (name == "change-clickthroughenemies") then
				self:SetAttribute("clickThroughEnemies", value); 
				self:CallMethod("UpdateCVars"); 
	
			elseif (name == "change-clickthroughfriends") then 
				self:SetAttribute("clickThroughFriends", value); 
				self:CallMethod("UpdateCVars"); 
	
			elseif (name == "change-clickthroughself") then 
				self:SetAttribute("clickThroughSelf", value); 
				self:CallMethod("UpdateCVars"); 
	
			end 
		]=])
		self.proxyUpdater = proxy
	end 
	return self.proxyUpdater
end
