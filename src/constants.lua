---@enum PATTERN
PATTERN = {
    REGEX_PACKET = 'window%.executeEvent%(\'event%.(.+)\', `(.+)`%);',
    EVENT_ADD_ITEM = 'mountain.testDrive.addVehicles',
    EVENT_OPEN_MENU = 'mountain.testDrive.initializeText',
    EVENT_SET_ACTIVE_VIEW = 'event.setActiveView',
    CLOSE_MENU = 'onActiveViewChanged|null',

    EVENT_INVENTORY = 'inventory.playerInventory',

    MOVE_ITEM = [[inventory.moveItem|(.+)]]
};

INVENTORY_RESTORE_DIALOG_TITLE = {
    -- [INVENTORY_RESTORE_STATE.WAIT_FOR_MAIN_MENU] = '',
    -- [INVENTORY_RESTORE_STATE.WAIT_FOR_PERSONAL_SETTINGS] = '',
    -- [INVENTORY_RESTORE_STATE.WAIT_FOR_INTERFACE_SETTINGS] = '',
    -- [INVENTORY_RESTORE_STATE.WAIT_FOR_INVENTORY_SETTINGS] = '',
    -- [INVENTORY_RESTORE_STATE.WAIT_FOR_INVENTORY_SECOND_CLICK] = '',
    -- [INVENTORY_RESTORE_STATE.CLOSE_ANY_DIALOG] = ''
};

---@enum INTERFACE_TYPE
INTERFACE_TYPE = {
    INVENTORY = 'inventory',
    HOTEL = 'hotel',
    STORAGE = 'storage'
};

---@type table<string, INTERFACE_TYPE>
INTERFACE_TYPE_REVERSED = (function()
    local l = {};
    for k, v in pairs(INTERFACE_TYPE) do
        l[v] = k;
    end
    return l;
end)();

INTERFACE_ACTION_TYPE = {
    [INTERFACE_TYPE.INVENTORY] = 1,
    [INTERFACE_TYPE.HOTEL] = 34,
    [INTERFACE_TYPE.STORAGE] = 25
};

INTERFACE_MAX_SLOTS = {
    [INTERFACE_TYPE.INVENTORY] = 100,
    [INTERFACE_TYPE.HOTEL] = 179,
    [INTERFACE_TYPE.STORAGE] = 179
};

INTERFACE_TAB_NAME = {
    [INTERFACE_TYPE.INVENTORY] = u8'Инвентарь',
    [INTERFACE_TYPE.HOTEL] = u8'Отель',
    [INTERFACE_TYPE.STORAGE] = u8'Склад'
};