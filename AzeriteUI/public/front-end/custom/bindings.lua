local ADDON, Private = ...

local Core = CogWheel("LibModule"):GetModule(ADDON)
if (not Core) then 
	return 
end

local Module = Core:NewModule("Bindings", "PLUGIN", "LibEvent", "LibDB", "LibFrame", "LibSound", "LibTooltip", "LibFader", "LibSlash")

-- Lua API
local _G = _G

-- WoW API
local GetCurrentBindingSet = _G.GetCurrentBindingSet
local InCombatLockdown = _G.InCombatLockdown
local LoadBindings = _G.LoadBindings
local SaveBindings = _G.SaveBindings

-- CHARACTER_KEY_BINDINGS = "Key Bindings for %s"
-- CHARACTER_SPECIFIC_KEYBINDINGS = "Character Specific Key Bindings"
-- KEY_BINDINGS = "Key Bindings"
-- KEY_BINDINGS_MAC = "Bindings"
-- KEY_UNBOUND_ERROR = "|cffff0000%s Function is Now Unbound!|r"

Module.OnChatCommand = function(self, editBox, ...)
	if InCombatLockdown() then 
		return 
	end 
	if (self:GetBindingFrame():IsShown()) then 
		self:CancelBindings()
	else 
		self:EnableBindMode()
	end
end

Module.EnableBindMode = function(self)
	if InCombatLockdown() then 
		-- add a printed message about why it can't happen?
		return 
	end 

	self.bindActive = true
	self:SetObjectFadeOverride(true)

	local ActionBars = Core:GetModule("ActionBarMain", true)
	if (ActionBars) then 
		ActionBars:SetForcedVisibility(true)
	end 

	self:GetBindingFrame():Show()
end 

Module.DisableBindMode = function(self)
	self.bindActive = false
	self:SetObjectFadeOverride(false)

	local ActionBars = Core:GetModule("ActionBarMain", true)
	if (ActionBars) then 
		ActionBars:SetForcedVisibility(false)
	end 

	self:GetBindingFrame():Hide()
end

Module.CancelBindings = function(self)
	LoadBindings(GetCurrentBindingSet())
	self:DisableBindMode()
end 

Module.ApplyBindings = function(self)
	SaveBindings(GetCurrentBindingSet())
	self:DisableBindMode()
end

Module.ChangeBindingSet = function(self)
	-- Check if current bindings have changed, 
	-- show a warning dialog if so. 
	if self.bindingsChanged then 
	end

	-- If accepted, or nothing changed, changed the profile; 
	if (self:GetBindingFrame().perCharacter:GetChecked()) then
		LoadBindings(CHARACTER_BINDINGS)
		SaveBindings(CHARACTER_BINDINGS)
	else
		LoadBindings(ACCOUNT_BINDINGS)
		SaveBindings(ACCOUNT_BINDINGS)
	end
end 

Module.RegisterButton = function(self, button, ...)
	
end

Module.OnEvent = function(self, event, ...)
	if (event == "PLAYER_REGEN_DISABLED") then 
		if self.bindActive then 
			-- Add a printed message about why it was canceled?
			self:CancelBindings()
		end	
	end
end

Module.PreInit = function(self)
	local PREFIX = Core:GetPrefix()
	L = CogWheel("LibLocale"):GetLocale(PREFIX)
	Layout = CogWheel("LibDB"):GetDatabase(PREFIX..": Layout [Bindings]")
end

Module.GetBindingsTooltip = function(self)
	return self:GetTooltip(ADDON.."_GetBindingsTooltip") or self:CreateTooltip(ADDON.."_GetBindingsTooltip")
end

Module.GetBindingFrame = function(self)
	if (not self.frame) then 
		local frame = self:CreateFrame("Frame", nil, "UICenter")
		frame:Hide()
		frame:SetFrameStrata("DIALOG")
		frame:SetFrameLevel(99)
		frame:EnableMouse(false)
		frame:EnableKeyboard(true)
		frame:EnableMouseWheel(true)
		frame:SetSize(unpack(Layout.Size))
		frame:Place(unpack(Layout.Place))
		frame.border = Layout.MenuWindow_CreateBorder(frame)


		local msg = frame:CreateFontString()
		msg:SetFontObject(Private.GetFont(14, true))
		msg:SetPoint("TOPLEFT", 40, -60)
		msg:SetSize(Layout.Size[1] - 80, Layout.Size[2] - 80 - 50)
		msg:SetJustifyH("LEFT")
		msg:SetJustifyV("TOP")
		msg:SetIndentedWordWrap(false)
		msg:SetWordWrap(true)
		msg:SetNonSpaceWrap(false)
		msg:SetText("Hover your mouse over any actionbutton and press a key or a mouse button to bind it. Press the ESC key to clear the current actionbutton's keybinding.")
		frame.msg = msg

		local perCharacter = frame:CreateFrame("CheckButton", nil, "OptionsCheckButtonTemplate")
		perCharacter:SetSize(32,32)
		perCharacter:SetHitRectInsets(-10, -10, -10, -10)
		perCharacter:SetPoint("TOPLEFT", 34, -16)
		perCharacter:SetScript("OnShow", function(self) self:SetChecked(GetCurrentBindingSet() == 2) end)
		perCharacter:SetScript("OnClick", function() self:ChangeBindingSet() end) 
		frame.perCharacter = perCharacter

		perCharacter:SetScript("OnEnter", function(self)
			local tooltip = Module:GetBindingsTooltip()
			tooltip:SetDefaultAnchor(self)
			tooltip:AddLine(CHARACTER_SPECIFIC_KEYBINDINGS, Private.Colors.title[1], Private.Colors.title[2], Private.Colors.title[3])
			tooltip:AddLine(CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP, Private.Colors.offwhite[1], Private.Colors.offwhite[2], Private.Colors.offwhite[3], true)
			tooltip:Show()
		end)

		perCharacter:SetScript("OnLeave", function(self)
			local tooltip = Module:GetBindingsTooltip()
			tooltip:Hide() 
		end)

		local perCharacterMsg = perCharacter:CreateFontString()
		perCharacterMsg:SetFontObject(Private.GetFont(14, true))
		perCharacterMsg:SetPoint("LEFT", perCharacter, "RIGHT", 10, 0)
		perCharacterMsg:SetJustifyH("CENTER")
		perCharacterMsg:SetJustifyV("TOP")
		perCharacterMsg:SetIndentedWordWrap(false)
		perCharacterMsg:SetWordWrap(true)
		perCharacterMsg:SetNonSpaceWrap(false)
		perCharacterMsg:SetText(CHARACTER_SPECIFIC_KEYBINDINGS)
		frame.perCharacter.msg = perCharacterMsg

		local cancel = Layout.MenuButton_PostCreate(frame:CreateFrame("Button"), CANCEL)
		cancel:SetSize(Layout.MenuButtonSize[1]*Layout.MenuButtonSizeMod, Layout.MenuButtonSize[2]*Layout.MenuButtonSizeMod)
		cancel:SetPoint("BOTTOMLEFT", 20, 10)
		cancel:SetScript("OnClick", function() self:CancelBindings() end)
		frame.cancel = cancel

		local apply = Layout.MenuButton_PostCreate(frame:CreateFrame("Button"), APPLY)
		apply:SetSize(Layout.MenuButtonSize[1]*Layout.MenuButtonSizeMod, Layout.MenuButtonSize[2]*Layout.MenuButtonSizeMod)
		apply:SetPoint("BOTTOMRIGHT", -20, 10)
		apply:SetScript("OnClick", function() self:ApplyBindings() end)
		frame.apply = apply

		if Layout.MenuButton_PostUpdate then 
			local PostUpdate = Layout.MenuButton_PostUpdate

			apply:HookScript("OnEnter", PostUpdate)
			apply:HookScript("OnLeave", PostUpdate)
			apply:HookScript("OnMouseDown", function(self) self.isDown = true; return PostUpdate(self) end)
			apply:HookScript("OnMouseUp", function(self) self.isDown = false; return PostUpdate(self) end)
			apply:HookScript("OnShow", function(self) self.isDown = false; return PostUpdate(self) end)
			apply:HookScript("OnHide", function(self) self.isDown = false; return PostUpdate(self) end)
			PostUpdate(apply)

			cancel:HookScript("OnEnter", PostUpdate)
			cancel:HookScript("OnLeave", PostUpdate)
			cancel:HookScript("OnMouseDown", function(self) self.isDown = true; return PostUpdate(self) end)
			cancel:HookScript("OnMouseUp", function(self) self.isDown = false; return PostUpdate(self) end)
			cancel:HookScript("OnShow", function(self) self.isDown = false; return PostUpdate(self) end)
			cancel:HookScript("OnHide", function(self) self.isDown = false; return PostUpdate(self) end)
			PostUpdate(cancel)
		else
			apply:HookScript("OnMouseDown", function(self) self.isDown = true end)
			apply:HookScript("OnMouseUp", function(self) self.isDown = false end)
			apply:HookScript("OnShow", function(self) self.isDown = false end)
			apply:HookScript("OnHide", function(self) self.isDown = false end)

			cancel:HookScript("OnMouseDown", function(self) self.isDown = true end)
			cancel:HookScript("OnMouseUp", function(self) self.isDown = false end)
			cancel:HookScript("OnShow", function(self) self.isDown = false end)
			cancel:HookScript("OnHide", function(self) self.isDown = false end)
		end 

		self.frame = frame
	end 
	return self.frame	
end

Module.HasBindingFrame = function(self)
	return self.frame and true or false
end

Module.GetCharSpecificDeletePopup = function(self)
end 

Module.GetCancelChangesPopup = function(self)
end 

Module.ConfirmCharacterSpecificDelete = function(self)
end

Module.ConfirmLosingBindingChanges = function(self)
end

Module.OnInit = function(self)
	--self:RegisterChatCommand("bind", "OnChatCommand") 
end 

Module.OnEnable = function(self)
	self:RegisterEvent("UPDATE_BINDINGS", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
end
