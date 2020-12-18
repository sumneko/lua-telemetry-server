local clog  = require 'script.log'
local lpack = require 'lpack'

local log = clog 'log/error.log'
local caches = {}

return function (token, stream)
    local client, errq = lpack.unpack('zz', stream)
    if errq:sub(1, 1) ~= '"' then
        return
    end
    local err = assert(load('return ' .. errq))()
    if caches[err] then
        return
    end
    caches[err] = true
    log.write(('client: %s\n%s\n'):format(client, err))
end
