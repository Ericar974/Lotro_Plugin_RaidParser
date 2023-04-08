import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

Turbine.Shell.WriteLine('RaidParser BETA from 8 April 2023') -- at launch

_G.Global = {} -- you can use Global.YourConst
Global.screenWidth , Global.screenHeight = Turbine.UI.Display.GetSize();

--[[
    List pb :

    rhaast pb de startBtn // Restart le plugin / 3chances pour init
    Lorellys de target qui n'envoie rien // doit reset le plugin (bug a chercher)
    lag quand clique (légere perte d'fps) à terme ça peut etre chiant // ( ca devrait aller ?)
    pb de stop // FAIT
    dégat en + que combatAnalisys // FAIT 

Welcome to the main page

exemple of Update

local aze = Turbine.UI.Lotro.Window()
aze:SetPosition(100, 100)
aze:SetSize(120, 40)
aze:SetOpacity(1)
aze:SetVisible(true)

local clockLabel = Turbine.UI.Label()
clockLabel:SetParent(aze)
clockLabel:SetPosition(30, 30)
clockLabel:SetSize(100, 20)
clockLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
clockLabel:SetWantsUpdates(true)
clockLabel:SetVisible(true)
function clockLabel:Update()
    self:SetText(Turbine.Engine.GetGameTime())
    self:SetVisible(true)
    aze:SetVisible(true)
end

]]

import "RaidParser.Preferences.main" -- users preferences
import "RaidParser.Parser.main" -- import the parser
import "RaidParser.Class.Button"

-- <icon image 
windowIcon = Turbine.UI.Window()
windowIcon:SetPosition(Global.Settings.iconPosition.left * Global.screenWidth, Global.Settings.iconPosition.top * Global.screenHeight)
windowIcon:SetSize(69,50)
windowIcon:SetOpacity(0.5)
windowIcon:SetZOrder(1)
windowIcon:SetVisible(true)

icon =  Turbine.UI.CheckBox()
icon:SetSize(69,50)
icon:SetParent(windowIcon)
icon:SetBackground("RaidParser/img/logoToLauch.tga")
icon:SetVisible(true)
icon.CheckedChanged = function(sender, args)
    Global.optionsVisible()
end

icon.MouseDown = function(sender, args)
    windowIcon.dragging = true
    windowIcon.oldX = args.X
    windowIcon.oldY = args.Y
end

icon.MouseUp = function(sender, args)
    windowIcon.dragging = false
end

icon.MouseMove = function(sender, args)
    if windowIcon.dragging then
        local mouseX, mouseY = Turbine.UI.Display.GetMousePosition()
        local screenWidth, screenHeight = Turbine.UI.Display:GetSize()
        local newX = math.max(0, math.min(mouseX - windowIcon.oldX, screenWidth - windowIcon:GetWidth()))
        local newY = math.max(0, math.min(mouseY - windowIcon.oldY, screenHeight - windowIcon:GetHeight()))
        windowIcon:SetPosition(newX, newY)
            -- Saving for Preferences
    Global.screenWidth , Global.screenHeight = Turbine.UI.Display.GetSize();
    Global.Settings.iconPosition.left = newX / Global.screenWidth
    Global.Settings.iconPosition.top = newY / Global.screenHeight
    end

end

--[[
comment...



-- Stocke la position de la fenêtre dans le fichier de configuration
function SavePreferences()
    local prefs = {}
    prefs.x = windowIcon:GetLeft()
    prefs.y = windowIcon:GetTop()
    Turbine.PluginData.Save(Turbine.DataScope.Character, "RaidParser", prefs)
end

-- Récupère les préférences de l'utilisateur à partir du fichier de configuration
function LoadPreferences()
    local prefs = Turbine.PluginData.Load(Turbine.DataScope.Character, "RaidParser") or {}
    windowIcon:SetPosition(prefs.x or 0, prefs.y or 0)
end

-- Enregistre les préférences lorsque la fenêtre du plugin est fermée
windowIcon.Closed = function(sender, args)
    SavePreferences()
end

-- Restaure les préférences lorsque le plugin est chargé
RaidParser.Loaded = function(sender, args)
    LoadPreferences()
end
]]