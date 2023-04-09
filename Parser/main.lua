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
import "RaidParser.Elements.roomDps"
import "RaidParser.Elements.optionWindow"

-- Get the local parse
import "RaidParser.Lang.en"
local Parse = Global.ParseEn --import
-- TODO : Load the correct Lang file.
-- import "RaidParser.Lang.fr"
-- import "RaidParser.Lang.de"
-- >

-- < define the local player
Global.localPlayer = Turbine.Gameplay.LocalPlayer.GetInstance()
local inCombat = true

PlayerName = Global.localPlayer:GetName()
PlayerClass = Global.localPlayer:GetClass()
PlayerDamage = 1 -- set the damage at 1


ChatId = Global.ChatId
ChaTyte = Global.ChaTyte

local SetEnabled = function(object, bool)
    object:SetEnabled(bool)
end

Global.saveBtn.MouseClick = function(sender, args)
    ChatId = Global.ChatId
    ChaTyte = Global.ChaTyte
    SetEnabled(Global.saveBtn, false)
end
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


local function abbreviateNumber(number) -- Convert dmg with K / M / B
    if number >= 1000000000 then
        return string.format("%.2fB", number / 1000000000)
    elseif number >= 1000000 then
        return string.format("%.2fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.2fk", number / 1000)
    else
        return number
    end
end

-- sort the playerList by the damage
function sortByDamage(a, b)
    return a[2] > b[2]
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
local updateDps = Global.ButtonImage(Global.Settings.imageBtn.left * Global.screenWidth, Global.Settings.imageBtn.top * Global.screenHeight, "RaidParser/img/picto-target.tga", 591, 591,
    "/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. PlayerDamage .. ";" .. PlayerClass)
   --local updateDps = Global.ButtonImage(550, 850, "RaidParser/img/briqueLait.tga", 600, 562,
    --"/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. PlayerDamage .. ";" .. PlayerClass)

-- The onClick image for update your informations
local imageUpdateDpsBtn = updateDps[2]
local updateDpsBtn = updateDps[3]

updateDps[2]:SetVisible(false)
updateDps[2].move.MouseClick = function (sender, args)
    UpdateShortCut(updateDpsBtn, PlayerDamage)
end

imageUpdateDpsBtn.MouseClick = function (sender,args)
    UpdateShortCut(updateDpsBtn, PlayerDamage)
end


EnableSendingButton = function(bool) -- make the updateDpsBtn invisible/visible
    updateDpsBtn.quickslot:SetVisible(bool);
    updateDps[2]:SetVisible(bool);
    updateDps[2].move:SetVisible(bool);
end

-- Update the data of the image that is sent to the chat
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

-- antispam for joining the room
local nbSpam = 0

updateDpsBtn.quickslot.MouseClick = function(sender, args) -- make the updateDpsBtn invisible at click
    EnableSendingButton(false)
    if not isStarted then
        if nbSpam < 2 then -- antispam ( 3 try )
            EnableSendingButton(true)
            nbSpam = nbSpam + 1
            return
        end
        return
    end
end

--setup of all buttons of Options Window and these functions MouseClick
local isListening = false
local isStarted = false

synchroBtn = Global.Button("Synchro", Global.helpToLaunch, 10, 100, 80, 50, true)
startBtn = Global.Button("Start", Global.helpToLaunch, 110, 100, 80, 50, false)
resetBtn = Global.Button("Reset", Global.helpToLaunch, 210, 100, 80, 50, false)
stopBtn = Global.Button("Quit", Global.helpToLaunch, 310, 100, 80, 50, false)

-- onclick
synchroBtn.MouseClick = function(sender, args)
    UpdateShortCut(updateDpsBtn, PlayerDamage)
    SetEnabled(synchroBtn, false)
    Global.helpToLaunch.labelSync:SetVisible(false)
    Global.helpToLaunch.labelInit:SetVisible(true)
    SetEnabled(stopBtn, true)
    isListening = true
    DpsWindow:SetVisible(true);
    EnableSendingButton(true)
end

startBtn.MouseClick = function(sender, args)
    Global.options:SetVisible(false)
    EnableSendingButton(false)
    SetEnabled(resetBtn, true)
    SetEnabled(startBtn, false)
    Global.helpToLaunch.labelInit:SetVisible(false)
    Global.helpToLaunch.labelStart:SetVisible(true)
    PlayerDamage = 0
    isStarted = true
    UpdateShortCut(updateDpsBtn, PlayerDamage)
    regeneragteRegex()
end

resetBtn.MouseClick = function(sender, args)
    EnableSendingButton(false)
    inCombat = true
    PlayerDamage = 0
    DamageMax = 1
    for i, value in ipairs(PlayersList) do
        value[2] = 1
    end
    updatePlayerDamage()
end

-- stopBtn mean quit the room and reset all parameters
stopBtn.MouseClick = function(sender, args)
    -- reset the Dps window
    roomDps = Global.RoomDps()
    DpsWindow = roomDps[1]
    DpsWindow.label = roomDps[2]
    -- reset btns
    SetEnabled(stopBtn, false)
    SetEnabled(resetBtn, false)
    SetEnabled(startBtn, false)
    SetEnabled(synchroBtn, true)
    Global.helpToLaunch.labelSync:SetVisible(true)
    Global.helpToLaunch.labelInit:SetVisible(false)
    Global.helpToLaunch.labelStart:SetVisible(false)
    newParse = false
    isListening = false
    isStarted = false
    PlayerDamage = 1
    DamageMax = 1
    nbSpam = 0
    EnableSendingButton(false)
    UpdateShortCut(updateDpsBtn, PlayerDamage)
    inCombat = true
    PlayersList = {}
    regex = "N:([%a]+);D:([%d%.]+);"
    regexTable = { "^x", "^x", "^x", "^x", "^x", "^x", "^x", "^x", "^x", "^x", "^x", "^x" }
    found = nil
    updatePlayerDamage()
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

        -- grab line from combat log, strip it of color, trim it, and parse it according to the localized parsing function
        --              1, initiatorName, targetName, skillName, amount, avoidType, critType, dmgType;
        local updateType, initiatorName, targetName, skillName, var1, var2, var3, var4 = Parse(string.gsub(
            string.gsub(args.Message, "<rgb=#......>(.*)</rgb>", "%1"), "^%s*(.-)%s*$", "%1"));
        if (updateType == nil) then return end
        PlayerDamage = PlayerDamage + var1
        -- >

        -- update every 1.5 seconde the room, the sendBtn
        if (timestamp - loopingTimer > 1.5) then
            UpdateShortCut(updateDpsBtn, PlayerDamage)
            EnableSendingButton(true)
            if newParse then
                updatePlayerDamage()
            end
            loopingTimer = timestamp
        end
        return

        -- < RAID CHAT COMBAT
        -- try all regex from playeList
    elseif (isListening and args.ChatType == ChaTyte and
        (string.match(args.Message, regex) or string.match(args.Message, regexTable[1]) or string.match(args.Message, regexTable[2]) or string.match(args.Message, regexTable[3])
        or string.match(args.Message, regexTable[4]) or string.match(args.Message, regexTable[5]) or string.match(args.Message, regexTable[6])
        or string.match(args.Message, regexTable[7]) or string.match(args.Message, regexTable[8]) or string.match(args.Message, regexTable[9])
        or string.match(args.Message, regexTable[10]) or string.match(args.Message, regexTable[11]) or string.match(args.Message, regexTable[12]))
        ) then
        local player = string.match(args.Message, "N:([%a]+);")
        local damage = string.match(args.Message, "D:([%d%.]+);")

        -- 1/ When room isn't setup
        if not isStarted then
            SetEnabled(startBtn, true)
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
        -- 2/ When room lock
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
    end
end);
-- >

AddCallback(Global.localPlayer, "InCombatChanged", function()
    inCombat = Global.localPlayer:IsInCombat();
    if (not inCombat) then
        updatePlayerDamage()
        UpdateShortCut(updateDpsBtn, PlayerDamage)
        EnableSendingButton(true)
    end
end);
