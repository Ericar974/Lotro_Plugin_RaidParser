import "Turbine.UI"

--[[
Class File 

Here we change the size of an image

call exemple:
local window = Global.ResizeImage(...)
]]


function Global.ResizeImage(imagePath, imageWidth, imageHeight, newWidth, newHeight) -- Resize a image 

    local window = Turbine.UI.Window()
    -- < litle trick to get the corect size of the image
    window:SetSize(imageWidth, imageHeight)
    window:SetBackground(imagePath); --img path
    window:SetStretchMode(1);
    window:SetSize(newWidth, newHeight)
    -- >
    window:SetVisible(true)

    return window
end
