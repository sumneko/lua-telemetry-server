local thd   = require 'bee.thread'
local net   = require 'net'
local timer = require 'timer'

local link = net.listen('tcp', '127.0.0.1', 11577)

local methods = {
    ['pulse'] = require 'method.pulse'
}

function link:on_accept(stream)
    function stream:on_data(data)
        local method, token, index = string.unpack('zz', data)
        methods[method](token, data:sub(index))
    end
    stream:update()
end

while true do
    thd.sleep(0.01)
    link:update()
    timer.update()
end
