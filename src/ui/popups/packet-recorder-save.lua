local buffer = imgui.new.char[32]('');

return function()
    if (imgui.BeginPopupModal('packet-recorder-save', nil, imgui.WindowFlags.NoDecoration)) then
        imgui.TextDisabled(u8'��������� ������');
        imgui.SetNextItemWidth(200);
        imgui.InputTextWithHint('##packet-recorder-save-name', u8'�������� ������', buffer, ffi.sizeof(buffer));
        if (imgui.Button(u8'���������', imgui.ImVec2(200, 24))) then
            table.insert(GlobalConfig.packetRecords, {
                name = ffi.string(buffer),
                packets = table.copy(PacketRecorder.currentRecord.packets);
            });
            imgui.CloseCurrentPopup();
            imgui.StrCopy(buffer, '');
        end
        if (imgui.Button(u8'�������', imgui.ImVec2(200, 24))) then
            imgui.CloseCurrentPopup();
            imgui.StrCopy(buffer, '');
        end
        imgui.EndPopup();
    end
end