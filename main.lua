local thd   = require 'bee.thread'
local timer = require 'timer'
local net   = require 'net'

require 'telemetry'
require 'web'

while true do
    thd.sleep(0.01)
    net.update()
    timer.update()
end
