Hook = {
    initialized = false
};

---@class InventoryEvent
---@field action number

---@class SkinSlot : InventorySlotItem

local moveItem = {
    waiting = false,
    from = 0,
    to = 0
};

MOVE_SOURCE = {
    inventory = 1,
    storage = 25,
    trunk = -999,
    house = -999
};

MOVE_SOURCE_NUMBER = {};

function Hook:init()
    for k, v in pairs(MOVE_SOURCE) do
        MOVE_SOURCE_NUMBER[v] = k;
    end
    
    SampEvents.onShowDialog = function(dialogId, style, title, button1, button2, text)
        print('DIALOG', title);
        if (Inventory.restoreData.state ~= INVENTORY_RESTORE_STATE.NONE) then
            

            local currentState = Inventory.restoreData.state;
            
            if (currentState == INVENTORY_RESTORE_STATE.WAIT_FOR_MAIN_MENU and title:find('Игровое меню')) then
                sampSendDialogResponse(dialogId, 1, 4, nil);
                sampCloseCurrentDialogWithButton(1);
                Inventory.restoreData.setState(INVENTORY_RESTORE_STATE.WAIT_FOR_PERSONAL_SETTINGS);
                return false;
            elseif (currentState == INVENTORY_RESTORE_STATE.WAIT_FOR_PERSONAL_SETTINGS and title:find('Личные настройки')) then
                sampSendDialogResponse(dialogId, 1, 12, nil);
                sampCloseCurrentDialogWithButton(1);
                Inventory.restoreData.setState(INVENTORY_RESTORE_STATE.WAIT_FOR_INTERFACE_SETTINGS);
                return false;
            elseif ((currentState == INVENTORY_RESTORE_STATE.WAIT_FOR_INTERFACE_SETTINGS or currentState == INVENTORY_RESTORE_STATE.WAIT_FOR_INVENTORY_SECOND_CLICK) and title:find('Кастомизация интерфейса')) then
                local waitForSecondClick = currentState == INVENTORY_RESTORE_STATE.WAIT_FOR_INVENTORY_SECOND_CLICK;
                local lineIndex = -2;
                for line in text:gmatch('[^\n]+') do
                    lineIndex = lineIndex + 1;
                    print(lineIndex, line);
                    if (line:find('Тип инвентаря')) then
                        local isNew = line:find('Новый');
                        Inventory.restoreData.setState(isNew and INVENTORY_RESTORE_STATE.WAIT_FOR_INVENTORY_SECOND_CLICK or INVENTORY_RESTORE_STATE.NONE);
                        local button = waitForSecondClick and 0 or 1;
                        Msg('State:', currentState, 'IsNew:', tostring(isNew), 'btn', button);
                        sampSendDialogResponse(dialogId, button, lineIndex, nil);
                        sampCloseCurrentDialogWithButton(button);
                        return false;
                    end
                end
            end
        end
    end
    sampRegisterChatCommand('fakecef.restore', function()
        Msg('Restoring interface...');
        Inventory.restoreData.setState(INVENTORY_RESTORE_STATE.WAIT_FOR_MAIN_MENU);
        sampSendChat('/mm');
    end);
    sampRegisterChatCommand('fakecef.reloadwindow', function()
        CEF:emulate(("(() => {%s})()"):format('window.location.reload()'), false);
    end);
    addEventHandler('onReceivePacket', function(id, bs)
        local status, event, data, json, packetString = CEF:readIncomingPacket(id, bs, true);
        if (status) then
            print(event)
            if (event == PATTERN.EVENT_INVENTORY) then
                --[[
                    window.executeEvent('event.inventory.playerInventory', `[{"action":1,"data":{"skin":{"model":78,"background":-1},"buttons":1}}]`);
                ]]
                
                -- if (data.action == 1) then
                --     -- Set big skin image
                --     data.data.skin.model = 49;
                --     CEF:emulate(([[window.executeEvent('event.inventory.playerInventory', `[%s]`);]]):format(encodeJson(data)), false);
                -- elseif (data.action == 2) then
                --     Msg('event 2')
                --     -- Change skin in slot
                --     ---@type SkinSlot
                    
                --     -- print(encodeJson(data.data.items[1]))
                --     -- print(data.data.items[0].text)
                --     -- data.data.items[1].text = 'TEST';
                --     -- NOT ONLY SKIN!
                --     CEF:emulate(([[window.executeEvent('event.inventory.playerInventory', `[%s]`);]]):format(encodeJson(data)), false);
                -- end

                --[[
                    window.executeEvent('event.inventory.playerInventory', `[{"action":2,"data":{"type":22,"items":[{"slot":0,"item":269,"amount":1,"unic_id":0,"unic_id_2":0,"unic_id_3":0,"text":"ID:78","enchant":0,"available":1,"blackout":0,"time":0}]}}]`);
                ]]
            end
            if (Config.inventory.enabled and event == 'inventory.updateCharacterTab') then
                Inventory:clearAll();
                Inventory:addItemsFromConfig();
                if (data == 'warehouse') then
                    Storage:clearAll();
                    Storage:addItemsFromConfig();
                end
            end
        end
    end);
    addEventHandler('onSendPacket', function(id, bs)
        local status, str = CEF:readOutcomingPacket(id, bs, false);
        if (status) then
            debug.log('OUT:', str);
            if (Config.inventory.enabled) then
                if (str:find(PATTERN.MOVE_ITEM)) then
                    local jsonPayload = str:match(PATTERN.MOVE_ITEM);
                    local moveData = decodeJson(jsonPayload);
                    if (moveData) then
                        local fromSlot, toSlot = moveData.from.slot, moveData.to.slot;
                        local source = {
                            from = MOVE_SOURCE_NUMBER[moveData.from.type],
                            to = MOVE_SOURCE_NUMBER[moveData.to.type]
                        };
                        Msg('item moved from', source.from, 'to', source.to, '|', moveData.from.slot, 'to', moveData.to.slot);

                       
                        local firstItem, secondItem = Config[source.from].slots[fromSlot], Config[source.to].slots[toSlot];
                        Config[source.to].slots[toSlot], Config[source.from].slots[fromSlot] = firstItem, secondItem;
                        if (Config[source.to].slots[toSlot]) then
                            Config[source.to].slots[toSlot].slot[0] = toSlot;
                        end
                        if (Config[source.from].slots[fromSlot]) then
                            Config[source.from].slots[fromSlot].slot[0] = fromSlot;
                        end

                        Inventory:update(moveData.from.slot);
                        Inventory:update(moveData.to.slot);
                        Storage:update(moveData.from.slot);
                        Storage:update(moveData.to.slot);
                        -- inventory.moveItem|{"from":{"slot":0,"type":1,"amount":3},"to":{"slot":1,"type":1}}
                        -- Inventory:handleItemMove(moveData.from.slot, moveData.to.slot);
                        
                        return false;
                    end
                end
            end
        end
    end);
    self.initialized = true;
end