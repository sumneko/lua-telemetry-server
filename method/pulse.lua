local timer = require 'script.timer'
local clog  = require 'script.log'
local lpack = require 'lpack'

local path = 'log/clients.log'

local userPulses  = {}
local userClients = {}

ngx.timer.every(10, function ()
    local clients = {}
    for token, lastPulse in pairs(userPulses) do
        if os.time() - lastPulse > 60 * 60 then
            userPulses[token]  = nil
            userClients[token] = nil
        else
            local client = userClients[token]
            clients[client] = (clients[client] or 0) + 1
        end
    end

    local list = {}
    for client in pairs(clients) do
        list[#list+1] = client
    end
    table.sort(list, function (a, b)
        return clients[a] > clients[b]
    end)

    local buf = {}
    for _, client in ipairs(list) do
        buf[#buf+1] = ('% 8d : %s'):format(clients[client], client)
    end
    local info = 'Clients:\n' .. table.concat(buf, '\n') .. '\n'
    io.stdout:write(info)
    io.stdout:flush()

    local f = io.open(path, 'wb')
    if f then
        f:write(info)
        f:close()
    end
end)

return function (token, stream)
    local client = lpack.unpack('z', stream)
    userPulses[token]  = os.time()
    userClients[token] = client
end
