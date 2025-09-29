local TABS = {
    { name = FaIcons('SUITCASE') .. u8' Инвентарь', interface = INTERFACE_TYPE.INVENTORY },
    { name = FaIcons('WAREHOUSE') .. u8' Склад', interface = INTERFACE_TYPE.STORAGE },
    { name = FaIcons('HOTEL') .. u8' Отель', interface = INTERFACE_TYPE.HOTEL },
    { name = FaIcons('TRUCK') .. u8' Багажник', interface = INTERFACE_TYPE.TRUNK },
    { name = FaIcons('HOUSE') .. u8' Дом', interface = INTERFACE_TYPE.HOUSE }
};

local function drawTab(name, interface)
    local size = imgui.GetWindowSize();
    local cfg = Config[interface];
    -- print('INT CFG', interface, cfg)
    if (imgui.BeginTabItem(name)) then
        if (interface == INTERFACE_TYPE.HOUSE) then
            imgui.SetNextItemWidth(imgui.GetWindowWidth() - 20);
            if (imgui.InputTextWithHint('##house-name', u8'Деньги в шкафу', Config[interface].money, ffi.sizeof(Config[interface].money), imgui.InputTextFlags.CharsDecimal)) then
                local moneyText = ffi.string(Config[interface].money);
                if (#moneyText == 0 or not tonumber(moneyText)) then
                    imgui.StrCopy(Config[interface].money, '0');
                end
            end
            UI.Components.Hint('hint-house-money', u8'Деньги в шкафу дома')
        end

         if (UI.Components.ClickableText(FaIcons('SUITCASE'), TEXT_BUTTON_COLOR[GlobalConfig.enabled and 'green' or 'red'].default, nil, imgui.ImVec2(24, 24))) then
            GlobalConfig.enabled = not GlobalConfig.enabled;
            CFG:save();
            if (not GlobalConfig.enabled) then
                Msg('Отключено, перезагрузка CEF интерфейса...');
                SlotInterface:reloadWindow();
            end
        end
        UI.Components.Hint('hint-enable-status-' .. interface, u8'Подмена предлметов ' .. u8(GlobalConfig.enabled and 'ВКЛЮЧЕНА' or 'ВЫКЛЮЧЕНА'));
        imgui.SameLine();
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
                SlotInterface:update(interface, UI.addItem.slot[0]);
                UI.addItem.slot[0] = #cfg.slots + 1;
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
        if (UI.Components.ClickableText(FaIcons('LIST'), imgui.ImVec4(0, 0.58, 1, 1))) then
            -- os.execute('start "https://items.shinoa.tech/"');
            imgui.OpenPopup('items-list');
        end
        UI.Popups.ItemsList();
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
           
            -- local columnPos = {

            -- };
            -- imgui.SameLine();
            -- imgui.TextDisabled(u8'Слот');
            -- imgui.SameLine();
            -- imgui.TextDisabled(u8'Заточка');
            -- imgui.SameLine();
            -- imgui.TextDisabled(u8'Количество');
            -- imgui.SameLine();
            -- imgui.TextDisabled(u8'Предмет');
            local index = 0;
            imgui.PushItemWidth(75);
            for slot, item in pairs(cfg.slots) do
                index = index + 1;
                UI.drawSlotItem(index, interface, slot, item);
            end
            imgui.PopItemWidth();
        end
        imgui.EndChild();
        imgui.EndTabItem();
    end
end

return function()
    for _, tabData in ipairs(TABS) do
        drawTab(tabData.name, tabData.interface);
    end
    if (imgui.BeginTabItem(FaIcons('CAMERA') .. u8' Запись')) then
        local size = imgui.GetWindowSize();
        if (imgui.Button((PacketRecorder.currentRecord.active and FaIcons('STOP') .. u8' Завершить' or FaIcons('PLAY') .. u8' Начать') .. u8'запись', imgui.ImVec2(size.x - 20, 24))) then
            if (PacketRecorder.currentRecord.active) then
                PacketRecorder.currentRecord.active = false;
                imgui.OpenPopup('packet-recorder-save');
            else
                PacketRecorder:startRecord();
            end
        end

        if (PacketRecorder.currentRecord.active) then
            imgui.Text(u8'Идет запись!');
            imgui.BulletText(u8'Записано пакетов: ' .. #PacketRecorder.currentRecord.packets);
        else
            if (#GlobalConfig.packetRecords == 0) then
                imgui.Text(u8'Упс, записей не найдено :(');
            else
                for index, record in ipairs(GlobalConfig.packetRecords) do
                    if (imgui.BeginChild('record-' .. index, imgui.ImVec2(size.x - 40, 100), true)) then
                        if (imgui.Button(FaIcons('PLAY') .. '##record-play-' .. index, imgui.ImVec2(24, 24))) then
                            PacketRecorder:play(record);
                        end
                        UI.Components.Hint('hint-records-play-' .. index, u8'Воспроизвести запись');
                        imgui.SameLine();
                        if (imgui.Button(FaIcons('XMARK') .. '##record-delete-' .. index, imgui.ImVec2(24, 24))) then
                            table.remove(GlobalConfig.packetRecords, index);
                        end
                        UI.Components.Hint('hint-records-delete-' .. index, u8'Удалить запись');
                        imgui.SameLine();
                        imgui.Text(('#%d. %s'):format(index, record.name));
                    end
                    imgui.EndChild();
                end
            end
        end
        UI.Popups.PacketRecorderSave();
        imgui.EndTabItem();
    end
end