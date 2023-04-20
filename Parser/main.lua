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
import "RaidParser.Elements.Room.main"
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
PlayerHeal = 1
PlayerTps = 1
PlayerPower = 1


ChatId = Global.ChatId
ChaTyte = Global.ChaTyte

local SetEnabled = function(object, bool)
    object:SetEnabled(bool)
end
-- >

PlayersList = {} -- PlayersList : Array[Array] with ['PlayerName'] = { his damage, his label }
RoomScoreMax = 1
PlayerListLength = 0

local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- Display the room
local RoomsWindow = Global.Room()

local loopingTimer = Turbine.Engine.GetGameTime();
local newParse = false


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
    return a[RoomsWindow.rooms.active] > b[RoomsWindow.rooms.active]
end


local function updatePlayerDamage(roomUse) -- Update the label damage of players
    --TODO : DO NOT LAUNCH the function when rooms invisible
    --if not RoomsWindow.rooms.visible then
    --    return
    --end
    Turbine.Shell.WriteLine(tostring(roomUse))
    local sortedList = {}
    for k, v in pairs(PlayersList) do
        table.insert(sortedList, { k, PlayersList[k][2], PlayersList[k][3],PlayersList[k][4], PlayersList[k][5] })
    end
    table.sort(sortedList, sortByDamage)
    RoomScoreMax = sortedList[1][roomUse]
    for i, value in ipairs(sortedList) do
        playeractual = value[1]
        PlayersList[playeractual][1][roomUse-1]:SetPosition(0, 10 + 24 * i)
        PlayersList[playeractual][1][roomUse-1].label:SetWidth(250 * value[roomUse] / RoomScoreMax);
        PlayersList[playeractual][1][roomUse-1].labe3:SetText(abbreviateNumber(value[roomUse]) .. " ");
    end
    newParse = false
end

Global.updatePlayer = function ()
    updatePlayerDamage(RoomsWindow.rooms.active)
end

-- The Window of onClick image for sending information
local updateDps = Global.ButtonImage(Global.Settings.imageBtn.left * Global.screenWidth,
    Global.Settings.imageBtn.top * Global.screenHeight, "RaidParser/img/picto-target.tga", 591, 591,
    "/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. PlayerDamage .. ";H:" .. PlayerHeal .. ";T:" .. PlayerTps .. ";P:" .. PlayerPower)
--local updateDps = Global.ButtonImage(550, 850, "RaidParser/img/briqueLait.tga", 600, 562,
--"/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. PlayerDamage .. ";" .. PlayerClass)

-- The onClick image for update your informations
local imageUpdateDpsBtn = updateDps[2]
local updateDpsBtn = updateDps[3]

updateDps[2]:SetVisible(false)
updateDps[2].move.MouseClick = function(sender, args)
    UpdateShortCut(updateDpsBtn, PlayerDamage, PlayerHeal, PlayerTps, PlayerPower)
end

imageUpdateDpsBtn.MouseClick = function(sender, args)
    UpdateShortCut(updateDpsBtn, PlayerDamage, PlayerHeal, PlayerTps, PlayerPower)
end


EnableSendingButton = function(bool) -- make the updateDpsBtn invisible/visible
    updateDpsBtn.quickslot:SetVisible(bool);
    updateDps[2]:SetVisible(bool);
end

Global.saveBtn.MouseClick = function(sender, args)
    ChatId = Global.ChatId
    ChaTyte = Global.ChaTyte
    SetEnabled(Global.saveBtn, false)
    UpdateShortCut(updateDpsBtn, PlayerDamage, PlayerHeal, PlayerTps, PlayerPower)
end

-- Update the data of the image that is sent to the chat
UpdateShortCut = function(quickslot, damage, heal, tps, power) -- Actualize the shortcut of onClick Image/updateDpsBrn
    quickslot.quickslot:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias,
        "/" .. ChatId .. " N:" .. PlayerName .. ";D:" .. damage .. ";H:" .. heal .. ";T:" .. tps .. ";P:" .. power));
end

-- regex for all player
local regex = "N:([%a]+);D:([%d%.]+);H:([%d%.]+);T:([%d%.]+);P:([%d%.]+)"

updateDpsBtn.quickslot.MouseClick = function(sender, args) -- make the updateDpsBtn invisible at click
    EnableSendingButton(false)
end

--setup of all buttons of Options Window and these functions MouseClick
local isListening = false
local isStarted = false

resetBtn = Global.Button("Reset", Global.helpToLaunch, 150, 100, 80, 50, true)

-- onclick

resetBtn.MouseClick = function(sender, args)
    inCombat = true
    PlayerDamage = 0
    PlayerHeal = 0
    PlayerTps = 0
    PlayerPower = 0
    RoomScoreMax = 1
    for k,v in pairs(PlayersList) do
        v[2] = 1
        v[3] = 1
        v[4] = 1
        v[5] = 1
      end
    updatePlayerDamage(RoomsWindow.rooms.active)
    UpdateShortCut(updateDpsBtn, PlayerDamage, PlayerHeal, PlayerTps, PlayerPower)
end

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
        if (updateType == nil) then 
            return
        elseif updateType == 1 then
             PlayerDamage = PlayerDamage + var1
        elseif updateType == 2 then
            PlayerHeal = PlayerHeal + var1
        elseif updateType == 3 then
            PlayerTps = PlayerTps + var1
        elseif updateType == 4 then
            PlayerPower = PlayerPower + var1
        end
       
        -- >

        -- update every 1.5 seconde the room, the sendBtn
        if (timestamp - loopingTimer > 1.5) then
            UpdateShortCut(updateDpsBtn, PlayerDamage, PlayerHeal, PlayerTps, PlayerPower)
            EnableSendingButton(true)
            if newParse then
                updatePlayerDamage(RoomsWindow.rooms.active)
            end
            loopingTimer = timestamp
        end
        return

        -- < RAID CHAT COMBAT
    elseif (isListening and args.ChatType == ChaTyte and string.match(args.Message, regex)) then
        local player = string.match(args.Message, "N:([%a]+);")
        local damage = tonumber(string.match(args.Message, "D:([%d%.]+);"))
        local heal = tonumber(string.match(args.Message, "H:([%d%.]+);"))
        local tps = tonumber(string.match(args.Message, "T:([%d%.]+);"))
        local power = tonumber(string.match(args.Message, "P:([%d%.]+)"))

        -- >
        if PlayersList[player] ~= nil then
            PlayersList[player][2] = damage
            PlayersList[player][3] = heal
            PlayersList[player][4] = tps
            PlayersList[player][5] = power
            newParse = true
            if not inCombat then
                updatePlayerDamage(RoomsWindow.rooms.active)
            end
            return
        end
        return
        -- >
    end
end);
-- >

AddCallback(Global.localPlayer, "InCombatChanged", function()
    inCombat = Global.localPlayer:IsInCombat();
    if (not inCombat) then
        updatePlayerDamage(RoomsWindow.rooms.active)
        UpdateShortCut(updateDpsBtn, PlayerDamage, PlayerHeal, PlayerTps, PlayerPower)
        EnableSendingButton(true)
    end
end);

-- group function
local player = Global.localPlayer
local party
local isGroup = false
local partyLength
local name


--< start of the plugin : init the window
if (type(player:GetParty()) == 'table') then
    isGroup = true
    PlayerDamage = 0
    PlayerHeal = 0
    PlayerTps = 0
    PlayerPower = 0
    isStarted = true
    UpdateShortCut(updateDpsBtn, PlayerDamage, PlayerHeal, PlayerTps, PlayerPower)
    party = player:GetParty();
    partyLength = party:GetMemberCount()
    RoomsWindow:SetVisible(true);
    EnableSendingButton(true)
    isListening = true
    for i = 1, partyLength do
        if i < 12 then
            name = tostring(party:GetMember(i):GetName())
            PlayersList[name] = { { Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window()}, 1, 1, 1, 1 }
            PlayerListLength = tablelength(PlayersList)
            Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
            RoomsWindow.rooms.dpsWindow,1)
            Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
            RoomsWindow.rooms.healWindow,2)
            Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
            RoomsWindow.rooms.tankWindow,3)
            Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
            RoomsWindow.rooms.powerWindow,4)
        end
        if i == 12 then
            name = tostring(player:GetName())
            PlayersList[name] = { { Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window()}, 1, 1, 1, 1 }
            PlayerListLength = tablelength(PlayersList)
            Global.newPlayer(name, 1, PlayerListLength, tostring(player:GetClass()), RoomsWindow.rooms.dpsWindow, 1)
            Global.newPlayer(name, 1, PlayerListLength, tostring(player:GetClass()), RoomsWindow.rooms.healWindow, 2)
            Global.newPlayer(name, 1, PlayerListLength, tostring(player:GetClass()), RoomsWindow.rooms.tankWindow, 3)
            Global.newPlayer(name, 1, PlayerListLength, tostring(player:GetClass()), RoomsWindow.rooms.powerWindow, 4)
        end
    end
    Turbine.Shell.WriteLine(PlayerListLength)
end
-->

AddCallback(player, "PartyChanged", function()
    Turbine.Shell.WriteLine('PartyChanged')
    if (type(player:GetParty()) == 'table') then
        if isGroup == false then
            isGroup = true
            PlayerDamage = 0
            PlayerHeal = 0
            PlayerTps = 0
            PlayerPower = 0
            isStarted = true
            UpdateShortCut(updateDpsBtn, PlayerDamage)
            party = player:GetParty();
            partyLength = party:GetMemberCount()
            RoomsWindow:SetVisible(true);
            EnableSendingButton(true)
            isListening = true
            for i = 1, partyLength do
                if i < 12 then
                    name = tostring(party:GetMember(i):GetName())
                    PlayersList[name] = { { Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window()}, 1,1,1,1 }
                    PlayerListLength = tablelength(PlayersList)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                    RoomsWindow.rooms.dpsWindow, 1)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                    RoomsWindow.rooms.healWindow, 2)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                    RoomsWindow.rooms.tankWindow, 3)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                    RoomsWindow.rooms.powerWindow, 4)
                elseif i == 12 then
                    name = tostring(player:GetName())
                    PlayersList[name] = { { Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window()}, 1,1,1,1 }
                    PlayerListLength = tablelength(PlayersList)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(player:GetClass()), RoomsWindow.rooms.dpsWindow, 1)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(player:GetClass()), RoomsWindow.rooms.healWindow, 2)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(player:GetClass()), RoomsWindow.rooms.tankWindow, 3)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(player:GetClass()), RoomsWindow.rooms.powerWindow, 4)
                end
            end
        end
    else
        -- if no group/raid juste reset all
        isGroup = false
        RoomsWindow:SetVisible(false)
        RoomsWindow = Global.Room()
        newParse = false
        isStarted = false
        PlayerDamage = 1
        PlayerHeal = 1
        PlayerTps = 1
        PlayerPower = 1
        RoomScoreMax = 1
        EnableSendingButton(false)
        UpdateShortCut(updateDpsBtn, PlayerDamage, PlayerHeal, PlayerTps, PlayerPower)
        inCombat = true
        PlayersList = {}
        regex = "N:([%a]+);D:([%d%.]+);H:([%d%.]+);T:([%d%.]+);P:([%d%.]+)"
        updatePlayerDamage(RoomsWindow.rooms.active)
    end
end);

AddCallback(Turbine.Gameplay.Party, "LeaderChanged", function()
    party = Turbine.Gameplay.LocalPlayer:GetInstance():GetParty()
    Turbine.Shell.WriteLine('LeaderChanged :' .. party.GetLeader(party):GetName())
end);

AddCallback(Turbine.Gameplay.Party, "MemberAdded", function(sender, args)
    party = Turbine.Gameplay.LocalPlayer:GetInstance():GetParty()
    name = tostring(args.Player:GetName())
    partyLength = party:GetMemberCount()
    if partyLength < 13 then
        PlayersList[name] = { { Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window()}, 1,1,1,1 }
        PlayerListLength = tablelength(PlayersList)
        Global.newPlayer(name, 1, PlayerListLength, tostring(args.Player:GetClass()), RoomsWindow.rooms.dpsWindow, 1)
        Global.newPlayer(name, 1, PlayerListLength, tostring(args.Player:GetClass()), RoomsWindow.rooms.healWindow, 2)
        Global.newPlayer(name, 1, PlayerListLength, tostring(args.Player:GetClass()), RoomsWindow.rooms.tankWindow, 3)
        Global.newPlayer(name, 1, PlayerListLength, tostring(args.Player:GetClass()), RoomsWindow.rooms.powerWindow, 4)
        updatePlayerDamage(RoomsWindow.rooms.active)
    end
end);

AddCallback(Turbine.Gameplay.Party, "MemberRemoved", function(sender, args)
    party = Turbine.Gameplay.LocalPlayer:GetInstance():GetParty()
    name = tostring(args.Player:GetName())
    PlayersList[name][1][2]:SetVisible(false)
    PlayersList[name][1][2].icon = nil
    PlayersList[name][1][2].label = nil
    PlayersList[name][1][2].labe2 = nil
    PlayersList[name][1][2].labe3 = nil
    PlayersList[name][1][3]:SetVisible(false)
    PlayersList[name][1][3].icon = nil
    PlayersList[name][1][3].label = nil
    PlayersList[name][1][3].labe2 = nil
    PlayersList[name][1][3].labe3 = nil
    PlayersList[name][1][4]:SetVisible(false)
    PlayersList[name][1][4].icon = nil
    PlayersList[name][1][4].label = nil
    PlayersList[name][1][4].labe2 = nil
    PlayersList[name][1][4].labe3 = nil
    PlayersList[name][1][5]:SetVisible(false)
    PlayersList[name][1][5].icon = nil
    PlayersList[name][1][5].label = nil
    PlayersList[name][1][5].labe2 = nil
    PlayersList[name][1][5].labe3 = nil
    PlayersList[name] = nil
    updatePlayerDamage(RoomsWindow.rooms.active)
end);
