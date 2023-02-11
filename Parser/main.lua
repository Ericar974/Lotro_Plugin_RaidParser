import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI.Lotro"

-- < import class
import "RaidParser.Class.ButtonImage"
-- >
import "RaidParser.Parser.parser" -- Get the local parse
import "RaidParser.Utils.update"  -- Send the local parse
import "RaidParser.Parser.allPlayerParser" -- Get the parse of other players


-- < define the local player
Global.localPlayer = Turbine.Gameplay.LocalPlayer.GetInstance()
Global.PlayerName = Global.localPlayer:GetName()
Global.PlayerDamage = 1 -- set the damage at 1
-- >



local updateDps = Global.ButtonImage( 550, 850, "RaidParser/img/send.tga", 512, 512, "/Say N:".. Global.PlayerName ..";D:".. Global.PlayerDamage ..";" )
local updateDpsBtn = updateDps[3]

Global.EnableButton = function (bool) -- make the updateDpsBtn invisible/visible 
    updateDpsBtn.quickslot:SetVisible(bool);
    updateDps[2]:SetVisible(bool);
end

updateDpsBtn.quickslot.MouseClick = function(sender,args) -- make the updateDpsBtn invisible at click
    Global.EnableButton(false)
end

Global.TimeLoop = function () -- Update the Dps value of the Btn for sending to chat
    Global.UpdateShortCut(updateDpsBtn,Global.PlayerDamage)
end


--[[
comment... Wait for this button ...

local resetBtn = Turbine.UI.Lotro.Button()
resetBtn:SetParent( updateDps );
resetBtn:SetText("Reset")
resetBtn:SetSize( 50, 20 );
resetBtn:SetPosition( 0, 0 );
resetBtn:SetVisible(true);
resetBtn.MouseClick = function(sender,args)
    Global.PlayerDamage = 1
    Global.TimeLoop()
    updateDpsBtn:SetVisible(true);
end
]]

