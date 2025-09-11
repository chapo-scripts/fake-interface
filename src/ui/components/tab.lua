local TABS = {
    { name = u8'Инвентарь', key = 'inventory' },
    { name = u8'Склад', key = 'storage' }
};

local function drawTab(name, key)
     local function updateSlot(slot)
        if (key == 'inventory') then
            Inventory:update(slot);
        elseif (key == 'storage') then
            Storage:update(slot);
        end
        Msg('Update', key, slot);
    end
    local size = imgui.GetWindowSize();
    local cfg = Config[key];
    if (imgui.BeginTabItem(name)) then
        if (imgui.Button(FaIcons('PLUS'), imgui.ImVec2(24, 24))) then
            local itemInfo = Net:getItemInfo(UI.addItem.id[0]);
            if (not itemInfo) then
                return Msg('Ошибка, не удалось найти предмет в базе!');
            end
            if (cfg.slots[UI.addItem.slot[0]]) then
                return Msg('Ошибка, этот слот уже занят!');
            end
            if (UI.addItem.id[0] > 0) then
                cfg.slots[UI.addItem.slot[0]] = {
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
                updateSlot(UI.addItem.slot[0]);
            else
                Msg('ID не может быть меньше нуля!', UI.addItem.id[0], tostring(UI.addItem.id[0] < 0));
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
        imgui.PushStyleColor(imgui.Col.Text, cfg.slots[UI.addItem.slot[0]] == nil and imgui.ImVec4(1, 1, 1, 1) or imgui.ImVec4(1, 0, 0, 1));
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
            if (UI.Components.ClickableText(FaIcons('SUITCASE'), TEXT_BUTTON_COLOR[cfg.enabled and 'green' or 'red'].default)) then
                cfg.enabled = not cfg.enabled;
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
            for slot, item in pairs(cfg.slots) do
                index = index + 1;
                UI.drawSlotItem(index, key, slot, item);
            end
            imgui.PopItemWidth();
        end
        imgui.EndChild();
        imgui.EndTabItem();
    end
end

return function()
    for _, tabData in ipairs(TABS) do
        drawTab(tabData.name, tabData.key);
    end
end