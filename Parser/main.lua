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

-- Get the local parse
import "RaidParser.Lang.en"
local Parse = Global.ParseEn --import
-- TODO : Load the correct Lang file.
-- import "RaidParser.Lang.fr"
-- import "RaidParser.Lang.de"
-- >

-- < define the local player
Global.localPlayer = Turbine.Gameplay.LocalPlayer.GetInstance()
local inCombat = Global.localPlayer:IsInCombat();

local playerName = Global.localPlayer:GetName()
local playerDamage = 1 -- set the damage at 1
local playerHeal = 1
local playerTps = 1
local playerPower = 1

local playerInterrupt = 0
local playerCorrupt = 0

ChatId = Global.ChatId
ChaTyte = Global.ChaTyte

local SetEnabled = function(object, bool)
    object:SetEnabled(bool)
end
-- >

PlayersList = {} -- PlayersList : Array[Array] with ['playerName'] = { his damage, his label }
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
    if not RoomsWindow.rooms.visible then
        return
    end
    local sortedList = {}
    for k, v in pairs(PlayersList) do
        table.insert(sortedList, { k, PlayersList[k][2], PlayersList[k][3], PlayersList[k][4], PlayersList[k][5] })
    end
    table.sort(sortedList, sortByDamage)
    if sortedList[1] == nil then
        newParse = false
        return
    end
    RoomScoreMax = sortedList[1][roomUse]
    for i, value in ipairs(sortedList) do
        playeractual = value[1]
        PlayersList[playeractual][1][roomUse - 1]:SetPosition(0, 10 + 24 * i)
        PlayersList[playeractual][1][roomUse - 1].label:SetWidth(250 * value[roomUse] / RoomScoreMax);
        PlayersList[playeractual][1][roomUse - 1].labe3:SetText(abbreviateNumber(value[roomUse]) .. " ");
    end
    newParse = false
end

Global.updatePlayer = function()
    updatePlayerDamage(RoomsWindow.rooms.active)
end

-- The Window of onClick image for sending information
local updateDps = Global.ButtonImage(Global.Settings.imageBtn.left * Global.screenWidth,
    Global.Settings.imageBtn.top * Global.screenHeight, "RaidParser/img/picto-target.tga", 591, 591,
    "/" ..
    ChatId ..
    " <rgb=#010010>N" ..
    playerName .. ";D" .. playerDamage .. "H" .. playerHeal .. "T" .. playerTps .. "P" .. playerPower .. '</rgb>')


-- The onClick image for update your informations
local imageUpdateDpsBtn = updateDps[2]
local updateDpsBtn = updateDps[3]

updateDps[2]:SetVisible(false)
updateDps[2].move.MouseClick = function(sender, args)
    UpdateShortCut(updateDpsBtn)
end

imageUpdateDpsBtn.MouseClick = function(sender, args)
    UpdateShortCut(updateDpsBtn)
end

EnableSendingButton = function(bool) -- make the updateDpsBtn invisible/visible
    updateDpsBtn.quickslot:SetVisible(bool);
    if bool then
        updateDps[2]:SetOpacity(1)
    elseif not bool then
        updateDps[2]:SetOpacity(0.5)
    end
end

Global.saveBtn.MouseClick = function(sender, args)
    ChatId = Global.ChatId
    ChaTyte = Global.ChaTyte
    SetEnabled(Global.saveBtn, false)
    UpdateShortCut(updateDpsBtn)
end

-- Update the data of the image that is sent to the chat
UpdateShortCut = function(quickslot) -- Actualize the shortcut of onClick Image/updateDpsBrn
    quickslot.quickslot:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias,
        "/" ..
        ChatId ..
        " <rgb=#010010>N" ..
        playerName .. ";D" .. playerDamage .. "H" .. playerHeal .. "T" .. playerTps .. "P" .. playerPower .. '</rgb>'));
end
UpdateShortCutReset = function(quickslot) -- Actualize the shortcut of onClick Image/updateDpsBrn
    quickslot.quickslot:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias,
        "/" ..
        ChatId ..
        " <rgb=#010010>N" ..
        playerName .. ";RESET</rgb>"));
end

-- regex for all player
local regex = "<rgb=#010010>N([^;]*);D([%d%.]+)H([%d%.]+)T([%d%.]+)P([%d%.]+)</rgb>"

updateDpsBtn.quickslot.MouseClick = function(sender, args) -- make the updateDpsBtn invisible at click
    EnableSendingButton(false)
end

--setup of all buttons of Options Window and these functions MouseClick
local isListening = false
local isStarted = false

local function reset()
    inCombat = true
    RoomScoreMax = 1
    for k, v in pairs(PlayersList) do
        v[2] = 1
        v[3] = 1
        v[4] = 1
        v[5] = 1
    end
    updatePlayerDamage(RoomsWindow.rooms.active)
    playerDamage = 0
    playerHeal = 0
    playerTps = 0
    playerPower = 0
    UpdateShortCut(updateDpsBtn)
    updateDps[1]:SetBackColor(Turbine.UI.Color(0,0,0,0))
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
    if (isStarted and inCombat and ((args.ChatType == Turbine.ChatType.EnemyCombat) or (args.ChatType == Turbine.ChatType.PlayerCombat) or (args.ChatType == Turbine.ChatType.Death))) then
        -- immediately grab timestamp (NB: actually it appears this doesn't change over successive calls in the same frame)
        local timestamp = Turbine.Engine.GetGameTime();

        -- grab line from combat log, strip it of color, trim it, and parse it according to the localized parsing function
        --              1, initiatorName, targetName, skillName, amount, avoidType, critType, dmgType;
        local updateType, initiatorName, targetName, skillName, var1, var2, var3, var4 = Parse(string.gsub(
            string.gsub(args.Message, "<rgb=#......>(.*)</rgb>", "%1"), "^%s*(.-)%s*$", "%1"));
        if (updateType == nil) then
            return
        elseif (updateType == 1 or updateType == 7) then
            -- a) Check for player name as initiator
            if (initiatorName == playerName) then
                -- Check for self damage
                if (targetName == playerName) then
                    -- NB: currently just ignore self interrupts
                    if (updateType == 7) then return end
                    updateType = 2;

                    -- Check if the skill used is a tracked Debuff (if it wasn't avoided)
                elseif (updateType == 1 and (var2 == 1 or (var2 > 7 and var2 < 11))) then
                end

                -- b) Check for player name as target
            elseif (targetName == playerName) then
                if (updateType == 7) then
                    updateType = 13;
                else
                    updateType = 2;
                end

                targetName = initiatorName;
                initiatorName = playerName;

                -- c) Ignore any interrupts that don't involve the player
            elseif (updateType == 7) then
                return;

                -- d) Make adjustments if pet was target
            elseif (updateType == 1 and args.ChatType == Turbine.ChatType.EnemyCombat) then
                -- NB: Currently ignore the possibility of self inflicted pet damage, and debuffs applied by pets

                updateType = 2;
                local petName = targetName;
                targetName = initiatorName;
                initiatorName = petName;
            end
        end

        if updateType == 1 then     --damage
            playerDamage = playerDamage + var1
        elseif updateType == 2 then -- tank
            playerTps = playerTps + var1
        elseif updateType == 3 then --heal
            playerHeal = playerHeal + var1
        elseif updateType == 4 then --power
            playerPower = playerPower + var1
        end

        -- >

        -- update every 1.5 seconde the room, the sendBtn
        if (timestamp - loopingTimer > 1.5) then
            UpdateShortCut(updateDpsBtn)
            EnableSendingButton(true)
            if newParse then
                updatePlayerDamage(RoomsWindow.rooms.active)
            end
            loopingTimer = timestamp
        end
        return

        -- < RAID CHAT COMBAT
    elseif (isListening and args.ChatType == ChaTyte and string.match(args.Message, regex)) then
        local player = string.match(args.Message, "<rgb=#010010>N([^;]*);")
        local damage = tonumber(string.match(args.Message, "D([%d%.]+)"))
        local heal = tonumber(string.match(args.Message, "H([%d%.]+)"))
        local tps = tonumber(string.match(args.Message, "T([%d%.]+)"))
        local power = tonumber(string.match(args.Message, "P([%d%.]+)</rgb>"))

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
    elseif (isListening and args.ChatType == ChaTyte and string.match(args.Message, "<rgb=#010010>N([^;]*);RESET")) then
        local player = string.match(args.Message, "<rgb=#010010>N([^;]*);")
        if(player == Turbine.Gameplay.LocalPlayer.GetInstance():GetParty():GetLeader():GetName()) then
            reset()
        end
    end
end);
-- >

AddCallback(Global.localPlayer, "InCombatChanged", function()
    inCombat = Global.localPlayer:IsInCombat();
    if (not inCombat) then
        updatePlayerDamage(RoomsWindow.rooms.active)
        UpdateShortCut(updateDpsBtn)
        EnableSendingButton(true)
    end
end);

-- group function
local player = Global.localPlayer
local party
local isGroup = false
local partyLength
local name



local resetTooltip = Turbine.UI.Window()
resetTooltip:SetSize(150, 20)
local resetTooltipAll = Turbine.UI.Window()
resetTooltipAll:SetSize(300, 20)


resetTooltip.label = Turbine.UI.Label()
resetTooltip.label:SetParent(resetTooltip)
resetTooltip.label:SetSize(150, 50)
resetTooltip.label:SetText("Reset your parse")
resetTooltip.label:SetVisible(true)

resetTooltipAll.label = Turbine.UI.Label()
resetTooltipAll.label:SetParent(resetTooltipAll)
resetTooltipAll.label:SetSize(300, 50)
resetTooltipAll.label:SetText("Reset all player parses")
resetTooltipAll.label:SetVisible(true)

local function windowsForReset()
    resetBtn = Turbine.UI.Window()
    resetBtn:SetParent(RoomsWindow.rooms)
    resetBtn:SetPosition(208, 10)
    resetBtn:SetSize(12, 14)
    resetBtn:SetBackground("RaidParser/img/reload.tga")
    resetBtn:SetVisible(true)

    resetBtnLead = Turbine.UI.Window()
    resetBtnLead:SetParent(RoomsWindow.rooms)
    resetBtnLead:SetPosition(190, 9)
    resetBtnLead:SetSize(12, 15)
    resetBtnLead:SetBackground("RaidParser/img/reloadLead.tga")
    resetBtnLead:SetVisible(false)
    resetBtnLead.MouseClick = function(sender, args)
        UpdateShortCutReset(updateDpsBtn)
        updateDps[1]:SetBackColor(Turbine.UI.Color(0.31,1,0,0))
        EnableSendingButton(true)
    end

    resetBtn.MouseClick = function(sender, args)
        inCombat = true
        playerDamage = 0
        playerHeal = 0
        playerTps = 0
        playerPower = 0
        RoomScoreMax = 1
        for k, v in pairs(PlayersList) do
            v[2] = 1
            v[3] = 1
            v[4] = 1
            v[5] = 1
        end
        updatePlayerDamage(RoomsWindow.rooms.active)
        UpdateShortCut(updateDpsBtn)
    end

    resetBtn.MouseEnter = function(sender, args)
        resetTooltip:SetPosition(Turbine.UI.Display.GetMouseX() - 80, Turbine.UI.Display.GetMouseY() - 30);
        resetTooltip:SetVisible(true);
    end
    resetBtn.MouseLeave = function(sender, args)
        resetTooltip:SetVisible(false);
    end
    resetBtnLead.MouseEnter = function(sender, args)
        resetTooltipAll:SetPosition(Turbine.UI.Display.GetMouseX() - 120, Turbine.UI.Display.GetMouseY() - 30);
        resetTooltipAll:SetVisible(true);
    end
    resetBtnLead.MouseLeave = function(sender, args)
        resetTooltipAll:SetVisible(false);
    end
end


--< start of the plugin : init the window
if (type(player:GetParty()) == 'table') then
    isGroup = true
    playerDamage = 0
    playerHeal = 0
    playerTps = 0
    playerPower = 0
    isStarted = true
    UpdateShortCut(updateDpsBtn)
    party = player:GetParty();
    partyLength = party:GetMemberCount()
    RoomsWindow:SetVisible(true);
    EnableSendingButton(false)
    updateDps[2]:SetVisible(true)
    isListening = true
    windowsForReset()
    for i = 1, partyLength do
        if i < 13 then
            name = tostring(party:GetMember(i):GetName())
            PlayersList[name] = { { Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window() },
                1, 1, 1, 1 }
            PlayerListLength = tablelength(PlayersList)
            Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                RoomsWindow.rooms.dpsWindow, 1)
            Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                RoomsWindow.rooms.healWindow, 2)
            Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                RoomsWindow.rooms.tankWindow, 3)
            Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                RoomsWindow.rooms.powerWindow, 4)
        end
    end
    if (party:GetLeader():GetName() == playerName) then
        resetBtnLead:SetVisible(true)
    end

    Global.saveBtn.MouseClick = function(sender, args)
        ChatId = Global.ChatId
        ChaTyte = Global.ChaTyte
        SetEnabled(Global.saveBtn, false)
        UpdateShortCut(updateDpsBtn)
    end
end
-->

AddCallback(player, "PartyChanged", function()
    if (type(player:GetParty()) == 'table') then
        if isGroup == false then
            isGroup = true
            playerDamage = 0
            playerHeal = 0
            playerTps = 0
            playerPower = 0
            isStarted = true
            UpdateShortCut(updateDpsBtn)
            party = player:GetParty();
            partyLength = party:GetMemberCount()
            RoomsWindow:SetVisible(true);
            EnableSendingButton(false)
            updateDps[2]:SetVisible(true)
            isListening = true
            windowsForReset()
            for i = 1, partyLength do
                if i < 13 then
                    name = tostring(party:GetMember(i):GetName())
                    PlayersList[name] = {
                        { Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window() }, 1, 1, 1,
                        1 }
                    PlayerListLength = tablelength(PlayersList)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                        RoomsWindow.rooms.dpsWindow, 1)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                        RoomsWindow.rooms.healWindow, 2)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                        RoomsWindow.rooms.tankWindow, 3)
                    Global.newPlayer(name, 1, PlayerListLength, tostring(party:GetMember(i):GetClass()),
                        RoomsWindow.rooms.powerWindow, 4)
                end
            end
            if (party:GetLeader():GetName() == playerName) then
                resetBtnLead:SetVisible(true)
            end
            Global.saveBtn.MouseClick = function(sender, args)
                ChatId = Global.ChatId
                ChaTyte = Global.ChaTyte
                SetEnabled(Global.saveBtn, false)
                UpdateShortCut(updateDpsBtn)
            end
        end
    else
        -- if no group/raid juste reset all
        isGroup = false
        RoomsWindow:SetVisible(false)
        RoomsWindow = Global.Room()
        newParse = false
        isStarted = false
        playerDamage = 1
        playerHeal = 1
        playerTps = 1
        playerPower = 1
        RoomScoreMax = 1
        EnableSendingButton(false)
        updateDps[2]:SetVisible(false)
        UpdateShortCut(updateDpsBtn)
        inCombat = true
        PlayersList = {}
        regex = "<rgb=#010010>N([^;]*);D([%d%.]+)H([%d%.]+)T([%d%.]+)P([%d%.]+)</rgb>"
        updatePlayerDamage(RoomsWindow.rooms.active)
    end
end);

AddCallback(Turbine.Gameplay.Party, "LeaderChanged", function()
    party = Turbine.Gameplay.LocalPlayer:GetInstance():GetParty()
    if (party:GetLeader():GetName() == playerName) then
        resetBtnLead:SetVisible(true)
    else
        resetBtnLead:SetVisible(false)
    end
end);

AddCallback(Turbine.Gameplay.Party, "MemberAdded", function(sender, args)
    party = Turbine.Gameplay.LocalPlayer:GetInstance():GetParty()
    name = tostring(args.Player:GetName())
    partyLength = party:GetMemberCount()
    if partyLength < 13 then
        PlayersList[name] = { { Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window(), Turbine.UI.Window() }, 1,
            1, 1, 1 }
        PlayerListLength = tablelength(PlayersList)
        Global.newPlayer(name, 1, PlayerListLength, tostring(args.Player:GetClass()), RoomsWindow.rooms.dpsWindow, 1)
        Global.newPlayer(name, 1, PlayerListLength, tostring(args.Player:GetClass()), RoomsWindow.rooms.tankWindow, 3)
        Global.newPlayer(name, 1, PlayerListLength, tostring(args.Player:GetClass()), RoomsWindow.rooms.healWindow, 2)
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
