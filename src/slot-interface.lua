SlotInterface = {
    slots = {};
};

local function getInterfaceType(interface)
    return INTERFACE_ACTION_TYPE[interface];
end

local function getInterfaceFromType(type)
    for k, v in pairs(INTERFACE_ACTION_TYPE) do
        if (v == type) then
            return k;
        end
    end
end

---@param interface INTERFACE_TYPE
---@param item Item
function SlotInterface:setItem(interface, item)
    self:setItems(interface, {item});
end

---@param interface INTERFACE_TYPE
---@param slot number
function SlotInterface:clearSlot(interface, slot)
    CEF:emulate(([[window.executeEvent('event.inventory.playerInventory', `[{"action":2,"data":{"type":%d,"items":[{"slot":%d}]}}]`);]]):format(getInterfaceType(interface), slot), false);
    self.slots[interface][slot] = nil;
end

---@param interface INTERFACE_TYPE
---@param items Item[]
function SlotInterface:setItems(interface, items)
    local type = getInterfaceType(interface);
    local data = {
        action = 2,
        data = {
            type = type,
            items = items
        }
    };
    CEF:emulate(([[window.executeEvent('event.inventory.playerInventory', `[%s]`);]]):format(encodeJson(data)), false);
    for _, item in ipairs(items) do
        self.slots[interface][item.slot] = item;
    end
end

---@param interface INTERFACE_TYPE
---@param min number
---@param max number
function SlotInterface:clearsSlots(interface, min, max)
    for i = min, max do
        self:clearSlotItem(interface, i);
    end
end

function SlotInterface:reloadWindow()
    CEF:emulate(("(() => {%s})()"):format('window.location.reload()'), false);
end

---@param interface INTERFACE_TYPE
function SlotInterface:clearAll(interface)
    for i = 0, INTERFACE_MAX_SLOTS[interface] do
        self:clearSlot(interface, i);
    end
end

---@param interface INTERFACE_TYPE
function SlotInterface:addItemsFromConfig(interface)
    DebugMsg('Adding items from config to', interface);
    local items = {};
    for slot, configItem in pairs(Config[interface].slots) do
        if (configItem.__enabled) then
            table.insert(items, self:convertConfigItemToItem(configItem));
        end
    end
    self:setItems(interface, items);

    if (interface == INTERFACE_TYPE.HOUSE) then
        self:setHouseWardrobeMoney(tonumber(ffi.string(Config[interface].money)) or -1);
    end
end

---@param amount number
function SlotInterface:setHouseWardrobeMoney(amount)
    DebugMsg('wardrobe, money set to', amount);
    --window.executeEvent('event.inventory.playerInventory', `[{"action":1,"data":{"type":5,"money":228}}]`);
    CEF:emulate(([[window.executeEvent('event.inventory.playerInventory', `[{"action":1,"data":{"type":5,"money":%d}}]`);]]):format(amount), false);
end

function SlotInterface:handleItemMove(from, to)
    local interface = { from = getInterfaceFromType(from.type), to = getInterfaceFromType(to.type) };
    local slot = { from = from.slot, to = to.slot };
    local item = { from = table.copy(Config[interface.from].slots[slot.from]), to = table.copy(Config[interface.to].slots[slot.to]) };
    -- print('move from', table.toString(item.from));
    -- print('move TO', table.toString(item.to));
    
    Config[interface.from].slots[slot.from], Config[interface.to].slots[slot.to] = item.to, item.from;
    if (Config[interface.to].slots[slot.to]) then
        Config[interface.to].slots[slot.to].slot[0] = slot.to;
    end
    if (Config[interface.from].slots[slot.from]) then
        Config[interface.from].slots[slot.from].slot[0] = slot.from;
    end
    -- print('FROM', interface.from, slot.from, table.toString(Config[interface.from]))
    -- print('TO', interface.to, slot.to, table.toString(Config[interface.to]))
    -- print(interface.to, interface.from, Config[interface.to].slots, Config[interface.from].slots);
    
    -- local firstItem, secondItem = Config[interface.from].slots[slot.from], Config[interface.from].slots[slot.to];
    -- Config[interface.to].slots[slot.to], Config[interface.from].slots[interface.from] = firstItem, secondItem;
    -- if (Config[interface.to].slots[slot.to]) then
    --     Config[interface.to].slots[slot.to].slot[0] = slot.to;
    -- end
    -- if (Config[interface.from].slots[slot.from]) then
    --     Config[interface.from].slots[slot.from].slot[0] = slot.from;
    -- end

    self:update(interface.from, slot.from);
    self:update(interface.to, slot.to);
    Msg('Moved from', interface.from, slot.from, ' ->', interface.to, slot.to);
end

---@param interface INTERFACE_TYPE
---@param slot number
function SlotInterface:update(interface, slot)
    local item = Config[interface].slots[slot];
    if (item and item.__enabled) then
        self:setItem(interface, self:convertConfigItemToItem(item));
        print(table.toString(item));
    else
        self:clearSlot(interface, slot);
    end
    debug.log('UPDATE, INT:', interface, 'slot', (item or (item and item.__enabled)) and 'ADDED' or 'CLEARED');
end

---@param configItem ConfigItem
function SlotInterface:convertConfigItemToItem(configItem)
    return {
        slot = configItem.slot[0],
        item = configItem.item[0],
        amount = configItem.amount[0],
        text = u8:decode(ffi.string(configItem.text)),
        background = configItem.background[0],
        enchant = configItem.enchant[0],
        color = configItem.color[0],
        strength = configItem.strength[0],
        available = configItem.available[0],
        blackout = configItem.blackout[0],
        time = configItem.time[0],
    };
end

function SlotInterface:init()
    for _, key in pairs(INTERFACE_TYPE) do
        self.slots[key] = {};
    end
end