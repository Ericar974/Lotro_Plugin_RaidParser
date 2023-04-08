import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

Global.optionsVisible = function()
    Global.options:SetVisible(not Global.options:IsVisible())
end
Global.ChatId = 1
Global.ChaTyte = Turbine.ChatType.UserChat1

Global.options = Turbine.UI.Lotro.GoldWindow()
Global.options:SetPosition(Global.screenWidth * Global.Settings.optionWindow.left, Global.screenHeight * Global.Settings.optionWindow.top)
Global.options:SetSize(400, 400)
Global.options:SetText('Options')
Global.options:SetWantsKeyEvents(true) -- setup the key event for escape
function Global.options.KeyDown(sender, args)
    if (args.Action == Turbine.UI.Lotro.Action.Escape) then
        -- close the window if escape pressed
        Global.options:SetVisible(false)
    end
end


import "RaidParser.Class.Button"
import "RaidParser.Class.HelpLabel"


-- < setup the chan
-- Create a table to store the button states
buttonStates = {
    { false, 1,  Turbine.ChatType.UserChat1,  '1' },
    { true,  2,  Turbine.ChatType.UserChat2,  '2' },
    { true,  3,  Turbine.ChatType.UserChat3,  '3' },
    { true,  4,  Turbine.ChatType.UserChat4,  '4' },
    { true,  5,  Turbine.ChatType.UserChat5,  '5' },
    { true,  6,  Turbine.ChatType.UserChat6,  '6' },
    { true,  7,  Turbine.ChatType.UserChat7,  '7' },
    { true,  8,  Turbine.ChatType.UserChat8,  '8' },
    { true,  9,  Turbine.ChatType.Fellowship, 'f' },
    { true,  10, Turbine.ChatType.Raid,       'ra' }
}

--window container for btns
windowChan = Turbine.UI.Window()
windowChan:SetParent(Global.options)
windowChan:SetPosition(0, 50)
windowChan:SetSize(400, 200)
windowChan:SetVisible(true)
windowChan:SetZOrder(1)

Global.options.MouseMove = function(sender, args)
    Global.screenWidth , Global.screenHeight = Turbine.UI.Display.GetSize();
    Global.Settings.optionWindow.left = Global.options.GetLeft(Global.options) / Global.screenWidth
    Global.Settings.optionWindow.top = Global.options.GetTop(Global.options) / Global.screenHeight
end

-- < help label for the command channels is game
helpListChan = Global.HelpLabel("/listchannels", windowChan, 150, 20)
helpListChan:SetSelectable(true)
helpListChan:SetPosition(30, 60)
helpListChan:SetFont(Turbine.UI.Lotro.Font.TrajanPro13);
helpListChan:SetForeColor(Turbine.UI.Color(1, 0.87, 0))

helpJoinChan = Global.HelpLabel("/joinchannel name ?password", windowChan, 150, 40)
helpJoinChan:SetSelectable(true)
helpJoinChan:SetPosition(30, 80)
helpJoinChan:SetFont(Turbine.UI.Lotro.Font.TrajanPro13);
helpJoinChan:SetForeColor(Turbine.UI.Color(1, 0.87, 0))

helpQuitChan = Global.HelpLabel("/leavechannel name", windowChan, 150, 40)
helpQuitChan:SetPosition(30, 120)
helpQuitChan:SetSelectable(true)
helpQuitChan:SetFont(Turbine.UI.Lotro.Font.TrajanPro13);
helpQuitChan:SetForeColor(Turbine.UI.Color(1, 0.87, 0))
-- >

-- save channel btn
Global.saveBtn = Global.Button('save', windowChan, 250, 100,
    0, 0, false)

-- create of all btn
local buttons = {}
for i = 1, 10 do
    if i == 9 then -- if btn is group
        buttons[i] = Global.Button('group', windowChan, 200 + ((i - 1) % 2) * 100, 40 + math.floor((i - 1) / 2) * 30, 0,
            0, buttonStates[i][1])
    elseif i == 10 then -- if btn is raid
        buttons[i] = Global.Button('raid', windowChan, 200 + ((i - 1) % 2) * 100, 40 + math.floor((i - 1) / 2) * 30, 0, 0,
            buttonStates[i][1])
    else
        buttons[i] = Global.Button(tostring(i), windowChan, 200 + ((i - 1) % 2) * 100, 40 + math.floor((i - 1) / 2) * 30,
            0, 0, buttonStates[i][1])
    end
    buttons[i].MouseClick = function(sender, args)
        for j = 1, 10 do
            if j == i then
                buttonStates[j][1] = false
                Global.ChatId = buttonStates[j][4]
                Global.ChaTyte = buttonStates[j][3]
            else
                buttonStates[j][1] = true
            end
            buttons[j]:SetEnabled(buttonStates[j][1])
        end
        Global.saveBtn:SetEnabled(true)
    end
end



windowChan:SetVisible(true)
-- >

Global.helpToLaunch = Turbine.UI.Window()
Global.helpToLaunch:SetParent(Global.options)
Global.helpToLaunch:SetSize(400, 150)
Global.helpToLaunch:SetPosition(0, 250)
Global.helpToLaunch:SetVisible(true)



helpChan = Global.HelpLabel("Select an UserChan#", windowChan, 400, 20)

Global.helpToLaunch.labelSync = Global.HelpLabel(
    "Everyone need to synchronize before continuing",
    Global.helpToLaunch, 400, 100)

Global.helpToLaunch.labelInit = Global.HelpLabel(
    "If everyone synchronized, click on the target to enter in the room, Start will lock the room",
    Global.helpToLaunch, 400, 100)
Global.helpToLaunch.labelInit:SetVisible(false)

Global.helpToLaunch.labelStart = Global.HelpLabel(
    "You can quit the room OR you can reset the actual room (if the group reset, everyone as to)",
    Global.helpToLaunch, 400, 100)
Global.helpToLaunch.labelStart:SetVisible(false)
