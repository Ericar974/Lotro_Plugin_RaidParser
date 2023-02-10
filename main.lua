import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

Turbine.Shell.WriteLine('RaidParser start') -- 

_G.Global = {}

Global.PlayerDamage = 0

window = Turbine.UI.Lotro.Window()
window:SetVisible(true);
window:SetPosition( 500, 900 );
window:SetSize( 200, 100 );
window:SetText( "Update" );



local quickslot = Turbine.UI.Lotro.Quickslot()
quickslot:SetParent( window );
quickslot:SetPosition( 25, 50 );
quickslot:SetSize( 150, 20 );
quickslot:SetVisible(true);
quickslot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "/Say D:".. Global.PlayerDamage ..";" ));
quickslot:SetAllowDrop(false);
quickslot:SetEnabled(true);
quickslot:SetWantsKeyEvents(true)
quickslot:GetWantsUpdates()
quickslot:SetBackColor(Turbine.UI.Color(0.27,0.23,0.78))
quickslot:SetOpacity(1)
quickslot.MouseClick = function(sender,args)
    quickslot:SetVisible(false);
end

Global.EnableButton = function ()
    quickslot:SetVisible(true);
end

local resetButton = Turbine.UI.Lotro.Button()
resetButton:SetText("Reset")
resetButton:SetParent( window );
resetButton:SetPosition( 25, 50 );
resetButton:SetVisible(true);
resetButton.MouseClick = function(sender,args)
    Global.PlayerDamage = 0
    Global.TimeLoop()
    quickslot:SetVisible(true);
end



import "RaidParser.Utils.update"

Global.TimeLoop = function ()
    Global.UpdateShortCut(quickslot,Global.PlayerDamage)
end

-- Create new chat command
GreetCommand = Turbine.ShellCommand()

-- Declare code to run when the chat command is issued
function GreetCommand:Execute(command, arguments)
    -- Fetch a reference to the player's character
	local player = Turbine.Gameplay.LocalPlayer.GetInstance()

    -- Write text to chat. Double dots concatenate two strings in lua, <rgb> is used to color text
	Turbine.Shell.WriteLine("<rgb=#FF0000>Total damage " .. command .. ": </rgb> " .. arguments)
end

-- Register the chat command and link the command word to the code
Turbine.Shell.AddCommand("GreetSelf", GreetCommand)


function Turbine.Chat.Received(sender, args) -- listen message in the chat of the game | args = {Message,Sender,ChatType}
    if string.match(args.Message, "D:([%d%.]+);") and args.ChatType == 5 then
        local player = args.Sender
        local damage = string.match(args.Message, "D:([%d%.]+);")
        GreetCommand:Execute(player, damage)
    end
end

import "RaidParser.Parser.parser"
