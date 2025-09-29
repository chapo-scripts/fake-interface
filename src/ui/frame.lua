


function UI.drawSlotItem(index, interface, slot, item)
    local cfg = Config[interface];
    local size = imgui.GetWindowSize();
    if (not cfg.slots[slot]) then
        return;
    end
    local styleColors = imgui.GetStyle().Colors;
    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.GetStyle().Colors[imgui.Col.FrameBg]);
    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.GetStyle().Colors[imgui.Col.WindowBg]);
    imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.GetStyle().Colors[imgui.Col.WindowBg]);
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.GetStyle().Colors[imgui.Col.WindowBg]);
    if (imgui.BeginChild('item-' .. index, imgui.ImVec2(size.x - 20, 5 + 24 + 5), true, imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar)) then
        imgui.SetCursorPos(imgui.ImVec2(5, 5));
        if (UI.Components.ClickableText(FaIcons('EYE') .. '##' .. slot, TEXT_BUTTON_COLOR[cfg.slots[slot].__enabled and 'green' or 'red'].default, nil, imgui.ImVec2(24, 24))) then
            cfg.slots[slot].__enabled = not cfg.slots[slot].__enabled;
            SlotInterface:update(interface, slot);
        end
        imgui.SameLine();
        
        -- imgui.SetCursorPos(imgui.ImVec2(5, 5 + 24 + 5));
        if (UI.Components.ClickableText(FaIcons('TRASH') .. '##' .. slot, TEXT_BUTTON_COLOR.red.default, nil, imgui.ImVec2(24, 24))) then
            cfg.slots[slot] = nil;
            SlotInterface:update(interface, slot);
        end
        imgui.SameLine();
        imgui.Text(('%s [%d]'):format(item.__info.name, item.item[0]));
        imgui.SameLine();
        imgui.TextDisabled(FaIcons('WINDOW_RESTORE'));
        imgui.SameLine();
        imgui.PushItemWidth(100);
        local oldSlot = item.slot[0];
        if (imgui.InputInt('##inventory-item-slot-' .. index, item.slot, -1)) then
            local newSlot = item.slot[0];
            if (cfg.slots[newSlot]) then
                item.slot[0] = oldSlot;
                Msg('Ошибка, слот #' .. newSlot .. ' уже занят!');
                imgui.SetKeyboardFocusHere(-2);
            else
                cfg.slots[newSlot] = item;
                cfg.slots[slot] = nil;
                return;
            end
            SlotInterface:update(interface, oldSlot);
            SlotInterface:update(interface, newSlot);
        end
        UI.Components.Hint('hint-inventory-item-slot-' .. index, u8'Слот');
        
        imgui.SameLine();
        imgui.TextDisabled(FaIcons('TAG'));
        imgui.SameLine();
        local textChanged = imgui.InputTextWithHint('##inventory-item-text-' .. index, u8'Текст', item.text, ffi.sizeof(item.text));
        UI.Components.Hint('hint-inventory-item-amount-' .. index, u8'Текст предмета (заточка, количество или время)');
        imgui.PopItemWidth();
        imgui.SameLine();
        local colorChanged = imgui.ColorEdit4('##inventory-item-color-' .. index, item.__color, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.AlphaPreview);
        if (imgui.IsItemClicked(1)) then
            item.__color = imgui.new.float[4](1, 1, 1, 0);
            item.background[0] = 0;
            colorChanged = true;
        end
        if (textChanged or colorChanged) then
            local colorFloat = item.__color;
            local colorArgb = JoinArgb(colorFloat[3] * 255, colorFloat[1] * 255, colorFloat[2] * 255, colorFloat[3] * 255);
            item.background[0] = colorArgb == 0xFFffffff and 0 or colorArgb;
            SlotInterface:update(interface, item.slot[0]);
        end
        imgui.SameLine();
        
        UI.Components.Hint('hint-inventory-item-color-' .. index, u8'Цвет фона (ПКМ что бы удалить)');
        -- if (imgui.Button(FaIcons('ELLIPSIS') .. '##hint-inventory-item-other-' .. index, imgui.ImVec2(24, 24))) then
            
        -- end
        -- UI.Components.Hint('hint-inventory-item-other-' .. index, u8'Прочее');
    end
    imgui.EndChild();
    imgui.PopStyleColor(4);
end

return function(frame)
    local resX, resY = getScreenResolution()
    local sizeX, sizeY = 600, 400;
    imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
    if imgui.Begin('FakeCEF', UI.menu, imgui.WindowFlags.NoCollapse) then
        local size = imgui.GetWindowSize();
        local style = imgui.GetStyle();

        if (imgui.BeginTabBar('tabs')) then
            UI.Components.Tab();
            imgui.EndTabBar();
        end
        imgui.End()
    end
end