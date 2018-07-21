local ADDON = ...

local AzeriteUI = CogWheel("LibModule"):GetModule("AzeriteUI")
if (not AzeriteUI) then 
	return 
end


local UnitFrameArena = AzeriteUI:NewModule("UnitFrameArena", "LibDB", "LibEvent", "LibUnitFrame", "LibStatusBar")
local Colors = CogWheel("LibDB"):GetDatabase("AzeriteUI: Colors")
local WhiteList = CogWheel("LibDB"):GetDatabase("AzeriteUI: Auras").WhiteList

-- Lua API
local _G = _G
local unpack = unpack

-- WoW Strings
local DEAD = _G.DEAD


-- Utility Functions
-----------------------------------------------------------------

-- Proxy function to get media from our local media folder
local getPath = function(fileName)
	return ([[Interface\AddOns\%s\media\%s.tga]]):format(ADDON, fileName)
end 


-- Callbacks
-----------------------------------------------------------------

-- Number abbreviations
local OverrideValue = function(element, unit, min, max, disconnected, dead, tapped)
	if (min >= 1e8) then 		element.Value:SetFormattedText("%dm", min/1e6) 		-- 100m, 1000m, 2300m, etc
	elseif (min >= 1e6) then 	element.Value:SetFormattedText("%.1fm", min/1e6) 	-- 1.0m - 99.9m 
	elseif (min >= 1e5) then 	element.Value:SetFormattedText("%dk", min/1e3) 		-- 100k - 999k
	elseif (min >= 1e3) then 	element.Value:SetFormattedText("%.1fk", min/1e3) 	-- 1.0k - 99.9k
	elseif (min > 0) then 		element.Value:SetText(min) 							-- 1 - 999
	else 						element.Value:SetText("")
	end 
end 

local OverrideHealthValue = function(element, unit, min, max, disconnected, dead, tapped)
	if dead then 
		return element.Value:SetText(DEAD)
	else 
		return OverrideValue(element, unit, min, max, disconnected, dead, tapped)
	end 
end 


local BuffFilter = function(element, button, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)

	-- ALways whitelisted auras, boss debuffs and stealable for mages
	if WhiteList[spellId] or isBossDebuff or (PlayerClass == "MAGE" and isStealable) then 
		return true 
	end 

	-- Try to hide non-player auras outdoors
	if (not isOwnedByPlayer) and (not IsInInstance()) then 
		return 
	end 

	-- Hide static and very long ones
	if (not duration) or (duration > 60) then 
		return 
	end 

	-- show our own short ones
	if (isOwnedByPlayer and duration and (duration > 0) and (duration < 60)) then 
		return true
	end 
	
	
end 

local DebuffFilter = function(element, button, unit, isOwnedByPlayer, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3)

	if WhiteList[spellId] or isBossDebuff then 
		return true 
	end 

	-- Try to hide non-player auras outdoors
	if (not isOwnedByPlayer) and (not IsInInstance()) then 
		return 
	end 

	-- Hide static and very long ones
	if (not duration) or (duration > 60) then 
		return 
	end 

	-- show our own short ones
	if (isOwnedByPlayer and duration and (duration > 0) and (duration < 60)) then 
		return true
	end 

end 

local PostCreateAuraButton = function(element, button)
	
	-- Downscale factor of the border backdrop
	local sizeMod = 2/4


	-- Restyle original elements
	----------------------------------------------------

	-- Spell icon
	-- We inset the icon, so the border aligns with the button edge
	local icon = button.Icon
	icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
	icon:ClearAllPoints()
	icon:SetPoint("TOPLEFT", 9*sizeMod, -9*sizeMod)
	icon:SetPoint("BOTTOMRIGHT", -9*sizeMod, 9*sizeMod)

	-- Aura stacks
	local count = button.Count
	count:SetFontObject(AzeriteFont11_Outline)
	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT", 2, -2)

	-- Aura time remaining
	local time = button.Time
	time:SetFontObject(AzeriteFont14_Outline)
	--time:ClearAllPoints()
	--time:SetPoint("CENTER", 0, 0)


	-- Create custom elements
	----------------------------------------------------

	-- Retrieve the icon drawlayer, and put our darkener right above
	local iconDrawLayer, iconDrawLevel = icon:GetDrawLayer()

	-- Darken the icons slightly, don't want them too bright
	local darken = button:CreateTexture()
	darken:SetDrawLayer(iconDrawLayer, iconDrawLevel + 1)
	darken:SetSize(icon:GetSize())
	darken:SetAllPoints(icon)
	darken:SetColorTexture(0, 0, 0, .25)

	-- Create our own custom border.
	-- Using our new thick tooltip border, just scaled down slightly.
	local border = button.Overlay:CreateFrame("Frame")
	border:SetPoint("TOPLEFT", -14 *sizeMod, 14 *sizeMod)
	border:SetPoint("BOTTOMRIGHT", 14 *sizeMod, -14 *sizeMod)
	border:SetBackdropBorderColor(Colors.ui.stone[1], Colors.ui.stone[2], Colors.ui.stone[3])
	border:SetBackdrop({
		edgeFile = getPath("tooltip_border"),
		edgeSize = 32 *sizeMod
	})

	-- This one we reference, for magic school coloring later on
	button.Border = border

end

-- Anything to post update at all?
local PostUpdateAuraButton = function(element, button)
end


-- Main Styling Function
local counter
local Style = function(self, unit, id, ...)

	-- Frame
	-----------------------------------------------------------

	-- just some crazy calcs while developing 
	if (not id) then 
		counter = (counter or 0) + 1 
		id = counter 
	end 

	local width, height = 96, 36
	local spacing = 30 + 14 + 6

	self:SetSize(width, height)
	self:Place("TOPRIGHT", "UICenter", "RIGHT", -64, (height*5 + spacing*4)*(1 - 2/5) - ((id-1) * (height + spacing)))

	-- Assign our own global custom colors
	self.colors = Colors


	-- Scaffolds
	-----------------------------------------------------------

	-- frame to contain art backdrops, shadows, etc
	local backdrop = self:CreateFrame("Frame")
	backdrop:SetAllPoints()
	backdrop:SetFrameLevel(self:GetFrameLevel())
	
	-- frame to contain bars, icons, etc
	local content = self:CreateFrame("Frame")
	content:SetAllPoints()
	content:SetFrameLevel(self:GetFrameLevel() + 5)

	-- frame to contain art overlays, texts, etc
	local overlay = self:CreateFrame("Frame")
	overlay:SetAllPoints()
	overlay:SetFrameLevel(self:GetFrameLevel() + 10)


	-- Health Bar
	-----------------------------------------------------------	

	local health = content:CreateStatusBar()
	health:SetSize(75, 13)
	health:Place("BOTTOM", 0, 0)
	health:SetOrientation("LEFT") -- set the bar to grow towards the right.
	health:SetSmoothingMode("bezier-fast-in-slow-out") -- set the smoothing mode.
	health:SetSmoothingFrequency(.5) -- set the duration of the smoothing.
	health:SetStatusBarTexture(getPath("cast_bar"))
	health.colorTapped = false -- color tap denied units 
	health.colorDisconnected = true -- color disconnected units
	health.colorClass = true -- color players by class 
	health.colorReaction = true -- color NPCs by their reaction standing with us
	health.colorHealth = true -- color anything else in the default health color
	health.frequent = true -- listen to frequent health events for more accurate updates
	self.Health = health

	local healthBg = health:CreateTexture()
	healthBg:SetDrawLayer("BACKGROUND", -1)
	healthBg:SetSize(130, 84)
	healthBg:SetPoint("CENTER", 0, -2)
	healthBg:SetTexture(getPath("cast_back"))
	healthBg:SetVertexColor(Colors.ui.stone[1], Colors.ui.stone[2], Colors.ui.stone[3])
	self.Health.Bg = healthBg


	-- Absorb Bar
	-----------------------------------------------------------	

	local absorb = content:CreateStatusBar()
	absorb:SetSize(75, 13)
	absorb:SetStatusBarTexture(getPath("cast_bar"))
	absorb:SetFrameLevel(health:GetFrameLevel() + 2)
	absorb:Place("BOTTOM", 0, 0)
	absorb:SetOrientation("RIGHT") -- grow the bar towards the left (grows from the end of the health)
	absorb:SetStatusBarColor(1, 1, 1, .25) -- make the bar fairly transparent, it's just an overlay after all. 
	self.Absorb = absorb


	-- Cast Bar
	-----------------------------------------------------------
	local cast = content:CreateStatusBar()
	cast:SetSize(75, 13)
	cast:SetStatusBarTexture(getPath("cast_bar"))
	cast:SetFrameLevel(health:GetFrameLevel() + 1)
	cast:Place("BOTTOM", 0, 0)
	cast:SetOrientation("LEFT") 
	cast:SetStatusBarColor(1, 1, 1, .15) 
	cast:DisableSmoothing(true) 
	self.Cast = cast


	-- Auras
	-----------------------------------------------------------

	local auras = content:CreateFrame("Frame")
	auras:Place("RIGHT", health, "LEFT", -26, -1)
	auras:SetSize(36*6 + 8*5, 36) -- auras will be aligned in the available space, this size gives us 7x1 auras

	auras.auraSize = 34 -- too much?
	auras.spacingH = 4 -- horizontal/column spacing between buttons
	auras.spacingV = 4 -- vertical/row spacing between aura buttons
	auras.growthX = "LEFT" -- auras grow to the left
	auras.growthY = "DOWN" -- rows grow downwards (we just have a single row, though)
	auras.maxButtons = nil -- when set will limit the number of buttons regardless of space available
	auras.showCooldownSpiral = false -- don't show the spiral as a timer
	auras.showCooldownTime = true -- show timer numbers

	-- Filter strings
	auras.auraFilter = nil -- general aura filter, only used if the below aren't here
	auras.buffFilter = "HELPFUL" -- buff specific filter passed to blizzard API calls
	auras.debuffFilter = "HARMFUL" -- debuff specific filter passed to blizzard API calls

	-- Filter methods
	auras.AuraFilter = nil -- general aura filter function, called when the below aren't there
	auras.BuffFilter = BuffFilter -- buff specific filter function
	auras.DebuffFilter = DebuffFilter -- debuff specific filter function

	-- Aura tooltip position
	auras.tooltipDefaultPosition = nil 
	auras.tooltipPoint = "TOPRIGHT"
	auras.tooltipAnchor = nil
	auras.tooltipRelPoint = "BOTTOMRIGHT"
	auras.tooltipOffsetX = -8 
	auras.tooltipOffsetY = -16
		
	self.Auras = auras
	self.Auras.PostCreateButton = PostCreateAuraButton -- post creation styling
	self.Auras.PostUpdateButton = PostUpdateAuraButton -- post updates when something changes (even timers)


	-- Texts
	-----------------------------------------------------------	

	-- Unit Name
	local name = overlay:CreateFontString()
	name:SetPoint("BOTTOMRIGHT", health, "TOPRIGHT", 0, 16)
	name:SetDrawLayer("OVERLAY")
	name:SetJustifyH("CENTER")
	name:SetJustifyV("TOP")
	name:SetFontObject(AzeriteFont14_Outline)
	name:SetShadowOffset(0, 0)
	name:SetShadowColor(0, 0, 0, 0)
	name:SetTextColor(240/255, 240/255, 240/255, .75)
	self.Name = name

	local healthVal = overlay:CreateFontString()
	healthVal:SetPoint("CENTER", health, "CENTER", 0, 0)
	healthVal:SetDrawLayer("OVERLAY")
	healthVal:SetJustifyH("CENTER")
	healthVal:SetJustifyV("MIDDLE")
	healthVal:SetFontObject(Game11Font_o1)
	healthVal:SetShadowOffset(-.85, -.85)
	healthVal:SetShadowColor(0, 0, 0, .75)
	healthVal:SetTextColor(240/255, 240/255, 240/255, .5)
	self.Health.Value = healthVal
	self.Health.OverrideValue = OverrideHealthValue


end 


UnitFrameArena.OnInit = function(self)
	self.frame = {}
	for i = 1,5 do 
		self.frame[i] = self:SpawnUnitFrame("arena"..i, "UICenter", Style)
		
		-- uncomment this and comment the above line out to test party frames 
		--self.frame[i] = self:SpawnUnitFrame("player", "UICenter", Style)
	end 
end 

