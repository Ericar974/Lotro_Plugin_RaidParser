import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

Global.PlayersList = {} -- PlayersList : Array[Array] with {PlayerName, his damage, his label}



DamageMax = 0
local found = nil
Turbine.Shell.WriteLine(#Global.PlayersList)

DpsWindow = Turbine.UI.Lotro.Window()
DpsWindow:SetVisible(true);
DpsWindow:SetPosition( 200, 400 );
DpsWindow:SetSize( 200, 300 );
DpsWindow:SetText( "Dps" );

local newPlayer = function (player, damage, index)
    Global.PlayersList[index][3]:SetText( player);
    Global.PlayersList[index][3]:SetParent( DpsWindow );
    Global.PlayersList[index][3]:SetSize( 130 * damage/DamageMax, 15 );
    Global.PlayersList[index][3]:SetPosition( 40, 50 + 20*index);
    Global.PlayersList[index][3]:SetBackColor( Turbine.UI.Color(math.random(7, 10)/10,math.random(1, 10)/10,math.random(1, 10)/10));
    Global.PlayersList[index][3]:SetForeColor( Turbine.UI.Color.Black );
    Global.PlayersList[index][3]:GetWantsUpdates(true)
end

local updatePlayerDamage = function ()
    for i, value in ipairs(Global.PlayersList) do
        Turbine.Shell.WriteLine(value[1])
        Turbine.Shell.WriteLine(value[2])
        Turbine.Shell.WriteLine(DamageMax)
        value[3]:SetPosition( 40, 50 + 20*i );
        value[3]:SetSize( 130 * value[2]/DamageMax, 15 );
    end
end

function sortByDamage(a, b)
    return tonumber(a[2]) > tonumber(b[2])
  end


Global.AddCallback(Turbine.Chat,"Received",function(sender, args) -- listen message in the chat of the game | args = {Message,Sender,ChatType}
    if string.match(args.Message, "N:([%a]+);D:([%d%.]+);") and args.ChatType == 5 then
        local player = string.match(args.Message, "N:([%a]+);")
        local damage = string.match(args.Message, "D:([%d%.]+);")

        -- < if damage is bigger than DamageMax we change DamageMax
        if (tonumber(damage) > DamageMax) then
            DamageMax = tonumber(damage)
          end
        -- >
        
        -- < foreach player in PlayersList
        found = false
        for i, value in ipairs(Global.PlayersList) do
            if value[1] == player then
                found = true
                value[2] = damage
            end
          end
          -- />

          if not found then
            table.insert(Global.PlayersList, #Global.PlayersList +1, {player, damage, Turbine.UI.Label()})
            newPlayer(player, damage, #Global.PlayersList)
          end
          
         table.sort(Global.PlayersList, sortByDamage)
         updatePlayerDamage()
    end
end);