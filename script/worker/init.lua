local process = require "ngx.process"
local master  = require 'script.worker.master'

ngx.log(ngx.INFO, 'Create worker:', process.type())
-- TODO 多个worker时要加锁，保证只有一个人在干
--if process.type() == "privileged agent" then
    master.init()
--end
