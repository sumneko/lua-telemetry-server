local clog    = require 'script.log'
local lpack   = require 'lpack'
local clients = require 'method.clients'

local log = clog 'log/error.log'
local caches = {}

return function (token, stream)
    local client = clients.getClient(token)
    local name, errq = lpack.unpack('zz', stream)
    if errq:sub(1, 1) ~= '"' then
        return
    end
    local err = assert(load('return ' .. errq))()
    if err:find('invalid address')
    or err:find('backtrack stack overflow') then
        return
    end
    if caches[err] then
        return
    end
    caches[err] = true
    local info = ('-----------------\nversion: %s\nclient: %s\n%s\n'):format(name, client:getVersion(), err)
    log:write(info)
    io.stdout:write(info)
    io.stdout:flush()
end
