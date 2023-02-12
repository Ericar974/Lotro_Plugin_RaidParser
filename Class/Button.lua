import "Turbine.UI"
import "Turbine.UI.Lotro"

--[[
Class File 

Just a simple Btn

call exemple:
local Button = Global.Button(...)
]]


function Global.Button( name, parent, x, y, w, h, enable) -- Create a button | name:String, parent:Controll, x:axeX, y:axeY , w:width, h:heigth, enable:bool
    -- Contructor
    local Btn = Turbine.UI.Lotro.Button()
    Btn:SetParent(parent)
    Btn:SetPosition(x,y)
    Btn:SetSize(w, h)
    Btn:SetText(name)
    Btn:SetEnabled(enable)
    Btn:SetVisible(true)

    return Btn
end