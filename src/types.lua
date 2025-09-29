---@meta

---@class Item
---@field slot number
---@field item number
---@field amount number
---@field text string
---@field background number
---@field enchant number
---@field color number
---@field strength number
---@field available number
---@field blackout number
---@field time number

---@class SavedPacket
---@field type 'in'|'out'
---@field bytes number[]
---@field timeFromLastPacket number

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
---@field name string
---@field inventory {slots: table<number, ConfigItem>}
---@field house {slots: table<number, ConfigItem>, money: ImBuffer}
---@field hotel {slots: table<number, ConfigItem>}
---@field trunk {slots: table<number, ConfigItem>}

---@class Record
---@field name string
---@field packets SavedPacket[]

---@class GlobalConfig
---@field configs table<string, Config>
---@field activeConfig Config
---@field enabled boolean
---@field packetRecords Record[]
---@field packetRecorderSaveIntervals boolean