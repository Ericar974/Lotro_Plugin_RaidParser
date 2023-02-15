import "Turbine.UI"
import "Turbine.UI.Lotro"

--create new player in a room
Global.newPlayer = function(player, damage, index, class)
    PlayersList[index][3]:SetParent(DpsWindow);
    PlayersList[index][3]:SetPosition(0, 10 + 24 * index);
    PlayersList[index][3]:SetSize(250 * damage / DamageMax, 22);
    PlayersList[index][3]:SetEnabled(true)
    PlayersList[index][3]:SetVisible(true)

    PlayersList[index][3].icon = Global.ResizeImage(Global.classIcon[class][1], 120, 120, PlayersList[index][3], 22, 22)


    PlayersList[index][3].label = Turbine.UI.Label()
    PlayersList[index][3].label:SetParent(PlayersList[index][3])
    PlayersList[index][3].label:SetFont(Turbine.UI.Lotro.Font.VerdanaBold16);
    PlayersList[index][3].label:SetBackColor(Global.classIcon[class][2]);
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