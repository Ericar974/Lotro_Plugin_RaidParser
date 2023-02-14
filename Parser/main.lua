import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

-- < import class
import "RaidParser.Class.ButtonImage"
import "RaidParser.Class.ResizeImage"
-- >
-- <import "RaidParser.Parser.parser" -- Get the local parse
import "RaidParser.Lang.en"


-- < define the local player
Global.localPlayer = Turbine.Gameplay.LocalPlayer.GetInstance()
local inCombat = true

PlayerName = Global.localPlayer:GetName()
PlayerClass = Global.localPlayer:GetClass()
PlayerDamage = 1 -- set the damage at 1

PlayersList = {} -- PlayersList : Array[Array] with {PlayerName, his damage, his label}
ChatId = 1
ChaTyte = Turbine.ChatType.UserChat1

DamageMax = 1
local newParse = false
local found = nil

function abbreviateNumber(number)
    if number < 1000 then
        return number
    elseif number >= 1000 and number < 1000000 then
        return string.format("%.1fk", number / 1000)
    elseif number >= 1000000 and number < 1000000000 then
        return string.format("%.1fM", number / 1000000)
    else
        return string.format("%.1fB", number / 1000000000)
    end
end

local updatePlayerDamage = function()
    table.sort(PlayersList, sortByDamage)
    for i, value in ipairs(PlayersList) do
        value[3]:SetPosition(0, 10 + 24 * i)
        value[3].label:SetWidth(250 * value[2] / DamageMax);
        value[3].labe3:SetText(abbreviateNumber(value[2]) .. " ");
    end
    newParse = false
end

local updateDps = Global.ButtonImage(550, 850, "RaidParser/img/picto-target.tga", 591, 591,
        "/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. PlayerDamage .. ";" .. PlayerClass)
updateDps[2]:SetVisible(false)
local updateDpsBtn = updateDps[3]

EnableButton = function(bool) -- make the updateDpsBtn invisible/visible
    updateDpsBtn.quickslot:SetVisible(bool);
    updateDps[2]:SetVisible(bool);
end

updateDpsBtn.quickslot.MouseClick = function(sender, args) -- make the updateDpsBtn invisible at click
    EnableButton(false)
end



TimeLoop = function() -- Update the Dps value of the Btn for sending to chat
    UpdateShortCut(updateDpsBtn, PlayerDamage)
end

--import "RaidParser.Utils.update"  -- Send the local parse
UpdateShortCut = function(quickslot, value)
    quickslot.quickslot:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias,
        "/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. value .. ";" .. PlayerClass));
end


local Parse = Global.Parse()

-- regex for all player
local regex = "N:([%a]+);D:([%d%.]+);"
local regexTable = { "^x", "^x", "^x", "^x", "^x", "^x", "^x", "^x", "^x", "^x", "^x", "^x" }
local regeneragteRegex = function()
    for i, value in ipairs(PlayersList) do
        beforeName = "N:("
        name = ""
        afterName = ");D:([%d%.]+);"
        name = name .. beforeName .. value[1] .. afterName
        regexTable[i] = name
    end
    regex = "^x"
end


-- >


-- < options window
local isListening = false
local isInit = false
local isStarted = false

Global.optionsVisible = function ()
    options:SetVisible(true)
end

options = Turbine.UI.Lotro.GoldWindow()
options:SetPosition(1500, 350)
options:SetSize(400, 400)
options:SetText('Options')

helpToLaunch = Turbine.UI.Window()
helpToLaunch:SetParent(options)
helpToLaunch:SetSize(400, 100)
helpToLaunch:SetPosition(0, 250)
helpToLaunch:SetOpacity(1)
--helpToLaunch:SetBackColor(Turbine.UI.Color.Red)
helpToLaunch:SetVisible(true)

-- need to make a class
import "RaidParser.Class.HelpLabel"
helpToLaunch.labelSync = Global.HelpLabel(
        "When your chan is configured, you must wait for everyone to start the synchronization before continuing.",
        helpToLaunch, 400, 100)
helpToLaunch.labelInit = Global.HelpLabel(
        "If everyone synchronized, click on the target to enter in the room, WAIT EVERYONE before starting (stop & restart if someone fail the sync)",
        helpToLaunch, 400, 100)
helpToLaunch.labelInit:SetVisible(false)
helpToLaunch.labelStart = Global.HelpLabel(
        "You can stop & leave the room OR you can reset your dps and the room (if the group reset, everyone as to)",
        helpToLaunch, 400, 100)
helpToLaunch.labelStart:SetVisible(false)


local SetEnabled = function(object, bool)
    object:SetEnabled(bool)
end

import "RaidParser.Class.Button"

--setup of all buttons of Options Window and these functions MouseClick
synchroBtn = Global.Button("Synchro", options, 10, 350, 80, 50, true)
startBtn = Global.Button("Start", options, 110, 350, 80, 50, false)
resetBtn = Global.Button("Reset", options, 210, 350, 80, 50, false)
stopBtn = Global.Button("Stop", options, 310, 350, 80, 50, false)

synchroBtn.MouseClick = function(sender, args)
    SetEnabled(synchroBtn, false)
    helpToLaunch.labelSync:SetVisible(false)

    helpToLaunch.labelInit:SetVisible(true)

    SetEnabled(stopBtn, true)

    isListening = true
    DpsWindow:SetVisible(true);

    EnableButton(true)
end

local initBtn = function(sender, args)
    SetEnabled(startBtn, true)
    isInit = true
end

startBtn.MouseClick = function(sender, args)
    options:SetVisible(false)
    SetEnabled(resetBtn, true)
    SetEnabled(startBtn, false)
    helpToLaunch.labelInit:SetVisible(false)
    helpToLaunch.labelStart:SetVisible(true)

    isStarted = true
    UpdateShortCut(updateDpsBtn, PlayerDamage)
    regeneragteRegex()
end

stopBtn.MouseClick = function(sender, args)
    SetEnabled(stopBtn, false)
    SetEnabled(resetBtn, false)
    initBtn()
    SetEnabled(startBtn, false)
    SetEnabled(synchroBtn, true)

    helpToLaunch.labelSync:SetVisible(true)
    helpToLaunch.labelInit:SetVisible(false)
    helpToLaunch.labelStart:SetVisible(false)

    isListening = false
    isInit = false
    isStarted = false

    DpsWindow:SetVisible(false);
    EnableButton(false)

    PlayerDamage = 1
    inCombat = true
    PlayersList = {}
    ChatId = 1
    ChaTyte = Turbine.ChatType.UserChat1
    regex = "N:([%a]+);D:([%d%.]+);"

    DamageMax = 1
    found = nil
    updatePlayerDamage()
    --reset the Dps window
    DpsWindow = Turbine.UI.Window()
DpsWindow:SetText("Room");
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
end

resetBtn.MouseClick = function(sender, args)
    EnableButton(false)
    PlayerDamage = 1
    inCombat = true
    DamageMax = 1
    for i, value in ipairs(PlayersList) do
        value[2] = 1
    end
    updatePlayerDamage()
end
-->


-- >



local loopingTimer = Turbine.Engine.GetGameTime();

function AddCallback(object, event, callback)
    if (object[event] == nil) then
        object[event] = callback;
    else
        if (type(object[event]) == "table") then
            table.insert(object[event], callback);
        else
            object[event] = { object[event], callback };
        end
    end
end

-- Get the parse of other players


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


local classIcon = {}
classIcon["23"] = { "RaidParser/img/classIcon/Guardian-icon.tga", Turbine.UI.Color(0.8, 0, 0) } -- guardian
classIcon["24"] = { "RaidParser/img/classIcon/Captain-icon.tga", Turbine.UI.Color(0.37, 0.81, 0.33) } -- captain
classIcon["31"] = { "RaidParser/img/classIcon/Minstrel-icon.tga", Turbine.UI.Color(0.95, 0.71, 0) } -- minstrel
classIcon["40"] = { "RaidParser/img/classIcon/Burglar-icon.tga", Turbine.UI.Color(0.51, 0.29, 0) } -- burglar
classIcon["215"] = { "RaidParser/img/classIcon/Brawler-icon.tga", Turbine.UI.Color(0.59, 0.43, 0.43) } -- brawler
classIcon["162"] = { "RaidParser/img/classIcon/Hunter-icon.tga", Turbine.UI.Color(0.06, 0.5, 0) } -- hunter
classIcon["172"] = { "RaidParser/img/classIcon/Champion-icon.tga", Turbine.UI.Color(0.18, 0.29, 0.64) } -- champ
classIcon["185"] = { "RaidParser/img/classIcon/Lore-master-icon.tga", Turbine.UI.Color(0.53, 0.24, 0.38) } -- lm
classIcon["193"] = { "RaidParser/img/classIcon/Rune-keeper-icon.tga", Turbine.UI.Color(0.71, 0, 0.85) } -- rk
classIcon["194"] = { "RaidParser/img/classIcon/Warden-icon.tga", Turbine.UI.Color(1, 0.46, 0.13) } -- warden
classIcon["214"] = { "RaidParser/img/classIcon/Beo.tga", Turbine.UI.Color(0.21, 0.52, 0.38) } -- beo


local newPlayer = function(player, damage, index, class)
    PlayersList[index][3]:SetParent(DpsWindow);
    PlayersList[index][3]:SetPosition(0, 10 + 24 * index);
    PlayersList[index][3]:SetSize(250 * damage / DamageMax, 22);
    PlayersList[index][3]:SetEnabled(true)
    PlayersList[index][3]:SetVisible(true)

    PlayersList[index][3].icon = Global.ResizeImage(classIcon[class][1], 120, 120, PlayersList[index][3], 22, 22)


    PlayersList[index][3].label = Turbine.UI.Label()
    PlayersList[index][3].label:SetParent(PlayersList[index][3])
    PlayersList[index][3].label:SetFont(Turbine.UI.Lotro.Font.VerdanaBold16);
    PlayersList[index][3].label:SetBackColor(classIcon[class][2]);
    PlayersList[index][3].label:SetOutlineColor(Turbine.UI.Color.Black)
    PlayersList[index][3].label:SetSize(250 * damage / DamageMax, 22);
    PlayersList[index][3].label:SetPosition(23, 0);
    PlayersList[index][3].label:SetForeColor(Turbine.UI.Color.White);
    PlayersList[index][3].label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);

    PlayersList[index][3].labe2 = Turbine.UI.Label()
    PlayersList[index][3].labe2:SetParent(PlayersList[index][3])
    PlayersList[index][3].labe2:SetFont(Turbine.UI.Lotro.Font.VerdanaBold16);
    PlayersList[index][3].labe2:SetText(" " .. player);
    PlayersList[index][3].labe2:SetOutlineColor(Turbine.UI.Color.Black)
    PlayersList[index][3].labe2:SetSize(250 * damage / DamageMax, 22);
    PlayersList[index][3].labe2:SetPosition(23, 0);
    PlayersList[index][3].labe2:SetForeColor(Turbine.UI.Color.White);
    PlayersList[index][3].labe2:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);

    PlayersList[index][3].labe3 = Turbine.UI.Label()
    PlayersList[index][3].labe3:SetParent(PlayersList[index][3])
    PlayersList[index][3].labe3:SetFont(Turbine.UI.Lotro.Font.VerdanaBold16);
    PlayersList[index][3].labe3:SetText(damage .. " ");
    PlayersList[index][3].labe3:SetOutlineColor(Turbine.UI.Color.Black)
    PlayersList[index][3].labe3:SetSize(250 * damage / DamageMax, 22);
    PlayersList[index][3].labe3:SetPosition(0, 0);
    PlayersList[index][3].labe3:SetForeColor(Turbine.UI.Color.White);
    PlayersList[index][3].labe3:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight);
end



function sortByDamage(a, b)
    return tonumber(a[2]) > tonumber(b[2])
end

AddCallback(Turbine.Chat, "Received", function(sender, args) -- track combat chat
    -- < PLAYER CHAT COMBAT
    -- 1) only parse combat text for now
    if (isStarted and ((args.ChatType == Turbine.ChatType.EnemyCombat) or (args.ChatType == Turbine.ChatType.PlayerCombat) or (args.ChatType == Turbine.ChatType.Death))) then
        -- immediately grab timestamp (NB: actually it appears this doesn't change over successive calls in the same frame)
        local timestamp = Turbine.Engine.GetGameTime();
        if (timestamp - loopingTimer > 3) then
            TimeLoop()
            EnableButton(true)
            if newParse then
                updatePlayerDamage()
            end
            loopingTimer = timestamp
        end

        -- grab line from combat log, strip it of color, trim it, and parse it according to the localized parsing function
        local updateType, initiatorName, targetName, skillName, var1, var2, var3, var4 = Parse(string.gsub(
                string.gsub(args.Message, "<rgb=#......>(.*)</rgb>", "%1"), "^%s*(.-)%s*$", "%1"));
        if (updateType == nil) then return end
        PlayerDamage = PlayerDamage + var1
        -- >
        return
    elseif (isListening and args.ChatType == ChaTyte and
        (string.match(args.Message, regex) or string.match(args.Message, regexTable[1]) or string.match(args.Message, regexTable[2]) or string.match(args.Message, regexTable[3])
        or string.match(args.Message, regexTable[4]) or string.match(args.Message, regexTable[5]) or string.match(args.Message, regexTable[6])
        or string.match(args.Message, regexTable[7]) or string.match(args.Message, regexTable[8]) or string.match(args.Message, regexTable[9])
        or string.match(args.Message, regexTable[10]) or string.match(args.Message, regexTable[11]) or string.match(args.Message, regexTable[12]))
        ) then
        -- < RAID CHAT COMBAT
        local player = string.match(args.Message, "N:([%a]+);")
        local damage = string.match(args.Message, "D:([%d%.]+);")

        if not isStarted then
            initBtn()
            -- < foreach player in PlayersList
            found = false
            for i, value in ipairs(PlayersList) do
                if value[1] == player then
                    found = true
                end
            end
            -- />
            if not found and #PlayersList < 12 then
                class = string.match(args.Message, "D:[%d%.]+;(.+)'")

                table.insert(PlayersList, #PlayersList + 1, { player, 1, Turbine.UI.Window() })
                newPlayer(player, 1, #PlayersList, class)
            end
            return
        end
        -- < if damage is bigger than DamageMax we change DamageMax
        damage = tonumber(damage)
        if (damage > DamageMax) then
            DamageMax = tonumber(damage)
        end
        -- >
        for i, value in ipairs(PlayersList) do
            if value[1] == player then
                value[2] = damage
                newParse = true
                if not inCombat then
                    updatePlayerDamage()
                end
                return
            end
        end
        -- >
    else
        return;
    end
end);
-- >

AddCallback(Global.localPlayer, "InCombatChanged", function()
    inCombat = Global.localPlayer:IsInCombat();

    if (not inCombat) then
        updatePlayerDamage()
    end
end);




--[[
comment... Wait for this button ...

local resetBtn = Turbine.UI.Lotro.Button()
resetBtn:SetParent( updateDps );
resetBtn:SetText("Reset")
resetBtn:SetSize( 50, 20 );
resetBtn:SetPosition( 0, 0 );
resetBtn:SetVisible(true);
resetBtn.MouseClick = function(sender,args)
    PlayerDamage = 1
    TimeLoop()
    updateDpsBtn:SetVisible(true);
end
]]
