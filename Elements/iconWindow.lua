import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

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
