import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

_G.Global = {} -- you can use Global.YourConst

--[[

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

Turbine.Shell.WriteLine('RaidParser Lunar BETA from 15/02/2023') -- at launch
import "RaidParser.Parser.main" -- import the parser
import "RaidParser.Class.Button"

-- <icon image 
windowIcon = Turbine.UI.Window()
windowIcon:SetSize(69,50)
windowIcon:SetPosition(20,20)
windowIcon:SetOpacity(0.5)
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
