import "Turbine.UI"
import "Turbine.UI.Lotro"

--[[
Class File 

Here we try to make a button/alias look better, 

The secret is to make a MomWindow with 2 ChildWindow, one of them as a background image and se second has an opacity of 0 and the alias command.
Both are in the same position but the image his behind(zAxe) the alias

call exemple:
local Button = Global.ButtonImage(...)
]]


function Global.ButtonImage(x,y,imagePath, imageWidth, imageHeight, shortcut) -- Return a table {window, ImageWindow, AliasWindow} | Button/alias but look better | x and y are the position , shortcut is the /alias

    local window = Turbine.UI.Window()
    window:SetPosition(x, y)
    window:SetSize(110, 110)
    window:SetVisible(true)

    -- Window for displaying image
    ImageWindow = Turbine.UI.Window()
    ImageWindow:SetParent(window);
    -- < litle trick to get the corect size of the image
    ImageWindow:SetSize(imageWidth, imageHeight)
    ImageWindow:SetBackground(imagePath); --img path
    ImageWindow:SetStretchMode(1);
    ImageWindow:SetSize(110, 110)                   -- >
    ImageWindow:SetVisible(true)

    ImageWindow.move = Turbine.UI.Window()
    ImageWindow.move:SetParent(window);
    ImageWindow.move:SetSize(10, 10)
    ImageWindow.move:SetBackColor(Turbine.UI.Color(0.84,0.76,0.33))
    ImageWindow.move:SetVisible(false)
    ImageWindow.move:SetZOrder(1)
    ImageWindow.move.MouseDown = function(sender, args)
        window.oldX = args.X
        window.oldY = args.Y
        ImageWindow.move.MouseMove = function(sender, args)
            window:SetPosition(window:GetLeft() + (args.X - window.oldX),
            window:GetTop() + (args.Y - window.oldY))
            window.oldX = args.X
            window.oldY = args.Y
        end
        ImageWindow.move.MouseUp = function(sender, args)
            ImageWindow.move.MouseMove = nil
            ImageWindow.move.MouseUp = nil
        end
    end

    -- < Alias window
    AliasWindow = Turbine.UI.Window()
    AliasWindow:SetParent(window);
    AliasWindow:SetSize(100, 100)
    AliasWindow:SetOpacity(0)
    AliasWindow:SetVisible(true)


    -- Create the shorcut
    AliasWindow.shortcut = Turbine.UI.Lotro.Shortcut();
    AliasWindow.shortcut:SetType(Turbine.UI.Lotro.ShortcutType.Alias);
    AliasWindow.shortcut:SetData(shortcut) --alias that you want

    AliasWindow.quickslot = Turbine.UI.Lotro.Quickslot();
    AliasWindow.quickslot:SetParent(AliasWindow);
    AliasWindow.quickslot:SetPosition(10, 10);
    AliasWindow.quickslot:SetSize(100, 100)
    AliasWindow.quickslot:SetBackColor(Turbine.UI.Color(0.27, 0.23, 0.78)) -- just to test
    AliasWindow.quickslot:SetShortcut(AliasWindow.shortcut);
    AliasWindow.quickslot:SetVisible(true);
    -- >

    return {window, ImageWindow, AliasWindow} -- [1] MomWindow , [2] Child ImageWindown, [3] child AliasWindow 
end
