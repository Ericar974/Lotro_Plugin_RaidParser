-- parse EN
Global.Parse = function(line)
    -- 1) Damage line ---
    local initiatorName,avoidAndCrit,skillName,targetNameAmountAndType = string.match(line,"^(.*) scored a (.*)hit(.*) on (.*)%.$"); 
        
        if (initiatorName ~= nil) then
            
            initiatorName = string.gsub(initiatorName,"^[Tt]he ","");
            
            local avoidType =
                string.match(avoidAndCrit,"^partially blocked") and 8 or
                string.match(avoidAndCrit,"^partially parried") and 9 or
                string.match(avoidAndCrit,"^partially evaded") and 10 or 1;
            local critType =
                string.match(avoidAndCrit,"critical $") and 2 or
                string.match(avoidAndCrit,"devastating $") and 3 or 1;
            --skillName = string.match(skillName,"^ with (.*)$") or L.DirectDamage;
            skillName = 0
            
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
          
          dmgType = string.match(dmgType, "^%(.*%) (.*)$") or dmgType; -- adjust for mounted combat
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
    end