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
        if (imgui.Button(FaIcons('X') .. u8' Закрыть##items-list-close', imgui.ImVec2(size.x - 10, 24))) then
            imgui.CloseCurrentPopup();
        end

        imgui.EndPopup();
    end
end