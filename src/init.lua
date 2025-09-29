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