local ADDON = ...

local Core = CogWheel("LibModule"):GetModule(ADDON)
if (not Core) then 
	return 
end

local Module = Core:NewModule("UnitFrameBoss", "LibDB", "LibEvent", "LibUnitFrame", "LibStatusBar")
local Layout = CogWheel("LibDB"):GetDatabase(ADDON..": Layout [UnitFrameBoss]")
local UnitFrameStyles = CogWheel("LibDB"):GetDatabase(ADDON..": UnitFrameStyles")

local fakeId = 0
local Style = function(self, unit, id, ...)
	if (not id) then 
		fakeId = fakeId + 1
		id = fakeId
	end 
	return UnitFrameStyles.StyleSmallFrame(self, unit, id, Layout, ...)
end

Module.OnInit = function(self)
	self.frame = {}
	for i = 1,5 do 
		self.frame[i] = self:SpawnUnitFrame("boss"..i, "UICenter", Style)
		
		-- uncomment this and comment the above line out to test party frames 
		--self.frame[i] = self:SpawnUnitFrame("player", "UICenter", Style)
	end 
end 

