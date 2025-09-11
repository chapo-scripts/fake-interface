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