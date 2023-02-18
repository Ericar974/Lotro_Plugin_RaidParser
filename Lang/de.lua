-- parse DE from CombatAnalysis
Global.ParseDe = function (line)
    -- 1) Damage line ---
	
	local initiatorName,avoidAndCrit,skillName,targetNameAmountAndType = string.match(line,"^(.*) gelang ein (.*)Treffer mit \"(.*)\" gegen (.*)%.$");
	
	if (initiatorName ~= nil) then
		initiatorName = TrimArticles(initiatorName);
		
		local avoidType =
			string.match(avoidAndCrit,"^teilweise geblockter") and 8 or
			string.match(avoidAndCrit,"^teilweise parierter") and 9 or
			string.match(avoidAndCrit,"^teilweise ausgewichener") and 10 or 1;
		local critType =
			string.match(avoidAndCrit,"kritischer $") and 2 or
			string.match(avoidAndCrit,"zerst\195\182rerischer $") and 3 or 1;

        skillName = ""
		
		local targetName,amount,dmgType,moralePower = string.match(targetNameAmountAndType, "^(.*) f\195\188r ([%d,]*) Punkte Schaden des Typs \"(.*)\" auf (.*)$");
		-- damage was absorbed
		if targetName == nil then
			targetName = TrimArticles(targetNameAmountAndType);
			amount = 0;
			dmgType = 10;
			moralePower = 3;
		-- some damage was dealt
		else
			targetName = TrimArticles(targetName);
			amount = string.gsub(amount,",","")+0;
			-- note there may be no damage type
			dmgType = 
				dmgType == "Allgemein" and 1 or
				dmgType == "Feuer" and 2 or
				dmgType == "Blitz" and 3 or
				dmgType == "Frost" and 4 or
				dmgType == "S\195\164ure" and 5 or
				dmgType == "Schatten" and 6 or
				dmgType == "Licht" and 7 or
				dmgType == "Beleriand" and 8 or
				dmgType == "Westernis" and 9 or
				dmgType == "Uralte Zwergenart" and 10 or
				dmgType == "Ork-Waffe" and 11 or
				dmgType == "Hass" and 12 or 13;
			moralePower = (moralePower == "Moral" and 1 or moralePower == "Kraft" and 2 or 3);
		end
		
		-- Currently ignores damage to power
		if (moralePower == 2) then return nil end
		
		-- Update
		return 1,initiatorName,targetName,skillName,amount,avoidType,critType,dmgType;
	end
	
	-- 2) Heal line --
	
	--     (note the distinction with which self heals are now handled)
	--     (note we consider the case of heals of zero magnitude, even though they presumably never occur)
	local initiatorName,crit,skillNameTargetNameAmountAndType = string.match(line,"^(.*) wandte \"(.*)Heilung\" mit (.*)%.$");

	if (initiatorName ~= nil) then
		initiatorName = TrimArticles(initiatorName);
		local critType =
			crit == "kritische " and 2 or
			crit == "zerst\195\182rerische " and 3 or 1;
			
		local skillNameTargetNameAndAmount,ending = string.match(skillNameTargetNameAmountAndType,"^(.*) Punkte (.*) wiederherstellte$");
		moralePower = (ending == "Moral" and 1 or ending == "Kraft" and 2 or 3);
		
		skillName,targetName,amount = string.match(skillNameTargetNameAndAmount,"^\"(.*)\" auf (.*) an, was ([%d,]*)$");
		targetName = TrimArticles(targetName);
		amount = string.gsub(amount,",","")+0;
		
		-- Update
		return (moralePower == 2 and 4 or 3),initiatorName,targetName,skillName,amount,critType;
	end
	
	-- 2.2) Self Heal
	
	--		(note that the self heal line is totally differend in comparision to the normal heal line in the german client)
	
	local skillName, initiatorName, critType, amount, moralPower = string.match(line, "^(.*) verursacht bei (.*) \"(.*)Heilung\" und stellt ([%d,]*) Punkte (.*) wieder her%.");
	if(initiatorName ~= nil) then
		initiatorName = TrimArticles(initiatorName);
		amount = string.gsub(amount, ",", "")+0;
		moralPower = (moralPower == "Moral" and 1 or moralPower == "Kraft" and 2 or 3);
		critType = critType == "kritische " and 2 or
				   critType == "zerst\195\182rerische " and 3 or 1;
		
		return (moralPower == 2 and 4 or 3), initiatorName, initiatorName, skillName, amount, critType;
	end
	
	-- 4) Avoid line --


	-- standard avoid
	local initiatorName,targetName,skillName,erSie,avoidType = string.match(line,"^(.*) wollte (.*) mit (.*) treffen\, aber(.*)konterte den Versuch mit (.*).");
	if (initiatorName ~= nil) then
		initiatorName = TrimArticles(initiatorName);
		targetName = TrimArticles(targetName);
		skillName = string.gsub(skillName, "\"", "");
		avoidType = string.gsub(avoidType, "\"", "");
		avoidType = 
				string.match(avoidType,"Blocken") and 5 or
				string.match(avoidType,"Parieren") and 6 or
				string.match(avoidType,"Ausweichen") and 7 or
				string.match(avoidType,"Widerstehen") and 4 or
				string.match(avoidType,"Immunit\195\164t") and 3 or 1;
		-- Sanity check: must have avoided in some manner
		if (avoidType == 1) then return nil end
		return 1,initiatorName,targetName,skillName,0,avoidType,1,10;
	end
		
	-- miss
	local initiatorName, targetName, skillName = string.match(line, "^(.*) verfehlte (.*) mit (.*)%.");
	
	if (initiatorName ~= nil) then
		initiatorName = TrimArticles(initiatorName);
		targetName = TrimArticles(targetName);
		skillName = string.gsub(skillName, "\"", "");
		local avoidType = 2;
		-- Update
		return 1,initiatorName,targetName,skillName,0,avoidType,1,10;
	end
		
	
	-- 5) Reflect line --
	
	local initiatorName, amount, reflectType, targetName = string.match(line, "^(.*) reflektierte ([%d,]*) Punkte (.*) von (.*).$");
	if(initiatorName ~= nil) then
		local skillName = "Reflektiert";
		initiatorName = TrimArticles(initiatorName);
		targetName = TrimArticles(targetName);
		
		amount = string.gsub(amount,",","")+0;
		local dmgType = string.match(reflectType, "^Schaden des Typs (.*) auf Moral$");
		
		if(dmgType ~= nil) then
			dmgType = 
				dmgType == "\"Allgemein\""  and 1 or
				dmgType == "\"Feuer\"" and 2 or
				dmgType == "\"Blitz\"" and 3 or
				dmgType == "\"Frost\"" and 4 or
				dmgType == "\"S\195\164ure\"" and 5 or
				dmgType == "\"Schatten\"" and 6 or
				dmgType == "\"Licht\"" and 7 or
				dmgType == "\"Beleriand\"" and 8 or
				dmgType == "\"Westernis\"" and 9 or
				dmgType == "\"Uralte Zwergenart\"" and 10 or
				dmgType == "\"Ork-Waffe\"" and 11 or
				dmgType == "\"Hass\"" and 12 or 13;
			-- a dmg reflect
			return 1,initiatorName,targetName,skillName,amount,1,1,dmgType;
		else
			-- a heal reflect
			return 3,initiatorName,targetName,skillName,amount,1;
		end
	end
end