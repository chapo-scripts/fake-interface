---@diagnostic disable:lowercase-global

ffi = require('ffi');
imgui = require('mimgui');
encoding = require('encoding');
encoding.default = 'CP1251';
u8 = encoding.UTF8;

FaIcons = require('fAwesome6');
require('net');
require('moonloader');
require('constants');
require('config');
require('hook');
require('inventory');
require('utils.bitstream');
require('utils.helpers');
require('ui.window');


-- error('')
function init()
    Net:init();
    Hook:init();
    Inventory:init();
    UI:init();
end

function main()
    while (not isSampAvailable()) do wait(0) end
    init();
    wait(-1);
end

--[[
    window.executeEvent('event.inventory.playerInventory', `[{"action":1,"data":{"skin":{"model":78,"background":-1},"buttons":1}}]`);
]]