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
    items = {}
};

function Net:init()
    AsyncHttpRequest(
        'GET',
        'https://items.shinoa.tech/items.php',
        nil,
        function(response)
            if (response.status_code ~= 200) then
                return Msg('Ошибка, невозможно загрузить список предметов: ' .. response.status_code);
            end
            self.items = decodeJson(response.text);
            self.listLoaded = true;
        end,
        function(err)
            Msg('Ошибка: ', tostring(err));
        end
    );
    --https://items.shinoa.tech/items.php
end

---@param itemId string|number
---@return ItemInfo | nil
function Net:getItemInfo(itemId)
    if (not self.listLoaded) then
        return nil;
    end
    local itemId = type(itemId) == 'number' and tostring(itemId) or itemId;
    assert(itemId);
    for k, v in ipairs(Net.items) do
        if (v.id == itemId) then
            return v;
        end
    end
    return nil;
end