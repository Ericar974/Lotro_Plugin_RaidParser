import "Turbine.UI"
import "Turbine.UI.Lotro"

--create new player in a room
Global.newPlayer = function(player, damage, index, class, parent, window)
     PlayersList[player][1][window]:SetParent(parent);
     PlayersList[player][1][window]:SetPosition(0, 10 + 24 * index);
     PlayersList[player][1][window]:SetSize(250 * damage / RoomScoreMax, 22);
     PlayersList[player][1][window]:SetEnabled(true)
     PlayersList[player][1][window]:SetVisible(true)

     PlayersList[player][1][window].icon = Global.ResizeImage(Global.classIcon[class][1], 120, 120,  PlayersList[player][1][window], 22, 22)


     PlayersList[player][1][window].label = Turbine.UI.Label()
     PlayersList[player][1][window].label:SetParent(PlayersList[player][1][window])
     PlayersList[player][1][window].label:SetFont(Turbine.UI.Lotro.Font.VerdanaBold16);
     PlayersList[player][1][window].label:SetBackColor(Global.classIcon[class][2]);
     PlayersList[player][1][window].label:SetOutlineColor(Turbine.UI.Color.Black)
     PlayersList[player][1][window].label:SetSize(250 * damage / RoomScoreMax, 22);
     PlayersList[player][1][window].label:SetPosition(23, 0);
     PlayersList[player][1][window].label:SetForeColor(Turbine.UI.Color.White);
     PlayersList[player][1][window].label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);

     PlayersList[player][1][window].labe2 = Turbine.UI.Label()
     PlayersList[player][1][window].labe2:SetParent(PlayersList[player][1][window])
     PlayersList[player][1][window].labe2:SetFont(Turbine.UI.Lotro.Font.VerdanaBold16);
     PlayersList[player][1][window].labe2:SetText(" " .. player);
     PlayersList[player][1][window].labe2:SetOutlineColor(Turbine.UI.Color.Black)
     PlayersList[player][1][window].labe2:SetSize(250 * damage / RoomScoreMax, 22);
     PlayersList[player][1][window].labe2:SetPosition(23, 0);
     PlayersList[player][1][window].labe2:SetForeColor(Turbine.UI.Color.White);
     PlayersList[player][1][window].labe2:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);

     PlayersList[player][1][window].labe3 = Turbine.UI.Label()
     PlayersList[player][1][window].labe3:SetParent(PlayersList[player][1][window])
     PlayersList[player][1][window].labe3:SetFont(Turbine.UI.Lotro.Font.VerdanaBold16);
     PlayersList[player][1][window].labe3:SetText(damage .. " ");
     PlayersList[player][1][window].labe3:SetOutlineColor(Turbine.UI.Color.Black)
     PlayersList[player][1][window].labe3:SetSize(250 * damage / RoomScoreMax, 22);
     PlayersList[player][1][window].labe3:SetPosition(0, 0);
     PlayersList[player][1][window].labe3:SetForeColor(Turbine.UI.Color.White);
     PlayersList[player][1][window].labe3:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight);
end