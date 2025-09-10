CFG = {
    initialized = false
};
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
---@field house {slots: table<number, ConfigItem>}
---@field hotel {slots: table<number, ConfigItem>}
---@field trunk {slots: table<number, ConfigItem>}

---@class GlobalConfig
---@field configs table<string, Config>
---@field activeConfig string
---@field enabled boolean

---@type GlobalConfig
GlobalConfig = {
    enabled = true,
    activeConfig = 'default',
    configs = {
        {
            name = 'default',
            inventory = { slots = {} },
            house = { slots = {} },
            hotel = { slots = {} },
            trunk = { slots = {} }
        }
    }
};

Config = GlobalConfig.configs.default;

---@param name string
---@return Config | nil cfg
function CFG:findConfig(name)
    for _, cfg in ipairs(GlobalConfig) do
        if (cfg.name == name) then
            return cfg;
        end
    end
    return nil;
end

function CFG:init()
    -- load using CarbJSON
    local cfg = self:findConfig(GlobalConfig.activeConfig);
    if (not cfg) then
        Msg(('Ошибка, не удалось загрузить конфиг "%s": конфиг не найден. Конфиг был изменен на "default".'):format(GlobalConfig.activeConfig));
        GlobalConfig.activeConfig = 'default';
    end
    Config = cfg;
end