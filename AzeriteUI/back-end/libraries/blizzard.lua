local LibBlizzard = CogWheel:Set("LibBlizzard", 29)
if (not LibBlizzard) then 
	return
end

local LibClientBuild = CogWheel("LibClientBuild")
assert(LibClientBuild, "LibBlizzard requires LibClientBuild to be loaded.")

local LibEvent = CogWheel("LibEvent")
assert(LibEvent, "LibBlizzard requires LibEvent to be loaded.")

LibEvent:Embed(LibBlizzard)

-- Lua API
local _G = _G
local assert = assert
local debugstack = debugstack
local error = error
local pairs = pairs
local select = select
local string_format = string.format
local string_join = string.join
local string_match = string.match
local type = type

-- WoW API
local CreateFrame = _G.CreateFrame
local IsAddOnLoaded = _G.IsAddOnLoaded
local SetCVar = _G.SetCVar
local TargetofTarget_Update = _G.TargetofTarget_Update

-- WoW Objects
local UIParent = _G.UIParent

LibBlizzard.embeds = LibBlizzard.embeds or {}
LibBlizzard.queue = LibBlizzard.queue or {}

-- Frame to securely hide items
if (not LibBlizzard.frame) then
	local frame = CreateFrame("Frame", nil, UIParent, "SecureHandlerAttributeTemplate")
	frame:Hide()
	frame:SetPoint("TOPLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", 0, 0)
	frame.children = {}
	RegisterAttributeDriver(frame, "state-visibility", "hide")

	-- Attach it to our library
	LibBlizzard.frame = frame
end

local UIHider = LibBlizzard.frame
local UIWidgets = {}
local UIWidgetDependency = {}

-- Syntax check 
local check = function(value, num, ...)
	assert(type(num) == "number", ("Bad argument #%.0f to '%s': %s expected, got %s"):format(2, "Check", "number", type(num)))
	for i = 1,select("#", ...) do
		if (type(value) == select(i, ...)) then 
			return 
		end
	end
	local types = string_join(", ", ...)
	local name = string_match(debugstack(2, 2, 0), ": in function [`<](.-)['>]")
	error(("Bad argument #%.0f to '%s': %s expected, got %s"):format(num, name, types, type(value)), 3)
end

-- Proxy function to retrieve the actual frame whether 
-- the input is a frame or a global frame name 
local getFrame = function(baseName)
	if (type(baseName) == "string") then
		return _G[baseName]
	else
		return baseName
	end
end

-- Kill off an existing frame in a secure, taint free way
-- @usage kill(object, [keepEvents], [silent])
-- @param object <table, string> frame, fontstring or texture to hide
-- @param keepEvents <boolean, nil> 'true' to leave a frame's events untouched
-- @param silent <boolean, nil> 'true' to return 'false' instead of producing an error for non existing objects
local kill = function(object, keepEvents, silent)
	check(object, 1, "string", "table")
	check(keepEvents, 2, "boolean", "nil")
	if (type(object) == "string") then
		if (silent and (not _G[object])) then
			return false
		end
		assert(_G[object], ("Bad argument #%.0f to '%s'. No object named '%s' exists."):format(1, "Kill", object))
		object = _G[object]
	end
	if (not UIHider[object]) then
		UIHider[object] = {
			parent = object:GetParent(),
			isshown = object:IsShown(),
			point = { object:GetPoint() }
		}
	end
	object:SetParent(UIHider)
	if (object.UnregisterAllEvents and (not keepEvents)) then
		object:UnregisterAllEvents()
	end
	return true
end

local killUnitFrame = function(baseName, keepParent)
	local frame = getFrame(baseName)
	if frame then
		if (not keepParent) then
			kill(frame, false, true)
		end
		frame:Hide()
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", -400, 500)

		local health = frame.healthbar
		if health then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if power then
			power:UnregisterAllEvents()
		end

		local spell = frame.spellbar
		if spell then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt
		if altpowerbar then
			altpowerbar:UnregisterAllEvents()
		end
	end
end

UIWidgets["ActionBars"] = function(self)
	for _,object in pairs({
		"CollectionsMicroButtonAlert",
		"EJMicroButtonAlert",
		"LFDMicroButtonAlert",
		"MainMenuBarVehicleLeaveButton",
		"OverrideActionBar",
		"PetActionBarFrame",
		"StanceBarFrame",
		"TalentMicroButtonAlert",
		"TutorialFrameAlertButton"
	}) do 
		if (_G[object]) then 
			_G[object]:UnregisterAllEvents()
		else 
			print(string_format("LibBlizzard: The object '%s' wasn't found, tell Goldpaw!", object))
		end
	end 
	for _,object in pairs({
		"CollectionsMicroButtonAlert",
		"EJMicroButtonAlert",
		"FramerateLabel",
		"FramerateText",
		"LFDMicroButtonAlert",
		"MainMenuBarArtFrame",
		"MainMenuBarVehicleLeaveButton",
		"MicroButtonAndBagsBar",
		"MultiBarBottomLeft",
		"MultiBarBottomRight",
		"MultiBarLeft",
		"MultiBarRight",
		"OverrideActionBar",
		"PetActionBarFrame",
		"PossessBarFrame",
		"StanceBarFrame",
		"StreamingIcon",
		"TalentMicroButtonAlert"
	}) do 
		if (_G[object]) then 
			_G[object]:SetParent(UIHider)
		else 
			print(string_format("LibBlizzard: The object '%s' wasn't found, tell Goldpaw!", object))
		end
	end 
	for _,object in pairs({
		"CollectionsMicroButtonAlert",
		"EJMicroButtonAlert",
		"LFDMicroButtonAlert",
		"MainMenuBarArtFrame",
		"MicroButtonAndBagsBar",
		"OverrideActionBar",
		"PetActionBarFrame",
		"PossessBarFrame",
		"StanceBarFrame",
		"StatusTrackingBarManager",
		"TutorialFrameAlertButton"
	}) do 
		if (_G[object]) then 
			_G[object]:Hide()
		else 
			print(string_format("LibBlizzard: The object '%s' wasn't found, tell Goldpaw!", object))
		end
	end 
	for _,object in pairs({
		"ActionButton", 
		"MultiBarBottomLeftButton", 
		"MultiBarBottomRightButton", 
		"MultiBarRightButton",
		"MultiBarLeftButton"
	}) do 
		for i = 1,NUM_ACTIONBAR_BUTTONS do
			local button = _G[object..i]
			button:Hide()
			button:UnregisterAllEvents()
			button:SetAttribute("statehidden", true)
		end
	end 
	for i = 1,6 do
		local button = _G["OverrideActionBarButton"..i]
		button:UnregisterAllEvents()
		button:SetAttribute("statehidden", true)

		-- Just in case it's still there, covering stuff. 
		-- This has happened in some rare cases. Hiding won't work. 
		button:EnableMouse(false) 
	end
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	elseif TalentFrame_LoadUI then
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end

	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetAlpha(0)
	MainMenuBar:UnregisterEvent("DISPLAY_SIZE_CHANGED")
	MainMenuBar:UnregisterEvent("UI_SCALE_CHANGED")
	MainMenuBar.slideOut:GetAnimations():SetOffset(0,0)

	-- If I'm not hiding this, it will become visible (though transparent)
	-- and cover our own custom vehicle/possess action bar. 
	OverrideActionBar:EnableMouse(false)
	OverrideActionBar:SetAlpha(0)
	OverrideActionBar.slideOut:GetAnimations():SetOffset(0,0)

	-- Gets rid of the loot anims
	MainMenuBarBackpackButton:UnregisterEvent("ITEM_PUSH") 
	for slot = 0,3 do
		_G["CharacterBag"..slot.."Slot"]:UnregisterEvent("ITEM_PUSH") 
	end

	UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["StanceBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiCastActionBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MULTICASTACTIONBAR_YPOS"] = nil
end

UIWidgets["Alerts"] = function(self)
	AlertFrame:UnregisterAllEvents()
	AlertFrame:SetParent(UIHider)
end 

UIWidgets["Auras"] = function(self)
	BuffFrame:SetScript("OnLoad", nil)
	BuffFrame:SetScript("OnUpdate", nil)
	BuffFrame:SetScript("OnEvent", nil)
	BuffFrame:SetParent(UIHider)
	BuffFrame:UnregisterAllEvents()
	TemporaryEnchantFrame:SetScript("OnUpdate", nil)
	TemporaryEnchantFrame:SetParent(UIHider)
end 

UIWidgets["BuffTimer"] = function(self)
	PlayerBuffTimerManager:SetParent(UIHider)
	PlayerBuffTimerManager:SetScript("OnEvent", nil)
	PlayerBuffTimerManager:UnregisterAllEvents()
end

UIWidgets["CaptureBar"] = function(self)
	UIWidgetBelowMinimapContainerFrame:SetParent(UIHider)
	UIWidgetBelowMinimapContainerFrame:SetScript("OnEvent", nil)
	UIWidgetBelowMinimapContainerFrame:UnregisterAllEvents()
end
UIWidgetDependency["CaptureBar"] = "Blizzard_UIWidgets"

UIWidgets["CastBars"] = function(self)
	CastingBarFrame:SetScript("OnEvent", nil)
	CastingBarFrame:SetScript("OnUpdate", nil)
	CastingBarFrame:SetParent(UIHider)
	CastingBarFrame:UnregisterAllEvents()

	PetCastingBarFrame:SetScript("OnEvent", nil)
	PetCastingBarFrame:SetScript("OnUpdate", nil)
	PetCastingBarFrame:SetParent(UIHider)
	PetCastingBarFrame:UnregisterAllEvents()
end 

UIWidgets["Chat"] = function(self)
	-- This was called FriendsMicroButton pre-Legion
	local killQuickToast = function(self, event, ...)
		QuickJoinToastButton:UnregisterAllEvents()
		QuickJoinToastButton:Hide()
		QuickJoinToastButton:SetAlpha(0)
		QuickJoinToastButton:EnableMouse(false)
		QuickJoinToastButton:SetParent(UIHider)
	end 
	--killQuickToast()

	-- This pops back up on zoning sometimes, so keep removing it
	--LibBlizzard:RegisterEvent("PLAYER_ENTERING_WORLD", killQuickToast)
end 

UIWidgets["Durability"] = function(self)
	DurabilityFrame:UnregisterAllEvents()
	DurabilityFrame:SetScript("OnShow", nil)
	DurabilityFrame:SetScript("OnHide", nil)

	-- Will this taint? 
	-- This is to prevent the durability frame size 
	-- affecting other anchors
	DurabilityFrame:SetParent(UIHider)
	DurabilityFrame:Hide()
	DurabilityFrame.IsShown = function() return false end
end

UIWidgets["LevelUpDisplay"] = function(self)
	LevelUpDisplay:UnregisterAllEvents()
	LevelUpDisplay:StopBanner()
end 

UIWidgets["Minimap"] = function(self)
	for _,object in pairs({
		"GameTimeFrame",
		"GarrisonLandingPageMinimapButton"
	}) do 
		if (_G[object]) then 
			_G[object]:UnregisterAllEvents()
		else
			print(string_format("LibBlizzard: The object '%s' wasn't found, tell Goldpaw!", object))
		end 
	end 
	for _,object in pairs({
		"GameTimeFrame",
		"GarrisonLandingPageMinimapButton",
		"GuildInstanceDifficulty",
		"MiniMapInstanceDifficulty",
		"MinimapBorder",
		"MinimapBorderTop",
		"MinimapCluster",
		"MiniMapMailBorder",
		"MiniMapMailFrame",
		"MinimapBackdrop", 
		"MinimapNorthTag",
		"MiniMapTracking",
		"MiniMapTrackingButton",
		"MiniMapWorldMapButton",
		"MinimapZoomIn",
		"MinimapZoomOut",
		"MinimapZoneTextButton"
	}) do 
		if (_G[object]) then 
			_G[object]:SetParent(UIHider)
		else
			print(string_format("LibBlizzard: The object '%s' wasn't found, tell Goldpaw!", object))
		end 
	end 

	QueueStatusMinimapButton:SetHighlightTexture("") 
	QueueStatusMinimapButtonBorder:SetAlpha(0)
	QueueStatusMinimapButtonBorder:SetTexture(nil)
	QueueStatusMinimapButton.Highlight:SetAlpha(0)
	QueueStatusMinimapButton.Highlight:SetTexture(nil)

	-- Ugly hack to keep the keybind functioning
	GarrisonLandingPageMinimapButton:Show()
	GarrisonLandingPageMinimapButton.Hide = GarrisonLandingPageMinimapButton.Show
	
	self:DisableUIWidget("MinimapClock")
end

UIWidgets["MinimapClock"] = function(self)
	TimeManagerClockButton:SetParent(UIHider)
	TimeManagerClockButton:UnregisterAllEvents()
end
UIWidgetDependency["MinimapClock"] = "Blizzard_TimeManager"

UIWidgets["MirrorTimer"] = function(self)
	for i = 1, _G.MIRRORTIMER_NUMTIMERS or 1 do
		local timer = _G["MirrorTimer"..i]
		timer:SetScript("OnEvent", nil)
		timer:SetScript("OnUpdate", nil)
		timer:SetParent(UIHider)
		timer:UnregisterAllEvents()
	end
end 

UIWidgetDependency["ObjectiveTracker"] = "Blizzard_ObjectiveTracker"
UIWidgets["ObjectiveTracker"] = function(self)

	ObjectiveTrackerFrame:UnregisterAllEvents()
	ObjectiveTrackerFrame:SetScript("OnLoad", nil)
	ObjectiveTrackerFrame:SetScript("OnEvent", nil)
	ObjectiveTrackerFrame:SetScript("OnUpdate", nil)
	ObjectiveTrackerFrame:SetScript("OnSizeChanged", nil)
	ObjectiveTrackerFrame:SetParent(UIHider)

	ObjectiveTrackerBlocksFrame:UnregisterAllEvents()
	ObjectiveTrackerBlocksFrame:SetScript("OnLoad", nil)
	ObjectiveTrackerBlocksFrame:SetScript("OnEvent", nil)
	ObjectiveTrackerBlocksFrame:SetScript("OnUpdate", nil)
	ObjectiveTrackerBlocksFrame:SetScript("OnSizeChanged", nil)
	ObjectiveTrackerBlocksFrame:SetParent(UIHider)

	-- Will this kill the keystoned mythic spam errors?
	ScenarioBlocksFrame:UnregisterAllEvents()
	ScenarioBlocksFrame:SetScript("OnLoad", nil)
	ScenarioBlocksFrame:SetScript("OnEvent", nil)
	ScenarioBlocksFrame:SetScript("OnUpdate", nil)
	ScenarioBlocksFrame:SetScript("OnSizeChanged", nil)
	ScenarioBlocksFrame:SetParent(UIHider)
end

UIWidgetDependency["OrderHall"] = "Blizzard_OrderHallUI"
UIWidgets["OrderHall"] = function(self)
	OrderHallCommandBar:SetScript("OnLoad", nil)
	OrderHallCommandBar:SetScript("OnShow", nil)
	OrderHallCommandBar:SetScript("OnHide", nil)
	OrderHallCommandBar:SetScript("OnEvent", nil)
	OrderHallCommandBar:SetParent(UIHider)
	OrderHallCommandBar:UnregisterAllEvents()
end 

UIWidgets["PlayerPowerBarAlt"] = function(self)
	PlayerPowerBarAlt.ignoreFramePositionManager = true
	PlayerPowerBarAlt:UnregisterAllEvents()
	PlayerPowerBarAlt:SetParent(UIHider)
end 

UIWidgets["TimerTracker"] = function(self)
	TimerTracker:SetScript("OnEvent", nil)
	TimerTracker:SetScript("OnUpdate", nil)
	TimerTracker:UnregisterAllEvents()
	if TimerTracker.timerList then
		for _, bar in pairs(TimerTracker.timerList) do
			bar:SetScript("OnEvent", nil)
			bar:SetScript("OnUpdate", nil)
			bar:SetParent(UIHider)
			bar:UnregisterAllEvents()
		end
	end
end

UIWidgets["TotemFrame"] = function(self)
	TotemFrame:UnregisterAllEvents()
	TotemFrame:SetScript("OnEvent", nil)
	TotemFrame:SetScript("OnShow", nil)
	TotemFrame:SetScript("OnHide", nil)
end

UIWidgets["Tutorials"] = function(self)
	TutorialFrame:UnregisterAllEvents()
	TutorialFrame:Hide()
	TutorialFrame.Show = TutorialFrame.Hide
end

UIWidgets["UnitFramePlayer"] = function(self)
	killUnitFrame("PlayerFrame")

	-- A lot of blizz modules relies on PlayerFrame.unit
	-- This includes the aura frame and several others. 
	PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	PlayerFrame:RegisterEvent("UNIT_ENTERING_VEHICLE")
	PlayerFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	PlayerFrame:RegisterEvent("UNIT_EXITING_VEHICLE")
	PlayerFrame:RegisterEvent("UNIT_EXITED_VEHICLE")

	-- User placed frames don't animate
	PlayerFrame:SetUserPlaced(true)
	PlayerFrame:SetDontSavePosition(true)

	-- Disable stagger bar events
	MonkStaggerBar:UnregisterAllEvents()
end

UIWidgets["UnitFramePet"] = function(self)
	killUnitFrame("PetFrame")
end

UIWidgets["UnitFrameTarget"] = function(self)
	killUnitFrame("TargetFrame")
	killUnitFrame("ComboFrame")
end

UIWidgets["UnitFrameToT"] = function(self)
	killUnitFrame("TargetFrameToT")
	TargetofTarget_Update(TargetFrameToT)
end

UIWidgets["UnitFrameFocus"] = function(self)
	killUnitFrame("FocusFrame")
	killUnitFrame("TargetofFocusFrame")
end 

UIWidgets["UnitFrameParty"] = function(self)
	for i = 1,4 do
		killUnitFrame(("PartyMemberFrame%.0f"):format(i))
	end
	PartyMemberBackground:SetParent(UIHider)
	PartyMemberBackground:Hide()
	PartyMemberBackground:SetAlpha(0)
end

UIWidgets["UnitFrameRaid"] = function(self)
	-- dropdowns cause taint through the blizz compact unit frames, so we disable them
	-- http://www.wowinterface.com/forums/showpost.php?p=261589&postcount=5
	CompactUnitFrameProfiles:UnregisterAllEvents()
	CompactRaidFrameManager:SetParent(UIHider)
	UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
end

UIWidgets["UnitFrameArena"] = function(self)
	for i = 1,5 do
		killUnitFrame(("ArenaEnemyFrame%.0f"):format(i))
	end
	Arena_LoadUI = function() end
	SetCVar("showArenaEnemyFrames", "0", "SHOW_ARENA_ENEMY_FRAMES_TEXT")
end

UIWidgets["UnitFrameBoss"] = function(self)
	for i = 1,MAX_BOSS_FRAMES do
		killUnitFrame(("Boss%.0fTargetFrame"):format(i))
	end
end

UIWidgets["ZoneText"] = function(self)
	ZoneTextFrame:SetParent(UIHider)
	ZoneTextFrame:UnregisterAllEvents()
	ZoneTextFrame:SetScript("OnUpdate", nil)
	
	SubZoneTextFrame:SetParent(UIHider)
	SubZoneTextFrame:UnregisterAllEvents()
	SubZoneTextFrame:SetScript("OnUpdate", nil)
	
	AutoFollowStatus:SetParent(UIHider)
	AutoFollowStatus:UnregisterAllEvents()
	AutoFollowStatus:SetScript("OnUpdate", nil)
end 

LibBlizzard.OnEvent = function(self, event, ...)
	local arg1 = ...
	if (event == "ADDON_LOADED") then
		local queueCount = 0
		for widgetName,addonName in pairs(self.queue) do 
			if (addonName == arg1) then 
				self.queue[widgetName] = nil
				UIWidgets[widgetName](self)
			else 
				queueCount = queueCount + 1
			end 
		end 
		if (queueCount == 0) then 
			if self:IsEventRegistered("ADDON_LOADED", "OnEvent") then 
				self:UnregisterEvent("ADDON_LOADED", "OnEvent")
			end 
		end 
	end 
end 

LibBlizzard.DisableUIWidget = function(self, name, ...)
	-- Just silently fail for widgets that don't exist.
	-- Makes it much simpler during development, 
	-- and much easier in the future to upgrade.
	if (not UIWidgets[name]) then 
		print(("LibBlizzard: The UI widget '%s' does not exist."):format(name))
		return 
	end 
	local dependency = UIWidgetDependency[name]
	if dependency then 
		if (not IsAddOnLoaded(dependency)) then 
			LibBlizzard.queue[name] = dependency
			if (not LibBlizzard:IsEventRegistered("ADDON_LOADED", "OnEvent")) then 
				LibBlizzard:RegisterEvent("ADDON_LOADED", "OnEvent")
			end 
			return 
		end 
	end 
	UIWidgets[name](LibBlizzard, ...)
end

LibBlizzard.DisableUIMenuOption = function(self, option_shrink, option_name)
	local option = _G[option_name]
	if not(option) or not(option.IsObjectType) or not(option:IsObjectType("Frame")) then
		print(("LibBlizzard: The menu option '%s' does not exist."):format(option_name))
		return
	end
	option:SetParent(UIHider)
	if option.UnregisterAllEvents then
		option:UnregisterAllEvents()
	end
	if option_shrink then
		option:SetHeight(0.00001)
		option:SetScale(0.00001) -- needed for the options to shrink properly. Watch out for side effects(?)
	end
	option.cvar = ""
	option.uvar = ""
	option.value = nil
	option.oldValue = nil
	option.defaultValue = nil
	option.setFunc = function() end
end

--local panel = { byID = {}, byName = {} }

LibBlizzard.DisableUIMenuPage = function(self, panel_id, panel_name)
	local button,window
	-- remove an entire blizzard options panel, 
	-- and disable its automatic cancel/okay functionality
	-- this is needed, or the option will be reset when the menu closes
	-- it is also a major source of taint related to the Compact group frames!
	if panel_id then
		local category = _G["InterfaceOptionsFrameCategoriesButton" .. panel_id]
		if category then
			category:SetScale(0.00001)
			category:SetAlpha(0)
			button = true
		end
	end
	if panel_name then
		local panel = _G[panel_name]
		if panel then
			panel:SetParent(UIHider)
			if panel.UnregisterAllEvents then
				panel:UnregisterAllEvents()
			end
			panel.cancel = function() end
			panel.okay = function() end
			panel.refresh = function() end
			window = true
		end
	end
	if (panel_id and not button) then
		print(("LibBlizzard: The panel button with id '%.0f' does not exist."):format(panel_id))
	end 
	if (panel_name and not window) then
		print(("LibBlizzard: The menu panel named '%s' does not exist."):format(panel_name))
	end 
end

-- Module embedding
local embedMethods = {
	DisableUIMenuOption = true,
	DisableUIMenuPage = true,
	DisableUIWidget = true
}

LibBlizzard.Embed = function(self, target)
	for method in pairs(embedMethods) do
		target[method] = self[method]
	end
	self.embeds[target] = true
	return target
end

-- Upgrade existing embeds, if any
for target in pairs(LibBlizzard.embeds) do
	LibBlizzard:Embed(target)
end
