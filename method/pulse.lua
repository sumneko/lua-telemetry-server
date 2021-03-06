local lpack   = require 'lpack'
local clients = require 'method.clients'

return function (token, stream)
    local name = lpack.unpack('z', stream)
    clients.onPulse(token, name)
end
