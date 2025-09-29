PacketRecorder = {
    currentRecord = {
        active = false,
        packets = {}
    }
};

local function handler(isIn, id, bs)
    if (PacketRecorder.currentRecord.active and id == 220) then
        ---@type SavedPacket
        local previousPacket = PacketRecorder.currentRecord.packets[#PacketRecorder.currentRecord.packets];
        local record = {
            type = isIn and 'in' or 'out',
            bytes = {},
            timeFromLastPacket = #PacketRecorder.currentRecord.packets == 0 and os.clock() or os.clock() - previousPacket.timeFromLastPacket
        };
        for i = 1, raknetBitStreamGetNumberOfBytesUsed(bs) do
            table.insert(record.bytes, raknetBitStreamReadInt8(bs));
        end
        table.insert(PacketRecorder.currentRecord.packets, record);
        dprint('Packet recorded', #PacketRecorder.currentRecord.packets, ('Data: type: %s, bytesCount: %d, timeFromLastPacket: %d'):format(record.type, #record.bytes, record.timeFromLastPacket));
    end
end

function PacketRecorder:init()
    addEventHandler('onReceivePacket', function(id, bs) handler(true, id, bs) end);
    addEventHandler('onSendPacket', function(id, bs) handler(false, id, bs) end);
    lua_thread.create(function()
        while (true) do
            wait(0);
            if (self.currentRecord.active) then
                printStyledString('RECORDED ' .. #self.currentRecord.packets .. ' CEF PACKETS', 100, 6);
            end
        end
    end);
end

---@param record Record
function PacketRecorder:play(record)
    DebugMsg('RecordPlayer started.');
    lua_thread.create(function()
        for index, packet in ipairs(record.packets) do
            DebugMsg(('Playing packet %d/%d. Intervals: %s -> %d'):format(index, #record.packets, tostring(GlobalConfig.packetRecorderSaveIntervals), packet.timeFromLastPacket));
            -- if (GlobalConfig.packetRecorderSaveIntervals) then
            --     wait(packet.timeFromLastPacket);
            -- end

            local bs = raknetNewBitStream();
            for _, byte in ipairs(packet.bytes) do
                raknetBitStreamWriteInt8(bs, byte);
            end    
            if (packet.type == 'in') then
                raknetEmulPacketReceiveBitStream(220, bs);
            elseif (packet.type == 'out') then
                raknetSendBitStream(bs);
            end
            raknetDeleteBitStream(bs);
            print('Emulated packet', index .. '/' .. #record.packets, packet.type);
        end
    end);
end

function PacketRecorder:startRecord()
    PacketRecorder.currentRecord = {
        active = true,
        packets = {}
    };
end