import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

_G.Global = {} -- you can use Global.YourConst

--[[

Welcome to the main page

]]

Turbine.Shell.WriteLine('RaidParser BETA 1.0.0 from 13/02/2023') -- at launch
--"N:([%a]+);D:([%d%.]+);"
import "RaidParser.Parser.main" -- import the parser
import "RaidParser.Class.Button"

-- icon image 
windowIcon = Turbine.UI.Window()
windowIcon:SetSize(69,50)
windowIcon:SetPosition(20,20)
windowIcon:SetOpacity(0.5)
windowIcon:SetVisible(true)

icon =  Turbine.UI.CheckBox()
icon:SetSize(69,50)
icon:SetParent(windowIcon)
icon:SetBackground("RaidParser/img/test.tga")
icon:SetVisible(true)
icon.CheckedChanged = function(sender, args)
    Global.optionsVisible()
end
icon.MouseDown = function(sender, args)
    windowIcon.oldX = args.X
    windowIcon.oldY = args.Y
    icon.MouseMove = function(sender, args)
        windowIcon:SetPosition(windowIcon:GetLeft() + (args.X - windowIcon.oldX),
        windowIcon:GetTop() + (args.Y - windowIcon.oldY))
        windowIcon.oldX = args.X
        windowIcon.oldY = args.Y
    end
    icon.MouseUp = function(sender, args)
        icon.MouseMove = nil
        icon.MouseUp = nil
    end
end
