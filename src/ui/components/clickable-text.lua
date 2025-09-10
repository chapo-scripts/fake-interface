return function(text, color, colorHovered, useButtonSize)
    local color = color or imgui.GetStyle().Colors[imgui.Col.Text];
    local colorHovered = colorHovered or imgui.ImVec4(color.x, color.y, color.z, color.w - 0.4);
    if (useButtonSize) then
        imgui.PushStyleColor(imgui.Col.Text, color);
        local button = imgui.Button(text, useButtonSize);
        imgui.PopStyleColor();
        return button;
    else
        local pos = imgui.GetCursorScreenPos();
        local textSize = imgui.CalcTextSize(text);
        local isHovered = imgui.IsMouseHoveringRect(pos, pos + textSize);
        imgui.TextColored(isHovered and colorHovered or color, text);
        return isHovered and imgui.IsMouseClicked(0);
    end
end