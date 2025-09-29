CFG = {
    initialized = false
};

---@type GlobalConfig
GlobalConfig = {
    enabled = false,
    activeConfig = {
        name = '',
        inventory = {
        enabled = true,
        slots = {}
        },
        storage = {
            slots = {}
        },
        hotel = {
            slots = {}
        },
        house = {
            slots = {},
            money = imgui.new.char[32]('0')
        },
        trunk = {
            slots = {}
        }
    },
    configs = {
        {
            name = 'default',
            inventory = { slots = {} },
            storage = { slots = {} },
            house = { slots = {}, money = imgui.new.char[32]('0') },
            hotel = { slots = {} },
            trunk = { slots = {} }
        }
    },
    packetRecords = {},
    packetRecorderSaveIntervals = false
};

Config = {};

function CFG:saveTo(index)
    local originalName = GlobalConfig.configs[index].name;
    GlobalConfig.configs[index] = table.copy(Config);
    GlobalConfig.configs[index].name = originalName;
    Msg(('Текущие настройки сохранены в профиль #%d "%s"'):format(index, u8:decode(originalName)));
end

function CFG:load(index)
    print('Loading', table.toString(GlobalConfig.configs[index]));
    Config = table.copy(GlobalConfig.configs[index]);
    Msg(('Загружены настройки из профиля #%d "%s"'):format(index, u8:decode(GlobalConfig.configs[index].name)));
end

function CFG:init()
    CarbJson.load(getGameDirectory() .. '\\moonloader\\config\\fakecef.json', GlobalConfig);
    Config = table.copy(GlobalConfig.activeConfig);
    self.initialized = true;
end

function CFG:save()
    GlobalConfig();
end