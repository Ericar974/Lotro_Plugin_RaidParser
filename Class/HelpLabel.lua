import "Turbine.UI"
import "Turbine.UI.Lotro"

--[[
Class File 

Just a simple Text label


]]


function Global.HelpLabel( text, parent, w, h) -- Create a button | name:String, parent:Controll, x:axeX, y:axeY , w:width, h:heigth, enable:bool
    Label = Turbine.UI.Label()
    Label:SetParent(parent)
    Label:SetSize(w,h)
    Label:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16);
    Label:SetForeColor(Turbine.UI.Color.White)
    Label:SetText(text)
    Label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    return Label
end