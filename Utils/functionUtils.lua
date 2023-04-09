--[[
comment...

exemple of Update

local aze = Turbine.UI.Lotro.Window()
aze:SetPosition(100, 100)
aze:SetSize(120, 40)
aze:SetOpacity(1)
aze:SetVisible(true)

local clockLabel = Turbine.UI.Label()
clockLabel:SetParent(aze)
clockLabel:SetPosition(30, 30)
clockLabel:SetSize(100, 20)
clockLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
clockLabel:SetWantsUpdates(true)
clockLabel:SetVisible(true)
function clockLabel:Update()
    self:SetText(Turbine.Engine.GetGameTime())
    self:SetVisible(true)
    aze:SetVisible(true)
end



]]
