import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

-- < import class
import "RaidParser.Class.ButtonImage"
-- >
-- <import "RaidParser.Parser.parser" -- Get the local parse
import "RaidParser.Lang.en"

-- < define the local player
localPlayer = Turbine.Gameplay.LocalPlayer.GetInstance()

PlayerName = localPlayer:GetName()
PlayerDamage = 1 -- set the damage at 1

PlayersList = {} -- PlayersList : Array[Array] with {PlayerName, his damage, his label}
ChatId = 1
ChaTyte = Turbine.ChatType.UserChat1

DamageMax = 1
local found = nil

local updatePlayerDamage = function()
    for i, value in ipairs(PlayersList) do
        Turbine.Shell.WriteLine(value[1])
        Turbine.Shell.WriteLine(value[2])
        Turbine.Shell.WriteLine(DamageMax)
        value[3]:SetPosition(40, 20 + 20 * i);
        value[3]:SetSize(130 * value[2] / DamageMax, 15);
    end
    
end

local updateDps = Global.ButtonImage(550, 850, "RaidParser/img/send.tga", 512, 512,
        "/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. PlayerDamage .. ";")
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
        "/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. value .. ";"));
end

local Parse = Global.Parse()
-- regex for all player
local regex = "N:([%a]+);D:([%d%.]+);"
local regexTable = {"^x","^x","^x","^x","^x","^x","^x","^x","^x","^x","^x","^x"}
local regeneragteRegex = function ()
    for i, value in ipairs(PlayersList) do
        beforeName ="N:("
        name = ""
        afterName = ");D:([%d%.]+);"
        name = name .. beforeName ..value[1] .. afterName
        regexTable[i] = name
    end
    regex = "^x"
    Turbine.Shell.WriteLine(regex)
end

-- >


-- < options window
local isListening = false
local isInit = false
local isStarted = false

options = Turbine.UI.Lotro.Window()
options:SetPosition(1500, 350)
options:SetSize(400, 400)
options:SetText('Options')
options:SetVisible(true)

local SetEnabled = function(object, bool)
    object:SetEnabled(bool)
end

import "RaidParser.Class.Button"

--setup of all buttons of Options Window and these functions MouseClick
synchroBtn = Global.Button("Synchro", options, 10, 350, 80, 50, true)
initBtn = Global.Button("Init", options, 110, 350, 80, 50, false)
startBtn = Global.Button("Start", options, 210, 350, 80, 50, false)
stopBtn = Global.Button("Stop", options, 310, 350, 80, 50, false)

synchroBtn.MouseClick = function(sender, args)
    SetEnabled(synchroBtn, false)
    SetEnabled(initBtn, true)
    SetEnabled(stopBtn, true)

    isListening = true
    DpsWindow:SetVisible(true);
    
    EnableButton(true)
end

local initBtn = function(sender, args)
    SetEnabled(initBtn, false)
    SetEnabled(startBtn, true)

    isInit = true

end

startBtn.MouseClick = function(sender, args)
    SetEnabled(startBtn, false)

    isStarted = true
    EnableButton(true)
    UpdateShortCut(updateDpsBtn, PlayerDamage)
    regeneragteRegex()
end

stopBtn.MouseClick = function(sender, args)
    SetEnabled(stopBtn, false)
    initBtn()
    SetEnabled(startBtn, false)
    SetEnabled(synchroBtn, true)

    isListening = false
    isInit = false
    isStarted = false

    DpsWindow:SetVisible(false);
    EnableButton(false)

    PlayerDamage = 1
    PlayersList = {}
    ChatId = 1
    ChaTyte = Turbine.ChatType.UserChat1
    regex = "N:([%a]+);D:([%d%.]+);"
    
    DamageMax = 1
    found = nil
    updatePlayerDamage()
    --reset the Dps window
    DpsWindow = Turbine.UI.Lotro.Window()
    DpsWindow:SetText("Room");
    DpsWindow:SetPosition(1500, 780);
    DpsWindow:SetSize(200, 300);
    --DpsWindow:SetBackColor(Turbine.UI.Color.Black)
    DpsWindow:SetVisible(false);
end
-->


-- >



local loopingTimer = Turbine.Engine.GetGameTime();
local resetTimer = loopingTimer

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


DpsWindow = Turbine.UI.Lotro.Window()
DpsWindow:SetText("Room");
DpsWindow:SetPosition(1500, 780);
DpsWindow:SetSize(200, 300);
--DpsWindow:SetBackColor(Turbine.UI.Color.Black)
DpsWindow:SetVisible(false);


local newPlayer = function(player, damage, index)
    PlayersList[index][3]:SetText(player .. " ".. damage);
    PlayersList[index][3]:SetParent(DpsWindow);
    PlayersList[index][3]:SetSize(130 * damage / DamageMax, 15);
    PlayersList[index][3]:SetPosition(40, 20 + 20 * index);
    PlayersList[index][3]:SetBackColor(Turbine.UI.Color(math.random(7, 10) / 10, math.random(1, 10) / 10,
        math.random(1, 10) / 10));
    PlayersList[index][3]:SetForeColor(Turbine.UI.Color.Black);
    PlayersList[index][3]:GetWantsUpdates(true)
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
        if (timestamp - resetTimer > 2) then
            EnableButton(true)
            resetTimer = timestamp
        end
        if (timestamp - loopingTimer > 1) then
            TimeLoop()
            loopingTimer = timestamp
        end

        -- grab line from combat log, strip it of color, trim it, and parse it according to the localized parsing function
        local updateType, initiatorName, targetName, skillName, var1, var2, var3, var4 = Parse(string.gsub(
                string.gsub(args.Message, "<rgb=#......>(.*)</rgb>", "%1"), "^%s*(.-)%s*$", "%1"));
        if (updateType == nil) then return end
        PlayerDamage = PlayerDamage + var1
        -- >
    elseif (isListening and 
    (string.match(args.Message, regex) or string.match(args.Message, regexTable[1]) or string.match(args.Message, regexTable[2]) or string.match(args.Message, regexTable[3]) 
    or string.match(args.Message, regexTable[4]) or string.match(args.Message, regexTable[5]) or string.match(args.Message, regexTable[6])
    or string.match(args.Message, regexTable[7]) or string.match(args.Message, regexTable[8]) or string.match(args.Message, regexTable[9])
    or string.match(args.Message, regexTable[10]) or string.match(args.Message, regexTable[11]) or string.match(args.Message, regexTable[12])) 
    and args.ChatType == ChaTyte) then
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
                table.insert(PlayersList, #PlayersList + 1, { player, 1, Turbine.UI.Label() })
                newPlayer(player, 1, #PlayersList)
            end
            return
        end
                    -- < TODO foreach player in PlayersList
                    found = false
                    for i, value in ipairs(PlayersList) do
                        if value[1] == player then
                            found = true
                            value[2] = damage
                        end
                    end
                    -- />

        -- < if damage is bigger than DamageMax we change DamageMax
        if (tonumber(damage) > DamageMax) then
            DamageMax = tonumber(damage)
        end
        -- >



        table.sort(PlayersList, sortByDamage)
        updatePlayerDamage()

        -- >
    else
        return;
    end
end);
-- >











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
