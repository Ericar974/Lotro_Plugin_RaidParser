import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

-- preferences for character ( keep things at the same place )

Global.Original_Settings = {
    roomDps = {
        left = 0.85,
        top = 0.60,
    },
    imageBtn = {
        left = 0.80,
        top = 0.62,
    },
    chan = {1, Turbine.ChatType.UserChat1, "1"}
}

Global.Settings = {}

local loadPrefs = Turbine.PluginData.Load(Turbine.DataScope.Character, "BETARaidParser_prefs")

if(type(loadPrefs) == 'table')then 
    Global.Settings = loadPrefs
else
    Global.Settings = Global.Original_Settings
end
function SavePreferences()
    Turbine.PluginData.Save(Turbine.DataScope.Character, "BETARaidParser_prefs", Global.Settings)
end

Turbine.Plugin.Unload = function (sender, args)
    SavePreferences();
end
