import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

Turbine.Shell.WriteLine("RaidParser Lunar's Beta from 24 April 2023") -- at launch

_G.Global = {} -- you can use Global.YourConst
Global.screenWidth , Global.screenHeight = Turbine.UI.Display.GetSize();

--[[
Welcome to the main page

]]

import "RaidParser.Preferences.main" -- users preferences
import "RaidParser.Parser.main" -- import the parser
import "RaidParser.Class.Button"
import "RaidParser.Elements.Room.main"
