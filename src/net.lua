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