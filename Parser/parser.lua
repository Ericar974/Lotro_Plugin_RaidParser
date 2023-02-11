import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

import "RaidParser.Lang.en"

local loopingTimer =  Turbine.Engine.GetGameTime();
local resetTimer =  loopingTimer

function Global.AddCallback(object, event, callback)
	if (object[event] == nil) then
		object[event] = callback;
	else
		if (type(object[event]) == "table") then
			table.insert(object[event], callback);
		else
			object[event] = {object[event], callback};
		end
	end
end


Global.AddCallback(Turbine.Chat,"Received",function(sender, args) -- track combat chat
    -- 1) only parse combat text for now
    if ((args.ChatType ~= Turbine.ChatType.EnemyCombat) and (args.ChatType ~= Turbine.ChatType.PlayerCombat) and (args.ChatType ~= Turbine.ChatType.Death)) then
        return;
    end

    -- immediately grab timestamp (NB: actually it appears this doesn't change over successive calls in the same frame)
    local timestamp = Turbine.Engine.GetGameTime();
    if (timestamp - resetTimer > 2) then
        Global.EnableButton(true)
        resetTimer = timestamp
    end
    if (timestamp - loopingTimer > 1) then
        Global.TimeLoop()
        loopingTimer = timestamp
    end

    -- grab line from combat log, strip it of color, trim it, and parse it according to the localized parsing function
	local updateType,initiatorName,targetName,skillName,var1,var2,var3,var4 = Global.Parse(string.gsub(string.gsub(args.Message,"<rgb=#......>(.*)</rgb>","%1"),"^%s*(.-)%s*$", "%1"));
	if (updateType == nil) then return end
    Global.PlayerDamage = Global.PlayerDamage + var1
    
    --Turbine.Shell.WriteLine(allDamage)
end);
