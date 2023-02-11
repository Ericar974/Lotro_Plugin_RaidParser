import "Turbine.UI.Lotro"

Global.UpdateShortCut = function (quickslot, value)
    quickslot.quickslot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "/Say N:"..Global.PlayerName..";D:".. value ..";" ));
end
