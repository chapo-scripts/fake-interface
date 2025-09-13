INVENTORY_RESTORE_STATE = {
    NONE = 0,
    WAIT_FOR_MAIN_MENU = 1,
    WAIT_FOR_PERSONAL_SETTINGS = 2,
    WAIT_FOR_INTERFACE_SETTINGS = 3,
    WAIT_FOR_INVENTORY_SETTINGS = 4,
    WAIT_FOR_INVENTORY_SECOND_CLICK = 5,
    CLOSE_ANY_DIALOG = 99
};

Inventory = {
    slots = {},
    restoreData = {
        state = INVENTORY_RESTORE_STATE.WAIT_FOR_MAIN_MENU
    }
};

function Inventory.restoreData.setState(state)
    local oldState = Inventory.restoreData.state;
    Inventory.restoreData.state = state;
    Msg(('Restoring interface (%d/%d)'):format(oldState, state));
end

function Inventory:clearSlot(slot)
    CEF:emulate(([[window.executeEvent('event.inventory.playerInventory', `[{"action":2,"data":{"type":1,"items":[{"slot":%d}]}}]`);]]):format(slot), false);
    self.slots[slot] = nil;
end

function Inventory:clearAll()
    for i = 0, 100 do
        self:clearSlot(i);
    end
end

---@param item Item
function Inventory:setItem(item)
    self:setItems({item});
end

local ITEM_DATA_TYPE_SET_STORAGE = 25;

---@param items Item[]
function Inventory:setItems(items, type)
    local data = {
        action = 2,
        data = {
            type = type or 1,
            items = items
        }
    };
    CEF:emulate(([[window.executeEvent('event.inventory.playerInventory', `[%s]`);]]):format(encodeJson(data)), false);
    for _, item in ipairs(items) do
        self.slots[item.slot] = item;
    end
end

function Inventory:convertConfigItemToItem(configItem)
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

-- function Inventory:c

function Inventory:handleItemMove(fromSlot, toSlot)
    local firstItem, secondItem = Config.inventory.slots[fromSlot], Config.inventory.slots[toSlot];
    Config.inventory.slots[toSlot], Config.inventory.slots[fromSlot] = firstItem, secondItem;
    if (Config.inventory.slots[toSlot]) then
        Config.inventory.slots[toSlot].slot[0] = toSlot;
    end
    if (Config.inventory.slots[fromSlot]) then
        Config.inventory.slots[fromSlot].slot[0] = fromSlot;
    end
    self:update(fromSlot);
    self:update(toSlot);
end

function Inventory:update(slot)
    local item = Config.inventory.slots[slot];
    if (item and item.__enabled) then
        self:setItem(self:convertConfigItemToItem(item));
    else
        self:clearSlot(slot);
    end
    debug.log('slot', 'slot', (item or (item and item.__enabled)) and 'ADDED' or 'CLEARED');
end

function Inventory:addItemsFromConfig()
    local items = {};
    for slot, configItem in pairs(Config.inventory.slots) do
        if (configItem.__enabled) then
            table.insert(items, self:convertConfigItemToItem(configItem));
        end
    end
    self:setItems(items);
end

function Inventory:init()
    lua_thread.create(function()
        while (true) do
            wait(0);
            if (wasKeyPressed(VK_1)) then
                sampAddChatMessage('Test', -1);
                for i = 1, 10 do
                    Inventory:clearSlot(i);
                end
            elseif (wasKeyPressed(VK_2)) then
                sampAddChatMessage('add', -1);
                Inventory:setItem({
                    slot = 5,
                    item = 6313,
                    amount = 1,
                    -- text = '',
                    background = -1248120833,
                    enchant = "12",
                    color = 0,
                    strength = 100,
                    available = 1,
                    blackout = 0,
                    time = 0
                });
            end
        end
    end);
end

--[[
    window.executeEvent('event.videoBackground.blockVideoByTime', `[0, 1]`);
    videoBackground.blockVideoByTime
    window.executeEvent('event.arizonahud.setUnreadStats', `[{"unreadMessengerMessages":0}]`);
    arizonahud.setUnreadStats
    window.executeEvent('event.inventory.playerInventory', `[{"action":0,"data":{"type":1,"items":[{"slot":0,"item":8141,"amount":1,"text":"","available":1,"blackout":0,"time":0},{"slot":1,"item":6508,"amount":2,"text":"2","available":1,"blackout":0,"time":0},{"slot":2,"item":679,"amount":1,"text":"","background":-589505281,"available":1,"blackout":0,"time":0},{"slot":3,"item":569,"amount":1,"text":"","available":1,"blackout":0,"time":0},{"slot":4,"item":800,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017994},{"slot":5,"item":801,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017994},{"slot":6,"item":802,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017994},{"slot":7,"item":803,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017994},{"slot":8,"item":804,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017994},{"slot":9,"item":805,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017994},{"slot":10,"item":806,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017994},{"slot":11,"item":1423,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017994},{"slot":12,"item":1934,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017994},{"slot":13,"item":6160,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017994},{"slot":14,"item":1172,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017995},{"slot":15,"item":1171,"amount":1,"text":"29 day","available":1,"blackout":0,"time":1760017997},{"slot":16,"item":4745,"amount":1,"text":"","available":1,"blackout":0,"time":1759585998},{"slot":17,"item":5841,"amount":1,"text":"","background":-1556328193,"available":1,"blackout":0,"time":0},{"slot":18,"item":8503,"amount":13,"text":"13","background":-1128744961,"available":1,"blackout":0,"time":0},{"slot":19,"item":3927,"amount":9,"text":"9","available":1,"blackout":0,"time":0},{"slot":20,"item":555,"amount":3,"text":"3","available":1,"blackout":0,"time":0}]}}]`);
    inventory.playerInventory
    window.executeEvent('event.inventory.playerInventory', `[{"action":0,"data":{"type":1,"items":[{"slot":21,"item":8733,"amount":1,"text":"","background":1097458175,"enchant":0,"color":0,"strength":100,"available":1,"blackout":0,"time":0},{"slot":22,"item":5846,"amount":1,"unic_id_2":0,"text":"","background":847291647,"available":1,"blackout":0,"time":0},{"slot":23,"item":8463,"amount":1,"text":"TUNING","background":927365375,"available":1,"blackout":0,"time":0},{"slot":24,"item":7820,"amount":1,"text":"","background":1711301375,"enchant":0,"color":0,"strength":100,"available":1,"blackout":0,"time":0},{"slot":25,"item":7945,"amount":5,"text":"5","background":-1556328193,"available":1,"blackout":0,"time":0},{"slot":26,"item":8551,"amount":1,"text":"","background":-4142081,"available":1,"blackout":0,"time":0},{"slot":27,"item":3562,"amount":1,"text":"","background":-1,"available":1,"blackout":0,"time":0},{"slot":28,"item":7425,"amount":1,"text":"","background":-1128744961,"available":1,"blackout":0,"time":0},{"slot":29,"item":709,"amount":1,"text":"","background":-7601921,"available":1,"blackout":0,"time":0},{"slot":30,"item":8681,"amount":1,"text":"","background":-1248120833,"enchant":0,"color":0,"strength":100,"available":1,"blackout":0,"time":0},{"slot":31,"item":161,"amount":1,"text":"","background":-1535560961,"enchant":0,"color":0,"strength":100,"available":1,"blackout":0,"time":0},{"slot":32,"item":726,"amount":1,"unic_id_2":0,"text":"","background":-1962934017,"available":1,"blackout":0,"time":0},{"slot":33,"item":811,"amount":1,"unic_id_2":0,"text":"","background":-1538575617,"enchant":0,"color":0,"strength":100,"available":1,"blackout":0,"time":0},{"slot":34,"item":7355,"amount":5,"text":"5","background":1417950975,"available":1,"blackout":0,"time":0},{"slot":35},{"slot":36},{"slot":37},{"slot":38},{"slot":39},{"slot":40},{"slot":41},{"slot":42},{"slot":43},{"slot":44},{"slot":45},{"slot":46},{"slot":47},{"slot":48},{"slot":49},{"slot":50},{"slot":51},{"slot":52},{"slot":53},{"slot":54},{"slot":55},{"slot":56},{"slot":57},{"slot":58},{"slot":59},{"slot":60},{"slot":61},{"slot":62},{"slot":63}]}}]`);
    inventory.playerInventory
    window.executeEvent('event.inventory.playerInventory', `[{"action":0,"data":{"type":1,"items":[{"slot":64},{"slot":65},{"slot":66},{"slot":67},{"slot":68},{"slot":69},{"slot":70},{"slot":71}]}}]`);
    inventory.playerInventory
    window.executeEvent('event.inventory.playerInventory', `[{"action":0,"data":{"type":10,"items":[{"slot":0},{"slot":1},{"slot":2},{"slot":3},{"slot":4},{"slot":5}]}}]`);
    inventory.playerInventory
    window.executeEvent('event.inventory.playerInventory', `[{"action":0,"data":{"type":2,"items":[{"slot":0},{"slot":1},{"slot":2},{"slot":3},{"slot":4},{"slot":5}]}}]`);
    inventory.playerInventory
    window.executeEvent('event.inventory.playerInventory', `[{"action":0,"data":{"type":17,"items":[{"slot":0},{"slot":1}]}}]`);
    inventory.playerInventory
    window.executeEvent('event.inventory.playerInventory', `[{"action":0,"data":{"type":22,"items":[{"slot":0,"item":269,"amount":1,"unic_id":0,"unic_id_2":0,"unic_id_3":0,"text":"ID:78","enchant":0,"available":1,"blackout":0,"time":0}]}}]`);
    inventory.playerInventory
    window.executeEvent('event.inventory.playerInventory', `[{"action":0,"data":{"type":24,"items":[{"slot":0},{"slot":1},{"slot":2},{"slot":3},{"slot":4},{"slot":5},{"slot":6},{"slot":7},{"slot":8},{"slot":9},{"slot":10},{"slot":11}]}}]`);
    inventory.playerInventory
    window.executeEvent('event.inventory.playerInventory', `[{"action":0,"data":{"type":30,"items":[{"slot":0,"id":0},{"slot":1,"id":0},{"slot":2,"id":0},{"slot":3,"id":0},{"slot":0,"id":1},{"slot":1,"id":1},{"slot":2,"id":1},{"slot":3,"id":1},{"slot":0,"id":2},{"slot":1,"id":2},{"slot":2,"id":2},{"slot":3,"id":2},{"slot":0,"id":3},{"slot":1,"id":3},{"slot":2,"id":3},{"slot":3,"id":3}]}}]`);
    inventory.playerInventory
    window.executeEvent('event.inventory.playerInventory', `[{"action":0,"data":{"type":33,"items":[{"slot":0,"id":0},{"slot":1,"id":0},{"slot":2,"id":0},{"slot":3,"id":0},{"slot":4,"id":0},{"slot":5,"id":0},{"slot":6,"id":0},{"slot":7,"id":0},{"slot":8,"id":0},{"slot":9,"id":0},{"slot":10,"id":0},{"slot":11,"id":0},{"slot":0,"id":1},{"slot":1,"id":1},{"slot":2,"id":1},{"slot":3,"id":1},{"slot":4,"id":1},{"slot":5,"id":1},{"slot":6,"id":1},{"slot":7,"id":1},{"slot":8,"id":1},{"slot":9,"id":1},{"slot":10,"id":1},{"slot":11,"id":1},{"slot":0,"id":2},{"slot":1,"id":2},{"slot":2,"id":2},{"slot":3,"id":2},{"slot":4,"id":2},{"slot":5,"id":2},{"slot":6,"id":2},{"slot":7,"id":2},{"slot":8,"id":2},{"slot":9,"id":2},{"slot":10,"id":2},{"slot":11,"id":2},{"slot":0,"id":3},{"slot":1,"id":3},{"slot":2,"id":3},{"slot":3,"id":3},{"slot":4,"id":3},{"slot":5,"id":3},{"slot":6,"id":3},{"slot":7,"id":3},{"slot":8,"id":3},{"slot":9,"id":3},{"slot":10,"id":3},{"slot":11,"id":3}]}}]`);
    inventory.playerInventory
]]