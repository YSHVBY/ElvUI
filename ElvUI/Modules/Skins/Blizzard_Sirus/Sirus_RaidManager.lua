---@diagnostic disable: undefined-global, redundant-parameter, param-type-mismatch
local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables
local function AllHideAndHandle(self,bool)
    self.TopLeft:Hide();
    self.TopRight:Hide();
    self.BottomLeft:Hide();
    self.BottomRight:Hide();
    self.TopMiddle:Hide();
    self.MiddleLeft:Hide();
    self.MiddleRight:Hide();
    self.BottomMiddle:Hide();
    self.MiddleMiddle:Hide();
	if bool then
		S:HandleButton(self)
	end
end

local classIcons = {
	["SHAMAN"] = "Interface\\AddOns\\ElvUI\\Media\\Textures\\flat_shaman.blp",
	["WARRIOR"] = "Interface\\AddOns\\ElvUI\\Media\\Textures\\flat_warrior.blp",
	["MAGE"] = "Interface\\AddOns\\ElvUI\\Media\\Textures\\flat_mage.blp",
	["ROGUE"] = "Interface\\AddOns\\ElvUI\\Media\\Textures\\flat_rogue.blp",
	["DRUID"] = "Interface\\AddOns\\ElvUI\\Media\\Textures\\flat_druid.blp",
	["HUNTER"] = "Interface\\AddOns\\ElvUI\\Media\\Textures\\flat_hunter.blp",
	["PRIEST"] = "Interface\\AddOns\\ElvUI\\Media\\Textures\\flat_priest.blp",
	["WARLOCK"] = "Interface\\AddOns\\ElvUI\\Media\\Textures\\flat_warlock.blp",
	["PALADIN"] = "Interface\\AddOns\\ElvUI\\Media\\Textures\\flat_paladin.blp",
	["DEATHKNIGHT"] = "Interface\\AddOns\\ElvUI\\Media\\Textures\\flat_dk.blp",
	-- ["SHAMAN"] = "",
}
local function GetNumClasses(class)
	local int = 0;
	for i = 1,GetNumRaidMembers() do
		local unit = "raid"..i;
		if UnitExists(unit) and select(2,UnitClass(unit)) == class then
			int = int+1;
		end
	end
	return int
end
local ui = {}
function ui:CreateClassFrame(parent,class,point)
	local frame = CreateFrame("Frame",nil,parent)
	frame.class = class
	frame:RegisterEvent("RAID_ROSTER_UPDATE")
	frame:RegisterEvent("PARTY_MEMBERS_CHANGED")

	frame:SetScript("OnEvent",function(self,upd)
		local num = GetNumClasses(self.class)
		if num == 0 then
			self.texture:SetDesaturated(1)
		else
			self.texture:SetDesaturated(nil)
		end
		self.fs:SetText(num)
	end)
	frame:SetSize(28,28)
	frame:SetPoint(point[1],point[2],point[3],point[4],point[5])
	frame.texture = frame:CreateTexture(nil,"ARTWORK")
	frame.texture:SetTexture(classIcons[class])
	frame.texture:SetAllPoints(frame)
	frame.fs = frame:CreateFontString("OVERLAY")
	frame.fs:FontTemplate()
	frame.fs:SetPoint("CENTER", frame, "CENTER", 5, -5)
	frame.fs:SetText(GetNumClasses(self.class))
	-- fs:Point(point[1],point[2],point[3],point[4],point[5])
	return frame
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true then return end
	-- CompactRaidFrameManager.displayFrame.label:Hide()
	local frameManager = CompactRaidFrameManager
	local displayFrame = frameManager.displayFrame
	-- local sizeForCompat = E.private.unitframe.disabledBlizzardFrames.raidFrames and 264 or 264
	-- CompactRaidFrameManagerDisplayFrameHeaderDelineator:StripTextures()
	frameManager:StripTextures()
	frameManager:CreateBackdrop()
	-- frameManager.backdrop:Point("TOPLEFT", 0, 0)
	-- frameManager.backdrop:Point("BOTTOMRIGHT", 0, 0)
	-- frameManager:Size(200,100)
	S:HandleButton(frameManager.toggleButton)
	frameManager.toggleButton:ClearAllPoints()
	frameManager.toggleButton:Width(10)
	frameManager.toggleButton:Point("RIGHT", -7, 0)

	frameManager.toggleButton.Icon = frameManager.toggleButton:CreateTexture()
	frameManager.toggleButton.Icon:Size(16)
	frameManager.toggleButton.Icon:SetPoint("CENTER")
	frameManager.toggleButton.Icon:SetTexture(E.Media.Textures.ArrowUp)
	frameManager.toggleButton.Icon:SetRotation(S.ArrowRotation.right)

	hooksecurefunc(frameManager.toggleButton:GetNormalTexture(), "SetTexCoord", function(_, a, b)
		if a > 0 then
			frameManager.toggleButton.Icon:SetRotation(S.ArrowRotation.left)
			-- if not InCombatLockdown then
			-- 	frameManager:Size(200,sizeForCompat)
			-- end
		elseif b < 1 then
			frameManager.toggleButton.Icon:SetRotation(S.ArrowRotation.right)
			-- if not InCombatLockdown then
			-- 	frameManager:Size(200,100)
			-- end
		end
	end)
	displayFrame:StripTextures()

	displayFrame.memberCountLabel:SetPoint("TOPRIGHT", -18, -8)

	for i = 1, 8 do
		_G["CompactRaidFrameManagerDisplayFrameRaidMarkersRaidMarker"..i]:SetNormalTexture(E.Media.Textures.RaidIcons)
		-- _G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i]:StripTextures()
		AllHideAndHandle(_G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i],true)
		-- S:HandleButton(_G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i])
	end

	S:HandleDropDownBox(CompactRaidFrameManagerDisplayFrameProfileSelector)

	displayFrame.convertToRaid:StripTextures(nil, true)
	S:HandleButton(displayFrame.convertToRaid, true)

	AllHideAndHandle(CompactRaidFrameManagerDisplayFrameLeaderOptionsCountdown,true)
	AllHideAndHandle(CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck,true)

	AllHideAndHandle(CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton,false)
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetTemplate(nil, true)
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetHighlightTexture("")
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:HookScript("OnEnter", S.SetModifiedBackdrop)
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:HookScript("OnLeave", S.SetOriginalBackdrop)


	-- AllHideAndHandle(CompactRaidFrameManagerDisplayFrameLockedModeToggle,true)
	-- AllHideAndHandle(CompactRaidFrameManagerDisplayFrameHiddenModeToggle,true)

	S:HandleCheckBox(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton,true)

	-- /run print(RaidFrameAllAssistCheckButton.text:GetText())
	CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton.text:ClearAllPoints()
	CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton.text:SetPoint("RIGHT",50,0)
	CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton.text:SetText(RaidFrameAllAssistCheckButton.text:GetText())
	CompactRaidFrameManagerDisplayFrameOptionsButton:ClearAllPoints()
	CompactRaidFrameManagerDisplayFrameOptionsButton:SetPoint("TOPRIGHT", 0, -7)



	if E.private.unitframe.disabledBlizzardFrames.raidFrames then
		CompactRaidFrameManagerDisplayFrameLockedModeToggle:Kill()
		CompactRaidFrameManagerDisplayFrameHiddenModeToggle:Kill()
		for i = 1, 8 do
			_G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i]:Kill()
		end
		if InterfaceOptionsFrameCategoriesButton17:GetText() == "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|tПрофили рейда" then
			InterfaceOptionsFrameCategoriesButton17:Kill()
		end
		CompactRaidFrameManagerDisplayFrameOptionsButton:Kill()
		CompactRaidFrameManagerDisplayFrameProfileSelector:Kill()
		CompactRaidFrameManagerDisplayFrameFilterOptions:Kill()
		-- C_Timer:After(5, function()
		-- 	CompactRaidFrameManagerDisplayFrameRaidMarkers:ClearAllPoints()
		-- 	CompactRaidFrameManagerDisplayFrameRaidMarkers:SetPoint("TOPLEFT",CompactRaidFrameManagerDisplayFrame,"TOPLEFT",0,-40)
		-- 	CompactRaidFrameManagerDisplayFrameLeaderOptionsCountdown:ClearAllPoints()
		-- 	CompactRaidFrameManagerDisplayFrameLeaderOptionsCountdown:SetPoint("TOPLEFT", 20, 55)
		-- 	CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton:ClearAllPoints()
		-- 	CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton:SetPoint("TOPLEFT", CompactRaidFrameManagerDisplayFrameOptionFlowContainer, "TOPLEFT", 20, -128)
		-- 	CompactRaidFrameManager:Size(200,100)
		-- end)


		-- создал локально потому что нет имен и потом сделаю обновление чутка по другому
		local SHAMAN = ui:CreateClassFrame(frameManager,"SHAMAN",{"TOPLEFT",frameManager,"TOPLEFT",15,-40})
		local WARRIOR = ui:CreateClassFrame(frameManager,"WARRIOR",{"TOPLEFT",frameManager,"TOPLEFT",50,-40})
		local MAGE = ui:CreateClassFrame(frameManager,"MAGE",{"TOPLEFT",frameManager,"TOPLEFT",80,-40})
		local ROGUE = ui:CreateClassFrame(frameManager,"ROGUE",{"TOPLEFT",frameManager,"TOPLEFT",110,-40})
		local DRUID = ui:CreateClassFrame(frameManager,"DRUID",{"TOPLEFT",frameManager,"TOPLEFT",140,-40})
		local HUNTER = ui:CreateClassFrame(frameManager,"HUNTER",{"TOPLEFT",frameManager,"TOPLEFT",15,-80})
		local PRIEST = ui:CreateClassFrame(frameManager,"PRIEST",{"TOPLEFT",frameManager,"TOPLEFT",50,-80})
		local WARLOCK = ui:CreateClassFrame(frameManager,"WARLOCK",{"TOPLEFT",frameManager,"TOPLEFT",80,-80})
		local PALADIN = ui:CreateClassFrame(frameManager,"PALADIN",{"TOPLEFT",frameManager,"TOPLEFT",110,-80})
		local DEATHKNIGHT = ui:CreateClassFrame(frameManager,"DEATHKNIGHT",{"TOPLEFT",frameManager,"TOPLEFT",140,-80})

	else
		AllHideAndHandle(CompactRaidFrameManagerDisplayFrameLockedModeToggle,true)
		AllHideAndHandle(CompactRaidFrameManagerDisplayFrameHiddenModeToggle,true)
	end

end

S:AddCallback("Skin_RaidManager", LoadSkin)