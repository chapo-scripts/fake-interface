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