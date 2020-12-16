local thd   = require 'bee.thread'
local net   = require 'net'
local timer = require 'timer'

local listen = net.listen('tcp', '0.0.0.0', 11577)

local methods = {
    ['pulse'] = require 'method.pulse',
    ['error'] = require 'method.error',
}

local function pushMethod(data)
    while true do
        while #data < 4 do
            data = data .. coroutine.yield()
        end
        local len = string.unpack('I4', data)
        data = data:sub(5)
        while #data < len do
            data = data .. coroutine.yield()
        end
        local msg = data:sub(1, len)
        local method, token, start = string.unpack('zz', msg)
        methods[method](token, msg:sub(start))
        data = data:sub(len + 1)
    end
end

local links = {}

function listen:on_accept(link)
    print('on_accept')

    table.insert(links, link)
    if #links >= 50 then
        links[1]:close()
    end

    local pushStream = coroutine.create(pushMethod)

    function link:on_data(data)
        print('on_data', data)
        local suc, err = coroutine.resume(pushStream, data)
        if not suc then
            self:close()
            print(err)
        end
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
