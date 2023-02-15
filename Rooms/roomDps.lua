import "Turbine.UI"
import "Turbine.UI.Lotro"

function Global.RoomDps()

DpsWindow = Turbine.UI.Window()
DpsWindow:Focus()
DpsWindow:SetEnabled(true);
DpsWindow:SetPosition(1500, 760);
DpsWindow:SetSize(250, 320);
DpsWindow:SetBackColor(Turbine.UI.Color(0.07, 0.07, 0.07))
DpsWindow.MouseDown = function(sender, args)
    DpsWindow.oldX = args.X
    DpsWindow.oldY = args.Y
    DpsWindow.MouseMove = function(sender, args)
        DpsWindow:SetPosition(DpsWindow:GetLeft() + (args.X - DpsWindow.oldX),
            DpsWindow:GetTop() + (args.Y - DpsWindow.oldY))
        DpsWindow.oldX = args.X
        DpsWindow.oldY = args.Y
    end
    DpsWindow.MouseUp = function(sender, args)
        DpsWindow.MouseMove = nil
        DpsWindow.MouseUp = nil
    end
end
DpsWindow.label = Turbine.UI.Label()
DpsWindow.label:SetParent(DpsWindow)
DpsWindow.label:SetSize(125, 20);
DpsWindow.label:SetPosition(20, 10);
DpsWindow.label:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16)
DpsWindow.label:SetText("Room " .. "Damage")


return {DpsWindow, DpsWindow.label}

end