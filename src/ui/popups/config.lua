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