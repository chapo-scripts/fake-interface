function Msg(...)
   return sampAddChatMessage(table.concat({ ... }, ' '), -1);
end

function DebugMsg(...)
   return Msg('[DEBUG]', ...);
end

function debug.log(...)
    if (_G.LUBU_BUNDLED) then return end ---@diagnostic disable-line
    local function tableToString(tbl, indent, compact)
        local function formatTableKey(k)
            local defaultType = type(k);
            if (defaultType ~= 'string') then
                k = tostring(k);
            end
            local useSquareBrackets = k:find('^(%d+)') or k:find('(%p)') or k:find('\\') or k:find('%-');
            return useSquareBrackets == nil and k or ('[%s]'):format(defaultType == 'string' and "'" .. k .. "'" or k);
        end
        local str = { '{' };
        local indent = indent or 0;
        for k, v in pairs(tbl) do
            table.insert(str, ('%s%s = %s,'):format(string.rep("    ", compact and 0 or indent + 1), formatTableKey(k), type(v) == "table" and tableToString(v, indent + 1, compact) or (type(v) == 'string' and "'" .. v .. "'" or tostring(v))));
        end
        table.insert(str, string.rep('    ',compact and 0 or indent) .. '}');
        return table.concat(str, compact and '' or '\n');
    end
    local function getTrace()
        local list = {};
        local level = 3;
        while true do
            local info = debug.getinfo(level, "nS")
            if not info then break end
            if info.what ~= "C" and info.name then
                table.insert(list, ('%s()[%s:%d]'):format(info.name, info.namewhat, info.linedefined));
            end
            level = level + 1
        end
        return list;
    end

    local args = { ... };
    local trace = getTrace();
    for k, v in ipairs(args) do
        if (type(v) ~= 'string') then
            args[k] = type(v) == 'table' and tableToString(v, nil, true) or tostring(v);
        end
    end
    print(('%s: %s'):format(table.concat(trace, '->'), table.concat(args, '\t')));
end

function AsyncHttpRequest(method, url, args, resolve, reject)
   local request_thread = Effil.thread(function (method, url, args)
      local result, response = pcall(Requests.request, method, url, args)
      if result then
         response.json, response.xml = nil, nil
         return true, response
      else
         return false, response
      end
   end)(method, url, args)
   -- Если запрос без функций обработки ответа и ошибок.
   if not resolve then resolve = function() end end
   if not reject then reject = function() end end
   -- Проверка выполнения потока
   lua_thread.create(function()
      local runner = request_thread
      while true do
         local status, err = runner:status()
         if not err then
            if status == 'completed' then
               local result, response = runner:get()
               if result then
                  resolve(response)
               else
                  reject(response)
               end
               return
            elseif status == 'canceled' then
               return reject(status)
            end
         else
            return reject(err)
         end
         wait(0)
      end
   end)
end

function JoinArgb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end