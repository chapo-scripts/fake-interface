return function(fontSize, pos, text, color, colorHovered, colorClicked, useDrawList)
    imgui.PushFont(UI.font[fontSize].Bold);
    local size = imgui.CalcTextSize(text);
    
    local isHovered = (useDrawList or (not imgui.IsAnyItemActive() and not imgui.IsItemHovered())) and imgui.IsMouseHoveringRect(pos, pos + size);
    local isClicked = isHovered and imgui.IsMouseClicked(0);
    if (isHovered) then
        imgui.SetMouseCursor(imgui.MouseCursor.Hand);
    end
    -- imgui.GetForegroundDrawList():AddRect(pos, pos + size, isClicked and 0xFF00ff00 or 0xFF0000ff);

    if (useDrawList) then
        imgui.GetWindowDrawList():AddTextFontPtr(UI.font[fontSize].Bold, fontSize, pos, imgui.GetColorU32Vec4(isHovered and (isClicked and colorClicked or colorHovered) or color), text);
    else
        local c = imgui.GetCursorPos();
        imgui.SetCursorScreenPos(pos);
        imgui.TextColored(color or imgui.ImVec4(1, 1, 1, 1), text);
        if (imgui.IsItemHovered()) then
            imgui.SetCursorScreenPos(pos);
            imgui.TextColored(colorHovered or imgui.ImVec4(1, 1, 1, 1), text);
        end
        imgui.SetCursorPos(c);
    end
    imgui.PopFont();
    if (useDrawList) then
        return isClicked and isHovered;
    end
    return imgui.IsItemClicked();
end