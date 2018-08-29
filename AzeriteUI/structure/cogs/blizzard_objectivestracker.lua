local ADDON = ...

local Core = CogWheel("LibModule"):GetModule(ADDON)
if (not Core) then 
	return 
end

local Module = Core:NewModule("BlizzardObjectivesTracker", "LibEvent", "LibFrame")
local Colors = CogWheel("LibDB"):GetDatabase(ADDON..": Colors")
local Fonts = CogWheel("LibDB"):GetDatabase(ADDON..": Fonts")
local Layout = CogWheel("LibDB"):GetDatabase(ADDON..": Layout [BlizzardObjectivesTracker]")
local L = CogWheel("LibLocale"):GetLocale(ADDON)

-- Lua API
local _G = _G
local math_min = math.min

-- WoW API
local hooksecurefunc = hooksecurefunc
local GetScreenHeight = _G.GetScreenHeight

-- Flags to track tracker visiblity
local IN_COMBAT
local IN_BOSS_FIGHT
local IN_ARENA

Module.StyleTracker = function(self)
	hooksecurefunc("ObjectiveTracker_Update", function()
		local frame = ObjectiveTrackerFrame.MODULES
		if frame then
			for i = 1, #frame do
				local modules = frame[i]
				if modules then
					local header = modules.Header
					local background = modules.Header.Background
					background:SetAtlas(nil)

					local text = modules.Header.Text
					text:SetParent(header)
				end
			end
		end
	end)
end 

Module.PositionTracker = function(self)
	if (not ObjectiveTrackerFrame) then 
		return self:RegisterEvent("ADDON_LOADED", "OnEvent")
	end 

	local ObjectiveFrameHolder = self:CreateFrame("Frame", nil, "UICenter")
	ObjectiveFrameHolder:SetWidth(Layout.Width)
	ObjectiveFrameHolder:SetHeight(22)
	ObjectiveFrameHolder:Place(unpack(Layout.Place))
	
	ObjectiveTrackerFrame:SetParent(self:GetFrame("UICenter")) -- taint or ok?
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")

	local top = ObjectiveTrackerFrame:GetTop() or 0
	local screenHeight = GetScreenHeight()
	local maxHeight = screenHeight - (Layout.SpaceBottom + Layout.SpaceTop)
	local objectiveFrameHeight = math_min(maxHeight, Layout.MaxHeight)

	ObjectiveTrackerFrame:SetWidth(Layout.Width)
	ObjectiveTrackerFrame:SetHeight(objectiveFrameHeight)
	ObjectiveTrackerFrame:SetClampedToScreen(false)
	ObjectiveTrackerFrame:SetAlpha(.9)

	local ObjectiveTrackerFrame_SetPosition = function(_,_, parent)
		if parent ~= ObjectiveFrameHolder then
			ObjectiveTrackerFrame:ClearAllPoints()
			ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
		end
	end
	hooksecurefunc(ObjectiveTrackerFrame,"SetPoint", ObjectiveTrackerFrame_SetPosition)

	self:StyleTracker()
end

Module.OnEvent = function(self, event, ...)
	if (event == "ADDON_LOADED") then 
		local addon = ...
		if (addon == "Blizzard_ObjectiveTracker") then 
			self:UnregisterEvent("ADDON_LOADED", "OnEvent")
			self:PositionTracker()
		end 
	end 
end

Module.CreateDriver = function(self)
	if Layout.HideInCombat or Layout.HideInBossFights or Layout.HideInArena then 
		local driverFrame = CreateFrame("Frame", nil, UIParent, "SecureHandlerAttributeTemplate")
		driverFrame:Hide()
		driverFrame:HookScript("OnShow", function() 
			if ObjectiveTrackerFrame then 
				ObjectiveTrackerFrame:SetAlpha(.9)
			end
		end)
		driverFrame:HookScript("OnHide", function() 
			if ObjectiveTrackerFrame then 
				ObjectiveTrackerFrame:SetAlpha(0)
			end
		end)
		driverFrame:SetAttribute("_onattributechanged", [=[
			if (name == "state-vis") then
				if (value == "show") then 
					if (not self:IsShown()) then 
						self:Show(); 
					end 
				elseif (value == "hide") then 
					if (self:IsShown()) then 
						self:Hide(); 
					end 
				end 
			end
		]=])

		local driver = "hide;show"
		if Layout.HideInArena then 
			driver = "[@arena1,exists]" .. driver
		end 
		if Layout.HideInBossFights then 
			driver = "[@boss1,exists]" .. driver
		end 
		if Layout.HideInCombat then 
			driver = "[combat]" .. driver
		end 

		RegisterAttributeDriver(driverFrame, "state-vis", driver)
	end 

end 

Module.OnInit = function(self)
	self:PositionTracker()
end 

Module.OnEnable = function(self)
	self:CreateDriver()
end