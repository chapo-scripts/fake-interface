---@diagnostic disable:lowercase-global

ffi = require('ffi');
imgui = require('mimgui');
encoding = require('encoding');
encoding.default = 'CP1251';
u8 = encoding.UTF8;

Effil = require('effil');
Requests = require('requests');

SampEvents = require('samp.events');
FaIcons = require('fAwesome6');

require('constants');
require('slot-interface');
require('net');
require('moonloader');
require('config');
require('hook');
require('inventory');
-- require('storage');
require('utils.bitstream');
require('utils.helpers');
require('ui.main');


-- error('')
function init()
    SlotInterface:init();
    Net:init();
    Hook:init();
    -- Inventory:init();
    -- Storage:init();
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