import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

Turbine.Shell.WriteLine('RaidParser BETA from 8 April 2023') -- at launch

_G.Global = {} -- you can use Global.YourConst
Global.screenWidth , Global.screenHeight = Turbine.UI.Display.GetSize();

--[[
    List pb :
    Lorellys de target qui n'envoie rien // doit reset le plugin (bug a chercher)
    lag quand clique (légere perte d'fps) à terme ça peut etre chiant // ( ca devrait aller ?)
    dégat en + que combatAnalisys // FAIT Mais heals compter comme des dégats

Welcome to the main page

]]

import "RaidParser.Preferences.main" -- users preferences
import "RaidParser.Parser.main" -- import the parser
import "RaidParser.Class.Button"
import "RaidParser.Elements.iconWindow"

import "RaidParser.Elements.Room.main"
