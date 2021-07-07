local lpack   = require 'lpack'
local clients = require 'method.clients'

return function (token, stream)
    local version = lpack.unpack('z', stream)
    clients.onVersion(token, version)
end
