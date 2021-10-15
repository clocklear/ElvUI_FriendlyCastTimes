local ADDON_NAME = ...;
local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames')
local NP = E:GetModule('NamePlates')
local FCT = E:NewModule("FriendlyCastTimes")
local EP = LibStub("LibElvUIPlugin-1.0")

E:RegisterModule(FCT:GetName())

local function InjectOptions()
  if not E.Options.args.FCT then
    E.Options.args.FCT = {
      type = "group",
      name = "Friendly Cast Times",
      args = {
        L1 = { type = "description", fontSize = "medium", order = 1, name = "A simple plugin for ElvUI that converts long cast times (more than 60 seconds) into more human readable formats (mm:ss, or hh:mm if longer than 1 hour).\n\nNo configuration is required.  Install alongside ElvUI and you're good to go!" },
        L2 = { type = "header", name = "Credits", order = 2 },
        L3 = { type = "description", order = 3, fontSize = "medium", name = "Written by clocklear (github.com/clocklear)" },
        L4 = { type = "description", order = 4, fontSize = "small",name = "",width = "full" },
        L5 = {order = 5, type = "header", name = "Feedback"},
        L6 = { type = "description", order = 6, fontSize = "medium", name = "Need help?  Have a feature request?  Open an issue on the code repository for ElvUI_FriendlyCastTimes or send me a PM on Reddit." },
        L7 = { type = "description", order = 7, fontSize = "medium", name = "", width = "full", },
        L8 = { type = "description", order = 8, fontSize = "medium", name = "Issue Tracker:", width = "half", },
        L9 = { type = "description", order = 9, fontSize = "medium", name = "github.com/clocklear/ElvUI_FriendlyCastTimes/issues", width = "double", },
        L10 = { type = "description", order = 10, fontSize = "small", name = "", width = "full", },
        L11 = { type = "description", order = 11, fontSize = "medium", name = "Reddit:", width = "half", },
        L12 = { type = "description", order = 12, fontSize = "medium", name = "neoeraser (reddit.com/u/neoeraser)", width = "double", },
      }
    }
  end
end

EP:RegisterPlugin(ADDON_NAME, InjectOptions)

-- Helper func for converting raw time (seconds) into mm:ss when > 1 min and < 1 hour, and hh:mm when > 1 hour
local function TimeFormat(num)
  if num <= 60 then
		return ("%.1f"):format(num)
	elseif num <= 3600 then
		return ("%d:%02d"):format(num / 60, num % 60)
	else
		return ("%d:%02d"):format( num / 3600, (num % 3600) / 60)
	end
end

-- Overwrite original unit frame cast time calculation funcs
function UF:CustomCastDelayText(duration)
	local db = self:GetParent().db
	if not (db and db.castbar) then return end
	db = db.castbar.format

	if self.channeling then
		if db == 'CURRENT' then
			self.Time:SetFormattedText('%s |cffaf5050%.1f|r', TimeFormat(abs(duration - self.max)), self.delay)
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText('%s / %s |cffaf5050%.1f|r', TimeFormat(duration), TimeFormat(self.max), self.delay)
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText('%s |cffaf5050%.1f|r', TimeFormat(duration), self.delay)
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText('%s / %s |cffaf5050%.1f|r', TimeFormat(abs(duration - self.max)), TimeFormat(self.max), self.delay)
		end
	else
		if db == 'CURRENT' then
			self.Time:SetFormattedText('%s |cffaf5050%s %.1f|r', TimeFormat(duration), '+', TimeFormat(self.delay))
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText('%s / %s |cffaf5050%s %.1f|r', TimeFormat(duration), TimeFormat(self.max), '+', self.delay)
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText('%s |cffaf5050%s %.1f|r', TimeFormat(abs(duration - self.max)), '+', self.delay)
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText('%s / %s |cffaf5050%s %.1f|r', TimeFormat(abs(duration - self.max)), TimeFormat(self.max), '+', self.delay)
		end
	end

	self.Time:SetWidth(self.Time:GetStringWidth())
end

function UF:CustomTimeText(duration)
	local db = self:GetParent().db
	if not (db and db.castbar) then return end
	db = db.castbar.format

	if self.channeling then
		if db == 'CURRENT' then
			self.Time:SetFormattedText('%s', TimeFormat(abs(duration - self.max)))
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText('%s / %s', TimeFormat(abs(duration - self.max)), TimeFormat(self.max))
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText('%s', TimeFormat(duration))
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText('%s / %s', TimeFormat(duration), TimeFormat(self.max))
		end
	else
		if db == 'CURRENT' then
			self.Time:SetFormattedText('%s', TimeFormat(duration))
		elseif db == 'CURRENTMAX' then
			self.Time:SetFormattedText('%s / %s', TimeFormat(duration), TimeFormat(self.max))
		elseif db == 'REMAINING' then
			self.Time:SetFormattedText('%s', TimeFormat(abs(duration - self.max)))
		elseif db == 'REMAININGMAX' then
			self.Time:SetFormattedText('%s / %s', TimeFormat(abs(duration - self.max)), TimeFormat(self.max))
		end
	end

	self.Time:SetWidth(self.Time:GetStringWidth())
end

-- Overwrite nameplate cast time calculation funcs
function NP:Castbar_CustomDelayText(duration)
	if self.channeling then
		if self.channelTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%s |cffaf5050%.1f|r', TimeFormat(abs(duration - self.max)), self.delay)
		elseif self.channelTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%s / %s |cffaf5050%.1f|r', TimeFormat(duration), TimeFormat(self.max), self.delay)
		elseif self.channelTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%s |cffaf5050%.1f|r', TimeFormat(duration), self.delay)
		elseif self.channelTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%s / %s |cffaf5050%.1f|r', TimeFormat(abs(duration - self.max)), TimeFormat(self.max), self.delay)
		end
	else
		if self.castTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%s |cffaf5050%s %.1f|r', TimeFormat(duration), '+', self.delay)
		elseif self.castTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%s / %s |cffaf5050%s %.1f|r', TimeFormat(duration), TimeFormat(self.max), '+', self.delay)
		elseif self.castTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%s |cffaf5050%s %.1f|r', TimeFormat(abs(duration - self.max)), '+', self.delay)
		elseif self.castTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%s / %s |cffaf5050%s %.1f|r', TimeFormat(abs(duration - self.max)), TimeFormat(self.max), '+', self.delay)
		end
	end
end

function NP:Castbar_CustomTimeText(duration)
	if self.channeling then
		if self.channelTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%s', TimeFormat(abs(duration - self.max)))
		elseif self.channelTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%s / %s', TimeFormat(abs(duration - self.max)), TimeFormat(self.max))
		elseif self.channelTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%s', TimeFormat(duration))
		elseif self.channelTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%s / %s', TimeFormat(duration), TimeFormat(self.max))
		end
	else
		if self.castTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%s', TimeFormat(duration))
		elseif self.castTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%s / %s', TimeFormat(duration), TimeFormat(self.max))
		elseif self.castTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%s', TimeFormat(abs(duration - self.max)))
		elseif self.castTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%s / %s', TimeFormat(abs(duration - self.max)), TimeFormat(self.max))
		end
	end
end