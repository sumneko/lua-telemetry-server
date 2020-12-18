local lpack = require 'lpack'

local methods = {
    ['error'] = require 'method.error',
    ['pulse'] = require 'method.pulse'
}

local m = {}

function m.accept()
    local sock, err = ngx.req.socket()
    if not sock then
        ngx.log(ngx.ERR, "unable to obtain request socket: ", err)
        return
    end

    while true do
        local lenb
        lenb, err = sock:receive(4)
        if not lenb then
            ngx.log(ngx.ERR, "unable to read request socket: ", err)
            return
        end
        local len = lpack.unpack('I4', lenb)
        local data
        data, err = sock:receive(len)
        if not data then
            ngx.log(ngx.ERR, "unable to read request socket: ", err)
            return
        end

        local method, token, start = lpack.unpack('zz', data)
        methods[method](token, data:sub(start))
    end
end

return m
