import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

-- preferences for character ( keep things at the same place )

Global.Original_Settings = {
    iconPosition = {
        left = 0.50,
        top = 0.50,
    },
    optionWindow = {
        left = 0.70,
        top = 0.30,
    },
    roomDps = {
        left = 0.30,
        top = 0.20,
    },
    imageBtn = {
        left = 0.50,
        top = 0.50,
    }
}

Global.Settings = {}

local loadPrefs = Turbine.PluginData.Load(Turbine.DataScope.Character, "RaidParser_prefs")

if(type(loadPrefs) == 'table')then 
    Global.Settings = loadPrefs
else
    Global.Settings = Global.Original_Settings
end
function SavePreferences()
    Turbine.PluginData.Save(Turbine.DataScope.Character, "RaidParser_prefs", Global.Settings)
end

Turbine.Plugin.Unload = function (sender, args)
    SavePreferences();
    Turbine.Shell.WriteLine("RaidParser: The plugin does not take resources if there is no room started");
end
