local LibStatusBar = CogWheel:Set("LibStatusBar", 37)
if (not LibStatusBar) then	
	return
end

local LibFrame = CogWheel("LibFrame")
assert(LibFrame, "LibStatusBar requires LibFrame to be loaded.")

LibFrame:Embed(LibStatusBar)

-- Lua API
local _G = _G
local assert = assert
local error = error
local ipairs = ipairs
local math_abs = math.abs
local math_max = math.max
local pairs = pairs
local select = select
local setmetatable = setmetatable
local type = type

-- WoW API
local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime

-- Library registries
LibStatusBar.bars = LibStatusBar.bars or {}
LibStatusBar.textures = LibStatusBar.textures or {}
LibStatusBar.embeds = LibStatusBar.embeds or {}

-- Speed shortcuts
local Bars = LibStatusBar.bars
local Textures = LibStatusBar.textures

-- Syntax check 
local check = function(value, num, ...)
	assert(type(num) == "number", ("Bad argument #%d to '%s': %s expected, got %s"):format(2, "Check", "number", type(num)))
	for i = 1,select("#", ...) do
		if type(value) == select(i, ...) then 
			return 
		end
	end
	local types = string_join(", ", ...)
	local name = string_match(debugstack(2, 2, 0), ": in function [`<](.-)['>]")
	error(("Bad argument #%d to '%s': %s expected, got %s"):format(num, name, types, type(value)), 3)
end


----------------------------------------------------------------
-- Statusbar template
----------------------------------------------------------------
local StatusBar = LibStatusBar:CreateFrame("Frame")
local StatusBar_MT = { __index = StatusBar }

-- Need to borrow some methods here
local Texture = StatusBar:CreateTexture() 
local Texture_MT = { __index = Texture }

-- Grab some of the original methods before we change them
local blizzardSetTexCoord = getmetatable(Texture).__index.SetTexCoord
local blizzardGetTexCoord = getmetatable(Texture).__index.GetTexCoord

-- Mad scientist stuff.
-- What we basically do is to apply texcoords to texcoords, 
-- to get an inner fraction of the already cropped texture. Awesome! :)
local SetTexCoord = function(self, ...)

	-- The displayed fraction of the full texture
	local fractionLeft, fractionRight, fractionTop, fractionBottom = ...

	local fullCoords = Textures[self] -- "full" / original texcoords
	local fullWidth = fullCoords[2] - fullCoords[1] -- full width of the original texcoord area
	local fullHeight = fullCoords[4] - fullCoords[3] -- full height of the original texcoord area

	local displayedLeft = fullCoords[1] + fractionLeft*fullWidth
	local displayedRight = fullCoords[2] - (1-fractionRight)*fullWidth
	local displayedTop = fullCoords[3] + fractionTop*fullHeight
	local displayedBottom = fullCoords[4] - (1-fractionBottom)*fullHeight

	-- Store the real coords (re-use old table, as this is called very often)
	local texCoords = Bars[self].texCoords
	texCoords[1] = displayedLeft
	texCoords[2] = displayedRight
	texCoords[3] = displayedTop
	texCoords[4] = displayedBottom

	-- Calculate the new area and apply it with the real blizzard method
	blizzardSetTexCoord(self, displayedLeft, displayedRight, displayedTop, displayedBottom)
end 

-- Will move this into the main update function later, 
-- just keeping it here for now while developing.
local UpdateByGrowthDirection = {
	RIGHT = function(self, percentage, displaySize, width, height, sparkBefore, sparkAfter)
		local data = Bars[self]
		local bar = data.bar
		local spark = data.spark

		if data.reversedH then
			-- bar grows from the left to right
			-- and the bar is also flipped horizontally 
			-- (e.g. AzeriteUI target absorbbar)
			SetTexCoord(bar, 1, 1-percentage, 0, 1) 
		else 
			-- bar grows from the left to right
			-- (e.g. AzeriteUI player healthbar)
			SetTexCoord(bar, 0, percentage, 0, 1) 
		end 

		bar:ClearAllPoints()
		bar:SetPoint("TOP")
		bar:SetPoint("BOTTOM")
		bar:SetPoint("LEFT")
		bar:SetSize(displaySize, height)
		
		spark:ClearAllPoints()
		spark:SetPoint("TOP", bar, "TOPRIGHT", 0, sparkBefore*height)
		spark:SetPoint("BOTTOM", bar, "BOTTOMRIGHT", 0, -sparkAfter*height)
		spark:SetSize(data.sparkThickness, height - (sparkBefore + sparkAfter)*height)

	end, 
	LEFT = function(self, percentage, displaySize, width, height, sparkBefore, sparkAfter)
		local data = Bars[self]
		local bar = data.bar
		local spark = data.spark

		if data.reversedH then 
			-- bar grows from the right to left
			-- and the bar is also flipped horizontally 
			-- (e.g. AzeriteUI target healthbar)
			SetTexCoord(bar, percentage, 0, 0, 1) 
		else 
			-- bar grows from the right to left
			-- (e.g. AzeriteUI player absorbbar)
			SetTexCoord(bar, 1-percentage, 1, 0, 1)
		end 

		bar:ClearAllPoints()
		bar:SetPoint("TOP")
		bar:SetPoint("BOTTOM")
		bar:SetPoint("RIGHT")
		bar:SetSize(displaySize, height)
		
		spark:ClearAllPoints()
		spark:SetPoint("TOP", bar, "TOPLEFT", 0, sparkBefore*height)
		spark:SetPoint("BOTTOM", bar, "BOTTOMLEFT", 0, -sparkAfter*height)
		spark:SetSize(data.sparkThickness, height - (sparkBefore + sparkAfter)*height)

	end, 
	UP = function(self, percentage, displaySize, width, height, sparkBefore, sparkAfter)
		local data = Bars[self]
		local bar = data.bar
		local spark = data.spark

		if data.reversed then 
			SetTexCoord(bar, 1, 0, 1-percentage, 1)
			sparkBefore, sparkAfter = sparkAfter, sparkBefore
		else 
			SetTexCoord(bar, 0, 1, 1-percentage, 1)
		end 

		bar:ClearAllPoints()
		bar:SetPoint("LEFT")
		bar:SetPoint("RIGHT")
		bar:SetPoint("BOTTOM")
		bar:SetSize(width, displaySize)
		
		spark:ClearAllPoints()
		spark:SetPoint("LEFT", bar, "TOPLEFT", -sparkBefore*width, 0)
		spark:SetPoint("RIGHT", bar, "TOPRIGHT", sparkAfter*width, 0)
		spark:SetSize(width - (sparkBefore + sparkAfter)*width, data.sparkThickness)

	end, 
	DOWN = function(self, percentage, displaySize, width, height, sparkBefore, sparkAfter)
		local data = Bars[self]
		local bar = data.bar
		local spark = data.spark

		if data.reversed then 
			SetTexCoord(bar, 1, 0, 0, percentage)
			sparkBefore, sparkAfter = sparkAfter, sparkBefore
		else 
			SetTexCoord(bar, 0, 1, 0, percentage)
		end 

		bar:ClearAllPoints()
		bar:SetPoint("LEFT")
		bar:SetPoint("RIGHT")
		bar:SetPoint("TOP")
		bar:SetSize(width, displaySize)

		spark:ClearAllPoints()
		spark:SetPoint("LEFT", bar, "BOTTOMLEFT", -sparkBefore*width, 0)
		spark:SetPoint("RIGHT", bar, "BOTTOMRIGHT", sparkAfter*width, 0)
		spark:SetSize(width - (sparkBefore + sparkAfter*width), data.sparkThickness)
	end
}

local Update = function(self, elapsed)
	local data = Bars[self]

	local value = data.disableSmoothing and data.barValue or data.barDisplayValue
	local min, max = data.barMin, data.barMax
	local orientation = data.barOrientation
	local width, height = data.statusbar:GetSize() 
	local bar = data.bar
	local spark = data.spark
	
	if (value > max) then
		value = max
	elseif (value < min) then
		value = min
	end
	
	if (value == min) or (max == min) then
		bar:Hide()
	else

		local displaySize, mult
		if (max > min) then
			mult = (value-min)/(max-min)
			displaySize = mult * ((orientation == "RIGHT" or orientation == "LEFT") and width or height)
			if (displaySize < .01) then 
				displaySize = .01
			end 
		else
			mult = .01
			displaySize = .01
		end

		-- if there's a sparkmap, let's apply it!
		local sparkPoint, sparkAnchor
		local sparkOffsetTop, sparkOffsetBottom = 0,0
		local sparkMap = data.sparkMap
		if sparkMap then 

			local sparkPercentage = mult
			if data.reversedH and ((orientation == "LEFT") or (orientation == "RIGHT")) then 
				sparkPercentage = 1 - mult
			end 
			if data.reversedV and ((orientation == "UP") or (orientation == "DOWN")) then 
				sparkPercentage = 1 - mult
			end 

			if (sparkMap.top and sparkMap.bottom) then 

				-- Iterate through the map to figure out what points we are between
				-- *There's gotta be a more elegant way to do this...
				local topBefore, topAfter = 1, #sparkMap.top
				local bottomBefore, bottomAfter = 1, #sparkMap.bottom
					
				-- Iterate backwards to find the first top point before our current bar value
				for i = topAfter,topBefore,-1 do 
					if sparkMap.top[i].keyPercent > sparkPercentage then 
						topAfter = i
					end 
					if sparkMap.top[i].keyPercent < sparkPercentage then 
						topBefore = i
						break
					end 
				end 
				-- Iterate backwards to find the first bottom point before our current bar value
				for i = bottomAfter,bottomBefore,-1 do 
					if sparkMap.bottom[i].keyPercent > sparkPercentage then 
						bottomAfter = i
					end 
					if sparkMap.bottom[i].keyPercent < sparkPercentage then 
						bottomBefore = i
						break
					end 
				end 
			
				-- figure out the offset at our current position 
				-- between our upper and lover points
				local belowPercentTop = sparkMap.top[topBefore].keyPercent
				local abovePercentTop = sparkMap.top[topAfter].keyPercent

				local belowPercentBottom = sparkMap.bottom[bottomBefore].keyPercent
				local abovePercentBottom = sparkMap.bottom[bottomAfter].keyPercent

				local currentPercentTop = (sparkPercentage - belowPercentTop)/(abovePercentTop-belowPercentTop)
				local currentPercentBottom = (sparkPercentage - belowPercentBottom)/(abovePercentBottom-belowPercentBottom)
	
				-- difference between the points
				local diffTop = sparkMap.top[topAfter].offset - sparkMap.top[topBefore].offset
				local diffBottom = sparkMap.bottom[bottomAfter].offset - sparkMap.bottom[bottomBefore].offset
	
				sparkOffsetTop = (sparkMap.top[topBefore].offset + diffTop*currentPercentTop) --* height
				sparkOffsetBottom = (sparkMap.bottom[bottomBefore].offset + diffBottom*currentPercentBottom) --* height
	
			else 
				-- iterate through the map to figure out what points we are between
				-- gotta be a more elegant way to do this
				local below, above = 1,#sparkMap
				for i = above,below,-1 do 
					if sparkMap[i].keyPercent > sparkPercentage then 
						above = i
					end 
					if sparkMap[i].keyPercent < sparkPercentage then 
						below = i
						break
					end 
				end 

				-- figure out the offset at our current position 
				-- between our upper and lover points
				local belowPercent = sparkMap[below].keyPercent
				local abovePercent = sparkMap[above].keyPercent
				local currentPercent = (sparkPercentage - belowPercent)/(abovePercent-belowPercent)

				-- difference between the points
				local diffTop = sparkMap[above].topOffset - sparkMap[below].topOffset
				local diffBottom = sparkMap[above].bottomOffset - sparkMap[below].bottomOffset

				sparkOffsetTop = (sparkMap[below].topOffset + diffTop*currentPercent) --* height
				sparkOffsetBottom = (sparkMap[below].bottomOffset + diffBottom*currentPercent) --* height
			end 
		end 
		
		-- Hashed tables are just such a nice way to get post updates done faster :) 
		UpdateByGrowthDirection[orientation](self, mult, displaySize, width, height, sparkOffsetTop, sparkOffsetBottom)

		if elapsed then
			local currentAlpha = spark:GetAlpha()
			local range = data.sparkMaxAlpha - data.sparkMinAlpha
			local targetAlpha = data.sparkDirection == "IN" and data.sparkMaxAlpha or data.sparkMinAlpha
			local alphaChange = elapsed/(data.sparkDirection == "IN" and data.sparkDurationIn or data.sparkDurationOut) * range
			if (data.sparkDirection == "IN") then
				if (currentAlpha + alphaChange < targetAlpha) then
					currentAlpha = currentAlpha + alphaChange
				else
					currentAlpha = targetAlpha
					data.sparkDirection = "OUT"
				end
			elseif (data.sparkDirection == "OUT") then
				if (currentAlpha + alphaChange > targetAlpha) then
					currentAlpha = currentAlpha - alphaChange
				else
					currentAlpha = targetAlpha
					data.sparkDirection = "IN"
				end
			end
			spark:SetAlpha(currentAlpha)
		end
		if (not bar:IsShown()) then
			bar:Show()
		end
	end
	
	-- Spark alpha animation
	if (value == max) or (value == min) or (value/max >= data.sparkMaxPercent) or (value/max <= data.sparkMinPercent) then
		if spark:IsShown() then
			spark:Hide()
			spark:SetAlpha(data.sparkMinAlpha)
			data.sparkDirection = "IN"
		end
	else
		if elapsed then
			local currentAlpha = spark:GetAlpha()
			local targetAlpha = data.sparkDirection == "IN" and data.sparkMaxAlpha or data.sparkMinAlpha
			local range = data.sparkMaxAlpha - data.sparkMinAlpha
			local alphaChange = elapsed/(data.sparkDirection == "IN" and data.sparkDurationIn or data.sparkDurationOut) * range
		
			if data.sparkDirection == "IN" then
				if currentAlpha + alphaChange < targetAlpha then
					currentAlpha = currentAlpha + alphaChange
				else
					currentAlpha = targetAlpha
					data.sparkDirection = "OUT"
				end
			elseif data.sparkDirection == "OUT" then
				if currentAlpha + alphaChange > targetAlpha then
					currentAlpha = currentAlpha - alphaChange
				else
					currentAlpha = targetAlpha
					data.sparkDirection = "IN"
				end
			end
			spark:SetAlpha(currentAlpha)
		end
		if (not spark:IsShown()) then
			spark:Show()
		end
	end

	-- Allow modules to add their postupdates here
	if (self.PostUpdate) then 
		self:PostUpdate(value, min, max)
	end

end

local smoothingMinValue = .3 -- if a value is lower than this, we won't smoothe
local smoothingFrequency = .5 -- time for the smooth transition to complete
local smoothingLimit = 1/60 -- max updates per second

local OnUpdate = function(self, elapsed)
	local data = Bars[self]
	data.elapsed = (data.elapsed or 0) + elapsed
	if (data.elapsed < smoothingLimit) then
		return
	end
	if (data.disableSmoothing) then
		if (data.barValue <= data.barMin) or (data.barValue >= data.barMax) then
			data.scaffold:SetScript("OnUpdate", nil)
		end
	elseif (data.smoothing) then
		if (math_abs(data.barDisplayValue - data.barValue) < smoothingMinValue) then 
			data.barDisplayValue = data.barValue
			data.smoothing = nil
		else 
			-- The fraction of the total bar this total animation should cover  
			local animsize = (data.barValue - data.smoothingInitialValue)/(data.barMax - data.barMin) 

			-- Points per second on average for the whole bar
			local pps = (data.barMax - data.barMin)/(data.smoothingFrequency or smoothingFrequency)

			-- Position in time relative to the length of the animation, scaled from 0 to 1
			local position = (GetTime() - data.smoothingStart)/(data.smoothingFrequency or smoothingFrequency) 
			if (position < 1) then 
				-- The change needed when using average speed
				local average = pps * animsize * data.elapsed -- can and should be negative

				-- Tha change relative to point in time and distance passed
				local change = 2*(3 * ( 1 - position )^2 * position) * average*2 --  y = 3 * (1 − t)^2 * t  -- quad bezier fast ascend + slow descend
				--local change = 2*(3 * ( 1 - position ) * position^2) * average*2 -- y = 3 * (1 − t) * t^2 -- quad bezier slow ascend + fast descend
				--local change = 2 * average * ((position < .7) and math_abs(position/.7) or math_abs((1-position)/.3)) -- linear slow ascend + fast descend
				
				--print(("time: %.3f pos: %.3f change: %.1f"):format(GetTime() - data.smoothingStart, position, change))

				-- If there's room for a change in the intended direction, apply it, otherwise finish the animation
				if ( (data.barValue > data.barDisplayValue) and (data.barValue > data.barDisplayValue + change) ) 
				or ( (data.barValue < data.barDisplayValue) and (data.barValue < data.barDisplayValue + change) ) then 
					data.barDisplayValue = data.barDisplayValue + change
				else 
					data.barDisplayValue = data.barValue
					data.smoothing = nil
				end 
			else 
				data.barDisplayValue = data.barValue
				data.smoothing = nil
			end 
		end 
	else
		if (data.barDisplayValue <= data.barMin) or (data.barDisplayValue >= data.barMax) or (not data.smoothing) then
			data.scaffold:SetScript("OnUpdate", nil)
		end
	end

	Update(self, data.elapsed)

	-- call module OnUpdate handler
	if data.OnUpdate then 
		data.OnUpdate(data.statusbar, data.elapsed)
	end 

	-- only reset this at the very end, as calculations above need it
	data.elapsed = 0
end

Texture.SetTexCoord = function(self, ...)
	local tex = Textures[self]
	tex[1], tex[2], tex[3], tex[4] = ...
	Update(tex._owner)
end

Texture.GetTexCoord = function(self)
	local tex = Textures[self]
	return tex[1], tex[2], tex[3], tex[4]
end

StatusBar.SetTexCoord = function(self, ...)
	local tex = Textures[self]
	tex[1], tex[2], tex[3], tex[4] = ...
	Update(self)
end

StatusBar.GetTexCoord = function(self)
	local tex = Textures[self]
	return tex[1], tex[2], tex[3], tex[4]
end

StatusBar.GetRealTexCoord = function(self)
	local texCoords = Bars[self].texCoords
	return texCoords[1], texCoords[2], texCoords[3], texCoords[4]
end

StatusBar.SetSmoothingFrequency = function(self, smoothingFrequency)
	Bars[self].smoothingFrequency = smoothingFrequency
end

StatusBar.SetSmoothingMode = function(self, mode)
	if (mode == "bezier-fast-in-slow-out")  
	or (mode == "bezier-slow-in-fast-out")  
	or (mode == "linear-fast-in-slow-out")  
	or (mode == "linear-slow-in-fast-out") 
	or (mode == "linear") then 
		Bars[self].barSmoothingMode = mode
	else 
		print(("LibStatusBar: 'SetSmoothingMode(mode)' - Unknown 'mode': %s"):format(mode), 2)
	end 
end 

StatusBar.DisableSmoothing = function(self, disableSmoothing)
	Bars[self].disableSmoothing = disableSmoothing
end

StatusBar.SetValue = function(self, value, overrideSmoothing)
	local data = Bars[self]
	local min, max = data.barMin, data.barMax
	if (value > max) then
		value = max
	elseif (value < min) then
		value = min
	end
	data.barValue = value
	if overrideSmoothing then 
		data.barDisplayValue = value
	end 
	if (not data.disableSmoothing) then
		if (data.barDisplayValue > max) then
			data.barDisplayValue = max
		elseif (data.barDisplayValue < min) then
			data.barDisplayValue = min
		end
		data.smoothingInitialValue = data.barDisplayValue
		data.smoothingStart = GetTime()
	end
	if (value ~= data.barDisplayValue) then
		data.smoothing = true
	end
	if (data.smoothing or (data.barDisplayValue > min) or (data.barDisplayValue < max)) then
		if (not data.scaffold:GetScript("OnUpdate")) then
			data.scaffold:SetScript("OnUpdate", OnUpdate)
		end
	end
	Update(self)
end

StatusBar.Clear = function(self)
	local data = Bars[self]
	data.barValue = data.barMin
	data.barDisplayValue = data.barMin
	Update(self)
end

StatusBar.SetMinMaxValues = function(self, min, max, overrideSmoothing)
	local data = Bars[self]
	if (data.barMin == min) and (data.barMax == max) then 
		return 
	end 
	if (data.barValue > max) then
		data.barValue = max
	elseif (data.barValue < min) then
		data.barValue = min
	end
	if overrideSmoothing then 
		data.barDisplayValue = data.barValue
	else 
		if (data.barDisplayValue > max) then
			data.barDisplayValue = max
		elseif (data.barDisplayValue < min) then
			data.barDisplayValue = min
		end
	end 
	data.barMin = min
	data.barMax = max
	Update(self)
end

StatusBar.SetStatusBarColor = function(self, ...)
	Bars[self].bar:SetVertexColor(...)
	Bars[self].spark:SetVertexColor(...)
end

StatusBar.SetStatusBarTexture = function(self, ...)
	local arg = ...
	if (type(arg) == "number") then
		Bars[self].bar:SetColorTexture(...)
	else
		Bars[self].bar:SetTexture(...)
	end
	-- Causes a stack overflow if the texture is changed in PostUpdate, 
	-- as could easily be the case with some bars. 
	--Update(self)
end

StatusBar.SetFlippedHorizontally = function(self, reversed)
	Bars[self].reversedH = reversed
end

StatusBar.SetFlippedVertically = function(self, reversed)
	Bars[self].reversedV = reversed
end

StatusBar.SetSparkMap = function(self, sparkMap)
	Bars[self].sparkMap = sparkMap
end

StatusBar.SetSparkTexture = function(self, ...)
	local arg = ...
	if (type(arg) == "number") then
		Bars[self].spark:SetColorTexture(...)
	else
		Bars[self].spark:SetTexture(...)
	end
end

StatusBar.SetSparkColor = function(self, ...)
	Bars[self].spark:SetVertexColor(...)
end 

StatusBar.SetSparkMinMaxPercent = function(self, min, max)
	local data = Bars[self]
	data.sparkMinPercent = min
	data.sparkMinPercent = max
end

StatusBar.SetSparkBlendMode = function(self, blendMode)
	Bars[self].spark:SetBlendMode(blendMode)
end 

StatusBar.SetSparkFlash = function(self, durationIn, durationOut, minAlpha, maxAlpha)
	local data = Bars[self]
	data.sparkDurationIn = durationIn
	data.sparkDurationOut = durationOut
	data.sparkMinAlpha = minAlpha
	data.sparkMaxAlpha = maxAlpha 
	data.sparkDirection = "IN"
	data.spark:SetAlpha(minAlpha)
end

StatusBar.SetOrientation = function(self, orientation)
	local data = Bars[self]
	data.barOrientation = orientation
	if (orientation == "LEFT") or (orientation == "RIGHT") then 
		data.spark:SetTexCoord(0, 1, 3/32, 28/32)
		--data.spark:SetTexCoord(0, 1, 11/32, 19/32)
	elseif (orientation == "UP") or (orientation == "DOWN") then 
		data.spark:SetTexCoord(1,11/32,0,11/32,1,19/32,0,19/32)
		--data.spark:SetTexCoord(1,3/32,0,3/32,1,28/32,0,28/32) 
	end 
end

StatusBar.CreateFrame = function(self, type, name, ...)
	return self:CreateFrame(type or "Frame", name, Bars[self].scaffold, ...)
--	return CreateFrame(type or "Frame", name, Bars[self].scaffold, ...)
end

StatusBar.CreateTexture = function(self, ...)
	return Bars[self].scaffold:CreateTexture(...)
end

StatusBar.CreateFontString = function(self, ...)
	return Bars[self].scaffold:CreateFontString(...)
end

StatusBar.SetScript = function(self, ...)
	-- can not allow the scaffold to get its scripts overwritten
	local scriptHandler, func = ... 
	if (scriptHandler == "OnUpdate") then 
		Bars[self].OnUpdate = func 
	else 
		Bars[self].scaffold:SetScript(...)
	end 
end

StatusBar.GetScript = function(self, ...)
	local scriptHandler, func = ... 
	if (scriptHandler == "OnUpdate") then 
		return Bars[self].OnUpdate
	else 
		return Bars[self].scaffold:GetScript(...)
	end 
end

StatusBar.ClearAllPoints = function(self)
	Bars[self].scaffold:ClearAllPoints()
end

StatusBar.SetPoint = function(self, ...)
	Bars[self].scaffold:SetPoint(...)
end

StatusBar.SetAllPoints = function(self, ...)
	Bars[self].scaffold:SetAllPoints(...)
end

StatusBar.GetPoint = function(self, ...)
	return Bars[self].scaffold:GetPoint(...)
end

StatusBar.SetSize = function(self, ...)
	Bars[self].scaffold:SetSize(...)
	--Update(self)
end

StatusBar.SetWidth = function(self, ...)
	Bars[self].scaffold:SetWidth(...)
	--Update(self)
end

StatusBar.SetHeight = function(self, ...)
	Bars[self].scaffold:SetHeight(...)
	--Update(self)
end

StatusBar.GetHeight = function(self, ...)
	local top = self:GetTop()
	local bottom = self:GetBottom()
	if top and bottom then
		return top - bottom
	else
		return Bars[self].scaffold:GetHeight(...)
	end
end

StatusBar.GetWidth = function(self, ...)
	local left = self:GetLeft()
	local right = self:GetRight()
	if left and right then
		return right - left
	else
		return Bars[self].scaffold:GetWidth(...)
	end
end

StatusBar.GetSize = function(self, ...)
	local top = self:GetTop()
	local bottom = self:GetBottom()
	local left = self:GetLeft()
	local right = self:GetRight()

	local width, height
	if left and right then
		width = right - left
	end
	if top and bottom then
		height = top - bottom
	end

	return width or Bars[self].scaffold:GetWidth(), height or Bars[self].scaffold:GetHeight()
end

StatusBar.SetFrameLevel = function(self, ...)
	Bars[self].scaffold:SetFrameLevel(...)
end

StatusBar.SetFrameStrata = function(self, ...)
	Bars[self].scaffold:SetFrameStrata(...)
end

StatusBar.SetAlpha = function(self, ...)
	Bars[self].scaffold:SetAlpha(...)
end

StatusBar.SetParent = function(self, ...)
	Bars[self].scaffold:SetParent()
end

StatusBar.GetValue = function(self)
	return Bars[self].barValue
end

StatusBar.GetMinMaxValues = function(self)
	return Bars[self].barMin, Bars[self].barMax
end

StatusBar.GetStatusBarColor = function(self)
	return Bars[self].bar:GetVertexColor()
end

-- Don't like exposing this, 
-- but it just makes life easier for some modules.
StatusBar.GetStatusBarTexture = function(self)
	return Bars[self].bar
end

StatusBar.GetOrientation = function(self)
	return Bars[self].barOrientation
end

StatusBar.GetFrameLevel = function(self)
	return Bars[self].scaffold:GetFrameLevel()
end

StatusBar.GetFrameStrata = function(self)
	return Bars[self].scaffold:GetFrameStrata()
end

StatusBar.GetAlpha = function(self)
	return Bars[self].scaffold:GetAlpha()
end

StatusBar.GetParent = function(self)
	return Bars[self].scaffold:GetParent()
end

StatusBar.GetObjectType = function(self) return "StatusBar" end
StatusBar.IsObjectType = function(self, type) return type == "StatusBar" or type == "Frame" end

StatusBar.Show = function(self) Bars[self].scaffold:Show() end
StatusBar.Hide = function(self) Bars[self].scaffold:Hide() end
StatusBar.IsShown = function(self) return Bars[self].scaffold:IsShown() end

LibStatusBar.CreateStatusBar = function(self, parent)

	-- The scaffold is the top level frame object 
	-- that will respond to SetSize, SetPoint and similar.
	local scaffold = CreateFrame("Frame", nil, parent or self)
	scaffold:SetSize(1,1)

	-- the bar texture
	local bar = setmetatable(scaffold:CreateTexture(), Texture_MT)
	bar:SetDrawLayer("BORDER", 0)
	bar:SetPoint("TOP")
	bar:SetPoint("BOTTOM")
	bar:SetPoint("LEFT")
	bar:SetWidth(scaffold:GetWidth())

	-- rare gem of a texture, works nicely on bars smaller than 256px in effective width 
	bar:SetTexture([[Interface\FontStyles\FontStyleMetal]]) 
	
	-- the spark texture
	local spark = scaffold:CreateTexture()
	spark:SetDrawLayer("BORDER", 1)
	spark:SetPoint("CENTER", bar, "RIGHT", 0, 0)
	spark:SetSize(1,1)
	spark:SetAlpha(.6)
	spark:SetBlendMode("ADD")
	spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]]) -- 32x32, centered vertical spark being 32x9px, from 0,11px to 32,19px
	spark:SetTexCoord(0, 1, 25/80, 55/80)

	-- The statusbar is the virtual object that we return to the user.
	-- This contains all the methods.
	local statusbar = CreateFrame("Frame", nil, scaffold)
	statusbar:SetAllPoints() -- lock down the points before we overwrite the methods

	-- Embed LibFrame's frame creation and methods directly.
	LibFrame:Embed(statusbar)

	-- Change to our custom metatable and methods.
	setmetatable(statusbar, StatusBar_MT)

	local data = {}
	data.scaffold = scaffold
	data.bar = bar
	data.spark = spark
	data.statusbar = statusbar 

	data.barMin = 0 -- min value
	data.barMax = 1 -- max value
	data.barValue = 0 -- real value
	data.barDisplayValue = 0 -- displayed value while smoothing
	data.barOrientation = "RIGHT" -- direction the bar is growing in 
	data.barSmoothingMode = "bezier-fast-in-slow-out"

	data.sparkThickness = 8
	data.sparkOffset = 1/32
	data.sparkDirection = "IN"
	data.sparkDurationIn = .75 
	data.sparkDurationOut = .55
	data.sparkMinAlpha = .25
	data.sparkMaxAlpha = .95
	data.sparkMinPercent = 1/100
	data.sparkMaxPercent = 99/100

	-- The real texcoords of the bar texture
	data.texCoords = {0, 1, 0, 1}

	-- Give multiple objects access using their 'self' as key
	Bars[statusbar] = data
	Bars[scaffold] = data
	Bars[bar] = data

	-- Virtual texcoord handling 
	local texCoords = { 0, 1, 0, 1 }
	texCoords._owner = statusbar

	-- Give both the bar texture and the virtual bar direct access
	Textures[bar] = texCoords
	Textures[statusbar] = texCoords
	
	Update(statusbar)

	return statusbar
end

-- Embed it in LibFrame
LibFrame:AddMethod("CreateStatusBar", LibStatusBar.CreateStatusBar)

-- Module embedding
local embedMethods = {
	CreateStatusBar = true
}

LibStatusBar.Embed = function(self, target)
	for method in pairs(embedMethods) do
		target[method] = self[method]
	end
	self.embeds[target] = true
	return target
end

-- Upgrade existing embeds, if any
for target in pairs(LibStatusBar.embeds) do
	LibStatusBar:Embed(target)
end
