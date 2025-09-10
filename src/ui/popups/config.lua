local save = {
    name = imgui.new.char[64]('testConfig');
};

return function(pos)
    imgui.SetNextWindowPos(pos + imgui.ImVec2(0, 24 + 5), imgui.Cond.Always);
    if (imgui.BeginPopup('configs')) then
        imgui.SetNextItemWidth(100);
        imgui.InputTextWithHint('##hint-popup-configs-name', u8'Название конфига', save.name, ffi.sizeof(save.name));
        imgui.SameLine();
        if (UI.Components.ClickableText(FaIcons('FLOPPY_DISK'), nil, nil, imgui.ImVec2(24, 24))) then
            
        end
        imgui.EndPopup();
    end
end