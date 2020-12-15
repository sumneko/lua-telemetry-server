local timer = require 'timer'
local log   = require 'log'
local fs    = require 'bee.filesystem'
local util  = require 'utility'

log.init(fs.path '', fs.path 'log/error.log')

return function (token, stream)
    local client, errq = string.unpack('zz', stream)
    local err = assert(load('return ' .. errq))()
    log.info(('client: %s\n%s'):format(client, err))
end
