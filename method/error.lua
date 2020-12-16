local timer = require 'timer'
local log   = dofile 'log.lua'
local fs    = require 'bee.filesystem'
local util  = require 'utility'

log.init(fs.path '', fs.path 'log/error.log')

local caches = {}

return function (token, stream)
    local client, errq = string.unpack('zz', stream)
    local err = assert(load('return ' .. errq))()
    if caches[err] then
        return
    end
    caches[err] = true
    log.info(('client: %s\n%s'):format(client, err))
end
