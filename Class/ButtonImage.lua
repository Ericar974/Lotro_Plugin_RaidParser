import "Turbine.UI"
import "Turbine.UI.Lotro"

--[[
NON CLASS FILE ==> For now it's use only one time for the display of target, don't duplicate this.

Here we try to make a button/alias look better, 

The secret is to make a MomWindow with 2 ChildWindow, one of them as a background image and se second has an opacity of 0 and the alias command.
Both are in the same position but the image his behind(zAxe) the alias

call exemple:
local Button = Global.ButtonImage(...)
]]


function Global.ButtonImage(x,y,imagePath, imageWidth, imageHeight, shortcut) -- Return a table {window, ImageWindow, AliasWindow} | Button/alias but look better | x and y are the position , shortcut is the /alias

    local window = Turbine.UI.Window()
    window:SetPosition(x, y)
    window:SetSize(80, 80)
    window:SetVisible(true)
    window:SetWantsKeyEvents(true)
    
    -- Window for displaying image
    ImageWindow = Turbine.UI.Window()
    ImageWindow:SetParent(window);
    -- < litle trick to get the corect size of the image
    ImageWindow:SetPosition(10, 10)
    ImageWindow:SetSize(imageWidth, imageHeight)
    ImageWindow:SetBackground(imagePath); --img path
    ImageWindow:SetStretchMode(1);
    ImageWindow:SetSize(70, 70)                   -- >
    ImageWindow:SetVisible(true)
    
    ImageWindow.hiddenMsg = Turbine.UI.Label()
    ImageWindow.hiddenMsg:SetParent(window)
    ImageWindow.hiddenMsg:SetPosition(20, 0)
    ImageWindow.hiddenMsg:SetSize(100, 20)
    ImageWindow.hiddenMsg:SetVisible(false)
    ImageWindow.hiddenMsg:SetZOrder(3)
    ImageWindow.hiddenMsg:SetWantsKeyEvents(true)
    ImageWindow.hiddenMsg:SetText('RP: icon')

    ImageWindow.move = Turbine.UI.Window()
    ImageWindow.move:SetParent(window);
    ImageWindow.move:SetSize(20, 20)
    ImageWindow.move:SetBackground("RaidParser/img/drag.tga")
    ImageWindow.move:SetVisible(false)
    ImageWindow.move:SetZOrder(3)
    ImageWindow.move:SetWantsKeyEvents(true)
    ImageWindow.move.MouseDown = function(sender, args)
        window.oldX = args.X
        window.oldY = args.Y
        window.dragging = true
    end
    window.KeyDown = function(sender, args)
        if (args.Action == Turbine.UI.Lotro.Action.ToggleHiddenDragBoxes) then
            ImageWindow.move:SetVisible(not ImageWindow.move:IsVisible())
            ImageWindow.hiddenMsg:SetVisible(not ImageWindow.hiddenMsg:IsVisible())
        end
    end
    
    ImageWindow.move.MouseMove = function(sender, args)
        if window.dragging then
            local mouseX, mouseY = Turbine.UI.Display.GetMousePosition()
            local newX = mouseX - window.oldX
            local newY = mouseY - window.oldY
            local screenWidth, screenHeight = Turbine.UI.Display:GetSize()
            local newLeft = math.max(0, math.min(newX, screenWidth - window:GetWidth()))
            local newTop = math.max(0, math.min(newY, screenHeight - window:GetHeight()))
            window:SetPosition(newLeft, newTop)

            -- for preferences
            Global.Settings.imageBtn.left = newLeft / Global.screenWidth
            Global.Settings.imageBtn.top = newTop / Global.screenHeight
        end
    end
    
    ImageWindow.move.MouseUp = function(sender, args)
        window.dragging = false
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
