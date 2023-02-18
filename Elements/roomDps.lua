import "Turbine.UI"
import "Turbine.UI.Lotro"

function Global.RoomDps()
    DpsWindow = Turbine.UI.Window()
    DpsWindow:Focus()
    DpsWindow:SetEnabled(true);
    DpsWindow:SetPosition(1500, 760);
    DpsWindow:SetSize(250, 320);
    DpsWindow.MouseDown = function(sender, args)
        DpsWindow.oldX = args.X
        DpsWindow.oldY = args.Y
        DpsWindow.dragging = true
    end
    DpsWindow.MouseMove = function(sender, args)
        if DpsWindow.dragging then
            local mouseX, mouseY = Turbine.UI.Display.GetMousePosition()
            local newX = mouseX - DpsWindow.oldX
            local newY = mouseY - DpsWindow.oldY
            local screenWidth, screenHeight = Turbine.UI.Display:GetSize()
            local newLeft = math.max(0, math.min(newX, screenWidth - DpsWindow:GetWidth()))
            local newTop = math.max(0, math.min(newY, screenHeight - DpsWindow:GetHeight()))
            DpsWindow:SetPosition(newLeft, newTop)
        end
    end
    DpsWindow.MouseUp = function(sender, args)
        DpsWindow.dragging = false
    end

    DpsWindow.label = Turbine.UI.Label()
    DpsWindow.label:SetParent(DpsWindow)
    DpsWindow.label:SetSize(125, 20);
    DpsWindow.label:SetPosition(20, 10);
    DpsWindow.label:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16)
    DpsWindow.label:SetText("Room " .. "Damage")


    return { DpsWindow, DpsWindow.label }
end
