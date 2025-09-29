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
    enchantsListStr = '\0'
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