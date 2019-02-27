local ADDON = ...

local Core = CogWheel("LibModule"):GetModule(ADDON)
if (not Core) then 
	return 
end

local Module = Core:NewModule("ChatWindows", "LibMessage", "LibEvent", "LibDB", "LibFrame", "LibChatWindow")
local Layout

-- Lua API
local _G = _G
local math_floor = math.floor
local string_len = string.len
local string_sub = string.sub 

-- WoW API
local FCF_GetButtonSide = _G.FCF_GetButtonSide
local FCF_SetWindowAlpha = _G.FCF_SetWindowAlpha
local FCF_SetWindowColor = _G.FCF_SetWindowColor
local FCF_Tab_OnClick = _G.FCF_Tab_OnClick
local FCF_UpdateButtonSide = _G.FCF_UpdateButtonSide
local IsShiftKeyDown = _G.IsShiftKeyDown
local UIFrameFadeRemoveFrame = _G.UIFrameFadeRemoveFrame
local UIFrameIsFading = _G.UIFrameIsFading
local UnitAffectingCombat = _G.UnitAffectingCombat
local VoiceChat_IsLoggedIn = _G.C_VoiceChat and _G.C_VoiceChat.IsLoggedIn

local alphaLocks = {}
local scaffolds = {}
	
Module.UpdateChatWindowAlpha = function(self, frame)
	local editBox = self:GetChatWindowCurrentEditBox(frame)
	local alpha
	if editBox:IsShown() then
		alpha = 0.25
	else
		alpha = 0
	end
	for index, value in pairs(CHAT_FRAME_TEXTURES) do
		if (not value:find("Tab")) then
			local object = _G[frame:GetName()..value]
			if object:IsShown() then
				UIFrameFadeRemoveFrame(object)
				object:SetAlpha(alpha)
			end
		end
	end
end 

Module.UpdateChatWindowButtons = function(self, frame)

	local buttonSide = FCF_GetButtonSide(frame)

	local buttonFrame = self:GetChatWindowButtonFrame(frame)
	local minimizeButton = self:GetChatWindowMinimizeButton(frame)
	local channelButton = self:GetChatWindowChannelButton()
	local deafenButton = self:GetChatWindowVoiceDeafenButton()
	local muteButton =self:GetChatWindowVoiceMuteButton()
	local menuButton = self:GetChatWindowMenuButton()
	local scrollBar = self:GetChatWindowScrollBar(frame)
	local scrollToBottomButton = self:GetChatWindowScrollToBottomButton(frame)

	local frameHeight = frame:GetHeight()
	local buttonCount, spaceNeeded = 0, 0
	local anchorTop, anchorBottom

	-- Calculate available space based on visible buttons
	if frame.isDocked then 
		if (channelButton and channelButton:IsShown()) then 
			buttonCount = buttonCount + 1
			spaceNeeded = spaceNeeded + channelButton:GetHeight()
			anchorTop = channelButton
		end 
		if (deafenButton and deafenButton:IsShown()) then 
			buttonCount = buttonCount + 1
			spaceNeeded = spaceNeeded + deafenButton:GetHeight()
			anchorTop = deafenButton
		end 
		if (muteButton and muteButton:IsShown()) then 
			buttonCount = buttonCount + 1
			spaceNeeded = spaceNeeded + muteButton:GetHeight()
			anchorTop = muteButton
		end 
		if (menuButton and menuButton:IsShown()) then 
			buttonCount = buttonCount + 1
			spaceNeeded = spaceNeeded + menuButton:GetHeight()
			anchorBottom = menuButton
		end 
	else
		if (minimizeButton and minimizeButton:IsShown()) then 
			buttonCount = buttonCount + 1
			spaceNeeded = spaceNeeded + minimizeButton:GetHeight()
			anchorTop = minimizeButton
		end 
	end 

	-- Isn't the bar always here...?
	if scrollBar then

		-- Cram it in with the other buttons when there is room enough
		if (frameHeight >= spaceNeeded) then 
			scrollBar:ClearAllPoints()
			if anchorTop then 
				scrollBar:SetPoint("TOP", anchorTop, "BOTTOM", 0, -4)
			else 
				scrollBar:SetPoint("TOP", buttonFrame, "TOP", 0, -4)
			end 
			if (scrollToBottomButton and scrollToBottomButton:IsShown()) then
				scrollToBottomButton:ClearAllPoints()
				if anchorBottom then 
					scrollToBottomButton:SetPoint("BOTTOM", anchorBottom, "TOP", 0, 9)
				else 
					scrollToBottomButton:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 4)
				end 
				scrollBar:SetPoint("BOTTOM", scrollToBottomButton, "TOP", 0, 5)
			else
				if anchorBottom then 
					scrollBar:SetPoint("BOTTOM", anchorBottom, "TOP", 0, 9)
				else 
					scrollBar:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 4)
				end 
			end 
		else 

			-- Put it back on the opposite side when there's not enough room
			if (buttonSide == "left") then 
				scrollBar:ClearAllPoints()
				scrollBar:SetPoint("TOPLEFT", frame, "TOPRIGHT", -13, -4)
				if (scrollToBottomButton and scrollToBottomButton:IsShown()) then
					scrollToBottomButton:SetPoint("BOTTOMRIGHT", frame.ResizeButton, "TOPRIGHT", -9, -11)
					scrollBar:SetPoint("BOTTOM", scrollToBottomButton, "TOP", -13, 5)
				elseif (frame.ResizeButton and frame.ResizeButton:IsShown()) then
					scrollBar:SetPoint("BOTTOM", frame.ResizeButton, "TOP", -13, 5)
				else
					scrollBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -13, 5)
				end

			elseif (buttonSide == "right") then 
				scrollBar:ClearAllPoints()
				scrollBar:SetPoint("TOPRIGHT", frame, "TOPLEFT", 13, -4)
				if (scrollToBottomButton and scrollToBottomButton:IsShown()) then
					scrollToBottomButton:SetPoint("BOTTOMLEFT", frame.ResizeButton, "TOPLEFT", 9, -11)
					scrollBar:SetPoint("BOTTOM", scrollToBottomButton, "TOP", 13, 5)
				elseif (frame.ResizeButton and frame.ResizeButton:IsShown()) then
					scrollBar:SetPoint("BOTTOM", frame.ResizeButton, "TOP", 13, 5)
				else
					scrollBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 13, 5)
				end
			end 
		end 
	end
end 

Module.UpdateChatWindowScale = function(self, frame)
	local targetScale = self:GetFrame("UICenter"):GetEffectiveScale()
	local parentScale = frame:GetParent():GetScale()
	local scale = targetScale / parentScale

	frame:SetScale(scale)

	local buttonFrame = self:GetChatWindowButtonFrame(frame)
	local scrollToBottomButton = self:GetChatWindowScrollToBottomButton(frame)
	if buttonFrame then 
		buttonFrame:SetWidth(Layout.ButtonFrameWidth/scale)
		buttonFrame:SetScale(scale)
	end 

	-- Chat tabs are direct descendants of the general dock manager, 
	-- which in turn is a direct descendant of UIParent
	local windowTab = self:GetChatWindowTab(frame)
	if windowTab then 
		windowTab:SetScale(scale)
	end 

	-- The editbox is a child of the chat frame
	local editBox = self:GetChatWindowEditBox(frame)
	if editBox then 
		editBox:SetScale(1)
	end 

	local scrollBar = self:GetChatWindowScrollBar(frame)
	local scrollThumb = self:GetChatWindowScrollBarThumbTexture(frame)
	if scrollBar then 
		scrollBar:SetScale(scale)
	end

end

Module.UpdateChatWindowScales = function(self)

	local targetScale = self:GetFrame("UICenter"):GetEffectiveScale()
	local parentScale = UIParent:GetScale()
	local scale = targetScale / parentScale

	local channelButton = self:GetChatWindowChannelButton()
	if channelButton then 
		channelButton:SetScale(scale)
	end 

	local deafenButton = self:GetChatWindowVoiceDeafenButton()
	if deafenButton then 
		deafenButton:SetScale(scale)
	end 

	local muteButton =self:GetChatWindowVoiceMuteButton()
	if muteButton then 
		muteButton:SetScale(scale)
	end 

	local menuButton = self:GetChatWindowMenuButton()
	if menuButton then 
		menuButton:SetScale(scale)
	end 

	for _,frameName in self:GetAllChatWindows() do 
		local frame = _G[frameName]
		if frame then 
			self:UpdateChatWindowScale(frame)
		end 
	end 
end 

Module.UpdateChatWindowPositions = function(self)
end 

Module.UpdateMainWindowButtonDisplay = function(self)

	local show

	local frame = self:GetSelectedChatFrame()
	if frame and frame.isDocked then 
		local editBox = self:GetChatWindowEditBox(frame)
		show = editBox and editBox:IsShown()
	end 

	local channelButton = self:GetChatWindowChannelButton()
	local deafenButton = self:GetChatWindowVoiceDeafenButton()
	local muteButton =self:GetChatWindowVoiceMuteButton()
	local menuButton = self:GetChatWindowMenuButton()

	if show then 
		if channelButton then 
			channelButton:Show()
		end 
		if VoiceChat_IsLoggedIn() then 
			if deafenButton then 
				deafenButton:Show()
			end 
			if muteButton then 
				muteButton:Show()
			end 
		else 
			if deafenButton then 
				deafenButton:Hide()
			end 
			if muteButton then 
				muteButton:Hide()
			end 
		end 
		if menuButton then 
			menuButton:Show()
		end

	else
		if channelButton then 
			channelButton:Hide()
		end 
		if deafenButton then 
			deafenButton:Hide()
		end 
		if muteButton then 
			muteButton:Hide()
		end 
		if menuButton then 
			menuButton:Hide()
		end 
	end 

	-- Post update button alignment in case changes to visible ones
	if frame then 
		self:UpdateChatWindowButtons(frame)
	end 
end

Module.PostCreateTemporaryChatWindow = function(self, frame, ...)
	local chatType, chatTarget, sourceChatFrame, selectWindow = ...

	-- Some temporary frames have weird fonts (like the pet battle log)
	frame:SetFontObject(ChatFrame1:GetFontObject())

	-- Run the normal post creation method
	self:PostCreateChatWindow(frame)
end 

Module.PostCreateChatWindow = function(self, frame)

	-- Window
	------------------------------
	frame:SetFading(Layout.ChatFadeTime)
	frame:SetTimeVisible(Layout.ChatVisibleTime)
	frame:SetIndentedWordWrap(Layout.ChatIndentedWordWrap) 

	-- just lock all frames away from our important objects
	frame:SetClampRectInsets(unpack(Layout.DefaultClampRectInsets))

	-- Set the frame's alpha and color
	FCF_SetWindowColor(frame, 0, 0, 0, 0)
	FCF_SetWindowAlpha(frame, 0, 1)

	-- Update the scale of this window
	self:UpdateChatWindowScale(frame)

	-- Tabs
	------------------------------
	-- strip away textures
	for tex in self:GetChatWindowTabTextures(frame) do 
		tex:SetTexture(nil)
		tex:SetAlpha(0)
	end 

	-- Take control of the tab's alpha changes
	-- and disable blizzard's own fading. 
	local tab = self:GetChatWindowTab(frame)
	tab:SetAlpha(1)
	tab.SetAlpha = UIFrameFadeRemoveFrame

	local tabText = self:GetChatWindowTabText(frame) 
	tabText:Hide()

	local tabIcon = self:GetChatWindowTabIcon(frame)
	if tabIcon then 
		tabIcon:Hide()
	end

	-- Hook all tab sizes to slightly smaller than ChatFrame1's chat
	hooksecurefunc(tabText, "Show", function() 
		-- Make it 2px smaller (before scaling), 
		-- but make 10px the minimum size.
		local font, size, style = ChatFrame1:GetFontObject():GetFont()
		size = math_floor(((size*10) + .5)/10)
		if (size + 2 >= 10) then 
			size = size - 2
		end 

		-- Stupid blizzard changing sizes by 0.0000001 and similar
		local ourFont, ourSize, ourStyle = tabText:GetFont()
		ourSize = math_floor(((ourSize*10) + .5)/10)

		-- Make sure the tabs keeps the same font as the frame, 
		-- and not some completely different size as it does by default. 
		if (ourFont ~= font) or (ourSize ~= size) or (style ~= ourStyle) then 
			tabText:SetFont(font, size, style)
		end 
	end)

	-- Toggle tab text visibility on hover
	tab:HookScript("OnEnter", function() 
		tabText:Show() 
		if tabIcon and frame.isTemporary then 
			tabIcon:Show()
		end
	end)
	tab:HookScript("OnLeave", function() 
		tabText:Hide() 
		if tabIcon and frame.isTemporary then 
			tabIcon:Hide()
		end
	end)
	tab:HookScript("OnClick", function() 
		-- We need to hide both tabs and button frames here, 
		-- but it must depend on visible editBoxes. 
		local frame = self:GetSelectedChatFrame()
		local editBox = self:GetChatWindowCurrentEditBox(frame)
		if editBox then
			editBox:Hide() 
		end
		local buttonFrame = self:GetChatWindowButtonFrame(frame)
		if buttonFrame then
			buttonFrame:Hide() 
		end
	end)

	local anywhereButton = self:GetChatWindowClickAnywhereButton(frame)
	if anywhereButton then 
		anywhereButton:HookScript("OnEnter", function() tabText:Show() end)
		anywhereButton:HookScript("OnLeave", function() tabText:Hide() end)
		anywhereButton:HookScript("OnClick", function() 
			if frame then 
				FCF_Tab_OnClick(frame) -- click the tab to actually select this frame
				local editBox = self:GetChatWindowCurrentEditBox(frame)
				if editBox then
					editBox:Hide() -- hide the annoying half-transparent editBox 
				end
			end 
		end)
	end


	-- EditBox
	------------------------------
	-- strip away textures
	for tex in self:GetChatWindowEditBoxTextures(frame) do 
		tex:SetTexture(nil)
		tex:SetAlpha(0)
	end 

	local editBox = self:GetChatWindowEditBox(frame)
	editBox:Hide()
	editBox:SetAltArrowKeyMode(false) 
	editBox:SetHeight(Layout.EditBoxHeight)
	editBox:ClearAllPoints()
	editBox:SetPoint("LEFT", frame, "LEFT", -Layout.EditBoxOffsetH, 0)
	editBox:SetPoint("RIGHT", frame, "RIGHT", Layout.EditBoxOffsetH, 0)
	editBox:SetPoint("TOP", frame, "BOTTOM", 0, -1)

	-- do any editBox backdrop styling here

	-- make it auto-hide when focus is lost
	editBox:HookScript("OnEditFocusGained", function(self) self:Show() end)
	editBox:HookScript("OnEditFocusLost", function(self) self:Hide() end)

	-- hook editBox updates to our coloring method
	--hooksecurefunc("ChatEdit_UpdateHeader", function(...) self:UpdateEditBox(...) end)

	-- Avoid dying from having the editBox open in combat
	editBox:HookScript("OnTextChanged", function(self)
		local msg = self:GetText()
		local maxRepeats = UnitAffectingCombat("player") and 5 or 10
		if (string_len(msg) > maxRepeats) then
			local stuck = true
			for i = 1, maxRepeats, 1 do 
				if (string_sub(msg,0-i, 0-i) ~= string_sub(msg,(-1-i),(-1-i))) then
					stuck = false
					break
				end
			end
			if stuck then
				self:SetText("")
				self:Hide()
				return
			end
		end
	end)

	-- ButtonFrame
	------------------------------
	local buttonFrame = self:GetChatWindowButtonFrame(frame)
	buttonFrame:SetWidth(Layout.ButtonFrameWidth)

	for tex in self:GetChatWindowButtonFrameTextures(frame) do 
		tex:SetTexture(nil)
		tex:SetAlpha(0)
	end

	editBox:HookScript("OnShow", function() 
		local frame = self:GetSelectedChatFrame()
		if frame then
			local buttonFrame = self:GetChatWindowButtonFrame(frame)
			if buttonFrame then
				buttonFrame:Show()
				buttonFrame:SetAlpha(1)
			end
			if frame.isDocked then
				self:UpdateMainWindowButtonDisplay(true)
			end
			self:UpdateChatWindowButtons(frame)
			self:UpdateChatWindowAlpha(frame)

			-- Hook all editbox chat sizes to the same as ChatFrame1
			local fontObject = frame:GetFontObject()
			local font, size, style = fontObject:GetFont()
			local x,y = fontObject:GetShadowOffset()
			local r, g, b, a = fontObject:GetShadowColor()
			local ourFont, ourSize, ourStyle = editBox:GetFont()

			-- Stupid blizzard changing sizes by 0.0000001 and similar
			size = math_floor(((size*10) + .5)/10)
			ourSize = math_floor(((ourSize*10) + .5)/10)

			editBox:SetFontObject(fontObject)
			editBox.header:SetFontObject(fontObject)

			-- Make sure the editbox keeps the same font as the frame, 
			-- and not some completely different size as it does by default. 
			if (ourFont ~= font) or (ourSize ~= size) or (style ~= ourStyle) then 
				editBox:SetFont(font, size, style)
			end 

			local ourFont, ourSize, ourStyle = editBox.header:GetFont()
			ourSize = math_floor(((ourSize*10) + .5)/10)

			if (ourFont ~= font) or (ourSize ~= size) or (style ~= ourStyle) then 
				editBox.header:SetFont(font, size, style)
			end 

			editBox:SetShadowOffset(x,y)
			editBox:SetShadowColor(r,g,b,a)

			editBox.header:SetShadowOffset(x,y)
			editBox.header:SetShadowColor(r,g,b,a)
		end
	end)

	editBox:HookScript("OnHide", function() 
		local frame = self:GetSelectedChatFrame()
		if frame then
			local buttonFrame = self:GetChatWindowButtonFrame(frame)
			if buttonFrame then
				buttonFrame:Hide()
			end
			if frame.isDocked then
				self:UpdateMainWindowButtonDisplay(false)
			end
			self:UpdateChatWindowButtons(frame)
			self:UpdateChatWindowAlpha(frame)
		end
	end)

	hooksecurefunc(buttonFrame, "SetAlpha", function(buttonFrame, alpha)
		if alphaLocks[buttonFrame] then 
			return 
		else
			alphaLocks[buttonFrame] = true
			local frame = self:GetSelectedChatFrame()
			if UIFrameIsFading(frame) then
				UIFrameFadeRemoveFrame(frame)
			end	
			local editBox = self:GetChatWindowCurrentEditBox(frame)
			if editBox then 
				if editBox:IsShown() then
					buttonFrame:SetAlpha(1) 
				else
					buttonFrame:SetAlpha(0)
				end 
			end 
			alphaLocks[buttonFrame] = false
		end 
	end)
	buttonFrame:Hide()


	-- Frame specific buttons
	------------------------------
	local scrollToBottomButton = self:GetChatWindowScrollToBottomButton(frame)
	if scrollToBottomButton then 
		self:SetUpButton(scrollToBottomButton, Layout.ButtonTextureScrollToBottom)
		scrollToBottomButton:SetPoint("BOTTOMRIGHT", frame.ResizeButton, "TOPRIGHT", -9, -11)
	end 

	local scrollBar = self:GetChatWindowScrollBar(frame)
	if scrollBar then 
		scrollBar:SetWidth(Layout.ScrollBarWidth)
	end

	local scrollThumb = self:GetChatWindowScrollBarThumbTexture(frame)
	if scrollThumb then 
		scrollThumb:SetWidth(Layout.ScrollBarWidth)
	end

	local minimizeButton = self:GetChatWindowMinimizeButton(frame)
	if minimizeButton then 
		self:SetUpButton(minimizeButton, Layout.ButtonTextureMinimizeButton)
	end 


	-- These will fire our own positioning callbacks
	FCF_UpdateScrollbarAnchors(frame)
	FCF_UpdateButtonSide(frame)

end 

Module.SetUpAlphaScripts = function(self)

	_G.CHAT_FRAME_BUTTON_FRAME_MIN_ALPHA = 0

	-- avoid mouseover alpha change, yet keep the background textures
	local alphaProxy = function(...) self:UpdateChatWindowAlpha(...) end
	
	hooksecurefunc("FCF_FadeInChatFrame", alphaProxy)
	hooksecurefunc("FCF_FadeOutChatFrame", alphaProxy)
	hooksecurefunc("FCF_SetWindowAlpha", alphaProxy)
	
end 

Module.SetUpScrollScripts = function(self)

	-- allow SHIFT + MouseWheel to scroll to the top or bottom
	hooksecurefunc("FloatingChatFrame_OnMouseScroll", function(self, delta)
		if delta < 0 then
			if IsShiftKeyDown() then
				self:ScrollToBottom()
			end
		elseif delta > 0 then
			if IsShiftKeyDown() then
				self:ScrollToTop()
			end
		end
	end)

	hooksecurefunc("FCF_UpdateButtonSide", function(frame) self:UpdateChatWindowButtons(frame) end)
	hooksecurefunc("FCF_UpdateScrollbarAnchors", function(frame) self:UpdateChatWindowButtons(frame) end)

end 

Module.SetUpMainFrames = function(self)

	-- Create a holder frame for our main chat window,
	-- which we'll use to move and size the window without 
	-- having to parent it to our upscaled master frame. 
	-- 
	-- The problem is that WoW renders chat to pixels 
	-- when the font is originally defined, 
	-- and any scaling later on is applied to that pixel font, 
	-- not to the original vector font. 
	local frame = self:CreateFrame("Frame", nil, "UICenter")
	frame:SetPoint(unpack(Layout.DefaultChatFramePlace))
	frame:SetSize(unpack(Layout.DefaultChatFrameSize))

	self:HandleAllChatWindows()
	self:SetChatWindowAsSlaveTo(ChatFrame1, frame)

	FCF_SetWindowColor(ChatFrame1, 0, 0, 0, 0)
	FCF_SetWindowAlpha(ChatFrame1, 0, 1)
	FCF_UpdateButtonSide(ChatFrame1)

end 

Module.SetUpButton = function(self, button, texture)
	if (not Layout.UseButtonTextures) then 
		return 
	end 

	local normal = button:GetNormalTexture()
	normal:SetTexture(texture or Layout.ButtonTextureNormal)
	normal:SetVertexColor(unpack(Layout.ButtonTextureColor))
	normal:ClearAllPoints()
	normal:SetPoint("CENTER", 0, 0)
	normal:SetSize(unpack(Layout.ButtonTextureSize))

	local highlight = button:GetHighlightTexture()
	highlight:SetTexture(texture or Layout.ButtonTextureNormal)
	highlight:SetVertexColor(1,1,1,.075)
	highlight:ClearAllPoints()
	highlight:SetPoint("CENTER", 0, 0)
	highlight:SetSize(unpack(Layout.ButtonTextureSize))
	highlight:SetBlendMode("ADD")

	local pushed = button:GetPushedTexture()
	pushed:SetTexture(texture or Layout.ButtonTextureNormal)
	pushed:SetVertexColor(unpack(Layout.ButtonTextureColor))
	pushed:ClearAllPoints()
	pushed:SetPoint("CENTER", -1, -2)
	pushed:SetSize(unpack(Layout.ButtonTextureSize))

	local disabled = button:GetDisabledTexture()
	if disabled then 
		disabled:SetTexture(texture or Layout.ButtonTextureNormal)
		disabled:SetVertexColor(unpack(Layout.ButtonTextureColor))
		disabled:SetDesaturated(true)
		disabled:ClearAllPoints()
		disabled:SetPoint("CENTER", 0, 0)
		disabled:SetSize(unpack(Layout.ButtonTextureSize))
	end 

	local flash = button.Flash
	if flash then 
		flash:SetTexture(texture or Layout.ButtonTextureNormal)
		flash:SetVertexColor(1,1,1,.075)
		flash:ClearAllPoints()
		flash:SetPoint("CENTER", 0, 0)
		flash:SetSize(unpack(Layout.ButtonTextureSize))
		flash:SetBlendMode("ADD")
	end 

	button:HookScript("OnMouseDown", function() 
		highlight:SetPoint("CENTER", -1, -2) 
		if flash then 
			flash:SetPoint("CENTER", -1, -2) 
		end 
	end)

	button:HookScript("OnMouseUp", function() 
		highlight:SetPoint("CENTER", 0, 0) 
		if flash then 
			flash:SetPoint("CENTER", 0, 0) 
		end 
	end)
end 

Module.SetUpMainButtons = function(self)
	local channelButton = self:GetChatWindowChannelButton()
	if channelButton then 
		self:SetUpButton(channelButton)
	end 
	local deafenButton = self:GetChatWindowVoiceDeafenButton()
	if deafenButton then 
		self:SetUpButton(deafenButton)
	end 
	local muteButton = self:GetChatWindowVoiceMuteButton()
	if muteButton then 
		self:SetUpButton(muteButton)
	end 
	local menuButton = self:GetChatWindowMenuButton()
	if menuButton then 
		self:SetUpButton(menuButton, Layout.ButtonTextureChatEmotes)
	end 
end 

Module.OnEvent = function(self, event, ...)
	self:UpdateMainWindowButtonDisplay()

	-- Do this cause taint? Shouldn't, but you never know. 
	if ((event == "CG_INTERFACE_SCALE_UPDATE") or (event == "CG_WORLD_SCALE_UPDATE")) then 
		self:UpdateChatWindowScales()
	end 
end 

Module.PreInit = function(self)
	local PREFIX = Core:GetPrefix()
	Layout = CogWheel("LibDB"):GetDatabase(PREFIX..":[BlizzardChatFrames]")
end

Module.OnInit = function(self)
	self:SetUpAlphaScripts()
	self:SetUpScrollScripts()
	self:SetUpMainFrames()
	self:SetUpMainButtons()
	self:UpdateChatWindowScales()
end 

Module.OnEnable = function(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("VOICE_CHAT_LOGIN", "OnEvent")
	self:RegisterEvent("VOICE_CHAT_LOGOUT", "OnEvent")
	self:RegisterEvent("VOICE_CHAT_MUTED_CHANGED", "OnEvent")
	self:RegisterEvent("VOICE_CHAT_SILENCED_CHANGED", "OnEvent")
	self:RegisterEvent("VOICE_CHAT_DEAFENED_CHANGED", "OnEvent")
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED", "OnEvent")
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED", "OnEvent")
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SILENCED_CHANGED", "OnEvent")
	self:RegisterMessage("CG_INTERFACE_SCALE_UPDATE", "OnEvent")
	self:RegisterMessage("CG_WORLD_SCALE_UPDATE", "OnEvent")
end 
