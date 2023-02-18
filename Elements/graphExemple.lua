import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"


-- Définissez les valeurs du tableau
testtable = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,100}



local minY = testtable[1]
local maxY = testtable[1]

for i = 2, #testtable do
    if testtable[i] < minY then
        minY = testtable[i]
    end
    if testtable[i] > maxY then
        maxY = testtable[i]
    end
end
table.insert(testtable,#testtable, maxY)
test =  Turbine.UI.Lotro.Window()
test:SetPosition(0, 0)
test:SetSize(600, 400)
test:SetVisible(true)

-- Créez une fenêtre pour le graphique
local graphWindow = Turbine.UI.Window()
graphWindow:SetParent(test)
graphWindow:SetPosition(50, 50)
graphWindow:SetSize(550, 300)
graphWindow:SetText("Graphique")


-- Définissez la taille et les marges de la zone de tracé
local plotAreaWidth = 450
local plotAreaHeight = 250
local marginLeft = 50
local marginBottom = 30

-- Calculez la plage de valeurs pour l'axe Y en utilisant les valeurs min et max du tableau

local yRange = maxY - minY
-- Augmentez la plage de valeurs en multipliant par un facteur, par exemple :
yRange = yRange * 2

-- Définissez la fonction de conversion pour les coordonnées Y
local function convertY(y)
    return plotAreaHeight - (y - minY) * plotAreaHeight / yRange
end

-- Tracez l'axe X
local xAxis = Turbine.UI.Control()
xAxis:SetParent(graphWindow)
xAxis:SetPosition(marginLeft, plotAreaHeight + marginBottom)
xAxis:SetSize(plotAreaWidth, 1)
xAxis:SetBackColor(Turbine.UI.Color(1, 1, 1))
xAxis:SetVisible(true)

-- Tracez l'axe Y
local yAxis = Turbine.UI.Control()
yAxis:SetParent(graphWindow)
yAxis:SetPosition(marginLeft, marginBottom)
yAxis:SetSize(1, plotAreaHeight)
yAxis:SetBackColor(Turbine.UI.Color(1, 1, 1))
yAxis:SetVisible(true)

-- Tracez la courbe en escalier
local plotLine = Turbine.UI.Control()
plotLine:SetParent(graphWindow)
plotLine:SetPosition(marginLeft, marginBottom)
plotLine:SetSize(plotAreaWidth, plotAreaHeight)
plotLine:SetBackColor(Turbine.UI.Color(0, 0, 0, 0))
plotLine:SetVisible(true)

-- Tracez la première ligne à partir du premier point
local startX = 0
local startY = convertY(testtable[1])
local prevX, prevY = startX, startY
local stepX = plotAreaWidth / (#testtable - 1)

for i = 2, #testtable do
    -- Calculez les coordonnées du prochain point
    local nextX = startX + (i - 1) * stepX
    local nextY = convertY(testtable[i])

    -- Tracez une ligne entre les points
    local line = Turbine.UI.Control()
    line:SetParent(plotLine)
    line:SetPosition(prevX, prevY)
    line:SetSize(nextX - prevX, 1)
    line:SetBackColor(Turbine.UI.Color(1, 0, 0))
    line:SetVisible(true)

    -- Tracez une ligne verticale jusqu'au prochain point
    local vline = Turbine.UI.Control()
    vline:SetParent(plotLine)
    vline:SetPosition(nextX, prevY)
    vline:SetSize(1, nextY - prevY)
    vline:SetBackColor(Turbine.UI.Color(1, 0, 0))

    -- Mettez à jour les coordonnées précédentes
    prevX, prevY = nextX, nextY
    vline:SetVisible(true)
    line:SetVisible(true)
end
graphWindow:SetVisible(true)