--[[
	Bundled Using LuBu - Simple Lua Bundler
	LuBu: https://github.com/chaposcripts/lubu
]]

-- Obfuscation disabled

-- Constants
LUBU_BUNDLED = true;
LUBU_BUNDLED_AT = 1759150698;
VERSION = "0.1";


-- Module "net" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\net.lua)
package['preload']['net'] = (function()
---@class ItemInfo
---@field id string
---@field item_name string
---@field model_id string
---@field eng_name string
---@field stack string
---@field useable string
---@field droppable string
---@field is_custom string
---@field colored string
---@field enchaned string
---@field slot_id string

Net = {
    listLoaded = false,
    items = {},
    sortedItems = {}
};

---@return boolean Status
---@return table<number, {id: number, name: string, icon: string, acs_slot: number, type: number, active: number}> ItemsList
---@return string StatusText
function LoadArizonaItems()
    local FRONTEND_ZIP_PATH = getGameDirectory() .. '\\frontend.zip';
    local TEMP_FILE = getGameDirectory() .. '\\resource';
    local result = {};

    local zipStatus, zip = pcall(require, 'zzlib');
    if (not zipStatus) then
        return false, result, 'NO_ZZLIB';
    end
   
    local zipEntries = zip.get_zip_entries(FRONTEND_ZIP_PATH);
    if (not zip.is_file_does_exists("frontend\\svelte_js\\main.bundle.js", zipEntries)) then
        return false, result, 'JS_NOT_EXISTS';
    end

    if (not zip.unzip_entry(FRONTEND_ZIP_PATH, "frontend\\svelte_js\\main.bundle.js", TEMP_FILE)) then
        return false, result, 'UNZIP_FAILED';
    end

    local file = io.open(TEMP_FILE .. '\\main.bundle.js', 'r');
    if (not file) then
        return false, result, 'UNABLE_TO_OPEN_TEMP_FILE';
    end

    local itemsJson = file:read('*a'):match('var ITEMS=(.-);');
    file:close();

    if (not itemsJson) then
        return false, result, 'INVALID_JSON';
    end

    local list = decodeJson(itemsJson);
    if (not list or #list == 0) then
        return false, result, 'JSON_DECODE_FAILED';
    end

    for _, item in ipairs(list) do
        item.icon = 'https://cdn.azresources.cloud/projects/arizona-rp/assets/images/donate/' .. item.icon;
        result[item.id] = item;
    end

    return true, result, tostring(#list);
end

function Net:init()
    local status, list, msg = LoadArizonaItems();
    if (status) then
        self.items = list;
        for k, v in pairs(self.items) do
            dprint(k, v)
            table.insert(self.sortedItems, v);
        end
        table.sort(self.sortedItems, function(a, b)
            return a.id < b.id;
        end);

        self.listLoaded = true;
    end
    -- AsyncHttpRequest(
    --     'GET',
    --     'https://items.shinoa.tech/items.php',
    --     nil,
    --     function(response)
    --         if (response.status_code ~= 200) then
    --             return Msg('Ошибка, невозможно загрузить список предметов: ' .. response.status_code);
    --         end
    --         self.items = decodeJson(response.text);
    --         self.listLoaded = true;
    --     end,
    --     function(err)
    --         Msg('Ошибка: ', tostring(err));
    --     end
    -- );
    --https://items.shinoa.tech/items.php
end

---@param itemId string|number
---@return ItemInfo | nil
function Net:getItemInfo(itemId)
    if (not self.listLoaded) then
        return {
            name = 'NOT_LOADED'
        };
    end
    return self.items[itemId] or nil;
end
end);

-- Module "ui.main" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\ui\main.lua)
package['preload']['ui.main'] = (function()
UI = {
    menu = imgui.new.bool(DEV),
    addItem = {
        id = imgui.new.int(6313),
        slot = imgui.new.int(0)
    },
    Popups = {
        Config = require('ui.popups.config'),
        ItemsList = require('ui.popups.items-list'),
        PacketRecorderSave = require('ui.popups.packet-recorder-save')
    },
    Components = {
        ClickableText = require('ui.components.clickable-text'),
        ClickableTextDL = require('ui.components.clickable-text-dl'),
        Hint = require('ui.components.hint'),
        Tab = require('ui.components.tab')
    },
    enchantsList = { u8'Нет' },
    enchantsListStr = '\0',
    resetIoRequired = false
};

TEXT_BUTTON_COLOR = {
    red = { default = imgui.ImVec4(1, 0, 0, 1), hovered = imgui.ImVec4(1, 0, 0, 0.7) },
    green = { default = imgui.ImVec4(0, 1, 0, 1), hovered = imgui.ImVec4(0, 1, 0, 0.7) }
};


local mainFrame = require('ui.frame');

function UI:init()
    for i = 1, 12 do
        table.insert(self.enchantsList, '+' .. i);
    end
    self.enchantsListStr = table.concat(self.enchantsList, '\0') .. '\0';
    addEventHandler('onWindowMessage', function(msg, id)
        if (UI.menu[0] and msg == 0x0100 and id == VK_ESCAPE) then
            UI.menu[0] = false;
            consumeWindowMessage(true, true);
        end
    end);
    sampRegisterChatCommand('fakecef', function()
        self.menu[0] = not self.menu[0];
        -- UI.resetIO();
        UI.resetIoRequired = true;
    end);
    
    imgui.OnInitialize(function()
        imgui.GetIO().IniFilename = nil;
        
        local config = imgui.ImFontConfig()
        config.MergeMode = true
        config.PixelSnapH = true
        iconRanges = imgui.new.ImWchar[3](FaIcons.min_range, FaIcons.max_range, 0)
        imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(FaIcons.get_font_data_base85('solid'), 14, config, iconRanges) -- solid - тип иконок, так же есть thin, regular, light и duotone


        local style = imgui.GetStyle();
        style.WindowPadding = imgui.ImVec2(10, 10);
        style.FrameRounding = 5;
        style.FramePadding = imgui.ImVec2(3, 5);
        style.ChildRounding = 5;
        style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5);

        local colors = style.Colors;
        colors[imgui.Col.WindowBg] = imgui.ImVec4(0.09, 0.09, 0.09, 1);
        colors[imgui.Col.ChildBg] = imgui.ImVec4(0.09, 0.09, 0.09, 1);
        colors[imgui.Col.FrameBg] = imgui.ImVec4(0.15, 0.15, 0.15, 1)
        colors[imgui.Col.Border] = imgui.ImVec4(0, 0, 0, 0);
        colors[imgui.Col.Header] = colors[imgui.Col.FrameBg];
        colors[imgui.Col.Tab] = colors[imgui.Col.FrameBg];
        colors[imgui.Col.Button] = imgui.ImVec4(0.51, 0.06, 0.8, 1);
        colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.51, 0.06, 0.8, 0.7);
        colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.51, 0.06, 0.8, 0.3);
        colors[imgui.Col.TabActive] = colors[imgui.Col.Button];
        colors[imgui.Col.TabHovered] = colors[imgui.Col.ButtonHovered]

        colors[imgui.Col.TitleBg] = colors[imgui.Col.Button];
        colors[imgui.Col.TitleBgActive] = colors[imgui.Col.TitleBg];
    end);
    imgui.OnFrame(
        function() return UI.menu[0] end,
        function(frame)
            if (UI.resetIoRequired) then
                UI.resetIO();
                UI.resetIoRequired = false;
            end
            mainFrame(frame);
        end
    );
end

function UI.resetIO()
    for i = 0, 511 do
        imgui.GetIO().KeysDown[i] = false
    end
    for i = 0, 4 do
        imgui.GetIO().MouseDown[i] = false
    end
    imgui.GetIO().KeyCtrl = false
    imgui.GetIO().KeyShift = false
    imgui.GetIO().KeyAlt = false
    imgui.GetIO().KeySuper = false
end
end);

-- Module "hook" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\hook.lua)
package['preload']['hook'] = (function()
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

MOVE_SOURCE = {
    inventory = 1,
    storage = 25,
    trunk = -999,
    house = -999
};

MOVE_SOURCE_NUMBER = {};

function Hook:init()
    for k, v in pairs(MOVE_SOURCE) do
        MOVE_SOURCE_NUMBER[v] = k;
    end
    
    -- SampEvents.onShowDialog = function(dialogId, style, title, button1, button2, text)
    --     print('DIALOG', title);
    --     if (Inventory.restoreData.state ~= INVENTORY_RESTORE_STATE.NONE) then
            

    --         local currentState = Inventory.restoreData.state;
            
    --         if (currentState == INVENTORY_RESTORE_STATE.WAIT_FOR_MAIN_MENU and title:find('Игровое меню')) then
    --             sampSendDialogResponse(dialogId, 1, 4, nil);
    --             sampCloseCurrentDialogWithButton(1);
    --             Inventory.restoreData.setState(INVENTORY_RESTORE_STATE.WAIT_FOR_PERSONAL_SETTINGS);
    --             return false;
    --         elseif (currentState == INVENTORY_RESTORE_STATE.WAIT_FOR_PERSONAL_SETTINGS and title:find('Личные настройки')) then
    --             sampSendDialogResponse(dialogId, 1, 12, nil);
    --             sampCloseCurrentDialogWithButton(1);
    --             Inventory.restoreData.setState(INVENTORY_RESTORE_STATE.WAIT_FOR_INTERFACE_SETTINGS);
    --             return false;
    --         elseif ((currentState == INVENTORY_RESTORE_STATE.WAIT_FOR_INTERFACE_SETTINGS or currentState == INVENTORY_RESTORE_STATE.WAIT_FOR_INVENTORY_SECOND_CLICK) and title:find('Кастомизация интерфейса')) then
    --             local waitForSecondClick = currentState == INVENTORY_RESTORE_STATE.WAIT_FOR_INVENTORY_SECOND_CLICK;
    --             local lineIndex = -2;
    --             for line in text:gmatch('[^\n]+') do
    --                 lineIndex = lineIndex + 1;
    --                 print(lineIndex, line);
    --                 if (line:find('Тип инвентаря')) then
    --                     local isNew = line:find('Новый');
    --                     Inventory.restoreData.setState(isNew and INVENTORY_RESTORE_STATE.WAIT_FOR_INVENTORY_SECOND_CLICK or INVENTORY_RESTORE_STATE.NONE);
    --                     local button = waitForSecondClick and 0 or 1;
    --                     Msg('State:', currentState, 'IsNew:', tostring(isNew), 'btn', button);
    --                     sampSendDialogResponse(dialogId, button, lineIndex, nil);
    --                     sampCloseCurrentDialogWithButton(button);
    --                     return false;
    --                 end
    --             end
    --         end
    --     end
    -- end
    -- sampRegisterChatCommand('fakecef.restore', function()
    --     Msg('Restoring interface...');
    --     Inventory.restoreData.setState(INVENTORY_RESTORE_STATE.WAIT_FOR_MAIN_MENU);
    --     sampSendChat('/mm');
    -- end);
    sampRegisterChatCommand('fakecef.reloadwindow', function()
        CEF:emulate(("(() => {%s})()"):format('window.location.reload()'), false);
    end);
    addEventHandler('onReceivePacket', function(id, bs)
        local status, event, data, json, packetString = CEF:readIncomingPacket(id, bs, true);
        if (status) then
            print(event)
            if (GlobalConfig.enabled and event == 'inventory.updateCharacterTab') then
                -- Inventory:clearAll();
                -- Inventory:addItemsFromConfig();
                
                for _, interface in pairs(INTERFACE_TYPE) do
                    SlotInterface:clearAll(interface);
                    SlotInterface:addItemsFromConfig(interface);
                end
                DebugMsg('Interface detected:', data);
                if (INTERFACE_TYPE_REVERSED[data]) then
                    Msg('Interface detected:', INTERFACE_TYPE_REVERSED[data]);
                end

                -- SlotInterface:clearAll(INTERFACE_TYPE.INVENTORY);
                -- SlotInterface:addItemsFromConfig(INTERFACE_TYPE.INVENTORY);
                -- if (data == 'warehouse') then
                --     -- Storage:clearAll();
                --     -- Storage:addItemsFromConfig();
                --     SlotInterface:clearAll(INTERFACE_TYPE.STORAGE);
                --     SlotInterface:addItemsFromConfig(INTERFACE_TYPE.STORAGE);

                --     SlotInterface:clearAll(INTERFACE_TYPE.HOTEL);
                --     SlotInterface:addItemsFromConfig(INTERFACE_TYPE.HOTEL);
                -- end
            end
        end
    end);
    addEventHandler('onSendPacket', function(id, bs)
        local status, str = CEF:readOutcomingPacket(id, bs, false);
        if (status) then
            debug.log('OUT:', str);
            if (GlobalConfig.enabled) then
                if (str:find(PATTERN.MOVE_ITEM)) then
                    local jsonPayload = str:match(PATTERN.MOVE_ITEM);
                    local moveData = decodeJson(jsonPayload);
                    if (moveData) then
                        SlotInterface:handleItemMove(moveData.from, moveData.to);
                        -- local fromSlot, toSlot = moveData.from.slot, moveData.to.slot;
                        -- local source = {
                        --     from = MOVE_SOURCE_NUMBER[moveData.from.type],
                        --     to = MOVE_SOURCE_NUMBER[moveData.to.type]
                        -- };
                        -- Msg('item moved from', source.from, 'to', source.to, '|', moveData.from.slot, 'to', moveData.to.slot);

                       
                        -- local firstItem, secondItem = Config[source.from].slots[fromSlot], Config[source.to].slots[toSlot];
                        -- Config[source.to].slots[toSlot], Config[source.from].slots[fromSlot] = firstItem, secondItem;
                        -- if (Config[source.to].slots[toSlot]) then
                        --     Config[source.to].slots[toSlot].slot[0] = toSlot;
                        -- end
                        -- if (Config[source.from].slots[fromSlot]) then
                        --     Config[source.from].slots[fromSlot].slot[0] = fromSlot;
                        -- end

                        -- Inventory:update(moveData.from.slot);
                        -- Inventory:update(moveData.to.slot);
                        -- Storage:update(moveData.from.slot);
                        -- Storage:update(moveData.to.slot);
                        -- -- inventory.moveItem|{"from":{"slot":0,"type":1,"amount":3},"to":{"slot":1,"type":1}}
                        -- Inventory:handleItemMove(moveData.from.slot, moveData.to.slot);
                        
                        return false;
                    end
                end
            end
        end
    end);
    self.initialized = true;
end
end);

-- Module "init" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\init.lua)
package['preload']['init'] = (function()
---@diagnostic disable:lowercase-global
DEV = LUBU_BUNDLED == nil; ---@diagnostic disable-line

ffi = require('ffi');
imgui = require('mimgui');
encoding = require('encoding');
encoding.default = 'CP1251';
u8 = encoding.UTF8;

Effil = require('effil');
Requests = require('requests');
CarbJson = require('carbjsonconfig');

SampEvents = require('samp.events');
FaIcons = require('fAwesome6');

require('constants');
require('slot-interface');
require('net');
require('moonloader');
require('config');
require('hook');
require('packet-recorder');
require('utils.bitstream');
require('utils.helpers');
require('ui.main');

function init()
    CFG:init();
    SlotInterface:init();
    Net:init();
    Hook:init();
    UI:init();
    PacketRecorder:init();
end

function main()
    while (not isSampAvailable()) do wait(0) end
    init();
    wait(-1);
end
end);

-- Module "ui.popups.config" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\ui\popups\config.lua)
package['preload']['ui.popups.config'] = (function()
local save = {
    name = imgui.new.char[64]('testConfig');
};

local function doesConfigExists(name)
    for _, cfg in ipairs(GlobalConfig.configs) do
        if (cfg.name == ffi.string(save.name)) then
            return true;
        end
    end
    return false;
end

return function(pos)
    imgui.SetNextWindowPos(pos + imgui.ImVec2(0, 24 + 5), imgui.Cond.Always);
    if (imgui.BeginPopup('configs')) then
        local width = 100;
        imgui.SetNextItemWidth(width + 24 + 5);
        imgui.InputTextWithHint('##hint-popup-configs-name', u8'Название конфига', save.name, ffi.sizeof(save.name));
        imgui.SameLine();
        if (UI.Components.ClickableText(FaIcons('PLUS') .. '##config-add', nil, nil, imgui.ImVec2(24, 24))) then
            local name = ffi.string(save.name);
            if (not doesConfigExists(name)) then
                table.insert(GlobalConfig.configs, {
                    name = name,
                    inventory = { slots = {} },
                    storage = { slots = {} },
                    house = { slots = {} },
                    hotel = { slots = {} },
                    trunk = { slots = {} }
                });
            else
                Msg('Ошибка, конфиг с таким названием уже существует!');
            end
        end
        imgui.Separator();
        for index, cfg in ipairs(GlobalConfig.configs) do
            if (imgui.Button(('#%d. %s'):format(index, cfg.name), imgui.ImVec2(width, 24))) then
                CFG:load(index);
            end
            imgui.SameLine();
            if (imgui.Button(FaIcons('FLOPPY_DISK') .. '##config-write-' .. index, imgui.ImVec2(24, 24))) then
                -- Msg('Профиль ' .. GlobalConfig.configs[index].name .. ' удален!');
                -- table.remove(GlobalConfig.configs, index);
                GlobalConfig.configs[index] = table.copy(Config);
                GlobalConfig.configs[index].name = cfg.name;
            end
            imgui.SameLine();
            if (imgui.Button(FaIcons('XMARK') .. '##config-remove-' .. index, imgui.ImVec2(24, 24))) then
                Msg('Профиль ' .. GlobalConfig.configs[index].name .. ' удален!');
                table.remove(GlobalConfig.configs, index);
            end
        end
        imgui.EndPopup();
    end
end
end);

-- Module "ui.components.hint" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\ui\components\hint.lua)
package['preload']['ui.components.hint'] = (function()
local imgui = require('mimgui');
return function(str_id, hint_text, color, no_center)
    color = color or imgui.GetStyle().Colors[imgui.Col.PopupBg]
    local p_orig = imgui.GetCursorPos()
    local hovered = imgui.IsItemHovered()
    imgui.SameLine(nil, 0)

    local animTime = 0.2
    local show = true

    if not POOL_HINTS then POOL_HINTS = {} end
    if not POOL_HINTS[str_id] then
        POOL_HINTS[str_id] = {
            status = false,
            timer = 0
        }
    end

    if hovered then
        for k, v in pairs(POOL_HINTS) do
            if k ~= str_id and os.clock() - v.timer <= animTime  then
                show = false
            end
        end
    end

    if show and POOL_HINTS[str_id].status ~= hovered then
        POOL_HINTS[str_id].status = hovered
        POOL_HINTS[str_id].timer = os.clock()
    end

    local getContrastColor = function(col)
        local luminance = 1 - (0.299 * col.x + 0.587 * col.y + 0.114 * col.z)
        return luminance < 0.5 and imgui.ImVec4(0, 0, 0, 1) or imgui.ImVec4(1, 1, 1, 1)
    end

    local rend_window = function(alpha)
        local size = imgui.GetItemRectSize()
        local scrPos = imgui.GetCursorScreenPos()
        local DL = imgui.GetWindowDrawList()
        local center = imgui.ImVec2( scrPos.x - (size.x / 2), scrPos.y + (size.y / 2) - (alpha * 4) + 10 )
        local a = imgui.ImVec2( center.x - 7, center.y - size.y - 3 )
        local b = imgui.ImVec2( center.x + 7, center.y - size.y - 3)
        local c = imgui.ImVec2( center.x, center.y - size.y + 3 )
        local col = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(color.x, color.y, color.z, alpha))

        DL:AddTriangleFilled(a, b, c, col)
        imgui.SetNextWindowPos(imgui.ImVec2(center.x, center.y - size.y - 3), imgui.Cond.Always, imgui.ImVec2(0.5, 1.0))
        imgui.PushStyleColor(imgui.Col.PopupBg, color)
        imgui.PushStyleColor(imgui.Col.Border, color)
        imgui.PushStyleColor(imgui.Col.Text, getContrastColor(color))
        imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 8))
        imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 6)
        imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)

        local max_width = function(text)
            local result = 0
            for line in text:gmatch('[^\n]+') do
                local len = imgui.CalcTextSize(line).x
                if len > result then
                    result = len
                end
            end
            return result
        end

        local hint_width = max_width(hint_text) + (imgui.GetStyle().WindowPadding.x * 2)
        imgui.SetNextWindowSize(imgui.ImVec2(hint_width, -1), imgui.Cond.Always)
        imgui.Begin('##' .. str_id, _, imgui.WindowFlags.Tooltip + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
            for line in hint_text:gmatch('[^\n]+') do
                if no_center then
                    imgui.Text(line)
                else
                    imgui.SetCursorPosX((hint_width - imgui.CalcTextSize(line).x) / 2)
                    imgui.Text(line)
                end
            end
        imgui.End()

        imgui.PopStyleVar(3)
        imgui.PopStyleColor(3)
    end

    if show then
        local between = os.clock() - POOL_HINTS[str_id].timer
        if between <= animTime then
            local s = function(f)
                return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
            end
            local alpha = hovered and s(between / animTime) or s(1.00 - between / animTime)
            rend_window(alpha)
        elseif hovered then
            rend_window(1.00)
        end
    end

    imgui.SetCursorPos(p_orig)
end
end);

-- Module "packet-recorder" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\packet-recorder.lua)
package['preload']['packet-recorder'] = (function()
PacketRecorder = {
    currentRecord = {
        active = false,
        packets = {}
    }
};

local function handler(isIn, id, bs)
    if (PacketRecorder.currentRecord.active and id == 220) then
        ---@type SavedPacket
        local previousPacket = PacketRecorder.currentRecord.packets[#PacketRecorder.currentRecord.packets];
        local record = {
            type = isIn and 'in' or 'out',
            bytes = {},
            timeFromLastPacket = #PacketRecorder.currentRecord.packets == 0 and os.clock() or os.clock() - previousPacket.timeFromLastPacket
        };
        for i = 1, raknetBitStreamGetNumberOfBytesUsed(bs) do
            table.insert(record.bytes, raknetBitStreamReadInt8(bs));
        end
        table.insert(PacketRecorder.currentRecord.packets, record);
        dprint('Packet recorded', #PacketRecorder.currentRecord.packets, ('Data: type: %s, bytesCount: %d, timeFromLastPacket: %d'):format(record.type, #record.bytes, record.timeFromLastPacket));
    end
end

function PacketRecorder:init()
    addEventHandler('onReceivePacket', function(id, bs) handler(true, id, bs) end);
    addEventHandler('onSendPacket', function(id, bs) handler(false, id, bs) end);
    lua_thread.create(function()
        while (true) do
            wait(0);
            if (self.currentRecord.active) then
                printStyledString('RECORDED ' .. #self.currentRecord.packets .. ' CEF PACKETS', 100, 6);
            end
        end
    end);
end

---@param record Record
function PacketRecorder:play(record)
    DebugMsg('RecordPlayer started.');
    lua_thread.create(function()
        for index, packet in ipairs(record.packets) do
            DebugMsg(('Playing packet %d/%d. Intervals: %s -> %d'):format(index, #record.packets, tostring(GlobalConfig.packetRecorderSaveIntervals), packet.timeFromLastPacket));
            -- if (GlobalConfig.packetRecorderSaveIntervals) then
            --     wait(packet.timeFromLastPacket);
            -- end

            local bs = raknetNewBitStream();
            for _, byte in ipairs(packet.bytes) do
                raknetBitStreamWriteInt8(bs, byte);
            end    
            if (packet.type == 'in') then
                raknetEmulPacketReceiveBitStream(220, bs);
            elseif (packet.type == 'out') then
                raknetSendBitStream(bs);
            end
            raknetDeleteBitStream(bs);
            print('Emulated packet', index .. '/' .. #record.packets, packet.type);
        end
    end);
end

function PacketRecorder:startRecord()
    PacketRecorder.currentRecord = {
        active = true,
        packets = {}
    };
end
end);

-- Module "slot-interface" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\slot-interface.lua)
package['preload']['slot-interface'] = (function()
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
end);

-- Module "types" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\types.lua)
package['preload']['types'] = (function()
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
end);

-- Module "ui.components.clickable-text" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\ui\components\clickable-text.lua)
package['preload']['ui.components.clickable-text'] = (function()
return function(text, color, colorHovered, useButtonSize)
    local color = color or imgui.GetStyle().Colors[imgui.Col.Text];
    local colorHovered = colorHovered or imgui.ImVec4(color.x, color.y, color.z, color.w - 0.4);
    if (useButtonSize) then
        imgui.PushStyleColor(imgui.Col.Text, color);
        local button = imgui.Button(text, useButtonSize);
        imgui.PopStyleColor();
        return button;
    else
        local pos = imgui.GetCursorScreenPos();
        local textSize = imgui.CalcTextSize(text);
        local isHovered = imgui.IsMouseHoveringRect(pos, pos + textSize);
        imgui.TextColored(isHovered and colorHovered or color, text);
        return isHovered and imgui.IsMouseClicked(0);
    end
end
end);

-- Module "ui.popups.packet-recorder-save" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\ui\popups\packet-recorder-save.lua)
package['preload']['ui.popups.packet-recorder-save'] = (function()
local buffer = imgui.new.char[32]('');

return function()
    if (imgui.BeginPopupModal('packet-recorder-save', nil, imgui.WindowFlags.NoDecoration)) then
        imgui.TextDisabled(u8'Сохранить запись');
        imgui.SetNextItemWidth(200);
        imgui.InputTextWithHint('##packet-recorder-save-name', u8'Название записи', buffer, ffi.sizeof(buffer));
        if (imgui.Button(u8'Сохранить', imgui.ImVec2(200, 24))) then
            table.insert(GlobalConfig.packetRecords, {
                name = ffi.string(buffer),
                packets = table.copy(PacketRecorder.currentRecord.packets);
            });
            imgui.CloseCurrentPopup();
            imgui.StrCopy(buffer, '');
        end
        if (imgui.Button(u8'Закрыть', imgui.ImVec2(200, 24))) then
            imgui.CloseCurrentPopup();
            imgui.StrCopy(buffer, '');
        end
        imgui.EndPopup();
    end
end
end);

-- Module "utils.bitstream" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\utils\bitstream.lua)
package['preload']['utils.bitstream'] = (function()
CEF = {};

---@param id number
---@param bs any
---@param printString boolean
---@return boolean status
---@return string event
---@return table data
---@return string json
---@return string fullString
function CEF:readIncomingPacket(id, bs, printString)
    if (id == 220) then
        raknetBitStreamIgnoreBits(bs, 8);
        if (raknetBitStreamReadInt8(bs) == 17) then
            raknetBitStreamIgnoreBits(bs, 32);
            local length = raknetBitStreamReadInt16(bs);
            local encoded = raknetBitStreamReadInt8(bs);
            local str = (encoded ~= 0) and raknetBitStreamDecodeString(bs, length + encoded) or
            raknetBitStreamReadString(bs, length);
            if (printString) then
                print(str);
            end
            if (not str:find(PATTERN.REGEX_PACKET)) then
                goto bad_packet
            end
            local event, json = str:match(PATTERN.REGEX_PACKET);
            -- print(event, json)
            return true, event, decodeJson(json)[1], json, str;
        end
    end
    ::bad_packet::
    return false, 'NONE', {}, '[]', '';
end

---@param id number
---@param bs any
---@param printString boolean
---@return boolean status
---@return string str
function CEF:readOutcomingPacket(id, bs, printString)
    if (id == 220) then
        local id = raknetBitStreamReadInt8(bs);
        local packettype = raknetBitStreamReadInt8(bs);
        local strlen = raknetBitStreamReadInt16(bs);
        local str = raknetBitStreamReadString(bs, strlen);
        if (packettype ~= 0 and packettype ~= 1 and #str > 2) then
            if (printString) then
                print('[SENT]', str);
            end
            return true, str;
        end
    end
    return false, 'NOT_220';
end

---@param str string
function CEF:send(str)
    local bs = raknetNewBitStream();
    raknetBitStreamWriteInt8(bs, 220);
    raknetBitStreamWriteInt8(bs, 18);
    raknetBitStreamWriteInt16(bs, #str);
    raknetBitStreamWriteString(bs, str);
    raknetBitStreamWriteInt32(bs, 0);
    raknetSendBitStream(bs);
    raknetDeleteBitStream(bs);
end

---@param code string
---@param encode boolean
function CEF:emulate(code, encode)
    local bs = raknetNewBitStream();
    raknetBitStreamWriteInt8(bs, 17);
    raknetBitStreamWriteInt32(bs, 0);
    raknetBitStreamWriteInt16(bs, #code);
    raknetBitStreamWriteInt8(bs, encode and 1 or 0);
    raknetBitStreamWriteString(bs, code);
    raknetEmulPacketReceiveBitStream(220, bs);
    raknetDeleteBitStream(bs);
    print('[CEF-EMULATED]', code);
end

---@param event string
---@param payload table?
function CEF:emulateEvent(event, payload)
    self:emulate(([[window.executeEvent('%s', `%s`);]]):format(event, payload and ('[%s]'):format(encodeJson(payload)) or 'null'), false);
end
end);

-- Module "utils.helpers" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\utils\helpers.lua)
package['preload']['utils.helpers'] = (function()
function Msg(...)
   return sampAddChatMessage(table.concat({ ... }, ' '), -1);
end

function DebugMsg(...)
   if (not DEV) then return end
   return Msg('[DEBUG]', ...);
end

function dprint(...)
   if (not DEV) then return end
   return print('[DEBUG]', ...);
end

function debug.log(...)
    if (_G.LUBU_BUNDLED) then return end ---@diagnostic disable-line
    local function tableToString(tbl, indent, compact)
        local function formatTableKey(k)
            local defaultType = type(k);
            if (defaultType ~= 'string') then
                k = tostring(k);
            end
            local useSquareBrackets = k:find('^(%d+)') or k:find('(%p)') or k:find('\\') or k:find('%-');
            return useSquareBrackets == nil and k or ('[%s]'):format(defaultType == 'string' and "'" .. k .. "'" or k);
        end
        local str = { '{' };
        local indent = indent or 0;
        for k, v in pairs(tbl) do
            table.insert(str, ('%s%s = %s,'):format(string.rep("    ", compact and 0 or indent + 1), formatTableKey(k), type(v) == "table" and tableToString(v, indent + 1, compact) or (type(v) == 'string' and "'" .. v .. "'" or tostring(v))));
        end
        table.insert(str, string.rep('    ',compact and 0 or indent) .. '}');
        return table.concat(str, compact and '' or '\n');
    end
    local function getTrace()
        local list = {};
        local level = 3;
        while true do
            local info = debug.getinfo(level, "nS")
            if not info then break end
            if info.what ~= "C" and info.name then
                table.insert(list, ('%s()[%s:%d]'):format(info.name, info.namewhat, info.linedefined));
            end
            level = level + 1
        end
        return list;
    end

    local args = { ... };
    local trace = getTrace();
    for k, v in ipairs(args) do
        if (type(v) ~= 'string') then
            args[k] = type(v) == 'table' and tableToString(v, nil, true) or tostring(v);
        end
    end
    print(('%s: %s'):format(table.concat(trace, '->'), table.concat(args, '\t')));
end

function table.copy(t)
   if (type(t) ~= 'table') then
      return nil;
   end
   local t2 = {};
   for k,v in pairs(t) do
      t2[k] = v;
   end
   return t2;
end

function table.toString(tbl, indent)
   if (type(tbl) ~= 'table') then
      return 'NOT_A_TABLE';
   end
   local function formatTableKey(k)
       local defaultType = type(k);
       if (defaultType ~= 'string') then
           k = tostring(k);
       end
       local useSquareBrackets = k:find('^(%d+)') or k:find('(%p)') or k:find('\\') or k:find('%-');
       return useSquareBrackets == nil and k or ('[%s]'):format(defaultType == 'string' and "'" .. k .. "'" or k);
   end
   local str = { '{' };
   local indent = indent or 0;
   for k, v in pairs(tbl) do
       table.insert(str, ('%s%s = %s,'):format(string.rep("    ", indent + 1), formatTableKey(k), type(v) == "table" and table.toString(v, indent + 1) or (type(v) == 'string' and "'" .. v .. "'" or tostring(v))));
   end
   table.insert(str, string.rep('    ', indent) .. '}');
   return table.concat(str, '\n');
end

function AsyncHttpRequest(method, url, args, resolve, reject)
   local request_thread = Effil.thread(function (method, url, args)
      local result, response = pcall(Requests.request, method, url, args)
      if result then
         response.json, response.xml = nil, nil
         return true, response
      else
         return false, response
      end
   end)(method, url, args)
   -- Если запрос без функций обработки ответа и ошибок.
   if not resolve then resolve = function() end end
   if not reject then reject = function() end end
   -- Проверка выполнения потока
   lua_thread.create(function()
      local runner = request_thread
      while true do
         local status, err = runner:status()
         if not err then
            if status == 'completed' then
               local result, response = runner:get()
               if result then
                  resolve(response)
               else
                  reject(response)
               end
               return
            elseif status == 'canceled' then
               return reject(status)
            end
         else
            return reject(err)
         end
         wait(0)
      end
   end)
end

function JoinArgb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end
end);

-- Module "arizona" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\arizona.lua)
package['preload']['arizona'] = (function()
---@return boolean Status
---@return table<number, {id: number, name: string, icon: string, acs_slot: number, type: number, active: number}> ItemsList
---@return string StatusText
function LoadArizonaItems()
    local FRONTEND_ZIP_PATH = getGameDirectory() .. '\\frontend.zip';
    local TEMP_FILE = getGameDirectory() .. '\\moonloader\\' .. thisScript().filename .. '-temp_arizona_items.js';
    local result = {};

    local zipStatus, zip = pcall(require, 'zzlib');
    if (not zipStatus) then
        return false, result, 'NO_ZZLIB';
    end
    
    local zipEntries = zip.get_zip_entries(FRONTEND_ZIP_PATH);
    if (not zip.is_file_does_exists("frontend\\svelte_js\\main.bundle.js", zipEntries)) then
        return false, result, 'JS_NOT_EXISTS';
    end

    if (not zip.unzip_entry(FRONTEND_ZIP_PATH, TEMP_FILE)) then
        return false, result, 'UNZIP_FAILED';
    end

    local file = io.open(TEMP_FILE, 'r');
    if (not file) then
        return false, result, 'UNABLE_TO_OPEN_TEMP_FILE';
    end

    local itemsJson = file:read('a'):match('var ITEMS=(.-)');
    file:close();

    if (not itemsJson) then
        return false, result, 'INVALID_JSON';
    end

    local list = decodeJson(itemsJson);
    if (#list == 0) then
        return false, result, 'JSON_DECODE_FAILED';
    end

    for _, item in ipairs(list) do
        item.icon = 'https://cdn.azresources.cloud/projects/arizona-rp/assets/images/donate/' .. item.icon;
        result[item.id] = item;
    end

    return true, result, tostring(#list);
end

local status, list, msg = LoadArizonaItems();
if (status) then
    print('Загружено', msg, 'предметов!');
    
    for id, item in pairs(list) do
        if (item.name:find('Махинатор')) then
            print(('Предмет: %s (ID: %d)\nКартинка: %s'):format(item.name, id, item.icon));
            break;
        end
    end
else
    print('Ошибка, не удалось загрузить список предметов:', msg);
end
end);

-- Module "ui.components.clickable-text-dl" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\ui\components\clickable-text-dl.lua)
package['preload']['ui.components.clickable-text-dl'] = (function()
return function(fontSize, pos, text, color, colorHovered, colorClicked, useDrawList)
    imgui.PushFont(UI.font[fontSize].Bold);
    local size = imgui.CalcTextSize(text);
    
    local isHovered = (useDrawList or (not imgui.IsAnyItemActive() and not imgui.IsItemHovered())) and imgui.IsMouseHoveringRect(pos, pos + size);
    local isClicked = isHovered and imgui.IsMouseClicked(0);
    if (isHovered) then
        imgui.SetMouseCursor(imgui.MouseCursor.Hand);
    end
    -- imgui.GetForegroundDrawList():AddRect(pos, pos + size, isClicked and 0xFF00ff00 or 0xFF0000ff);

    if (useDrawList) then
        imgui.GetWindowDrawList():AddTextFontPtr(UI.font[fontSize].Bold, fontSize, pos, imgui.GetColorU32Vec4(isHovered and (isClicked and colorClicked or colorHovered) or color), text);
    else
        local c = imgui.GetCursorPos();
        imgui.SetCursorScreenPos(pos);
        imgui.TextColored(color or imgui.ImVec4(1, 1, 1, 1), text);
        if (imgui.IsItemHovered()) then
            imgui.SetCursorScreenPos(pos);
            imgui.TextColored(colorHovered or imgui.ImVec4(1, 1, 1, 1), text);
        end
        imgui.SetCursorPos(c);
    end
    imgui.PopFont();
    if (useDrawList) then
        return isClicked and isHovered;
    end
    return imgui.IsItemClicked();
end
end);

-- Module "ui.frame" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\ui\frame.lua)
package['preload']['ui.frame'] = (function()



function UI.drawSlotItem(index, interface, slot, item)
    local cfg = Config[interface];
    local size = imgui.GetWindowSize();
    if (not cfg.slots[slot]) then
        return;
    end
    local styleColors = imgui.GetStyle().Colors;
    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.GetStyle().Colors[imgui.Col.FrameBg]);
    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.GetStyle().Colors[imgui.Col.WindowBg]);
    imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.GetStyle().Colors[imgui.Col.WindowBg]);
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.GetStyle().Colors[imgui.Col.WindowBg]);
    if (imgui.BeginChild('item-' .. index, imgui.ImVec2(size.x - 20, 5 + 24 + 5), true, imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar)) then
        imgui.SetCursorPos(imgui.ImVec2(5, 5));
        if (UI.Components.ClickableText(FaIcons('EYE') .. '##' .. slot, TEXT_BUTTON_COLOR[cfg.slots[slot].__enabled and 'green' or 'red'].default, nil, imgui.ImVec2(24, 24))) then
            cfg.slots[slot].__enabled = not cfg.slots[slot].__enabled;
            SlotInterface:update(interface, slot);
        end
        imgui.SameLine();
        
        -- imgui.SetCursorPos(imgui.ImVec2(5, 5 + 24 + 5));
        if (UI.Components.ClickableText(FaIcons('TRASH') .. '##' .. slot, TEXT_BUTTON_COLOR.red.default, nil, imgui.ImVec2(24, 24))) then
            cfg.slots[slot] = nil;
            SlotInterface:update(interface, slot);
        end
        imgui.SameLine();
        imgui.Text(('%s [%d]'):format(item.__info.name, item.item[0]));
        imgui.SameLine();
        imgui.TextDisabled(FaIcons('WINDOW_RESTORE'));
        imgui.SameLine();
        imgui.PushItemWidth(100);
        local oldSlot = item.slot[0];
        if (imgui.InputInt('##inventory-item-slot-' .. index, item.slot, -1)) then
            local newSlot = item.slot[0];
            if (cfg.slots[newSlot]) then
                item.slot[0] = oldSlot;
                Msg('Ошибка, слот #' .. newSlot .. ' уже занят!');
                imgui.SetKeyboardFocusHere(-2);
            else
                cfg.slots[newSlot] = item;
                cfg.slots[slot] = nil;
                return;
            end
            SlotInterface:update(interface, oldSlot);
            SlotInterface:update(interface, newSlot);
        end
        UI.Components.Hint('hint-inventory-item-slot-' .. index, u8'Слот');
        
        imgui.SameLine();
        imgui.TextDisabled(FaIcons('TAG'));
        imgui.SameLine();
        local textChanged = imgui.InputTextWithHint('##inventory-item-text-' .. index, u8'Текст', item.text, ffi.sizeof(item.text));
        UI.Components.Hint('hint-inventory-item-amount-' .. index, u8'Текст предмета (заточка, количество или время)');
        imgui.PopItemWidth();
        imgui.SameLine();
        local colorChanged = imgui.ColorEdit4('##inventory-item-color-' .. index, item.__color, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.AlphaPreview);
        if (imgui.IsItemClicked(1)) then
            item.__color = imgui.new.float[4](1, 1, 1, 0);
            item.background[0] = 0;
            colorChanged = true;
        end
        if (textChanged or colorChanged) then
            local colorFloat = item.__color;
            local colorArgb = JoinArgb(colorFloat[3] * 255, colorFloat[1] * 255, colorFloat[2] * 255, colorFloat[3] * 255);
            item.background[0] = colorArgb == 0xFFffffff and 0 or colorArgb;
            SlotInterface:update(interface, item.slot[0]);
        end
        imgui.SameLine();
        
        UI.Components.Hint('hint-inventory-item-color-' .. index, u8'Цвет фона (ПКМ что бы удалить)');
        -- if (imgui.Button(FaIcons('ELLIPSIS') .. '##hint-inventory-item-other-' .. index, imgui.ImVec2(24, 24))) then
            
        -- end
        -- UI.Components.Hint('hint-inventory-item-other-' .. index, u8'Прочее');
    end
    imgui.EndChild();
    imgui.PopStyleColor(4);
end

return function(frame)
    local resX, resY = getScreenResolution()
    local sizeX, sizeY = 600, 400;
    imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
    if imgui.Begin('FakeCEF', UI.menu, imgui.WindowFlags.NoCollapse) then
        local size = imgui.GetWindowSize();
        local style = imgui.GetStyle();

        if (imgui.BeginTabBar('tabs')) then
            UI.Components.Tab();
            imgui.EndTabBar();
        end
        imgui.End()
    end
end
end);

-- Module "ui.popups.items-list" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\ui\popups\items-list.lua)
package['preload']['ui.popups.items-list'] = (function()
TEMP_PATH = getGameDirectory() .. '\\moonloader\\resource\\fakecef-temp';
local search = imgui.new.char[128]('');

local images = {};
local loadingImages = {};

local function loadItemImage(item)
    local filePath = TEMP_PATH .. '\\item_' .. item.id .. '.png';
    if (not doesDirectoryExist(TEMP_PATH)) then
        createDirectory(TEMP_PATH);
    end
    if (doesFileExist(filePath)) then
        images[item.id] = imgui.CreateTextureFromFile(filePath);
    else
        if (not loadingImages[item.id]) then
            loadingImages[item.id] = true;
            local iconUrl = item.icon:gsub('.webp', '.png');
            downloadUrlToFile(iconUrl, filePath);
        end
    end
end

local filtredItems = {};

return function()
    if (imgui.BeginPopupModal('items-list', nil, imgui.WindowFlags.NoDecoration)) then
        local size = imgui.GetWindowSize();
        imgui.SetNextItemWidth(400);
        local isSearchActive = #ffi.string(search) > 0;
        if (imgui.InputTextWithHint('##items-search-input', u8'Найти предмет', search, ffi.sizeof(search))) then
            filtredItems = {};
            for k, v in ipairs(Net.sortedItems) do
                if (('%s [%d]'):format(v.name, v.id):find(ffi.string(search))) then
                    table.insert(filtredItems, v);
                end
            end
        end
        local list = isSearchActive and filtredItems or Net.sortedItems;

        if (imgui.BeginChild('items-list-container', imgui.ImVec2(size.x - 20, 400), true)) then
            imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0, 0.5));
            local clipper = imgui.ImGuiListClipper();
            clipper:Begin(#list, 24);
            while (clipper:Step()) do
                local itemIndex = 0;
                for index = clipper.DisplayStart + 1, clipper.DisplayEnd do
                    itemIndex = index + 1;
                    local item = list[itemIndex];
                    if (item) then
                        if (imgui.Button(('#%d. %s [ID: %d]'):format(itemIndex, item.name, item.id), imgui.ImVec2(size.x - 40, 24))) then
                            UI.addItem.id[0] = item.id;
                            imgui.CloseCurrentPopup();
                        end
                        if (imgui.IsItemHovered()) then
                            imgui.BeginTooltip();
                            if (images[item.id]) then
                                imgui.Image(images[item.id], imgui.ImVec2(200, 200));
                            else
                                loadItemImage(item);
                                imgui.Text(u8'Загрузка изображения...');
                            end
                            imgui.EndTooltip();
                        end
                    end
                end
            end
            imgui.PopStyleVar();
        end
        imgui.EndChild();
        if (imgui.Button(FaIcons('XMARK') .. u8' Закрыть##items-list-close', imgui.ImVec2(size.x - 10, 24))) then
            imgui.CloseCurrentPopup();
        end

        imgui.EndPopup();
    end
end
end);

-- Module "ui.components.tab" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\ui\components\tab.lua)
package['preload']['ui.components.tab'] = (function()
local TABS = {
    { name = FaIcons('SUITCASE') .. u8' Инвентарь', interface = INTERFACE_TYPE.INVENTORY },
    { name = FaIcons('WAREHOUSE') .. u8' Склад', interface = INTERFACE_TYPE.STORAGE },
    { name = FaIcons('HOTEL') .. u8' Отель', interface = INTERFACE_TYPE.HOTEL },
    { name = FaIcons('TRUCK') .. u8' Багажник', interface = INTERFACE_TYPE.TRUNK },
    { name = FaIcons('HOUSE') .. u8' Дом', interface = INTERFACE_TYPE.HOUSE }
};

local function drawTab(name, interface)
    local size = imgui.GetWindowSize();
    local cfg = Config[interface];
    -- print('INT CFG', interface, cfg)
    if (imgui.BeginTabItem(name)) then
        if (interface == INTERFACE_TYPE.HOUSE) then
            imgui.SetNextItemWidth(imgui.GetWindowWidth() - 20);
            if (imgui.InputTextWithHint('##house-name', u8'Деньги в шкафу', Config[interface].money, ffi.sizeof(Config[interface].money), imgui.InputTextFlags.CharsDecimal)) then
                local moneyText = ffi.string(Config[interface].money);
                if (#moneyText == 0 or not tonumber(moneyText)) then
                    imgui.StrCopy(Config[interface].money, '0');
                end
            end
            UI.Components.Hint('hint-house-money', u8'Деньги в шкафу дома')
        end

         if (UI.Components.ClickableText(FaIcons('SUITCASE'), TEXT_BUTTON_COLOR[GlobalConfig.enabled and 'green' or 'red'].default, nil, imgui.ImVec2(24, 24))) then
            GlobalConfig.enabled = not GlobalConfig.enabled;
            CFG:save();
            if (not GlobalConfig.enabled) then
                Msg('Отключено, перезагрузка CEF интерфейса...');
                SlotInterface:reloadWindow();
            end
        end
        UI.Components.Hint('hint-enable-status-' .. interface, u8'Подмена предлметов ' .. u8(GlobalConfig.enabled and 'ВКЛЮЧЕНА' or 'ВЫКЛЮЧЕНА'));
        imgui.SameLine();
        if (imgui.Button(FaIcons('PLUS'), imgui.ImVec2(24, 24))) then
            local itemInfo = Net:getItemInfo(UI.addItem.id[0]);
            if (not itemInfo) then
                return Msg('Ошибка, не удалось найти предмет в базе!');
            end
            if (cfg.slots[UI.addItem.slot[0]]) then
                return Msg('Ошибка, этот слот уже занят!');
            end
            if (UI.addItem.id[0] > 0) then
                cfg.slots[UI.addItem.slot[0]] = {
                    slot = imgui.new.int(UI.addItem.slot[0]),
                    text = imgui.new.char[64](''),
                    item = imgui.new.int(UI.addItem.id[0]),
                    amount = imgui.new.int(0),
                    background = imgui.new.int(0),
                    enchant = imgui.new.int(0),
                    color = imgui.new.int(0),
                    strength = imgui.new.int(0),
                    available = imgui.new.int(1),
                    blackout = imgui.new.int(0),
                    time = imgui.new.int(0),
                    __enabled = true,
                    __info = itemInfo,
                    __color = imgui.new.float[4](1, 1, 1, 0)
                };
                SlotInterface:update(interface, UI.addItem.slot[0]);
                UI.addItem.slot[0] = #cfg.slots + 1;
            else
                Msg('ID не может быть меньше нуля!', UI.addItem.id[0], tostring(UI.addItem.id[0] < 0));
            end
        end
        UI.Components.Hint('hint-inventory-add-item-', u8('Добавить предмет #%d в слот %d'):format(UI.addItem.id[0], UI.addItem.slot[0]));
        imgui.PushItemWidth(75);
        imgui.SameLine();
        imgui.TextDisabled(FaIcons('HASHTAG'));
        imgui.SameLine();
        imgui.InputInt('##id', UI.addItem.id, -1);
        UI.Components.Hint('hint-inventory-add_id-item-', u8'Серверный ID предмета');
        imgui.SameLine();
        if (UI.Components.ClickableText(FaIcons('LIST'), imgui.ImVec4(0, 0.58, 1, 1))) then
            -- os.execute('start "https://items.shinoa.tech/"');
            imgui.OpenPopup('items-list');
        end
        UI.Popups.ItemsList();
        UI.Components.Hint('hint-inventory-add_items_url-item-', u8'Список предметов');
        imgui.SameLine(nil, 25);
        imgui.TextDisabled(FaIcons('WINDOW_RESTORE'));
        imgui.SameLine();
        imgui.PushStyleColor(imgui.Col.Text, cfg.slots[UI.addItem.slot[0]] == nil and imgui.ImVec4(1, 1, 1, 1) or imgui.ImVec4(1, 0, 0, 1));
        imgui.InputInt('##slot', UI.addItem.slot, -1);
        imgui.PopStyleColor();
        UI.Components.Hint('hint-inventory-add_slot-item-', u8'Слот');
        imgui.PopItemWidth();
        imgui.SameLine();
        local configsButtonPos = imgui.GetCursorScreenPos();
        if (imgui.Button(FaIcons('FOLDER') .. '##configs', imgui.ImVec2(24, 24))) then
            imgui.OpenPopup('configs');
        end
        UI.Components.Hint('hint-configs', u8'Конфиги');
        UI.Popups.Config(configsButtonPos);
        
        if (imgui.BeginChild('items-inventory', imgui.ImVec2(size.x - 20, size.y - 10 - imgui.GetCursorPosY()), true)) then
           
            -- local columnPos = {

            -- };
            -- imgui.SameLine();
            -- imgui.TextDisabled(u8'Слот');
            -- imgui.SameLine();
            -- imgui.TextDisabled(u8'Заточка');
            -- imgui.SameLine();
            -- imgui.TextDisabled(u8'Количество');
            -- imgui.SameLine();
            -- imgui.TextDisabled(u8'Предмет');
            local index = 0;
            imgui.PushItemWidth(75);
            for slot, item in pairs(cfg.slots) do
                index = index + 1;
                UI.drawSlotItem(index, interface, slot, item);
            end
            imgui.PopItemWidth();
        end
        imgui.EndChild();
        imgui.EndTabItem();
    end
end

return function()
    for _, tabData in ipairs(TABS) do
        drawTab(tabData.name, tabData.interface);
    end
    if (imgui.BeginTabItem(FaIcons('CAMERA') .. u8' Запись')) then
        local size = imgui.GetWindowSize();
        if (imgui.Button((PacketRecorder.currentRecord.active and FaIcons('STOP') .. u8' Завершить' or FaIcons('PLAY') .. u8' Начать') .. u8'запись', imgui.ImVec2(size.x - 20, 24))) then
            if (PacketRecorder.currentRecord.active) then
                PacketRecorder.currentRecord.active = false;
                imgui.OpenPopup('packet-recorder-save');
            else
                PacketRecorder:startRecord();
            end
        end

        if (PacketRecorder.currentRecord.active) then
            imgui.Text(u8'Идет запись!');
            imgui.BulletText(u8'Записано пакетов: ' .. #PacketRecorder.currentRecord.packets);
        else
            if (#GlobalConfig.packetRecords == 0) then
                imgui.Text(u8'Упс, записей не найдено :(');
            else
                for index, record in ipairs(GlobalConfig.packetRecords) do
                    if (imgui.BeginChild('record-' .. index, imgui.ImVec2(size.x - 40, 100), true)) then
                        if (imgui.Button(FaIcons('PLAY') .. '##record-play-' .. index, imgui.ImVec2(24, 24))) then
                            PacketRecorder:play(record);
                        end
                        UI.Components.Hint('hint-records-play-' .. index, u8'Воспроизвести запись');
                        imgui.SameLine();
                        if (imgui.Button(FaIcons('XMARK') .. '##record-delete-' .. index, imgui.ImVec2(24, 24))) then
                            table.remove(GlobalConfig.packetRecords, index);
                        end
                        UI.Components.Hint('hint-records-delete-' .. index, u8'Удалить запись');
                        imgui.SameLine();
                        imgui.Text(('#%d. %s'):format(index, record.name));
                    end
                    imgui.EndChild();
                end
            end
        end
        UI.Popups.PacketRecorderSave();
        imgui.EndTabItem();
    end
end
end);

-- Module "config" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\config.lua)
package['preload']['config'] = (function()
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
end);

-- Module "constants" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\constants.lua)
package['preload']['constants'] = (function()
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
    STORAGE = 'storage',
    TRUNK = 'trunk',
    HOUSE = 'house'
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
    [INTERFACE_TYPE.STORAGE] = 25,
    [INTERFACE_TYPE.TRUNK] = 8,
    [INTERFACE_TYPE.HOUSE] = 2
};

INTERFACE_MAX_SLOTS = {
    [INTERFACE_TYPE.INVENTORY] = 99,
    [INTERFACE_TYPE.HOTEL] = 179,
    [INTERFACE_TYPE.STORAGE] = 179,
    [INTERFACE_TYPE.TRUNK] = 29,
    [INTERFACE_TYPE.HOUSE] = 179
};

INTERFACE_TAB_NAME = {
    [INTERFACE_TYPE.INVENTORY] = u8'Инвентарь',
    [INTERFACE_TYPE.HOTEL] = u8'Отель',
    [INTERFACE_TYPE.STORAGE] = u8'Склад',
    [INTERFACE_TYPE.TRUNK] = u8'Багажник',
    [INTERFACE_TYPE.STORAGE] = u8'Дом'
};
end);

-- Module "house" (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\house.lua)
package['preload']['house'] = (function()

end);

-- Init (from C:\Users\dmitry\AppData\Local\Programs\Arizona Games Launcher\bin\arizona\moonly\fake-interface\src\init.lua) 
LUBU_ENTRY_POINT = (function()
---@diagnostic disable:lowercase-global
DEV = LUBU_BUNDLED == nil; ---@diagnostic disable-line

ffi = require('ffi');
imgui = require('mimgui');
encoding = require('encoding');
encoding.default = 'CP1251';
u8 = encoding.UTF8;

Effil = require('effil');
Requests = require('requests');
CarbJson = require('carbjsonconfig');

SampEvents = require('samp.events');
FaIcons = require('fAwesome6');

require('constants');
require('slot-interface');
require('net');
require('moonloader');
require('config');
require('hook');
require('packet-recorder');
require('utils.bitstream');
require('utils.helpers');
require('ui.main');

function init()
    CFG:init();
    SlotInterface:init();
    Net:init();
    Hook:init();
    UI:init();
    PacketRecorder:init();
end

function main()
    while (not isSampAvailable()) do wait(0) end
    init();
    wait(-1);
end
end);
LUBU_ENTRY_POINT();