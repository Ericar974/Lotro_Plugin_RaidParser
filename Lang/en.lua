-- parse EN from CombatAnalysis
Global.ParseEn = function(line)
    -- 1) Damage line ---
	
	local initiatorName,avoidAndCrit,skillName,targetNameAmountAndType = string.match(line,"^(.*) scored a (.*)hit(.*) on (.*)%.$"); -- (updated in v4.1.0)
	
	if (initiatorName ~= nil) then
		
		initiatorName = string.gsub(initiatorName,"^[Tt]he ","");
		
		local avoidType =
			string.match(avoidAndCrit,"^partially blocked") and 8 or
			string.match(avoidAndCrit,"^partially parried") and 9 or
			string.match(avoidAndCrit,"^partially evaded") and 10 or 1;
		local critType =
			string.match(avoidAndCrit,"critical $") and 2 or
			string.match(avoidAndCrit,"devastating $") and 3 or 1;
		--skillName = string.match(skillName,"^ with (.*)$") or L.DirectDamage; -- (as of v4.1.0)
		skillName = ""

		local targetName,amount,dmgType,moralePower = string.match(targetNameAmountAndType,"^(.*) for ([%d,]*) (.*)damage to (.*)$");
		-- damage was absorbed
		if targetName == nil then
			targetName = string.gsub(targetNameAmountAndType,"^[Tt]he ","");
			amount = 0;
			dmgType = 12;
			moralePower = 3;
		-- some damage was dealt
		else
			targetName = string.gsub(targetName,"^[Tt]he ","");
			amount = string.gsub(amount,",","")+0;
      
      dmgType = string.match(dmgType, "^%(.*%) (.*)$") or dmgType; -- 4.2.3 adjust for mounted combat
			-- note there may be no damage type
			dmgType = 
				dmgType == "Common " and 1 or
				dmgType == "Fire " and 2 or
				dmgType == "Lightning " and 3 or
				dmgType == "Frost " and 4 or
				dmgType == "Acid " and 5 or
				dmgType == "Shadow " and 6 or
				dmgType == "Light " and 7 or
				dmgType == "Beleriand " and 8 or
				dmgType == "Westernesse " and 9 or
				dmgType == "Ancient Dwarf-make " and 10 or 
        dmgType == "Orc-craft " and 11 or
        dmgType == "Fell-wrought " and 12 or 13;
			moralePower = (moralePower == "Morale" and 1 or moralePower == "Power" and 2 or 3);
		end
		
		-- Currently ignores damage to power
		if (moralePower == 2) then return nil end
		
		-- Update
		return 1,initiatorName,targetName,skillName,amount,avoidType,critType,dmgType;
	end
	--[[
	comment...
	

	
    -- 2) Heal line --
	--     (note the distinction with which self heals are now handled)
	--     (note we consider the case of heals of zero magnitude, even though they presumably never occur)
	local initiatorName,crit,skillNameTargetNameAmountAndType = string.match(line,"^(.*) applied a (.-)heal (.*)%.$");
	
	if (initiatorName ~= nil) then
		initiatorName = string.gsub(initiatorName,"^[Tt]he ","");
		local critType =
			crit == "critical " and 2 or
			crit == "devastating " and 3 or 1;
		
		local skillNameTargetNameAndAmount,ending = string.match(skillNameTargetNameAmountAndType,"^(.*)to (.*)$");
		local targetName,skillName,amount;
		moralePower = (ending == "Morale" and 1 or (ending == "Power" and 2 or 3));
		-- heal was absorbed (unfortunately it appears this actually shows as a "hit" instead, so we never get into the first conditional)
		if (moralePower == 3) then
			targetName = string.gsub(ending,"^[Tt]he ","");
			amount = 0;
			-- skill name will equal nil if this was a self heal
			skillName = string.match(skillNameTargetNameAndAmount,"^with (.*) $");
		-- heal applied
		else
			skillName,targetName,amount = string.match(skillNameTargetNameAndAmount,"^(.*)to (.*) restoring ([%d,]*) points? $");
			targetName = string.gsub(targetName,"^[Tt]he ","");
			amount = string.gsub(amount,",","")+0;
			-- skill name will equal nil if this was a self heal
			skillName = string.match(skillName,"^with (.*) $");
		end
		
		-- rearrange if this was a self heal
		if (skillName == nil) then
			skillName = initiatorName;
			initiatorName = targetName;
		end
		
		-- Update
		return (moralePower == 2 and 4 or 3),initiatorName,targetName,skillName,amount,critType;
	end

    -- 4) Avoid line --
	local initiatorNameMiss,skillName,targetNameAvoidType = string.match(line,"^(.*) to use (.*) on (.*)%.$");
	
	if (initiatorNameMiss ~= nil) then
		initiatorName = string.match(initiatorNameMiss,"^(.*) tried$");
		local targetName, avoidType;
		-- standard avoid
		if (initiatorName ~= nil) then
			initiatorName = string.gsub(initiatorName,"^[Tt]he ","");
			targetName,avoidType = string.match(targetNameAvoidType,"^(.*) but (.*) the attempt$");
			targetName = string.gsub(targetName,"^[Tt]he ","");
			avoidType = 
				string.match(avoidType," blocked$") and 5 or
				string.match(avoidType," parried$") and 6 or
				string.match(avoidType," evaded$") and 7 or
				string.match(avoidType," resisted$") and 4 or
				string.match(avoidType," was immune to$") and 3 or 1;
				
		-- miss or deflect (deflect added in v4.2.2)
		else
			initiatorName = string.match(initiatorNameMiss,"^(.*) missed trying$");
      if (initiatorName == nil) then
        initiatorName = string.match(initiatorNameMiss,"^(.*) was deflected trying$");
        avoidType = 11;
      else
        avoidType = 2;
      end
      
			initiatorName = string.gsub(initiatorName,"^[Tt]he ","");
			targetName = string.gsub(targetNameAvoidType,"^[Tt]he ","");
		end
		
		-- Sanity check: must have avoided in some manner
		if (avoidType == 1) then return nil end
		
		-- Update
		return 1,initiatorName,targetName,skillName,0,avoidType,1,10;
	end
	
	-- 5) Reflect line --
	
	local initiatorName,amount,dmgType,targetName = string.match(line,"^(.*) reflected ([%d,]*) (.*) to the Morale of (.*)%.$");
	
	if (initiatorName ~= nil) then
		local skillName = "Reflect";
		initiatorName = string.gsub(initiatorName,"^[Tt]he ","");
		targetName = string.gsub(targetName,"^[Tt]he ","");
		amount = string.gsub(amount,",","")+0;
		
		local dmgType = string.match(dmgType,"^(.*)damage$");
		-- a damage reflect
		if (dmgType ~= nil) then
			dmgType = 
				dmgType == "Common " and 1 or
				dmgType == "Fire " and 2 or
				dmgType == "Lightning " and 3 or
				dmgType == "Frost " and 4 or
				dmgType == "Acid " and 5 or
				dmgType == "Shadow " and 6 or
				dmgType == "Light " and 7 or
				dmgType == "Beleriand " and 8 or
				dmgType == "Westernesse " and 9 or
				dmgType == "Ancient Dwarf-make " and 10 or 11;
						
			-- Update
			return 1,initiatorName,targetName,skillName,amount,1,1,dmgType;
		-- a heal reflect
		else
			-- Update
			return 3,initiatorName,targetName,skillName,amount,1;
		end
	end
		]]
end
