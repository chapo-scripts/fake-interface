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

function Hook:init()
    addEventHandler('onReceivePacket', function(id, bs)
        local status, event, data, json, packetString = CEF:readIncomingPacket(id, bs, true);
        if (status) then
            print(event)
            if (event == PATTERN.EVENT_INVENTORY) then
                --[[
                    window.executeEvent('event.inventory.playerInventory', `[{"action":1,"data":{"skin":{"model":78,"background":-1},"buttons":1}}]`);
                ]]
                
                if (data.action == 1) then
                    -- Set big skin image
                    data.data.skin.model = 49;
                    CEF:emulate(([[window.executeEvent('event.inventory.playerInventory', `[%s]`);]]):format(encodeJson(data)), false);
                elseif (data.action == 2) then
                    Msg('event 2')
                    -- Change skin in slot
                    ---@type SkinSlot
                    
                    -- print(encodeJson(data.data.items[1]))
                    -- print(data.data.items[0].text)
                    -- data.data.items[1].text = 'TEST';
                    -- NOT ONLY SKIN!
                    CEF:emulate(([[window.executeEvent('event.inventory.playerInventory', `[%s]`);]]):format(encodeJson(data)), false);
                end

                --[[
                    window.executeEvent('event.inventory.playerInventory', `[{"action":2,"data":{"type":22,"items":[{"slot":0,"item":269,"amount":1,"unic_id":0,"unic_id_2":0,"unic_id_3":0,"text":"ID:78","enchant":0,"available":1,"blackout":0,"time":0}]}}]`);
                ]]
            end

            if (packetString == [[window.executeEvent('event.inventory.updateCharacterTab', `["character"]`);]]) then
                Msg('Update');
                if (Config.inventory.enabled) then
                    Inventory:clearAll();
                    Inventory:addItemsFromConfig();
                    -- for slot, item in pairs(Config.inventory.slots) do
                    --     Inventory:setItem(item);
                    --     print(item.slot)
                    -- end
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
                        -- inventory.moveItem|{"from":{"slot":0,"type":1,"amount":3},"to":{"slot":1,"type":1}}
                        Inventory:handleItemMove(moveData.from.slot, moveData.to.slot);
                        return false;
                    end
                end
            end
        end
    end);
    self.initialized = true;
end