local thd   = require 'bee.thread'
local net   = require 'net'
local timer = require 'timer'

local link = net.listen('tcp', '0.0.0.0', 11577)

local methods = {
    ['pulse'] = require 'method.pulse',
    ['error'] = require 'method.error',
}

local function pushMethod(data)
    while #data > 0 do
        local msg, index = string.unpack('s4', data)
        data = data:sub(index)
        local method, token, start = string.unpack('zz', msg)
        methods[method](token, data:sub(start))
    end
end

function link:on_accept(stream)
    print('on_accept')
    function stream:on_data(data)
        print('on_data', data)
        xpcall(pushMethod, print, data)
    end
end

while true do
    thd.sleep(0.01)
    net.update()
    timer.update()
end
