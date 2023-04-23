import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

--< options room
Global.ChatNb = Global.Settings.chan[1]
Global.ChaTyte = Global.Settings.chan[2]
Global.ChatId = Global.Settings.chan[3]

import "RaidParser.Class.Button"
import "RaidParser.Class.HelpLabel"


-- < setup the chan
-- Create a table to store the button states
buttonStates = {
    { true, 1,  Turbine.ChatType.UserChat1,  '1' },
    { true, 2,  Turbine.ChatType.UserChat2,  '2' },
    { true, 3,  Turbine.ChatType.UserChat3,  '3' },
    { true, 4,  Turbine.ChatType.UserChat4,  '4' },
    { true, 5,  Turbine.ChatType.UserChat5,  '5' },
    { true, 6,  Turbine.ChatType.UserChat6,  '6' },
    { true, 7,  Turbine.ChatType.UserChat7,  '7' },
    { true, 8,  Turbine.ChatType.UserChat8,  '8' },
    { true, 9,  Turbine.ChatType.Fellowship, 'f' },
    { true, 10, Turbine.ChatType.Raid,       'ra' }
}
for i, value in ipairs(buttonStates) do
    if (value[2] == Global.Settings.chan[1]) then
        value[1] = false
    end
end

function Global.Room()
    ContentWindow = Turbine.UI.Window() -- mother of them all
    ContentWindow:SetSize(250, 340);
    ContentWindow:SetPosition(Global.Settings.roomDps.left * Global.screenWidth,
        Global.Settings.roomDps.top * Global.screenHeight);
    ContentWindow:Focus()
    ContentWindow:SetZOrder(-1)
    ContentWindow:SetVisible(false)

    ContentWindow.rooms = Turbine.UI.Window() -- title and elder of all childrens
    ContentWindow.rooms:SetParent(ContentWindow)
    ContentWindow.rooms:SetSize(250, 33);
    ContentWindow.rooms:SetPosition(0, 20)
    ContentWindow.rooms:SetVisible(true)
    ContentWindow.rooms:SetZOrder(4)
    ContentWindow.rooms:SetBackColor(Turbine.UI.Color(0.5, 0, 0, 0))


    ContentWindow.rooms.hiddenMsg = Turbine.UI.Label()
    ContentWindow.rooms.hiddenMsg:SetParent(ContentWindow)
    ContentWindow.rooms.hiddenMsg:SetPosition(20, 0)
    ContentWindow.rooms.hiddenMsg:SetSize(100, 20)
    ContentWindow.rooms.hiddenMsg:SetVisible(false)
    ContentWindow.rooms.hiddenMsg:SetZOrder(3)
    ContentWindow.rooms.hiddenMsg:SetWantsKeyEvents(true)
    ContentWindow.rooms.hiddenMsg:SetText('RP: rooms')

    ContentWindow.rooms.drag = Turbine.UI.Window()
    ContentWindow.rooms.drag:SetParent(ContentWindow)
    ContentWindow.rooms.drag:SetBackground("RaidParser/img/drag.tga")
    ContentWindow.rooms.drag:SetSize(20, 20)
    ContentWindow.rooms.drag:SetStretchMode(1)
    ContentWindow.rooms.drag:SetVisible(false)
    ContentWindow.rooms:SetWantsKeyEvents(true)
    ContentWindow.rooms.KeyDown = function(sender, args)
        if (args.Action == Turbine.UI.Lotro.Action.ToggleHiddenDragBoxes) then
            ContentWindow.rooms.drag:SetVisible(not ContentWindow.rooms.drag:IsVisible())
            ContentWindow.rooms.hiddenMsg:SetVisible(not ContentWindow.rooms.hiddenMsg:IsVisible())
        end
    end

    --window container for btns
    Global.ChatNb = Global.Settings.chan[1]
    Global.ChaTyte = Global.Settings.chan[2]
    Global.ChatId = Global.Settings.chan[3]

    ContentWindow.rooms.optionsMother = Turbine.UI.Window()
    ContentWindow.rooms.optionsMother:SetParent(ContentWindow)
    ContentWindow.rooms.optionsMother:Focus()
    ContentWindow.rooms.optionsMother:SetEnabled(true);
    ContentWindow.rooms.optionsMother:SetSize(250, 320);
    ContentWindow.rooms.optionsMother:SetPosition(0, 20)
    ContentWindow.rooms.optionsMother:SetBackColor(Turbine.UI.Color.Black)
    ContentWindow.rooms.optionsMother:SetVisible(false)
    ContentWindow.rooms.optionsMother:SetZOrder(1)

    windowChan = Turbine.UI.Window()
    windowChan:SetParent(ContentWindow.rooms.optionsMother)
    windowChan:SetPosition(0, 50)
    windowChan:SetSize(250, 320)
    windowChan:SetVisible(true)
    windowChan:SetZOrder(1)


    -- < help label for the command channels is game
    helpListChan = Global.HelpLabel("/listchannels", windowChan, 150, 20)
    helpListChan:SetSelectable(true)
    helpListChan:SetPosition(50, 160)
    helpListChan:SetFont(Turbine.UI.Lotro.Font.TrajanPro13);
    helpListChan:SetForeColor(Turbine.UI.Color(1, 0.87, 0))

    helpJoinChan = Global.HelpLabel("/joinchannel name ?password", windowChan, 150, 40)
    helpJoinChan:SetSelectable(true)
    helpJoinChan:SetPosition(50, 180)
    helpJoinChan:SetFont(Turbine.UI.Lotro.Font.TrajanPro13);
    helpJoinChan:SetForeColor(Turbine.UI.Color(1, 0.87, 0))

    helpQuitChan = Global.HelpLabel("/leavechannel name", windowChan, 150, 40)
    helpQuitChan:SetPosition(50, 210)
    helpQuitChan:SetSelectable(true)
    helpQuitChan:SetFont(Turbine.UI.Lotro.Font.TrajanPro13);
    helpQuitChan:SetForeColor(Turbine.UI.Color(1, 0.87, 0))
    -- >

    -- save channel btn
    Global.saveBtn = Global.Button('save', windowChan, 180, 120,
        0, 0, false)

    -- create of all btn
    local buttons = {}
    for i = 1, 10 do
        if i == 9 then -- if btn is group
            buttons[i] = Global.Button('group', windowChan,30 + ((i - 1) % 2) * 50, 120,
                0,
                0, buttonStates[i][1])
        elseif i == 10 then -- if btn is raid
            buttons[i] = Global.Button('raid', windowChan, 30 +((i - 1) % 2) * 50, 120,
                0, 0,
                buttonStates[i][1])
        else
            if i <= 4 then -- if btn is in first row
                buttons[i] = Global.Button(tostring(i), windowChan, 30 +(i - 1) * 50, 60, 0, 0, buttonStates[i][1])
            elseif i <= 8 then -- if btn is in second row
                buttons[i] = Global.Button(tostring(i), windowChan, 30 +(i - 5) * 50, 90, 0, 0, buttonStates[i][1])
            end
        end
        buttons[i].MouseClick = function(sender, args)
            for j = 1, 10 do
                if j == i then
                    buttonStates[j][1] = false
                    Global.ChatId = buttonStates[j][4]
                    Global.ChatNb = buttonStates[j][2]
                    Global.ChaTyte = buttonStates[j][3]
                else
                    buttonStates[j][1] = true
                end
                buttons[j]:SetEnabled(buttonStates[j][1])
            end
            Global.saveBtn:SetEnabled(true)
            -- for preferences
            Global.Settings.chan = { Global.ChatNb, Global.ChaTyte, Global.ChatId }
        end
    end

    windowChan:SetVisible(true)
    -- >

    helpChan = Global.HelpLabel("Select an UserChan#", windowChan, 250, 80)
    helpChan:SetZOrder(-2)

    -- options btn
    ContentWindow.rooms.optionsbtn = Turbine.UI.Window()
    ContentWindow.rooms.optionsbtn:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.optionsbtn:SetPosition(225, 8)
    ContentWindow.rooms.optionsbtn:SetZOrder(2)
    ContentWindow.rooms.optionsbtn:SetSize(17, 17)
    ContentWindow.rooms.optionsbtn:SetBackground("RaidParser/img/gears.tga")
    ContentWindow.rooms.optionsbtn:SetVisible(true)
    ContentWindow.rooms.optionsbtn.MouseClick = function(sender, args)
        ContentWindow.rooms.optionsMother:SetVisible(not ContentWindow.rooms.optionsMother:IsVisible())
    end
    -->

    local windowUse
    ContentWindow.rooms.active = 2

    --< dps room 2
    ContentWindow.rooms.dpsLabel = Turbine.UI.Label()
    ContentWindow.rooms.dpsLabel:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.dpsLabel:SetSize(100, 20);
    ContentWindow.rooms.dpsLabel:SetPosition(20, 10);
    ContentWindow.rooms.dpsLabel:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16)
    ContentWindow.rooms.dpsLabel:SetText("Damages")
    ContentWindow.rooms.dpsLabel:SetForeColor(Turbine.UI.Color.Red)

    ContentWindow.rooms.dpsWindow = Turbine.UI.Window()
    ContentWindow.rooms.dpsWindow:SetParent(ContentWindow)
    ContentWindow.rooms.dpsWindow:Focus()
    ContentWindow.rooms.dpsWindow:SetEnabled(true);
    ContentWindow.rooms.dpsWindow:SetSize(250, 320);
    ContentWindow.rooms.dpsWindow:SetPosition(0, 20)
    ContentWindow.rooms.dpsWindow:SetBackColor(Turbine.UI.Color(0, 0, 0, 0))
    ContentWindow.rooms.dpsWindow:SetVisible(true)

    ContentWindow.rooms.dpsButton = Turbine.UI.Window()
    ContentWindow.rooms.dpsButton:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.dpsButton:SetPosition(120, 12)
    ContentWindow.rooms.dpsButton:SetSize(10, 10)
    ContentWindow.rooms.dpsButton:SetBackColor(Turbine.UI.Color.Red)
    ContentWindow.rooms.dpsButton:SetVisible(true)
    ContentWindow.rooms.dpsButton.MouseClick = function(sender, args)
        windowUse = ContentWindow.rooms.dpsWindow
        ContentWindow.rooms.active = 2
        ContentWindow.rooms.visible = true
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
    ContentWindow.rooms.healLabel:SetSize(100, 20);
    ContentWindow.rooms.healLabel:SetPosition(20, 10);
    ContentWindow.rooms.healLabel:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16)
    ContentWindow.rooms.healLabel:SetText("Heals")
    ContentWindow.rooms.healLabel:SetForeColor(Turbine.UI.Color(0.44, 0.61, 0.28))
    ContentWindow.rooms.healLabel:SetVisible(false)

    ContentWindow.rooms.healWindow = Turbine.UI.Window()
    ContentWindow.rooms.healWindow:SetParent(ContentWindow)
    ContentWindow.rooms.healWindow:Focus()
    ContentWindow.rooms.healWindow:SetEnabled(true);
    ContentWindow.rooms.healWindow:SetSize(250, 320);
    ContentWindow.rooms.healWindow:SetPosition(0, 20)
    ContentWindow.rooms.healWindow:SetBackColor(Turbine.UI.Color(0, 0, 0, 0))
    ContentWindow.rooms.healWindow:SetVisible(false)

    ContentWindow.rooms.healButton = Turbine.UI.Window()
    ContentWindow.rooms.healButton:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.healButton:SetPosition(150, 12)
    ContentWindow.rooms.healButton:SetSize(10, 10)
    ContentWindow.rooms.healButton:SetBackColor(Turbine.UI.Color(0.44, 0.61, 0.28))
    ContentWindow.rooms.healButton:SetVisible(true)
    ContentWindow.rooms.healButton.MouseClick = function(sender, args)
        windowUse = ContentWindow.rooms.healWindow
        ContentWindow.rooms.active = 3
        ContentWindow.rooms.visible = true
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
    ContentWindow.rooms.tankLabel:SetSize(100, 20);
    ContentWindow.rooms.tankLabel:SetPosition(20, 10);
    ContentWindow.rooms.tankLabel:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16)
    ContentWindow.rooms.tankLabel:SetText("Tank")
    ContentWindow.rooms.tankLabel:SetForeColor(Turbine.UI.Color(0.8, 0.69, 0.33))
    ContentWindow.rooms.tankLabel:SetVisible(false)

    ContentWindow.rooms.tankWindow = Turbine.UI.Window()
    ContentWindow.rooms.tankWindow:SetParent(ContentWindow)
    ContentWindow.rooms.tankWindow:Focus()
    ContentWindow.rooms.tankWindow:SetEnabled(true);
    ContentWindow.rooms.tankWindow:SetSize(250, 320);
    ContentWindow.rooms.tankWindow:SetPosition(0, 20)
    ContentWindow.rooms.tankWindow:SetBackColor(Turbine.UI.Color(0.0, 0, 0, 0))
    ContentWindow.rooms.tankWindow:SetVisible(false)

    ContentWindow.rooms.tankButton = Turbine.UI.Window()
    ContentWindow.rooms.tankButton:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.tankButton:SetPosition(135, 12)
    ContentWindow.rooms.tankButton:SetSize(10, 10)
    ContentWindow.rooms.tankButton:SetBackColor(Turbine.UI.Color(0.8, 0.69, 0.33))
    ContentWindow.rooms.tankButton:SetVisible(true)
    ContentWindow.rooms.tankButton.MouseClick = function(sender, args)
        windowUse = ContentWindow.rooms.tankWindow
        ContentWindow.rooms.active = 4
        ContentWindow.rooms.visible = true
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
    ContentWindow.rooms.powerLabel:SetSize(100, 20);
    ContentWindow.rooms.powerLabel:SetPosition(20, 10);
    ContentWindow.rooms.powerLabel:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16)
    ContentWindow.rooms.powerLabel:SetText("Powers")
    ContentWindow.rooms.powerLabel:SetForeColor(Turbine.UI.Color(0.41, 0.42, 0.91))
    ContentWindow.rooms.powerLabel:SetVisible(false)

    ContentWindow.rooms.powerWindow = Turbine.UI.Window()
    ContentWindow.rooms.powerWindow:SetParent(ContentWindow)
    ContentWindow.rooms.powerWindow:Focus()
    ContentWindow.rooms.powerWindow:SetEnabled(true);
    ContentWindow.rooms.powerWindow:SetSize(250, 320);
    ContentWindow.rooms.powerWindow:SetPosition(0, 20)
    ContentWindow.rooms.powerWindow:SetBackColor(Turbine.UI.Color(0.0, 0, 0, 0))
    ContentWindow.rooms.powerWindow:SetVisible(false)

    ContentWindow.rooms.powerButton = Turbine.UI.Window()
    ContentWindow.rooms.powerButton:SetParent(ContentWindow.rooms)
    ContentWindow.rooms.powerButton:SetPosition(165, 12)
    ContentWindow.rooms.powerButton:SetSize(10, 10)
    ContentWindow.rooms.powerButton:SetBackColor(Turbine.UI.Color(0.41, 0.42, 0.91))
    ContentWindow.rooms.powerButton:SetVisible(true)
    ContentWindow.rooms.powerButton.MouseClick = function(sender, args)
        windowUse = ContentWindow.rooms.powerWindow
        ContentWindow.rooms.active = 5
        ContentWindow.rooms.visible = true
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
    ContentWindow.rooms.closeButton:SetPosition(240, 0)
    ContentWindow.rooms.closeButton:SetSize(10, 10)
    ContentWindow.rooms.closeButton:SetBackColor(Turbine.UI.Color(0.48, 0.47, 0.47))
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
