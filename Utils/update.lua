import "Turbine.UI.Lotro"

Global.UpdateShortCut = function (quickslot, value)
    quickslot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "/Say D:".. value ..";" ));
end
