local timer = require 'script.timer'
local sleep = require 'script.ffi.sleep'
require 'script.jzslm.task'

while true do
    timer.update()
    sleep(1000)
end
