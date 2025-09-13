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