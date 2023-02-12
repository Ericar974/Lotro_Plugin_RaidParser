import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI.Lotro"

_G.Global = {} -- you can use Global.YourConst

--[[

Welcome to the main page

]]

Turbine.Shell.WriteLine('RaidParser BETA 1.0.0 from 13/02/2023') -- at launch
--"N:([%a]+);D:([%d%.]+);"
import "RaidParser.Parser.main" -- import the parser
import "RaidParser.Class.Button"





