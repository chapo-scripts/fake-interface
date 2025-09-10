UI = {
    menu = imgui.new.bool(true),
    addItem = {
        id = imgui.new.int(6313),
        slot = imgui.new.int(0)
    },
    Popups = {
        Config = require('ui.popups.config')
    },
    Components = {
        ClickableText = require('ui.components.clickable-text'),
        ClickableTextDL = require('ui.components.clickable-text-dl'),
        Hint = require('ui.components.hint')
    },
    Frame = {
        Main = require('ui.frame')
    },
    enchantsList = { u8'���' },
    enchantsListStr = '\0'
};

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
    end);
    
    imgui.OnInitialize(function()
        imgui.GetIO().IniFilename = nil;
        
        local config = imgui.ImFontConfig()
        config.MergeMode = true
        config.PixelSnapH = true
        iconRanges = imgui.new.ImWchar[3](FaIcons.min_range, FaIcons.max_range, 0)
        imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(FaIcons.get_font_data_base85('solid'), 14, config, iconRanges) -- solid - ��� ������, ��� �� ���� thin, regular, light � duotone


        local style = imgui.GetStyle();
        style.WindowPadding = imgui.ImVec2(10, 10);
        style.FrameRounding = 5;
        style.FramePadding = imgui.ImVec2(3, 5);

        local colors = style.Colors;
        
    end);
    imgui.OnFrame(
        function() return UI.menu[0] end,
        function(frame)
            UI.Frame.Main(frame);
        end
    );
end