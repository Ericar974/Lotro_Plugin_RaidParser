import "Turbine"
import "Turbine.Gameplay" 
import "Turbine.UI"
import "Turbine.UI.Lotro"

function Global.Room()
    ContentWindow = Turbine.UI.Window() -- mother of them all
    ContentWindow:SetSize(250, 320);
    ContentWindow:SetPosition(Global.Settings.roomDps.left * Global.screenWidth, Global.Settings.roomDps.top * Global.screenHeight);
    ContentWindow:Focus()
    ContentWindow:SetZOrder(4)
    ContentWindow:SetVisible(false)
    
    ContentWindow.rooms = Turbine.UI.Window() -- title and elder of all childrens
    ContentWindow.rooms:SetParent(ContentWindow)
    ContentWindow.rooms:SetSize(250, 30);
    ContentWindow.rooms:SetVisible(true)
    ContentWindow.rooms:SetZOrder(4)
    ContentWindow.rooms:SetBackColor(Turbine.UI.Color(0.3,0,0,0))
    
    ContentWindow.rooms.drag = Turbine.UI.Window()
    ContentWindow.rooms.drag:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.drag:SetBackground("RaidParser/img/drag.tga")
    ContentWindow.rooms.drag:SetSize(20,20)
    ContentWindow.rooms.drag:SetPosition(0,7)
    ContentWindow.rooms.drag:SetStretchMode(1)
    ContentWindow.rooms.drag:SetVisible(false)
    ContentWindow.rooms:SetWantsKeyEvents(true)
    ContentWindow.rooms.KeyDown = function(sender, args)
        if (args.Action == Turbine.UI.Lotro.Action.ToggleHiddenDragBoxes) then
            ContentWindow.rooms.drag:SetVisible(not ContentWindow.rooms.drag:IsVisible())
        end
    end
    local windowUse
    ContentWindow.rooms.active = 2
 
    --< dps room 2
    ContentWindow.rooms.dpsLabel = Turbine.UI.Label()
    ContentWindow.rooms.dpsLabel:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.dpsLabel:SetSize(125, 20);
    ContentWindow.rooms.dpsLabel:SetPosition(20, 10);
    ContentWindow.rooms.dpsLabel:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16)
    ContentWindow.rooms.dpsLabel:SetText("Room " .. "Damage")

    ContentWindow.rooms.dpsWindow = Turbine.UI.Window()
    ContentWindow.rooms.dpsWindow:SetParent(ContentWindow)
    ContentWindow.rooms.dpsWindow:Focus()
    ContentWindow.rooms.dpsWindow:SetEnabled(true);
    ContentWindow.rooms.dpsWindow:SetSize(250, 320);
    ContentWindow.rooms.dpsWindow:SetBackColor(Turbine.UI.Color(0.6,0,0,0))
    ContentWindow.rooms.dpsWindow:SetVisible(true)

    ContentWindow.rooms.dpsButton = Turbine.UI.Window()
    ContentWindow.rooms.dpsButton:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.dpsButton:SetPosition(150,12)
    ContentWindow.rooms.dpsButton:SetSize(10,10)
    ContentWindow.rooms.dpsButton:SetBackColor(Turbine.UI.Color.Red)
    ContentWindow.rooms.dpsButton:SetVisible(true)
    ContentWindow.rooms.dpsButton.MouseClick = function(sender, args)
        windowUse = ContentWindow.rooms.dpsWindow
        ContentWindow.rooms.active = 2
        Global.updatePlayer()

        ContentWindow.rooms.dpsWindow:SetVisible(true)
        ContentWindow.rooms.dpsLabel:SetVisible(true)

        ContentWindow.rooms.healWindow:SetVisible(false)
        ContentWindow.rooms.healLabel:SetVisible(false)

        ContentWindow.rooms.tankWindow:SetVisible(false)
        ContentWindow.rooms.tankLabel:SetVisible(false)

        ContentWindow.rooms.powerWindow:SetVisible(false)
        ContentWindow.rooms.powerLabel:SetVisible(false)
    end
    -->
    --< heal room 3
    ContentWindow.rooms.healLabel = Turbine.UI.Label()
    ContentWindow.rooms.healLabel:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.healLabel:SetSize(125, 20);
    ContentWindow.rooms.healLabel:SetPosition(20, 10);
    ContentWindow.rooms.healLabel:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16)
    ContentWindow.rooms.healLabel:SetText("Room " .. "Heal")
    ContentWindow.rooms.healLabel:SetVisible(false)

    ContentWindow.rooms.healWindow = Turbine.UI.Window()
    ContentWindow.rooms.healWindow:SetParent(ContentWindow)
    ContentWindow.rooms.healWindow:Focus()
    ContentWindow.rooms.healWindow:SetEnabled(true);
    ContentWindow.rooms.healWindow:SetSize(250, 320);
    ContentWindow.rooms.healWindow:SetBackColor(Turbine.UI.Color(0.6,0,0,0))
    ContentWindow.rooms.healWindow:SetVisible(false)

    ContentWindow.rooms.healButton = Turbine.UI.Window()
    ContentWindow.rooms.healButton:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.healButton:SetPosition(165,12)
    ContentWindow.rooms.healButton:SetSize(10,10)
    ContentWindow.rooms.healButton:SetBackColor(Turbine.UI.Color(0.44,0.61,0.28))
    ContentWindow.rooms.healButton:SetVisible(true)
    ContentWindow.rooms.healButton.MouseClick = function(sender, args)
        windowUse = ContentWindow.rooms.healWindow
        ContentWindow.rooms.active = 3
        Global.updatePlayer()

        ContentWindow.rooms.healWindow:SetVisible(true)
        ContentWindow.rooms.healLabel:SetVisible(true)

        ContentWindow.rooms.dpsWindow:SetVisible(false)
        ContentWindow.rooms.dpsLabel:SetVisible(false)
        
        ContentWindow.rooms.tankWindow:SetVisible(false)
        ContentWindow.rooms.tankLabel:SetVisible(false)

        ContentWindow.rooms.powerWindow:SetVisible(false)
        ContentWindow.rooms.powerLabel:SetVisible(false)
    end
    -->
    --< tank room 4
    ContentWindow.rooms.tankLabel = Turbine.UI.Label()
    ContentWindow.rooms.tankLabel:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.tankLabel:SetSize(125, 20);
    ContentWindow.rooms.tankLabel:SetPosition(20, 10);
    ContentWindow.rooms.tankLabel:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16)
    ContentWindow.rooms.tankLabel:SetText("Room " .. "Tank")
    ContentWindow.rooms.tankLabel:SetVisible(false)

    ContentWindow.rooms.tankWindow = Turbine.UI.Window()
    ContentWindow.rooms.tankWindow:SetParent(ContentWindow)
    ContentWindow.rooms.tankWindow:Focus()
    ContentWindow.rooms.tankWindow:SetEnabled(true);
    ContentWindow.rooms.tankWindow:SetSize(250, 320);
    ContentWindow.rooms.tankWindow:SetBackColor(Turbine.UI.Color(0.6,0,0,0))
    ContentWindow.rooms.tankWindow:SetVisible(false)

    ContentWindow.rooms.tankButton = Turbine.UI.Window()
    ContentWindow.rooms.tankButton:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.tankButton:SetPosition(180,12)
    ContentWindow.rooms.tankButton:SetSize(10,10)
    ContentWindow.rooms.tankButton:SetBackColor(Turbine.UI.Color(0.8,0.69,0.33))
    ContentWindow.rooms.tankButton:SetVisible(true)
    ContentWindow.rooms.tankButton.MouseClick = function(sender, args)
        windowUse = ContentWindow.rooms.tankWindow
        ContentWindow.rooms.active = 4
        Global.updatePlayer()

        ContentWindow.rooms.tankWindow:SetVisible(true)
        ContentWindow.rooms.tankLabel:SetVisible(true)

        ContentWindow.rooms.healWindow:SetVisible(false)
        ContentWindow.rooms.healLabel:SetVisible(false)

        ContentWindow.rooms.dpsWindow:SetVisible(false)
        ContentWindow.rooms.dpsLabel:SetVisible(false)

        ContentWindow.rooms.powerWindow:SetVisible(false)
        ContentWindow.rooms.powerLabel:SetVisible(false)
    end
    -->
    --< power room 5
     ContentWindow.rooms.powerLabel = Turbine.UI.Label()
     ContentWindow.rooms.powerLabel:SetParent(ContentWindow.rooms)
     ContentWindow.rooms.powerLabel:SetSize(125, 20);
     ContentWindow.rooms.powerLabel:SetPosition(20, 10);
     ContentWindow.rooms.powerLabel:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16)
     ContentWindow.rooms.powerLabel:SetText("Room " .. "Power")
     ContentWindow.rooms.powerLabel:SetVisible(false)
 
     ContentWindow.rooms.powerWindow = Turbine.UI.Window()
     ContentWindow.rooms.powerWindow:SetParent(ContentWindow)
     ContentWindow.rooms.powerWindow:Focus()
     ContentWindow.rooms.powerWindow:SetEnabled(true);
     ContentWindow.rooms.powerWindow:SetSize(250, 320);
     ContentWindow.rooms.powerWindow:SetBackColor(Turbine.UI.Color(0.6,0,0,0))
     ContentWindow.rooms.powerWindow:SetVisible(false)
 
     ContentWindow.rooms.powerButton = Turbine.UI.Window()
     ContentWindow.rooms.powerButton:SetParent(ContentWindow.rooms)
     ContentWindow.rooms.powerButton:SetPosition(195,12)
     ContentWindow.rooms.powerButton:SetSize(10,10)
     ContentWindow.rooms.powerButton:SetBackColor(Turbine.UI.Color(0.24,0.25,0.64))
     ContentWindow.rooms.powerButton:SetVisible(true)
     ContentWindow.rooms.powerButton.MouseClick = function(sender, args)
        windowUse = ContentWindow.rooms.powerWindow
        ContentWindow.rooms.active = 5
        Global.updatePlayer()

        ContentWindow.rooms.powerWindow:SetVisible(true)
        ContentWindow.rooms.powerLabel:SetVisible(true)

        ContentWindow.rooms.tankWindow:SetVisible(false)
        ContentWindow.rooms.tankLabel:SetVisible(false)
 
        ContentWindow.rooms.healWindow:SetVisible(false)
        ContentWindow.rooms.healLabel:SetVisible(false)
 
        ContentWindow.rooms.dpsWindow:SetVisible(false)
        ContentWindow.rooms.dpsLabel:SetVisible(false)
     end
     -->
    --< close
     ContentWindow.rooms.closeButton = Turbine.UI.Window()
    ContentWindow.rooms.closeButton:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.closeButton:SetPosition(240,0)
    ContentWindow.rooms.closeButton:SetSize(10,10)
    ContentWindow.rooms.closeButton:SetBackColor(Turbine.UI.Color(0.48,0.47,0.47))
    ContentWindow.rooms.closeButton:SetVisible(true)
    ContentWindow.rooms.closeButton.MouseClick = function(sender, args)
        windowUse:SetVisible(not windowUse:IsVisible(windowUse))
        ContentWindow.rooms.visible = not ContentWindow.rooms.visible
        Global.updatePlayer()
    end
    -->
    --whitch window visible ?
    windowUse = ContentWindow.rooms.dpsWindow
    ContentWindow.rooms.active = 2
    ContentWindow.rooms.visible = true

    ContentWindow.rooms.drag.MouseDown = function(sender, args)
        ContentWindow.oldX = args.X
        ContentWindow.oldY = args.Y
        ContentWindow.dragging = true
    end
    ContentWindow.rooms.drag.MouseMove = function(sender, args)
        if ContentWindow.dragging then
            local mouseX, mouseY = Turbine.UI.Display.GetMousePosition()
            local newX = mouseX - ContentWindow.oldX
            local newY = mouseY - ContentWindow.oldY
            local screenWidth, screenHeight = Turbine.UI.Display:GetSize()
            local newLeft = math.max(0, math.min(newX, screenWidth - ContentWindow.rooms:GetWidth()))
            local newTop = math.max(0, math.min(newY, screenHeight - ContentWindow.rooms:GetHeight()))
            ContentWindow:SetPosition(newLeft, newTop)

            -- for preferences
            Global.Settings.roomDps.left = newLeft / Global.screenWidth
            Global.Settings.roomDps.top = newTop / Global.screenHeight
        end
    end
    ContentWindow.rooms.drag.MouseUp = function(sender, args)
        ContentWindow.dragging = false
    end
    return ContentWindow
end