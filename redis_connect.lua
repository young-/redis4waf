require 'config'
require 'function_lib'

local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")
-- ngx.log(ngx.INFO, 'some message')

local ok, err = red:connect("127.0.0.1", 6379 )
if not ok then
    ngx.log(ngx.ERR, "Notice ! failed to connect: ", err)
    return
end

-- 如果没有获取到客户端IP，输出到nginx错误日志，返回
local CLIENT_IP = get_client_ip_url_args()
if CLIENT_IP == 'unknown' then
    ngx.log(ngx.ERR, "Notice ! Can not get client IP ")
    return
end

-- ngx.log(ngx.ERR, "Notice !  ", CLIENT_IP,"||", ngx.var.uri..'|?|'..ngx.var.args)

-- 超过阈值，403 返回
local IS_BIND, ERR = red:get("bind:"..CLIENT_IP)
if IS_BIND == '1'  then
    waf_output()
end

--如果CLIENT_IP记录时间大于指定时间间隔或者记录时间或者不存在CLIENT_IP时间key则重置时间key和计数key
--如果CLIENT_IP时间key小于时间间隔，则CLIENT_IP计数+1，且如果CLIENT_IP计数大于CLIENT_IP频率计数，则设置CLIENT_IP的封禁key为1
--同时设置封禁key的过期时间为封禁CLIENT_IP的时间
local start_time, err = red:get("time:"..CLIENT_IP)
local count_ip, err = red:get("count:"..CLIENT_IP)

red:init_pipeline()
if start_time == ngx.null or os.time() - start_time > findtime then
    local res, err = red:set("time:"..CLIENT_IP , os.time())
    local res, err = red:expire("time:"..CLIENT_IP, bantime)

    local res, err = red:set("count:"..CLIENT_IP , 1)
    local res, err = red:expire("count:"..CLIENT_IP, bantime)
else
    local count_ip = count_ip + 1
    local res, err = red:incr("count:"..CLIENT_IP)


    if count_ip >= maxretry then
        local res, err = red:set("bind:"..CLIENT_IP, 1)
        local res, err = red:expire("bind:"..CLIENT_IP, bantime)
    end
end
local results, err = red:commit_pipeline()
if not results then
    ngx.log(ngx.ERR, "failed to commit the pipelined requests: ", err)
    return
end

local ok, err = red:close()
return
