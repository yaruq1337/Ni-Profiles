local data = ni.utils.require("darhanger_leveling.lua");

local popup_shown = false;
local queue = {
	"Window",	
	"AutoTarget",
	"Universal pause",
	"Life Tap (Regen)",
	"Firestone",
	"Soulstone",
	"Healthstone",	
	"Fel Armor",
	"Fel Domination",
	"Summon pet (Imp)",
	"Soul Link",
	"Combat specific Pause",
	"Pet Attack/Follow",	
	"Healthstone (Use)",
	"Heal Potions (Use)",
	"Mana Potions (Use)",		
	"Racial Stuff",
	"Use enginer gloves",
	"Trinkets",
	"Spell Lock (Interrupt)",
	"Soulshatter",
	"Shadowflame",		
	"Life Tap (Glyph Buff)",
	"Life Tap",
	"Death Coil",
	"Rain of Fire",
	"Incinerate (Non cast)",
	"Curse of Elements",
	"Curse of Doom",
	"Curse of Agony",
	"Immolate",
	"Immolate AoE",
	"Chaos Bolt",
	"Conflagrate",
	"Life Tap (Moving)",	
	"Corruption",
	"Incinerate",
}
local abilities = {
-----------------------------------
	["Universal pause"] = function()
			if data.UniPause() then
			return true
		end
	end,
-----------------------------------
	["AutoTarget"] = function()
		if UnitAffectingCombat("player")
		 and (not UnitExists("target")
		 or (UnitExists("target") 
		 and not UnitCanAttack("player", "target"))) then
			ni.player.runtext("/targetenemy")
		end
	end,
-----------------------------------
	["Firestone"] = function()
		if not GetWeaponEnchantInfo() 
		 and not ni.player.ismoving()
		 and not UnitAffectingCombat("player") then
		 if not ni.player.hasitem(41174)
		 and IsUsableSpell(GetSpellInfo(60220))
		 and ni.spell.available(60220) then
			ni.spell.cast(60220)
			return true
		 else
			ni.player.useitem(41174)
			ni.player.useinventoryitem(16)
			return true
			end
		end
	end,
-----------------------------------
	["Soulstone"] = function()
		if not ni.player.hasitem(36895)
		 and not ni.player.ismoving()
		 and not UnitAffectingCombat("player")
		 and IsUsableSpell(GetSpellInfo(47884))
		 and ni.spell.available(47884) then
			ni.spell.cast(47884)
			return true
		 else
		 if UnitExists("focus")
		 and UnitInRange("focus")
		 and ni.player.hasitem(36895)
		 and not UnitIsDeadOrGhost("focus")
		 and not ni.unit.buff("focus", 47883)
		 and not ni.player.ismoving()
		 and ni.player.itemcd(36895) == 0 then
			ni.player.useitem(36895, "focus")
			return true
			end
		end
	end,
-----------------------------------
	["Healthstone"] = function()
		local hstones = { 36892, 36893, 36894 }
		if data.warlock.Stones == nil then
			for b = 0, 4 do
			for s = 1, GetContainerNumSlots(b) do
			for i = 1, #hstones do
			if GetContainerItemID(b, s) == hstones[i] then
				Stones = true;
			break
						end
					end
				end
			end
		end
		if Stones == nil
		and IsUsableSpell(GetSpellInfo(47878))
		and ni.spell.available(47878)
		and not ni.player.ismoving()
		and not UnitAffectingCombat("player") then
			ni.spell.cast(47878)
			return true
		end
	end,
-----------------------------------
	["Fel Armor"] = function()
		if not ni.player.buff(47893)
		 and ni.spell.available(47893)
		 and ni.spell.isinstant(47893) then
			ni.spell.cast(47893)
			return true
		end
	end,
-----------------------------------
	["Fel Domination"] = function()
		if not UnitExists("playerpet")
		 and ni.spell.isinstant(18708) 
		 and ni.spell.available(data.warlock.petDest)
		 and IsUsableSpell(GetSpellInfo(data.warlock.petDest))
		 and ni.spell.available(18708) then
			ni.spell.cast(18708)
			return true
		end
	end,
-----------------------------------
	["Summon pet (Imp)"] = function()
		if not UnitExists("playerpet")
		 and not ni.player.buff(61431)
		 and not ni.player.ismoving()
		 and not UnitAffectingCombat("player")
		 and IsUsableSpell(GetSpellInfo(data.warlock.petDest))
		 and ni.spell.available(data.warlock.petDest)
		 and GetTime() - data.warlock.LastSummon > 2 then
			ni.spell.cast(data.warlock.petDest)
			data.warlock.LastSummon = GetTime()
			return true
		end
	end,
-----------------------------------
	["Soul Link"] = function()
		if ni.spell.available(19028)
		 and UnitExists("playerpet")
		 and not ni.player.buff(19028)
		 and ni.spell.isinstant(19028) then
			ni.spell.cast(19028)
			return true
		end
	end,
-----------------------------------
	["Pet Attack/Follow"] = function()
		if ni.unit.hp("playerpet") < 20
		 and UnitExists("playerpet")
		 and UnitExists("target")
		 and UnitIsUnit("target", "pettarget")
		 and not UnitIsDeadOrGhost("playerpet") then
			data.petFollow()
		 else
		if UnitAffectingCombat("player")
		 and UnitExists("playerpet")
		 and ni.unit.hp("playerpet") > 60
		 and UnitExists("target")
		 and not UnitIsUnit("target", "pettarget")
		 and not UnitIsDeadOrGhost("playerpet") then 
			data.petAttack()
			end
		end
	end,
-----------------------------------
	["Life Tap (Regen)"] = function()
		if not UnitAffectingCombat("player")
		 and ni.player.power() < 85
		 and ni.player.hp() > 35
		 and ni.spell.isinstant(57946) then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Combat specific Pause"] = function()
		if data.casterStop()
		 or UnitCanAttack("player","target") == nil
		 or (UnitAffectingCombat("target") == nil 
		 and ni.unit.isdummy("target") == nil 
		 and UnitIsPlayer("target") == nil) then 
			return true
		end
	end,
-----------------------------------
	["Healthstone (Use)"] = function()
		local hstones = { 36892, 36893, 36894 }
		for i = 1, #hstones do
			if ni.player.power() < 35
			 and ni.player.hasitem(hstones[i]) 
			 and not ni.player.itemcd(hstones[i]) then
				ni.player.useitem(hstones[i])
				return true
			end
		end	
	end,
-----------------------------------
	["Heal Potions (Use)"] = function()
		local hpot = { 33447, 43569, 40087, 41166, 40067 }
		for i = 1, #hpot do
			if ni.player.hp() < 30
			 and ni.player.hasitem(hpot[i])
			 and not ni.player.itemcd(hpot[i]) then
				ni.player.useitem(hpot[i])
				return true
			end
		end
	end,
-----------------------------------
	["Mana Potions (Use)"] = function()
		local mpot = { 33448, 43570, 40087, 42545, 39671 }
		for i = 1, #mpot do
			if ni.player.power() < 25
			 and ni.player.hasitem(mpot[i])
			 and not ni.player.itemcd(mpot[i]) then
				ni.player.useitem(mpot[i])
				return true
			end
		end
	end,
-----------------------------------
	["Racial Stuff"] = function()
		local hracial = { 33697, 20572, 33702, 26297 }
		local alracial = { 20594, 28880 }
		--- Undead
		if IsSpellKnown(7744)
		 and data.forsaken()
		 and ni.spell.available(7744) then
				ni.spell.cast(7744)
				return true
		end
		--- Horde race
		for i = 1, #hracial do
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and IsSpellKnown(hracial[i])
		 and ni.spell.available(hracial[i])
		 and ni.spell.valid("target", 47809) then 
					ni.spell.cast(hracial[i])
					return true
			end
		end
		--- Ally race
		for i = 1, #alracial do
		if ni.spell.valid("target", 47809)
		 and ni.player.hp() < 20
		 and IsSpellKnown(alracial[i])
		 and ni.spell.available(alracial[i]) then 
					ni.spell.cast(alracial[i])
					return true
				end
			end
		end,
-----------------------------------
	["Use enginer gloves"] = function()
		if ni.player.slotcastable(10)
		 and ni.player.slotcd(10) == 0 
		 and ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.spell.valid("target", 47809) then
			ni.player.useinventoryitem(10)
			return true
		end
	end,
-----------------------------------
	["Trinkets"] = function()
		if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(13)
		 and ni.player.slotcd(13) == 0 
		 and ni.spell.valid("target", 47809) then
			ni.player.useinventoryitem(13)
		else
		 if ( ni.vars.combat.cd or ni.unit.isboss("target") )
		 and ni.player.slotcastable(14)
		 and ni.player.slotcd(14) == 0 
		 and ni.spell.valid("target", 47809) then
			ni.player.useinventoryitem(14)
			return true
			end
		end
	end,
-----------------------------------	
	["Spell Lock (Interrupt)"] = function()
		if ni.spell.shouldinterrupt("target")
		 and IsSpellKnown(19647, true)
		 and GetSpellCooldown(19647) == 0
		 and GetTime() - data.LastInterrupt > 9 then
			ni.spell.castinterrupt("target")
			data.LastInterrupt = GetTime()
			return true
		end
	end,
-----------------------------------	
	["Soulshatter"] = function()
		if #ni.members > 1
		 and ni.unit.threat("player") >= 2
		 and ni.spell.cd(29858) == 0
		 and ni.spell.isinstant(29858) 
		 and IsUsableSpell(GetSpellInfo(29858)) then 
			ni.spell.cast(29858)
			return true
		end
	end,
-----------------------------------
	["Shadowflame"] = function()	
		if ni.player.distance("target") < 6
		 and ni.spell.available(61290)
		 and ni.spell.isinstant(61290) then
			ni.spell.cast(61290)
			return true
		end
	end,
-----------------------------------
	["Life Tap (Glyph Buff)"] = function()
		if ni.player.hasglyph(63320)
		 and not ni.player.buff(63321)
		 and ni.spell.isinstant(57946) then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Life Tap"] = function()
		if ni.player.power() <= 20
		 and ni.player.hp() > 50 then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Life Tap (Moving)"] = function()
		local elem = data.warlock.elem()
		local CotE = data.warlock.CotE()
		local eplag = data.warlock.eplag()
		local earmoon = data.warlock.earmoon()
		local agony = data.warlock.agony()
		local doom = data.warlock.doom()
		if ni.player.ismoving()
		 and ni.player.power() < 75
		 and ni.player.hp() > 50
		 and (elem or CotE or eplag or earmoon or doom or agony)
		 and ni.unit.debuffremaining("target", 47813, "player")
		 and ni.unit.debuffremaining("target", 47811, "player")
		 and ni.spell.isinstant(57946) then
			ni.spell.cast(57946)
			return true
		end
	end,
-----------------------------------
	["Death Coil"] = function()
		if ni.player.hp() < 47
		 and ni.spell.available(47860)
		 and ni.spell.valid("target", 47860, true, true) then
			ni.spell.cast(47860, "target")
			return true
		end
	end,
-----------------------------------
	["Rain of Fire"] = function()
		if ni.vars.combat.aoe
		 and not ni.player.ismoving()
		 and ni.spell.available(47820) then
			ni.spell.castat(47820, "target")
			return true
		end
	end,
-----------------------------------
	["Incinerate (Non cast)"] = function()
		if ni.player.buff(34936)
		 and ni.spell.available(47838)
		 and ni.spell.valid("target", 47838, true, true) then
			ni.spell.cast(47838, "target")
			return true
		end
	end,
-----------------------------------
	["Curse of Elements"] = function()
		local elem = data.warlock.elem()
		local CotE = data.warlock.CotE()
		local eplag = data.warlock.eplag()
		local earmoon = data.warlock.earmoon()
		if not (elem or CotE or eplag or earmoon)
		 and ni.spell.available(47865)
		 and ni.spell.valid("target", 47865, false, true, true)	
		 and GetTime() - data.warlock.LastCurse > 2 then
			ni.spell.cast(47865, "target")
			data.warlock.LastCurse = GetTime()
			return true
		end
	end,
-----------------------------------
	["Curse of Doom"] = function()
		local elem = data.warlock.elem()
		local CotE = data.warlock.CotE()
		local eplag = data.warlock.eplag()
		local earmoon = data.warlock.earmoon()
		if (ni.unit.isboss("target") 
		or UnitHealthMax("target") > 750000)
		 and ni.unit.ttd("target") > 65
		 and ((CotE and not elem) or eplag or earmoon)
		 and ni.spell.available(47867)
		 and ni.spell.valid("target", 47867, false, true, true)	
		 and GetTime() - data.warlock.LastCurse > 1 then
			ni.spell.cast(47867, "target")
			data.warlock.LastCurse = GetTime()
			return true
		end
	end,
-----------------------------------
	["Curse of Agony"] = function()
		local elem = data.warlock.elem()
		local doom = data.warlock.doom()
		local agony = data.warlock.agony()
		if not elem
		 and not doom
		 and not agony
		 and ni.unit.ttd("target") < 60
		 and ni.spell.available(47864)
		 and ni.spell.valid("target", 47864, false, true, true)
		 and GetTime() - data.warlock.LastCurse > 1 then
			ni.spell.cast(47864, "target")
			data.warlock.LastCurse = GetTime()
			return true
		end
	end,
-----------------------------------
	["Immolate"] = function()
		if not ni.player.ismoving()
		 and ni.unit.debuffremaining("target", 47811, "player") < ni.spell.casttime(47811)
		 and ni.spell.available(47811)
		 and ni.spell.valid("target", 47811, true, true)
		 and GetTime() - data.warlock.Lastimmolate > 2.1 then
			ni.spell.cast(47811, "target")
			data.warlock.Lastimmolate = GetTime()
			return true
		end
	end,
-----------------------------------
	["Immolate AoE"] = function()
		local enemies;
		if ni.rotation.custommod()
		 and UnitExists("target")
		 and ni.spell.available(47811)
		 and UnitCanAttack("player", "target") then
			enemies = ni.unit.enemiesinrange("target", 15)
			for i = 1, # enemies do
				local tar = enemies[i].guid;
				if ni.unit.creaturetype(enemies[i].guid) ~= 8
				 and ni.unit.creaturetype(enemies[i].guid) ~= 11
				 and not ni.unit.debuffs(tar, "23920||35399||69056")
				 and not ni.unit.debuff(tar, 47811, "player")
				 and ni.spell.valid(enemies[i].guid, 47811, true, true) then
					ni.spell.cast(47811, tar)
					return true
				end
			end
		end
	end,
---------------------------
	["Chaos Bolt"] = function()
		local immolate = data.warlock.immolate()
		if immolate
		 and not ni.player.ismoving()
		 and ni.spell.available(59172)
		 and ni.spell.valid("target", 59172, true, true) then
			ni.spell.cast(59172, "target")
			return true
		end
	end,
-----------------------------------
	["Conflagrate"] = function()
		local immolate = data.warlock.immolate()
		if immolate
		 and IsUsableSpell(GetSpellInfo(17962))
		 and ni.spell.available(17962)
		 and ni.spell.valid("target", 17962, true, true) then
			ni.spell.cast(17962, "target")
			return true
		end
	end,
-----------------------------------
	["Corruption"] = function()
		local corruption = data.warlock.corruption()
		local seed = data.warlock.seed()	
		if ni.spell.available(47813)
		 and not corruption
		 and not seed
		 and ni.spell.isinstant(47813)
		 and ni.spell.valid("target", 47813, false, true, true)
		 and GetTime() - data.warlock.LastCorrupt > 1.5 then
			ni.spell.cast(47813, "target")
			data.warlock.LastCorrupt = GetTime()
			return true
		end
	end,
-----------------------------------
	["Incinerate"] = function()
		local immolate = data.warlock.immolate()
		if immolate
		 and not ni.player.ismoving()
		 and ni.spell.available(47838)
		 and ni.spell.valid("target", 47838, true, true) then
			ni.spell.cast(47838, "target")
			return true
		end
	end,
-----------------------------------
	["Window"] = function()
		if not popup_shown then
		 ni.debug.popup("Destruction Warlock by darhanger -- Modified by Xcesius for leveling",
		 "Welcome to Destruction Warlock Profile! Support and more in Discord > https://discord.gg/u4mtjws.\n\n--Profile Function--\n-For use Immolate (AoE) mode configure Custom Key Modifier and hold it for put spell on nearest enemies.\n-For use Rain of Fire configure AoE Toggle key.\n-Focus target for use Soulstone.\n-For better experience make Pet passive.")
		popup_shown = true;
		end 
	end,
}
	
ni.bootstrap.profile("Destruction_darhanger_leveling", queue, abilities);