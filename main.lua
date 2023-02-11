import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

Turbine.Shell.WriteLine('RaidParser start') -- 

_G.Global = {}

localPlayer = Turbine.Gameplay.LocalPlayer.GetInstance()
Global.PlayerName = localPlayer:GetName()
Global.PlayerDamage = 1


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
quickslot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "/Say N:".. Global.PlayerName ..";D:".. Global.PlayerDamage ..";" ));
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


import "RaidParser.Parser.parser"
import "RaidParser.Parser.allPlayerParser"
