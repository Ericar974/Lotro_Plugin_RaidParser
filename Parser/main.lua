import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

-- < import class
import "RaidParser.Class.ButtonImage"
import "RaidParser.Class.ResizeImage"
-- >

import "RaidParser.Utils.classIcons"
import "RaidParser.Utils.newPlayerInRoom"
import "RaidParser.Rooms.roomDps"

-- < define the local player
Global.localPlayer = Turbine.Gameplay.LocalPlayer.GetInstance()
local inCombat = true

PlayerName = Global.localPlayer:GetName()
PlayerClass = Global.localPlayer:GetClass()
PlayerDamage = 1 -- set the damage at 1
ChatId = 1
ChaTyte = Turbine.ChatType.UserChat1

-- >

PlayersList = {} -- PlayersList : Array[Array] with {PlayerName, his damage, his label}
DamageMax = 1

-- Display the dps room
roomDps = Global.RoomDps()
DpsWindow = roomDps[1]
DpsWindow.label = roomDps[2]

local loopingTimer = Turbine.Engine.GetGameTime();
local newParse = false
local found = nil
-- <import "RaidParser.Parser.parser" -- Get the local parse
import "RaidParser.Lang.en"
-- >
local Parse = Global.ParseEn() --import

local function abbreviateNumber(number) -- Convert dmg with K / M / B
    if number >= 1000000000 then
        return string.format("%.1fB", number / 1000000000)
    elseif number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fk", number / 1000)
    else
        return number
    end
end

-- sort the playerList by the damage
function sortByDamage(a, b)
    return tonumber(a[2]) > tonumber(b[2])
end

local function updatePlayerDamage() -- Update the label damage of players
    table.sort(PlayersList, sortByDamage)
    for i, value in ipairs(PlayersList) do
        value[3]:SetPosition(0, 10 + 24 * i)
        value[3].label:SetWidth(250 * value[2] / DamageMax);
        value[3].labe3:SetText(abbreviateNumber(value[2]) .. " ");
    end
    newParse = false
end


-- The Window of onClick image for sending information
local updateDps = Global.ButtonImage(550, 850, "RaidParser/img/picto-target.tga", 591, 591,
    "/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. PlayerDamage .. ";" .. PlayerClass)
updateDps[2]:SetVisible(false)

-- The onClick image for update your informations
local updateDpsBtn = updateDps[3]

EnableButton = function(bool) -- make the updateDpsBtn invisible/visible
    updateDpsBtn.quickslot:SetVisible(bool);
    updateDps[2]:SetVisible(bool);
    updateDps[2].move:SetVisible(bool);
end

updateDpsBtn.quickslot.MouseClick = function(sender, args) -- make the updateDpsBtn invisible at click
    EnableButton(false)
end

TimeLoop = function() -- Update the Dps value of the Btn for sending to chat
    UpdateShortCut(updateDpsBtn, PlayerDamage)
end

UpdateShortCut = function(quickslot, value) -- Actualize the shortcut of onClick Image/updateDpsBrn
    quickslot.quickslot:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias,
        "/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. value .. ";" .. PlayerClass));
end

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

-- < options window
local isListening = false
local isStarted = false

Global.optionsVisible = function()
    options:SetVisible(true)
end

options = Turbine.UI.Lotro.GoldWindow()
options:SetPosition(1500, 350)
options:SetSize(400, 400)
options:SetText('Options')
options:SetWantsKeyEvents(true) -- setup the key event for escape
function options.KeyDown(sender, args)
    if (args.Action == Turbine.UI.Lotro.Action.Escape) then
      -- close the window if escape pressed
      options:SetVisible(false)
    end
end



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

-- >

-- < onclick events for each btn
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

stopBtn.MouseClick = function(sender, args)
    SetEnabled(stopBtn, false)
    SetEnabled(resetBtn, false)
    SetEnabled(startBtn, false)
    SetEnabled(synchroBtn, true)

    helpToLaunch.labelSync:SetVisible(true)
    helpToLaunch.labelInit:SetVisible(false)
    helpToLaunch.labelStart:SetVisible(false)

    isListening = false
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
    roomDps = Global.RoomDps()
    DpsWindow = roomDps[1]
    DpsWindow.label = roomDps[2]
end
-->


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

AddCallback(Turbine.Chat, "Received", function(sender, args) -- track chat ingame
    -- < PLAYER CHAT COMBAT
    -- 1) only parse combat text for now
    if (isStarted and ((args.ChatType == Turbine.ChatType.EnemyCombat) or (args.ChatType == Turbine.ChatType.PlayerCombat) or (args.ChatType == Turbine.ChatType.Death))) then
        -- immediately grab timestamp (NB: actually it appears this doesn't change over successive calls in the same frame)
        local timestamp = Turbine.Engine.GetGameTime();
        -- update every 3seconde the room, the sendBtn
        if (timestamp - loopingTimer > 3) then
            TimeLoop()
            EnableButton(true)
            if newParse then
                updatePlayerDamage()
            end
            loopingTimer = timestamp
        end

        -- grab line from combat log, strip it of color, trim it, and parse it according to the localized parsing function
        --              1, initiatorName, targetName, skillName, amount, avoidType, critType, dmgType;
        local updateType, initiatorName, targetName, skillName, var1, var2, var3, var4 = Parse(string.gsub(
            string.gsub(args.Message, "<rgb=#......>(.*)</rgb>", "%1"), "^%s*(.-)%s*$", "%1"));
        if (updateType == nil) then return end
        PlayerDamage = PlayerDamage + var1
        -- >
        return
        -- try all regex from playeList
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
                Global.newPlayer(player, 1, #PlayersList, class)
            end
            return
        end
        -- < if damage is bigger than DamageMax we change DamageMax
        damage = tonumber(damage)
        if (damage > DamageMax) then
            DamageMax = damage
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
        return
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
