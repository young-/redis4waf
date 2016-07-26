-- lua lib file
-- by zhangjunyang 2016/7/25
--
require 'config'

--获取客户端IP
function get_client_ip()
    CLIENT_IP = ngx.req.get_headers()["X_real_ip"]
    if CLIENT_IP == nil then
        CLIENT_IP = ngx.req.get_headers()["X_Forwarded_For"]
    end
    if CLIENT_IP == nil then
        CLIENT_IP  = ngx.var.remote_addr 
    end
    if CLIENT_IP == nil then
        CLIENT_IP  = "unknown"
    end
    return CLIENT_IP
end

-- 合并IP、URL、ARGS
function get_client_ip_url_args()
    -- 如果没有获取到客户端IP，输出到nginx错误日志，返回
    local CLIENT_IP = get_client_ip()
    if CLIENT_IP == 'unknown' then
        --ngx.log(ngx.ERR, "Notice ! Can not get client IP ")
        return CLIENT_IP
    end
    -- 合并IP，url，args,判断args是否为空 
    if IP_URL == 'on' and URL_ARGS == 'on' then
        if ngx.var.args then
            CLIENT_IP = CLIENT_IP..ngx.var.uri..'?'..ngx.var.args
        else
            CLIENT_IP = CLIENT_IP..ngx.var.uri
        end
    end
    if IP_URL == 'on' and URL_ARGS == 'off' then
        CLIENT_IP = CLIENT_IP..ngx.var.uri
    end
    return CLIENT_IP
end

-- 退出函数
function waf_output()
    ngx.header.content_type = "text/html"
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say(config_output_html)
    ngx.exit(ngx.status)
end
