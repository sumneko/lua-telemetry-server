local thd   = require 'bee.thread'
local net   = require 'net'
local timer = require 'timer'

local listen = net.listen('tcp', '0.0.0.0', 11577)

local methods = {
    ['pulse'] = require 'method.pulse',
    ['error'] = require 'method.error',
}

local function pushMethod(data)
    while #data > 0 do
        local msg, index = string.unpack('s4', data)
        data = data:sub(index)
        local method, token, start = string.unpack('zz', msg)
        methods[method](token, msg:sub(start))
    end
end

local links = {}

function listen:on_accept(link)
    print('on_accept')

    table.insert(links, link)
    if #links >= 50 then
        links[1]:close()
    end

    function link:on_data(data)
        print('on_data', data)
        xpcall(pushMethod, print, data)
        self:close()
    end

    function link:on_close()
        for i = 1, #links do
            if links[i] == self then
                table.remove(links, i)
                break
            end
        end
    end
end

function listen:on_error(...)
    print('ERROR!', ...)
end

while true do
    thd.sleep(0.01)
    net.update()
    timer.update()
end
