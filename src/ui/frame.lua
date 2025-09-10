

local TEXT_BUTTON_COLOR = {
    red = { default = imgui.ImVec4(1, 0, 0, 1), hovered = imgui.ImVec4(1, 0, 0, 0.7) },
    green = { default = imgui.ImVec4(0, 1, 0, 1), hovered = imgui.ImVec4(0, 1, 0, 0.7) }
};

function UI.drawSlotItem(index, slot, item)
    local size = imgui.GetWindowSize();
    if (imgui.BeginChild('item-' .. index, imgui.ImVec2(size.x - 20, 5 + 24 + 5 + 25 + 5), true, imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar)) then
        imgui.SetCursorPos(imgui.ImVec2(5, 5));
        if (UI.Components.ClickableText(FaIcons('EYE') .. '##' .. slot, TEXT_BUTTON_COLOR[Config.inventory.slots[slot].__enabled and 'green' or 'red'].default, nil, imgui.ImVec2(24, 24))) then
            Config.inventory.slots[slot].__enabled = not Config.inventory.slots[slot].__enabled;
            Inventory:update(slot);
        end
        imgui.SameLine();
        imgui.Text(('%s [%d]'):format(item.__info.item_name, item.item[0]));
        
        imgui.SetCursorPos(imgui.ImVec2(5, 5 + 24 + 5));
        if (UI.Components.ClickableText(FaIcons('TRASH') .. '##' .. slot, TEXT_BUTTON_COLOR.red.default, nil, imgui.ImVec2(24, 24))) then
            Config.inventory.slots[slot] = nil;
            Inventory:update(slot);
        end
        imgui.SameLine();
        imgui.TextDisabled(FaIcons('WINDOW_RESTORE'));
        imgui.SameLine();
        imgui.PushItemWidth(50);
        local oldSlot = item.slot[0];
        if (imgui.InputInt('##inventory-item-slot-' .. index, item.slot, -1)) then
            local newSlot = item.slot[0];
            if (Config.inventory.slots[newSlot]) then
                item.slot[0] = oldSlot;
                Msg('Ошибка, слот #' .. newSlot .. ' уже занят!');
                imgui.SetKeyboardFocusHere(-2);
            else
                Config.inventory.slots[newSlot] = item;
                Config.inventory.slots[slot] = nil;
                return;
            end
        end
        UI.Components.Hint('hint-inventory-item-slot-' .. index, u8'Слот');
        imgui.SameLine();
        imgui.TextDisabled(FaIcons('STAR'));
        imgui.SameLine();
        local enchantChanged = imgui.ComboStr('##inventory-item-enchant-' .. index, item.enchant, UI.enchantsListStr, 5);
        UI.Components.Hint('hint-inventory-item-enchant-' .. index, u8'Заточка');
        imgui.SameLine();
        imgui.TextDisabled(FaIcons('TAG'));
        imgui.SameLine();
        local amountChanged = imgui.InputTextWithHint('##inventory-item-text-' .. index, u8'Текст', item.text, ffi.sizeof(item.text));
        UI.Components.Hint('hint-inventory-item-amount-' .. index, u8'Текст предмета (заточка, количество или время)');
        imgui.PopItemWidth();
        imgui.SameLine();
        local colorChanged = imgui.ColorEdit4('##inventory-item-color-' .. index, item.__color, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.AlphaPreview);
        if (imgui.IsItemClicked(1)) then
            item.__color = imgui.new.float[4](1, 1, 1, 0);
            item.background[0] = 0;
            colorChanged = true;
        end
        if (enchantChanged or amountChanged or colorChanged) then
            local colorFloat = item.__color;
            local colorArgb = JoinArgb(colorFloat[3] * 255, colorFloat[1] * 255, colorFloat[2] * 255, colorFloat[3] * 255);
            item.background[0] = colorArgb == 0xFFffffff and 0 or colorArgb;
            Inventory:update(item.slot[0]);
        end
        imgui.SameLine();
        
        UI.Components.Hint('hint-inventory-item-color-' .. index, u8'Цвет фона (ПКМ что бы удалить)');
        -- if (imgui.Button(FaIcons('ELLIPSIS') .. '##hint-inventory-item-other-' .. index, imgui.ImVec2(24, 24))) then
            
        -- end
        -- UI.Components.Hint('hint-inventory-item-other-' .. index, u8'Прочее');
    end
    imgui.EndChild();
end

return function()
    local resX, resY = getScreenResolution()
    local sizeX, sizeY = 400, 400;
    imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
    if imgui.Begin('FakeCEF', UI.menu) then
        local size = imgui.GetWindowSize();
        local style = imgui.GetStyle();

        if (imgui.BeginTabBar('tabs')) then
            if (imgui.BeginTabItem(u8'Инвентарь')) then
                if (imgui.Button(FaIcons('PLUS'), imgui.ImVec2(24, 24))) then
                    local itemInfo = Net:getItemInfo(UI.addItem.id[0]);
                    if (not itemInfo) then
                        return Msg('Ошибка, не удалось найти предмет в базе!');
                    end
                    if (Config.inventory.slots[UI.addItem.slot[0]]) then
                        return Msg('Ошибка, этот слот уже занят!');
                    end
                    if (UI.addItem.id[0] < 0) then
                        Config.inventory.slots[UI.addItem.slot[0]] = {
                            slot = imgui.new.int(UI.addItem.slot[0]),
                            text = imgui.new.char[64](''),
                            item = imgui.new.int(UI.addItem.id[0]),
                            amount = imgui.new.int(0),
                            background = imgui.new.int(0),
                            enchant = imgui.new.int(0),
                            color = imgui.new.int(0),
                            strength = imgui.new.int(0),
                            available = imgui.new.int(1),
                            blackout = imgui.new.int(0),
                            time = imgui.new.int(0),
                            __enabled = true,
                            __info = itemInfo,
                            __color = imgui.new.float[4](1, 1, 1, 0)
                        };
                        Inventory:update(UI.addItem.slot[0]);
                    else
                        Msg('ID не может быть меньше нуля!');
                    end
                end
                UI.Components.Hint('hint-inventory-add-item-', u8('Добавить предмет #%d в слот %d'):format(UI.addItem.id[0], UI.addItem.slot[0]));
                imgui.PushItemWidth(75);
                imgui.SameLine();
                imgui.TextDisabled(FaIcons('HASHTAG'));
                imgui.SameLine();
                imgui.InputInt('##id', UI.addItem.id, -1);
                UI.Components.Hint('hint-inventory-add_id-item-', u8'Серверный ID предмета');
                imgui.SameLine();
                if (UI.Components.ClickableText(FaIcons('LINK'), imgui.ImVec4(0, 0.58, 1, 1))) then
                    os.execute('start "https://items.shinoa.tech/"');
                end
                UI.Components.Hint('hint-inventory-add_items_url-item-', u8'Список предметов');
                imgui.SameLine(nil, 25);
                imgui.TextDisabled(FaIcons('WINDOW_RESTORE'));
                imgui.SameLine();
                imgui.PushStyleColor(imgui.Col.Text, Config.inventory.slots[UI.addItem.slot[0]] == nil and imgui.ImVec4(1, 1, 1, 1) or imgui.ImVec4(1, 0, 0, 1));
                imgui.InputInt('##slot', UI.addItem.slot, -1);
                imgui.PopStyleColor();
                UI.Components.Hint('hint-inventory-add_slot-item-', u8'Слот');
                imgui.PopItemWidth();
                imgui.SameLine();
                local configsButtonPos = imgui.GetCursorScreenPos();
                if (imgui.Button(FaIcons('FOLDER') .. '##configs', imgui.ImVec2(24, 24))) then
                    imgui.OpenPopup('configs');
                end
                UI.Components.Hint('hint-configs', u8'Конфиги');
                UI.Popups.Config(configsButtonPos);

                if (imgui.BeginChild('items-inventory', imgui.ImVec2(size.x - 20, size.y - 10 - imgui.GetCursorPosY()), true)) then
                    if (UI.Components.ClickableText(FaIcons('SUITCASE'), TEXT_BUTTON_COLOR[Config.inventory.enabled and 'green' or 'red'].default)) then
                        Config.inventory.enabled = not Config.inventory.enabled;
                    end
                    local columnPos = {

                    };
                    imgui.SameLine();
                    imgui.TextDisabled(u8'Слот');
                    imgui.SameLine();
                    imgui.TextDisabled(u8'Заточка');
                    imgui.SameLine();
                    imgui.TextDisabled(u8'Количество');
                    imgui.SameLine();
                    imgui.TextDisabled(u8'Предмет');
                    local index = 0;
                    imgui.PushItemWidth(75);
                    for slot, item in pairs(Config.inventory.slots) do
                        index = index + 1;
                        UI.drawSlotItem(index, slot, item);
                    end
                    imgui.PopItemWidth();
                end
                imgui.EndChild();
                imgui.EndTabItem();
            end
            imgui.EndTabBar();
        end
        imgui.End()
    end
end