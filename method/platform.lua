local lpack   = require 'lpack'
local clients = require 'method.clients'

return function (token, stream)
    local OS, CRT, Compiler = lpack.unpack('zzz', stream)
    clients.onPlatform(token, OS, CRT, Compiler)
end
