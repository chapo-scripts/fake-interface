---@class ConfigItem
---@field slot ImInt
---@field item ImInt
---@field amount ImInt
---@field text ImBuffer
---@field background ImInt
---@field enchant ImInt
---@field color ImInt
---@field strength ImInt
---@field available ImInt
---@field blackout ImInt
---@field time ImInt

---@class Config
---@field inventory {slots: table<number, ConfigItem>}
---@field house {slots: table<number, ConfigItem>}
---@field hotel {slots: table<number, ConfigItem>}
---@field trunk {slots: table<number, ConfigItem>}

Config = {
    inventory = {
        enabled = true,
        skin = {
            id = 49,
            text = 'ID: TEST',
            smallImage = '269'
        },
        slots = {}
    }
};